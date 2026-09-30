package com.maduraifinance.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "org_info")
public class OrgInfo extends AuditColumns {

    @Id
    private String pkOrgId;
    private String orgName;
    private String orgEmail;
    private String status;

    public String getPkOrgId() { return pkOrgId; }
    public String getOrgName() { return orgName; }
    public String getOrgEmail() { return orgEmail; }
    public String getStatus() { return status; }
}
