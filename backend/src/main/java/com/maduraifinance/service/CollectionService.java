package com.maduraifinance.service;

import com.maduraifinance.domain.LoanCollection;
import com.maduraifinance.domain.LoanInfo;
import com.maduraifinance.domain.UserInfo;
import com.maduraifinance.repository.LoanCollectionRepository;
import com.maduraifinance.repository.LoanInfoRepository;
import com.maduraifinance.web.dto.CollectionDtos;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import static com.maduraifinance.service.AccessService.COLLECT;
import static com.maduraifinance.service.AccessService.COLLECTION;
import static com.maduraifinance.service.AccessService.VIEW;

@Service
public class CollectionService {

    private final LoanCollectionRepository collections;
    private final LoanInfoRepository loans;
    private final LoanService loanService;
    private final UserService userService;
    private final AccessService access;
    private final AuditService audit;
    private final IdGenerator ids;

    public CollectionService(LoanCollectionRepository collections, LoanInfoRepository loans, LoanService loanService,
                             UserService userService, AccessService access, AuditService audit, IdGenerator ids) {
        this.collections = collections;
        this.loans = loans;
        this.loanService = loanService;
        this.userService = userService;
        this.access = access;
        this.audit = audit;
        this.ids = ids;
    }

    /** Collections the viewer may see: their own payments for customers, the whole org otherwise. */
    public List<LoanCollection> visibleCollections(UserInfo viewer) {
        return access.isCustomer(viewer)
                ? collections.findByCollectionOrgIdAndCollectionUserIdOrderByPkCollectionIdDesc(viewer.getUserOrgId(), viewer.getPkUserId())
                : collections.findByCollectionOrgIdOrderByPkCollectionIdDesc(viewer.getUserOrgId());
    }

    @Transactional(readOnly = true)
    public List<CollectionDtos.Collection> list(UserInfo viewer) {
        access.require(viewer, COLLECTION, VIEW);
        return toDtos(visibleCollections(viewer), viewer.getUserOrgId());
    }

    public List<CollectionDtos.Collection> toDtos(List<LoanCollection> rows, String orgId) {
        Map<String, String> names = userService.nameMap(orgId);
        return rows.stream().map(c -> new CollectionDtos.Collection(
                c.getPkCollectionId(), c.getCollectionLoanId(), c.getCollectionUserId(),
                names.getOrDefault(c.getCollectionUserId(), c.getCollectionUserId()),
                c.getCollectionAmount(), c.getCollectionDate(), c.getPaymentMode(), c.getReferenceNo(),
                c.getCollectedByUserId(),
                c.getCollectedByUserId() == null ? null : names.getOrDefault(c.getCollectedByUserId(), c.getCollectedByUserId()),
                c.getRemarks(), c.getStatus())).toList();
    }

    @Transactional(readOnly = true)
    public List<CollectionDtos.CollectableLoan> collectableLoans(UserInfo viewer) {
        access.require(viewer, COLLECTION, COLLECT);
        String orgId = viewer.getUserOrgId();
        Map<String, String> names = userService.nameMap(orgId);
        Map<String, BigDecimal> collected = loanService.collectedByLoan(orgId);
        return loans.findByLoanOrgIdAndStatusOrderByPkLoanId(orgId, LoanInfo.DISBURSED).stream()
                .map(l -> new CollectionDtos.CollectableLoan(l.getPkLoanId(),
                        names.getOrDefault(l.getLoanUserId(), l.getLoanUserId()),
                        LoanService.outstanding(l, collected.get(l.getPkLoanId()))))
                .filter(l -> l.outstanding() != null && l.outstanding().signum() > 0)
                .toList();
    }

    @Transactional
    public CollectionDtos.Collection create(UserInfo actor, CollectionDtos.CreateCollectionRequest req) {
        access.require(actor, COLLECTION, COLLECT);
        LoanInfo loan = loans.findByPkLoanIdAndLoanOrgId(req.loanId(), actor.getUserOrgId())
                .orElseThrow(() -> ApiException.badRequest("Loan not found."));
        if (!LoanInfo.DISBURSED.equals(loan.getStatus())) {
            throw ApiException.conflict("Collections can only be recorded against disbursed loans.");
        }
        if (!LoanCollection.PAYMENT_MODES.contains(req.paymentMode())) {
            throw ApiException.badRequest("Unknown payment mode " + req.paymentMode() + ".");
        }
        BigDecimal outstanding = loanService.outstanding(loan);
        if (req.amount().compareTo(outstanding) > 0) {
            throw ApiException.badRequest("Amount exceeds outstanding balance of " + Money.inr(outstanding) + ".");
        }

        LoanCollection c = new LoanCollection();
        c.setPkCollectionId(ids.next("COLL", 3, collections.findAllIds()));
        c.setCollectionOrgId(actor.getUserOrgId());
        c.setCollectionLoanId(loan.getPkLoanId());
        c.setCollectionUserId(loan.getLoanUserId());
        c.setCollectionAmount(req.amount());
        c.setCollectionDate(req.date() == null ? LocalDate.now() : req.date());
        c.setPaymentMode(req.paymentMode());
        c.setReferenceNo(blankToNull(req.referenceNo()));
        c.setCollectedByUserId(actor.getPkUserId());
        c.setRemarks(blankToNull(req.remarks()));
        c.setStatus(LoanCollection.SUCCESS);
        c.touchedBy(actor.getPkUserId());
        collections.save(c);
        audit.log(actor, "COLLECT", "Collected " + Money.inr(req.amount()) + " against loan " + loan.getPkLoanId()
                + " (" + req.paymentMode() + ")");

        BigDecimal remaining = outstanding.subtract(req.amount());
        loan.setOutstandingAmount(remaining);
        loan.touchedBy(actor.getPkUserId());
        if (remaining.signum() <= 0) {
            loan.setStatus(LoanInfo.CLOSED);
            audit.log(actor, "CLOSE_LOAN", "Loan " + loan.getPkLoanId() + " fully repaid and closed");
        }
        return toDtos(List.of(c), actor.getUserOrgId()).get(0);
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
