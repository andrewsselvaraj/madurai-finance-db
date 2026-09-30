package com.maduraifinance.service;

import com.maduraifinance.domain.LoanCollection;
import com.maduraifinance.domain.LoanInfo;
import com.maduraifinance.domain.UserInfo;
import com.maduraifinance.repository.LoanCollectionRepository;
import com.maduraifinance.repository.LoanInfoRepository;
import com.maduraifinance.repository.UserInfoRepository;
import com.maduraifinance.web.dto.AuditDto;
import com.maduraifinance.web.dto.ReportDtos;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

/** Dashboard stat cards and the role-specific reports. */
@Service
public class ReportService {

    private static final int RECENT_ACTIVITY = 6;

    private final LoanInfoRepository loans;
    private final LoanCollectionRepository collections;
    private final UserInfoRepository users;
    private final LoanService loanService;
    private final CollectionService collectionService;
    private final UserService userService;
    private final AccessService access;
    private final AuditService audit;

    public ReportService(LoanInfoRepository loans, LoanCollectionRepository collections, UserInfoRepository users,
                         LoanService loanService, CollectionService collectionService, UserService userService,
                         AccessService access, AuditService audit) {
        this.loans = loans;
        this.collections = collections;
        this.users = users;
        this.loanService = loanService;
        this.collectionService = collectionService;
        this.userService = userService;
        this.access = access;
        this.audit = audit;
    }

    @Transactional(readOnly = true)
    public ReportDtos.Dashboard dashboard(UserInfo viewer) {
        String orgId = viewer.getUserOrgId();
        List<LoanInfo> visibleLoans = loanService.visibleLoans(viewer);
        List<LoanCollection> visibleColls = collectionService.visibleCollections(viewer);
        Map<String, BigDecimal> collected = loanService.collectedByLoan(orgId);

        BigDecimal totalDisbursed = BigDecimal.ZERO;
        BigDecimal totalOutstanding = BigDecimal.ZERO;
        long activeLoans = 0;
        for (LoanInfo l : visibleLoans) {
            if (l.hasBalance()) totalDisbursed = totalDisbursed.add(l.getLoanAmount());
            BigDecimal out = LoanService.outstanding(l, collected.get(l.getPkLoanId()));
            if (out != null) totalOutstanding = totalOutstanding.add(out);
            if (LoanInfo.DISBURSED.equals(l.getStatus())) activeLoans++;
        }
        BigDecimal totalCollected = sumSuccessful(visibleColls);

        List<ReportDtos.StatCard> cards = new ArrayList<>(List.of(
                new ReportDtos.StatCard("Total Disbursed", totalDisbursed, "currency"),
                new ReportDtos.StatCard("Outstanding", totalOutstanding, "currency"),
                new ReportDtos.StatCard("Total Collected", totalCollected, "currency"),
                new ReportDtos.StatCard("Active Loans", BigDecimal.valueOf(activeLoans), "count")));
        if (access.isDataEntryOperator(viewer)) {
            long customers = users.countByUserOrgIdAndUserRoleId(orgId, access.customerRoleId(orgId));
            cards.add(new ReportDtos.StatCard("Customers", BigDecimal.valueOf(customers), "count"));
        } else if (access.canViewUsers(viewer)) {
            cards.add(new ReportDtos.StatCard("Org Users", BigDecimal.valueOf(users.countByUserOrgId(orgId)), "count"));
        }

        // Roles without Audit access only see their own activity.
        List<AuditDto> recent = access.can(viewer, AccessService.AUDIT, AccessService.VIEW)
                ? audit.recentForOrg(orgId, RECENT_ACTIVITY)
                : audit.recentForUser(viewer, RECENT_ACTIVITY);
        return new ReportDtos.Dashboard(cards, recent);
    }

    @Transactional(readOnly = true)
    public ReportDtos.Reports reports(UserInfo viewer) {
        String role = access.roleName(viewer);
        return switch (role) {
            case AccessService.FINANCIER, AccessService.DATA_ENTRY_OPERATOR ->
                    new ReportDtos.Reports(loanPortfolio(viewer), null, null);
            case AccessService.COLLECTION_AGENT -> new ReportDtos.Reports(null, collectionPerformance(viewer), null);
            case AccessService.SECURITY -> new ReportDtos.Reports(loanPortfolio(viewer), collectionPerformance(viewer), null);
            case AccessService.CUSTOMER -> new ReportDtos.Reports(null, null, customerStatement(viewer));
            default -> new ReportDtos.Reports(null, null, null);
        };
    }

    private ReportDtos.LoanPortfolio loanPortfolio(UserInfo viewer) {
        List<LoanInfo> rows = loans.findByLoanOrgIdOrderByPkLoanIdDesc(viewer.getUserOrgId());
        List<ReportDtos.AmountBucket> byStatus = buckets(rows, LoanInfo::getStatus, LoanInfo::getLoanAmount);
        return new ReportDtos.LoanPortfolio(byStatus, loanService.toDtos(rows, viewer));
    }

    private ReportDtos.CollectionPerformance collectionPerformance(UserInfo viewer) {
        String orgId = viewer.getUserOrgId();
        List<LoanCollection> ok = collections.findByCollectionOrgIdOrderByPkCollectionIdDesc(orgId).stream()
                .filter(c -> LoanCollection.SUCCESS.equals(c.getStatus())).toList();
        Map<String, String> names = userService.nameMap(orgId);
        return new ReportDtos.CollectionPerformance(
                sumSuccessful(ok),
                buckets(ok, LoanCollection::getPaymentMode, LoanCollection::getCollectionAmount),
                buckets(ok, c -> c.getCollectedByUserId() == null ? "Unknown"
                        : names.getOrDefault(c.getCollectedByUserId(), c.getCollectedByUserId()),
                        LoanCollection::getCollectionAmount));
    }

    private ReportDtos.CustomerStatement customerStatement(UserInfo viewer) {
        String orgId = viewer.getUserOrgId();
        List<LoanInfo> own = loans.findByLoanOrgIdAndLoanUserIdOrderByPkLoanIdDesc(orgId, viewer.getPkUserId());
        List<LoanCollection> payments = collections
                .findByCollectionOrgIdAndCollectionUserIdOrderByPkCollectionIdDesc(orgId, viewer.getPkUserId());
        return new ReportDtos.CustomerStatement(loanService.toDtos(own, viewer), collectionService.toDtos(payments, orgId));
    }

    private static BigDecimal sumSuccessful(List<LoanCollection> rows) {
        return rows.stream().filter(c -> LoanCollection.SUCCESS.equals(c.getStatus()))
                .map(LoanCollection::getCollectionAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private static <T> List<ReportDtos.AmountBucket> buckets(List<T> rows, Function<T, String> key, Function<T, BigDecimal> amount) {
        Map<String, BigDecimal> totals = new LinkedHashMap<>();
        for (T row : rows) totals.merge(key.apply(row), amount.apply(row), BigDecimal::add);
        return totals.entrySet().stream().map(e -> new ReportDtos.AmountBucket(e.getKey(), e.getValue())).toList();
    }
}
