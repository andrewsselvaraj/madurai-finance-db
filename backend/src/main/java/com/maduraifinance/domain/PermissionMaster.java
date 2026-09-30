package com.maduraifinance.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "permission_master")
public class PermissionMaster extends AuditColumns {

    @Id
    private String pkPermissionId;
    private String permissionName;
    private String permissionCode;

    public String getPkPermissionId() { return pkPermissionId; }
    public String getPermissionName() { return permissionName; }
    public String getPermissionCode() { return permissionCode; }
}
