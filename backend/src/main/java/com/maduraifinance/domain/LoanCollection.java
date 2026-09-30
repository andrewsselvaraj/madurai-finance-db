package com.maduraifinance.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Set;

@Entity
@Table(name = "loan_collection")
public class LoanCollection extends AuditColumns {

    public static final String SUCCESS = "SUCCESS";
    public static final Set<String> PAYMENT_MODES = Set.of("CASH", "UPI", "BANK_TRANSFER", "CHEQUE", "CARD");

    @Id
    private String pkCollectionId;
    private String collectionOrgId;
    private String collectionLoanId;
    private String collectionUserId;
    private BigDecimal collectionAmount;
    private LocalDate collectionDate;
    private String paymentMode;
    private String referenceNo;
    private String collectedByUserId;
    private String remarks;
    private String status;

    public String getPkCollectionId() { return pkCollectionId; }
    public void setPkCollectionId(String pkCollectionId) { this.pkCollectionId = pkCollectionId; }
    public String getCollectionOrgId() { return collectionOrgId; }
    public void setCollectionOrgId(String collectionOrgId) { this.collectionOrgId = collectionOrgId; }
    public String getCollectionLoanId() { return collectionLoanId; }
    public void setCollectionLoanId(String collectionLoanId) { this.collectionLoanId = collectionLoanId; }
    public String getCollectionUserId() { return collectionUserId; }
    public void setCollectionUserId(String collectionUserId) { this.collectionUserId = collectionUserId; }
    public BigDecimal getCollectionAmount() { return collectionAmount; }
    public void setCollectionAmount(BigDecimal collectionAmount) { this.collectionAmount = collectionAmount; }
    public LocalDate getCollectionDate() { return collectionDate; }
    public void setCollectionDate(LocalDate collectionDate) { this.collectionDate = collectionDate; }
    public String getPaymentMode() { return paymentMode; }
    public void setPaymentMode(String paymentMode) { this.paymentMode = paymentMode; }
    public String getReferenceNo() { return referenceNo; }
    public void setReferenceNo(String referenceNo) { this.referenceNo = referenceNo; }
    public String getCollectedByUserId() { return collectedByUserId; }
    public void setCollectedByUserId(String collectedByUserId) { this.collectedByUserId = collectedByUserId; }
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
