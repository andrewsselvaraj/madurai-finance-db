package com.maduraifinance.repository;

import com.maduraifinance.domain.UserInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface UserInfoRepository extends JpaRepository<UserInfo, String> {

    Optional<UserInfo> findByUserEmailIgnoreCase(String email);

    boolean existsByUserEmailIgnoreCase(String email);

    List<UserInfo> findByUserOrgIdOrderByPkUserId(String orgId);

    List<UserInfo> findByUserOrgIdAndUserRoleIdOrderByPkUserId(String orgId, String roleId);

    List<UserInfo> findByUserEmailIn(Collection<String> emails);

    long countByUserOrgId(String orgId);

    long countByUserOrgIdAndUserRoleId(String orgId, String roleId);

    @Query("select u.pkUserId from UserInfo u")
    List<String> findAllIds();
}
