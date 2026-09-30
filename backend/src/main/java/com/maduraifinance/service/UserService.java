package com.maduraifinance.service;

import com.maduraifinance.domain.RoleMaster;
import com.maduraifinance.domain.UserInfo;
import com.maduraifinance.repository.UserInfoRepository;
import com.maduraifinance.web.dto.UserDtos;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class UserService {

    private final UserInfoRepository users;
    private final AccessService access;
    private final AuditService audit;
    private final IdGenerator ids;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserInfoRepository users, AccessService access, AuditService audit,
                       IdGenerator ids, PasswordEncoder passwordEncoder) {
        this.users = users;
        this.access = access;
        this.audit = audit;
        this.ids = ids;
        this.passwordEncoder = passwordEncoder;
    }

    /** pk_user_id -> user_name for everyone in the org. */
    public Map<String, String> nameMap(String orgId) {
        return users.findByUserOrgIdOrderByPkUserId(orgId).stream()
                .collect(Collectors.toMap(UserInfo::getPkUserId, UserInfo::getUserName));
    }

    @Transactional(readOnly = true)
    public List<UserDtos.UserRow> list(UserInfo viewer) {
        if (!access.canViewUsers(viewer)) throw ApiException.forbidden("Your role cannot view users.");
        String orgId = viewer.getUserOrgId();
        List<UserInfo> rows = access.isDataEntryOperator(viewer)
                ? users.findByUserOrgIdAndUserRoleIdOrderByPkUserId(orgId, access.customerRoleId(orgId))
                : users.findByUserOrgIdOrderByPkUserId(orgId);
        Map<String, RoleMaster> roles = access.rolesById(orgId);
        boolean manager = access.canManageUsers(viewer);
        return rows.stream().map(u -> {
            RoleMaster role = roles.get(u.getUserRoleId());
            return new UserDtos.UserRow(u.getPkUserId(), u.getUserName(), u.getUserEmail(), u.getUserRoleId(),
                    role == null ? u.getUserRoleId() : role.getRoleName(), u.getStatus(),
                    manager && !u.getPkUserId().equals(viewer.getPkUserId()));
        }).toList();
    }

    @Transactional(readOnly = true)
    public List<UserDtos.Role> roles(UserInfo viewer) {
        return access.rolesById(viewer.getUserOrgId()).values().stream()
                .sorted((a, b) -> a.getPkRoleId().compareTo(b.getPkRoleId()))
                .map(r -> new UserDtos.Role(r.getPkRoleId(), r.getRoleName(), r.getRoleDescription()))
                .toList();
    }

    @Transactional
    public UserDtos.UserRow create(UserInfo actor, UserDtos.CreateUserRequest req) {
        if (!access.canAddCustomer(actor)) throw ApiException.forbidden("Your role cannot create users.");
        String orgId = actor.getUserOrgId();

        String roleId = access.isDataEntryOperator(actor) ? access.customerRoleId(orgId) : req.roleId();
        RoleMaster role = roleId == null ? null : access.rolesById(orgId).get(roleId);
        if (role == null) throw ApiException.badRequest("Choose a valid role.");

        String email = req.email().trim();
        if (users.existsByUserEmailIgnoreCase(email)) throw ApiException.conflict("A user with that email already exists.");

        UserInfo user = new UserInfo();
        user.setPkUserId(ids.next("USR", 3, users.findAllIds()));
        user.setUserOrgId(orgId);
        user.setUserName(req.name().trim());
        user.setUserEmail(email);
        user.setUserRoleId(role.getPkRoleId());
        user.setPassword(passwordEncoder.encode(req.password()));
        user.setStatus(UserInfo.ACTIVE);
        user.touchedBy(actor.getPkUserId());
        users.save(user);

        audit.log(actor, "CREATE_USER", "Created user " + user.getUserName() + " (" + role.getRoleName() + ")");
        return new UserDtos.UserRow(user.getPkUserId(), user.getUserName(), user.getUserEmail(),
                role.getPkRoleId(), role.getRoleName(), user.getStatus(), access.canManageUsers(actor));
    }

    @Transactional
    public void toggleStatus(UserInfo actor, String userId) {
        if (!access.canManageUsers(actor)) throw ApiException.forbidden("Your role cannot change user status.");
        if (actor.getPkUserId().equals(userId)) throw ApiException.badRequest("You cannot disable your own account.");
        UserInfo target = users.findById(userId)
                .filter(u -> u.getUserOrgId().equals(actor.getUserOrgId()))
                .orElseThrow(() -> ApiException.notFound("User not found."));
        target.setStatus(target.isActive() ? UserInfo.DISABLED : UserInfo.ACTIVE);
        target.touchedBy(actor.getPkUserId());
        audit.log(actor, "UPDATE_USER_STATUS",
                "Set " + target.getUserName() + " (" + target.getPkUserId() + ") to " + target.getStatus());
    }
}
