package com.maduraifinance.repository;

import com.maduraifinance.domain.AuditLog;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface AuditLogRepository extends JpaRepository<AuditLog, String> {

    List<AuditLog> findByAuditOrgIdOrderByAuditDatetimeDescPkAuditIdDesc(String orgId, Pageable page);

    List<AuditLog> findByAuditOrgIdAndAuditUserIdOrderByAuditDatetimeDescPkAuditIdDesc(String orgId, String userId, Pageable page);

    @Query("select a.pkAuditId from AuditLog a")
    List<String> findAllIds();
}
