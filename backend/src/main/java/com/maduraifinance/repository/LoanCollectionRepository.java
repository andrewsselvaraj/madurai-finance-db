package com.maduraifinance.repository;

import com.maduraifinance.domain.LoanCollection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;

public interface LoanCollectionRepository extends JpaRepository<LoanCollection, String> {

    List<LoanCollection> findByCollectionOrgIdOrderByPkCollectionIdDesc(String orgId);

    List<LoanCollection> findByCollectionOrgIdAndCollectionUserIdOrderByPkCollectionIdDesc(String orgId, String userId);

    /** Sum of successful collections against a loan; null when there are none. */
    @Query("select sum(c.collectionAmount) from LoanCollection c "
            + "where c.collectionLoanId = :loanId and c.status = 'SUCCESS'")
    BigDecimal sumSuccessfulForLoan(@Param("loanId") String loanId);

    @Query("select c.pkCollectionId from LoanCollection c")
    List<String> findAllIds();
}
