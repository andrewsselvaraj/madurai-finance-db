package com.maduraifinance.web.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDate;

public final class CollectionDtos {

    private CollectionDtos() {}

    public record Collection(String id, String loanId, String customerId, String customerName,
                             BigDecimal amount, LocalDate date, String paymentMode, String referenceNo,
                             String collectedById, String collectedByName, String remarks, String status) {}

    /** A disbursed loan that still has a balance to collect. */
    public record CollectableLoan(String id, String customerName, BigDecimal outstanding) {}

    public record CreateCollectionRequest(
            @NotBlank(message = "Choose a loan.") String loanId,
            @NotNull(message = "Amount is required.") @DecimalMin(value = "0.01", message = "Amount must be positive.")
            @Digits(integer = 13, fraction = 2) BigDecimal amount,
            LocalDate date,
            @NotBlank(message = "Payment mode is required.") String paymentMode,
            @Size(max = 100) String referenceNo,
            @Size(max = 255) String remarks) {}
}
