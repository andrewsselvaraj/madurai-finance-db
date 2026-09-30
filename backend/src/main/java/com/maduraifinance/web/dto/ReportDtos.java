package com.maduraifinance.web.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.math.BigDecimal;
import java.util.List;

public final class ReportDtos {

    private ReportDtos() {}

    /** format is "currency" or "count". */
    public record StatCard(String label, BigDecimal value, String format) {}

    public record Dashboard(List<StatCard> cards, List<AuditDto> recentActivity) {}

    public record AmountBucket(String label, BigDecimal amount) {}

    public record LoanPortfolio(List<AmountBucket> byStatus, List<LoanDtos.Loan> loans) {}

    public record CollectionPerformance(BigDecimal totalCollected, List<AmountBucket> byMode, List<AmountBucket> byAgent) {}

    public record CustomerStatement(List<LoanDtos.Loan> loans, List<CollectionDtos.Collection> payments) {}

    /** Only the sections the viewer's role gets are present. */
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record Reports(LoanPortfolio loanPortfolio, CollectionPerformance collectionPerformance,
                          CustomerStatement customerStatement) {}
}
