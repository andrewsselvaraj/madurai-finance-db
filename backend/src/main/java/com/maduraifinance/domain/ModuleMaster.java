package com.maduraifinance.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "module_master")
public class ModuleMaster extends AuditColumns {

    @Id
    private String pkModuleId;
    private String moduleName;
    private String moduleCode;

    public String getPkModuleId() { return pkModuleId; }
    public String getModuleName() { return moduleName; }
    public String getModuleCode() { return moduleCode; }
}
