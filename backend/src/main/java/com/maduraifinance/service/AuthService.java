package com.maduraifinance.service;

import com.maduraifinance.domain.OrgInfo;
import com.maduraifinance.domain.RoleMaster;
import com.maduraifinance.domain.UserInfo;
import com.maduraifinance.repository.OrgInfoRepository;
import com.maduraifinance.repository.UserInfoRepository;
import com.maduraifinance.web.dto.AuthDtos;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AuthService {

    private final UserInfoRepository users;
    private final OrgInfoRepository orgs;
    private final AccessService access;
    private final AuditService audit;
    private final PasswordEncoder passwordEncoder;
    private final List<String> demoAccounts;

    public AuthService(UserInfoRepository users, OrgInfoRepository orgs, AccessService access, AuditService audit,
                       PasswordEncoder passwordEncoder, @Value("${app.demo-accounts:}") List<String> demoAccounts) {
        this.users = users;
        this.orgs = orgs;
        this.access = access;
        this.audit = audit;
        this.passwordEncoder = passwordEncoder;
        this.demoAccounts = demoAccounts.stream().map(String::trim).filter(s -> !s.isEmpty()).toList();
    }

    /** Checks the credentials and records the login; the caller stores the session. */
    @Transactional
    public UserInfo authenticate(String email, String password) {
        UserInfo user = users.findByUserEmailIgnoreCase(email.trim())
                .filter(u -> passwordEncoder.matches(password, u.getPassword()))
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Incorrect email or password."));
        if (!user.isActive()) {
            throw ApiException.forbidden("This account is disabled. Contact your administrator.");
        }
        audit.log(user, "LOGIN", user.getUserName() + " logged in");
        return user;
    }

    @Transactional
    public void recordLogout(UserInfo user) {
        audit.log(user, "LOGOUT", user.getUserName() + " logged out");
    }

    @Transactional(readOnly = true)
    public AuthDtos.Me me(UserInfo user) {
        RoleMaster role = access.role(user);
        String orgName = orgs.findById(user.getUserOrgId()).map(OrgInfo::getOrgName).orElse(user.getUserOrgId());
        return new AuthDtos.Me(user.getPkUserId(), user.getUserName(), user.getUserEmail(),
                user.getUserOrgId(), orgName, role.getPkRoleId(), role.getRoleName(),
                new ArrayList<>(access.permissions(user)),
                access.canManageUsers(user), access.canAddCustomer(user), access.canViewUsers(user),
                access.isDataEntryOperator(user));
    }

    /** Quick-login buttons on the login screen, in configured order. */
    @Transactional(readOnly = true)
    public List<AuthDtos.DemoAccount> demoAccounts() {
        if (demoAccounts.isEmpty()) return List.of();
        Map<String, UserInfo> byEmail = new HashMap<>();
        users.findByUserEmailIn(demoAccounts).forEach(u -> byEmail.put(u.getUserEmail().toLowerCase(), u));
        List<AuthDtos.DemoAccount> result = new ArrayList<>();
        for (String email : demoAccounts) {
            UserInfo u = byEmail.get(email.toLowerCase());
            if (u == null || !u.isActive()) continue;
            result.add(new AuthDtos.DemoAccount(u.getUserEmail(), u.getUserName(), u.getUserRoleId(), access.roleName(u)));
        }
        return result;
    }
}
