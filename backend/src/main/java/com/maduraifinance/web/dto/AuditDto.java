package com.maduraifinance.web.dto;

import com.maduraifinance.domain.AuditLog;

import java.time.format.DateTimeFormatter;

public record AuditDto(String id, String datetime, String userId, String userName, String action, String details) {

    private static final DateTimeFormatter FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public static AuditDto from(AuditLog a) {
        return new AuditDto(a.getPkAuditId(),
                a.getAuditDatetime() == null ? null : a.getAuditDatetime().format(FORMAT),
                a.getAuditUserId(), a.getAuditUserName(), a.getAction(), a.getDetails());
    }
}
