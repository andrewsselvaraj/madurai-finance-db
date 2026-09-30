package com.maduraifinance.web;

import com.maduraifinance.service.CurrentUser;
import com.maduraifinance.service.LoanService;
import com.maduraifinance.web.dto.LoanDtos;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/loans")
public class LoanController {

    private final LoanService loanService;
    private final CurrentUser currentUser;

    public LoanController(LoanService loanService, CurrentUser currentUser) {
        this.loanService = loanService;
        this.currentUser = currentUser;
    }

    @GetMapping
    public List<LoanDtos.Loan> list() {
        return loanService.list(currentUser.get());
    }

    @GetMapping("/customers")
    public List<LoanDtos.CustomerOption> customers() {
        return loanService.customers(currentUser.get());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public LoanDtos.Loan create(@Valid @RequestBody LoanDtos.CreateLoanRequest req) {
        return loanService.create(currentUser.get(), req);
    }

    @PostMapping("/{id}/approve")
    public LoanDtos.Loan approve(@PathVariable String id) {
        return loanService.approve(currentUser.get(), id);
    }

    @PostMapping("/{id}/reject")
    public LoanDtos.Loan reject(@PathVariable String id) {
        return loanService.reject(currentUser.get(), id);
    }

    @PostMapping("/{id}/disburse")
    public LoanDtos.Loan disburse(@PathVariable String id) {
        return loanService.disburse(currentUser.get(), id);
    }

    @PostMapping("/{id}/receive")
    public LoanDtos.Loan receive(@PathVariable String id) {
        return loanService.receive(currentUser.get(), id);
    }
}
