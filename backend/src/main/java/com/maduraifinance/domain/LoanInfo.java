package com.maduraifinance.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "loan_info")
public class LoanInfo extends AuditColumns {

    public static final String PENDING = "PENDING";
    public static final String APPROVED = "APPROVED";
    public static final String DISBURSED = "DISBURSED";
    public static final String CLOSED = "CLOSED";
    public static final String REJECTED = "REJECTED";

    @Id
    private String pkLoanId;
    private String loanOrgId;
    private String loanUserId;
    private BigDecimal loanAmount;
    private BigDecimal interestRate;
    private Integer tenureMonths;
    private String purpose;
    private LocalDate applicationDate;
    private LocalDate approvalDate;
    private LocalDate disbursementDate;
    private LocalDate dueDate;
    private BigDecimal outstandingAmount;
    private LocalDate receivedDate;
    private String status;

    /** An outstanding balance only exists once the money has gone out. */
    public boolean hasBalance() { return DISBURSED.equals(status) || CLOSED.equals(status); }

    public String getPkLoanId() { return pkLoanId; }
    public void setPkLoanId(String pkLoanId) { this.pkLoanId = pkLoanId; }
    public String getLoanOrgId() { return loanOrgId; }
    public void setLoanOrgId(String loanOrgId) { this.loanOrgId = loanOrgId; }
    public String getLoanUserId() { return loanUserId; }
    public void setLoanUserId(String loanUserId) { this.loanUserId = loanUserId; }
    public BigDecimal getLoanAmount() { return loanAmount; }
    public void setLoanAmount(BigDecimal loanAmount) { this.loanAmount = loanAmount; }
    public BigDecimal getInterestRate() { return interestRate; }
    public void setInterestRate(BigDecimal interestRate) { this.interestRate = interestRate; }
    public Integer getTenureMonths() { return tenureMonths; }
    public void setTenureMonths(Integer tenureMonths) { this.tenureMonths = tenureMonths; }
    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }
    public LocalDate getApplicationDate() { return applicationDate; }
    public void setApplicationDate(LocalDate applicationDate) { this.applicationDate = applicationDate; }
    public LocalDate getApprovalDate() { return approvalDate; }
    public void setApprovalDate(LocalDate approvalDate) { this.approvalDate = approvalDate; }
    public LocalDate getDisbursementDate() { return disbursementDate; }
    public void setDisbursementDate(LocalDate disbursementDate) { this.disbursementDate = disbursementDate; }
    public LocalDate getDueDate() { return dueDate; }
    public void setDueDate(LocalDate dueDate) { this.dueDate = dueDate; }
    public BigDecimal getOutstandingAmount() { return outstandingAmount; }
    public void setOutstandingAmount(BigDecimal outstandingAmount) { this.outstandingAmount = outstandingAmount; }
    public LocalDate getReceivedDate() { return receivedDate; }
    public void setReceivedDate(LocalDate receivedDate) { this.receivedDate = receivedDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
