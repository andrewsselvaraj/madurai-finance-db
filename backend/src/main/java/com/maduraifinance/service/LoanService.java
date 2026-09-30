package com.maduraifinance.service;

import com.maduraifinance.domain.LoanCollection;
import com.maduraifinance.domain.LoanInfo;
import com.maduraifinance.domain.UserInfo;
import com.maduraifinance.repository.LoanCollectionRepository;
import com.maduraifinance.repository.LoanInfoRepository;
import com.maduraifinance.repository.UserInfoRepository;
import com.maduraifinance.web.dto.LoanDtos;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static com.maduraifinance.service.AccessService.APPROVE;
import static com.maduraifinance.service.AccessService.CREATE;
import static com.maduraifinance.service.AccessService.DISBURSE;
import static com.maduraifinance.service.AccessService.LOAN;
import static com.maduraifinance.service.AccessService.RECEIVE;
import static com.maduraifinance.service.AccessService.VIEW;

@Service
public class LoanService {

    private final LoanInfoRepository loans;
    private final LoanCollectionRepository collections;
    private final UserInfoRepository users;
    private final UserService userService;
    private final AccessService access;
    private final AuditService audit;
    private final IdGenerator ids;

    public LoanService(LoanInfoRepository loans, LoanCollectionRepository collections, UserInfoRepository users,
                       UserService userService, AccessService access, AuditService audit, IdGenerator ids) {
        this.loans = loans;
        this.collections = collections;
        this.users = users;
        this.userService = userService;
        this.access = access;
        this.audit = audit;
        this.ids = ids;
    }

    /* ---------- Balance ---------- */

    /** Successful collection totals per loan for the org. */
    public Map<String, BigDecimal> collectedByLoan(String orgId) {
        return collections.findByCollectionOrgIdOrderByPkCollectionIdDesc(orgId).stream()
                .filter(c -> LoanCollection.SUCCESS.equals(c.getStatus()))
                .collect(Collectors.toMap(LoanCollection::getCollectionLoanId, LoanCollection::getCollectionAmount, BigDecimal::add));
    }

    /** Loan amount minus successful collections; null before disbursement. */
    public static BigDecimal outstanding(LoanInfo loan, BigDecimal collected) {
        if (!loan.hasBalance()) return null;
        BigDecimal remaining = loan.getLoanAmount().subtract(collected == null ? BigDecimal.ZERO : collected);
        return remaining.signum() < 0 ? BigDecimal.ZERO : remaining;
    }

    public BigDecimal outstanding(LoanInfo loan) {
        return outstanding(loan, collections.sumSuccessfulForLoan(loan.getPkLoanId()));
    }

    /* ---------- Queries ---------- */

    /** Loans the viewer may see: their own for customers, the whole org otherwise. */
    public List<LoanInfo> visibleLoans(UserInfo viewer) {
        return access.isCustomer(viewer)
                ? loans.findByLoanOrgIdAndLoanUserIdOrderByPkLoanIdDesc(viewer.getUserOrgId(), viewer.getPkUserId())
                : loans.findByLoanOrgIdOrderByPkLoanIdDesc(viewer.getUserOrgId());
    }

    @Transactional(readOnly = true)
    public List<LoanDtos.Loan> list(UserInfo viewer) {
        access.require(viewer, LOAN, VIEW);
        return toDtos(visibleLoans(viewer), viewer);
    }

    public List<LoanDtos.Loan> toDtos(List<LoanInfo> rows, UserInfo viewer) {
        String orgId = viewer.getUserOrgId();
        Map<String, String> names = userService.nameMap(orgId);
        Map<String, BigDecimal> collected = collectedByLoan(orgId);
        Set<String> perms = access.permissions(viewer);
        return rows.stream().map(l -> toDto(l, names, collected.get(l.getPkLoanId()), perms, viewer)).toList();
    }

    private static LoanDtos.Loan toDto(LoanInfo l, Map<String, String> names, BigDecimal collected,
                                       Set<String> perms, UserInfo viewer) {
        List<String> actions = new ArrayList<>();
        if (perms.contains(LOAN + ":" + APPROVE) && LoanInfo.PENDING.equals(l.getStatus())) {
            actions.add("APPROVE");
            actions.add("REJECT");
        }
        if (perms.contains(LOAN + ":" + DISBURSE) && LoanInfo.APPROVED.equals(l.getStatus())) {
            actions.add("DISBURSE");
        }
        if (perms.contains(LOAN + ":" + RECEIVE) && l.getLoanUserId().equals(viewer.getPkUserId())
                && LoanInfo.DISBURSED.equals(l.getStatus()) && l.getReceivedDate() == null) {
            actions.add("RECEIVE");
        }
        return new LoanDtos.Loan(l.getPkLoanId(), l.getLoanUserId(), names.getOrDefault(l.getLoanUserId(), l.getLoanUserId()),
                l.getLoanAmount(), l.getInterestRate(), l.getTenureMonths(), l.getPurpose(),
                l.getApplicationDate(), l.getApprovalDate(), l.getDisbursementDate(), l.getDueDate(),
                outstanding(l, collected), l.getReceivedDate(), l.getStatus(), actions);
    }

    private LoanDtos.Loan toDto(LoanInfo loan, UserInfo viewer) {
        return toDtos(List.of(loan), viewer).get(0);
    }

    private LoanInfo find(UserInfo viewer, String loanId) {
        return loans.findByPkLoanIdAndLoanOrgId(loanId, viewer.getUserOrgId())
                .orElseThrow(() -> ApiException.notFound("Loan " + loanId + " not found."));
    }

    private String nameOf(String userId) {
        return users.findById(userId).map(UserInfo::getUserName).orElse(userId);
    }

    private static void requireStatus(LoanInfo loan, String expected) {
        if (!expected.equals(loan.getStatus())) {
            throw ApiException.conflict("Loan " + loan.getPkLoanId() + " is " + loan.getStatus() + ", expected " + expected + ".");
        }
    }

    @Transactional(readOnly = true)
    public List<LoanDtos.CustomerOption> customers(UserInfo viewer) {
        access.require(viewer, LOAN, CREATE);
        String orgId = viewer.getUserOrgId();
        return users.findByUserOrgIdAndUserRoleIdOrderByPkUserId(orgId, access.customerRoleId(orgId)).stream()
                .filter(UserInfo::isActive)
                .map(u -> new LoanDtos.CustomerOption(u.getPkUserId(), u.getUserName()))
                .toList();
    }

    /* ---------- Commands ---------- */

    @Transactional
    public LoanDtos.Loan create(UserInfo actor, LoanDtos.CreateLoanRequest req) {
        access.require(actor, LOAN, CREATE);
        String orgId = actor.getUserOrgId();
        UserInfo customer = users.findById(req.customerId())
                .filter(u -> u.getUserOrgId().equals(orgId))
                .orElseThrow(() -> ApiException.badRequest("Customer not found."));
        if (!customer.isActive() || !customer.getUserRoleId().equals(access.customerRoleId(orgId))) {
            throw ApiException.badRequest("Loans can only be created for active customers.");
        }

        LoanInfo loan = new LoanInfo();
        loan.setPkLoanId(ids.next("LOAN", 3, loans.findAllIds()));
        loan.setLoanOrgId(orgId);
        loan.setLoanUserId(customer.getPkUserId());
        loan.setLoanAmount(req.amount());
        loan.setInterestRate(req.interestRate());
        loan.setTenureMonths(req.tenureMonths());
        loan.setPurpose(req.purpose() == null || req.purpose().isBlank() ? null : req.purpose().trim());
        loan.setApplicationDate(LocalDate.now());
        loan.setStatus(LoanInfo.PENDING);
        loan.touchedBy(actor.getPkUserId());
        loans.save(loan);

        audit.log(actor, "CREATE_LOAN", "Created loan " + loan.getPkLoanId() + " (" + Money.inr(loan.getLoanAmount())
                + ") for " + customer.getUserName());
        return toDto(loan, actor);
    }

    @Transactional
    public LoanDtos.Loan approve(UserInfo actor, String loanId) {
        access.require(actor, LOAN, APPROVE);
        LoanInfo loan = find(actor, loanId);
        requireStatus(loan, LoanInfo.PENDING);
        loan.setStatus(LoanInfo.APPROVED);
        loan.setApprovalDate(LocalDate.now());
        loan.touchedBy(actor.getPkUserId());
        audit.log(actor, "APPROVE_LOAN", "Approved loan " + loanId + " for " + nameOf(loan.getLoanUserId()));
        return toDto(loan, actor);
    }

    @Transactional
    public LoanDtos.Loan reject(UserInfo actor, String loanId) {
        access.require(actor, LOAN, APPROVE);
        LoanInfo loan = find(actor, loanId);
        requireStatus(loan, LoanInfo.PENDING);
        loan.setStatus(LoanInfo.REJECTED);
        loan.touchedBy(actor.getPkUserId());
        audit.log(actor, "REJECT_LOAN", "Rejected loan " + loanId + " for " + nameOf(loan.getLoanUserId()));
        return toDto(loan, actor);
    }

    @Transactional
    public LoanDtos.Loan disburse(UserInfo actor, String loanId) {
        access.require(actor, LOAN, DISBURSE);
        LoanInfo loan = find(actor, loanId);
        requireStatus(loan, LoanInfo.APPROVED);
        LocalDate today = LocalDate.now();
        loan.setStatus(LoanInfo.DISBURSED);
        loan.setDisbursementDate(today);
        loan.setDueDate(today.plusMonths(loan.getTenureMonths()));
        loan.setOutstandingAmount(loan.getLoanAmount());
        loan.touchedBy(actor.getPkUserId());
        audit.log(actor, "DISBURSE_LOAN", "Disbursed " + Money.inr(loan.getLoanAmount()) + " for loan " + loanId
                + " to " + nameOf(loan.getLoanUserId()));
        return toDto(loan, actor);
    }

    @Transactional
    public LoanDtos.Loan receive(UserInfo actor, String loanId) {
        access.require(actor, LOAN, RECEIVE);
        LoanInfo loan = find(actor, loanId);
        if (!loan.getLoanUserId().equals(actor.getPkUserId())) throw ApiException.forbidden("This is not your loan.");
        requireStatus(loan, LoanInfo.DISBURSED);
        if (loan.getReceivedDate() != null) throw ApiException.conflict("Receipt already acknowledged.");
        loan.setReceivedDate(LocalDate.now());
        loan.touchedBy(actor.getPkUserId());
        audit.log(actor, "RECEIVE_LOAN", actor.getUserName() + " acknowledged receipt of loan " + loanId);
        return toDto(loan, actor);
    }
}
