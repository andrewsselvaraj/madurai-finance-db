package com.maduraifinance.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "audit_log")
public class AuditLog {

    @Id
    private String pkAuditId;
    private String auditOrgId;
    private LocalDateTime auditDatetime;
    private String auditUserId;
    private String auditUserName;
    private String action;
    private String details;

    protected AuditLog() {}

    public AuditLog(String pkAuditId, UserInfo user, String action, String details) {
        this.pkAuditId = pkAuditId;
        this.auditOrgId = user.getUserOrgId();
        this.auditDatetime = LocalDateTime.now().withNano(0);
        this.auditUserId = user.getPkUserId();
        this.auditUserName = user.getUserName();
        this.action = action;
        this.details = details;
    }

    public String getPkAuditId() { return pkAuditId; }
    public String getAuditOrgId() { return auditOrgId; }
    public LocalDateTime getAuditDatetime() { return auditDatetime; }
    public String getAuditUserId() { return auditUserId; }
    public String getAuditUserName() { return auditUserName; }
    public String getAction() { return action; }
    public String getDetails() { return details; }
}
