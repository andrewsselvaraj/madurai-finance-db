package com.maduraifinance.repository;

import com.maduraifinance.domain.PermissionMaster;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PermissionMasterRepository extends JpaRepository<PermissionMaster, String> {

    Optional<PermissionMaster> findByPermissionCode(String permissionCode);
}
