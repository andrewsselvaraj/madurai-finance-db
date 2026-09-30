package com.maduraifinance.repository;

import com.maduraifinance.domain.LoanInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface LoanInfoRepository extends JpaRepository<LoanInfo, String> {

    List<LoanInfo> findByLoanOrgIdOrderByPkLoanIdDesc(String orgId);

    List<LoanInfo> findByLoanOrgIdAndLoanUserIdOrderByPkLoanIdDesc(String orgId, String userId);

    List<LoanInfo> findByLoanOrgIdAndStatusOrderByPkLoanId(String orgId, String status);

    Optional<LoanInfo> findByPkLoanIdAndLoanOrgId(String loanId, String orgId);

    @Query("select l.pkLoanId from LoanInfo l")
    List<String> findAllIds();
}
