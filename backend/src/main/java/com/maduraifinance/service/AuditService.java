package com.maduraifinance.service;

import com.maduraifinance.domain.AuditLog;
import com.maduraifinance.domain.UserInfo;
import com.maduraifinance.repository.AuditLogRepository;
import com.maduraifinance.web.dto.AuditDto;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AuditService {

    public static final int MAX_ROWS = 500;

    private final AuditLogRepository auditLogs;
    private final IdGenerator ids;
    private final AccessService access;

    public AuditService(AuditLogRepository auditLogs, IdGenerator ids, AccessService access) {
        this.auditLogs = auditLogs;
        this.ids = ids;
        this.access = access;
    }

    @Transactional
    public void log(UserInfo user, String action, String details) {
        String id = ids.next("AUD", 5, auditLogs.findAllIds());
        auditLogs.save(new AuditLog(id, user, action, details));
    }

    @Transactional(readOnly = true)
    public List<AuditDto> list(UserInfo user) {
        access.require(user, AccessService.AUDIT, AccessService.VIEW);
        return recentForOrg(user.getUserOrgId(), MAX_ROWS);
    }

    public List<AuditDto> recentForOrg(String orgId, int limit) {
        return auditLogs.findByAuditOrgIdOrderByAuditDatetimeDescPkAuditIdDesc(orgId, PageRequest.of(0, limit))
                .stream().map(AuditDto::from).toList();
    }

    public List<AuditDto> recentForUser(UserInfo user, int limit) {
        return auditLogs.findByAuditOrgIdAndAuditUserIdOrderByAuditDatetimeDescPkAuditIdDesc(
                        user.getUserOrgId(), user.getPkUserId(), PageRequest.of(0, limit))
                .stream().map(AuditDto::from).toList();
    }
}
