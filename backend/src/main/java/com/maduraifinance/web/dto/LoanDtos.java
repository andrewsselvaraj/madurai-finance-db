package com.maduraifinance.web.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public final class LoanDtos {

    private LoanDtos() {}

    /**
     * outstanding is null until the loan is disbursed. actions lists what the
     * viewer may do next: APPROVE, REJECT, DISBURSE, RECEIVE.
     */
    public record Loan(String id, String customerId, String customerName,
                       BigDecimal amount, BigDecimal interestRate, Integer tenureMonths, String purpose,
                       LocalDate applicationDate, LocalDate approvalDate, LocalDate disbursementDate,
                       LocalDate dueDate, BigDecimal outstanding, LocalDate receivedDate,
                       String status, List<String> actions) {}

    /** An active customer a new loan can be created for. */
    public record CustomerOption(String id, String name) {}

    public record CreateLoanRequest(
            @NotBlank(message = "Choose a customer.") String customerId,
            @NotNull(message = "Amount is required.") @DecimalMin(value = "0.01", message = "Amount must be positive.")
            @Digits(integer = 13, fraction = 2) BigDecimal amount,
            @NotNull(message = "Interest rate is required.") @DecimalMin(value = "0", message = "Interest rate cannot be negative.")
            @Digits(integer = 3, fraction = 2) BigDecimal interestRate,
            @NotNull(message = "Tenure is required.") @Min(value = 1, message = "Tenure must be at least 1 month.")
            @Max(600) Integer tenureMonths,
            @Size(max = 255) String purpose) {}
}
