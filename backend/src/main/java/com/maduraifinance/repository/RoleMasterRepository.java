package com.maduraifinance.repository;

import com.maduraifinance.domain.RoleMaster;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RoleMasterRepository extends JpaRepository<RoleMaster, String> {

    List<RoleMaster> findByRoleOrgIdOrderByPkRoleId(String orgId);

    Optional<RoleMaster> findFirstByRoleOrgIdAndRoleName(String orgId, String roleName);
}
