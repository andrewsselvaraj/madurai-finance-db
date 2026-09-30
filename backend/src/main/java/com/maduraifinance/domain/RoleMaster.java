package com.maduraifinance.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "role_master")
public class RoleMaster extends AuditColumns {

    @Id
    private String pkRoleId;
    private String roleOrgId;
    private String roleName;
    private String roleDescription;
    private String status;

    public String getPkRoleId() { return pkRoleId; }
    public String getRoleOrgId() { return roleOrgId; }
    public String getRoleName() { return roleName; }
    public String getRoleDescription() { return roleDescription; }
    public String getStatus() { return status; }
}
