package com.maduraifinance.repository;

import com.maduraifinance.domain.RolePermissionMapping;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RolePermissionMappingRepository extends JpaRepository<RolePermissionMapping, String> {

    List<RolePermissionMapping> findByMapOrgIdAndMapRoleId(String orgId, String roleId);

    boolean existsByMapOrgIdAndMapRoleIdAndMapModuleIdAndMapPermissionId(
            String orgId, String roleId, String moduleId, String permissionId);
}
