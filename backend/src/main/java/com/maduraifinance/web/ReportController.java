package com.maduraifinance.web;

import com.maduraifinance.service.AuditService;
import com.maduraifinance.service.CurrentUser;
import com.maduraifinance.service.ReportService;
import com.maduraifinance.web.dto.AuditDto;
import com.maduraifinance.web.dto.ReportDtos;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class ReportController {

    private final ReportService reportService;
    private final AuditService auditService;
    private final CurrentUser currentUser;

    public ReportController(ReportService reportService, AuditService auditService, CurrentUser currentUser) {
        this.reportService = reportService;
        this.auditService = auditService;
        this.currentUser = currentUser;
    }

    @GetMapping("/dashboard")
    public ReportDtos.Dashboard dashboard() {
        return reportService.dashboard(currentUser.get());
    }

    @GetMapping("/reports")
    public ReportDtos.Reports reports() {
        return reportService.reports(currentUser.get());
    }

    @GetMapping("/audit")
    public List<AuditDto> audit() {
        return auditService.list(currentUser.get());
    }
}
