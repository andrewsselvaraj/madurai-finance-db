package com.maduraifinance.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "role_permission_mapping")
public class RolePermissionMapping extends AuditColumns {

    @Id
    private String pkMappingId;
    private String mapOrgId;
    private String mapRoleId;
    private String mapModuleId;
    private String mapPermissionId;

    public String getPkMappingId() { return pkMappingId; }
    public String getMapOrgId() { return mapOrgId; }
    public String getMapRoleId() { return mapRoleId; }
    public String getMapModuleId() { return mapModuleId; }
    public String getMapPermissionId() { return mapPermissionId; }
}
