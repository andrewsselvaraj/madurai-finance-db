package com.maduraifinance.service;

import com.maduraifinance.domain.ModuleMaster;
import com.maduraifinance.domain.PermissionMaster;
import com.maduraifinance.domain.RoleMaster;
import com.maduraifinance.domain.RolePermissionMapping;
import com.maduraifinance.domain.UserInfo;
import com.maduraifinance.repository.ModuleMasterRepository;
import com.maduraifinance.repository.PermissionMasterRepository;
import com.maduraifinance.repository.RoleMasterRepository;
import com.maduraifinance.repository.RolePermissionMappingRepository;
import org.springframework.stereotype.Service;

import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Permission engine. Module access is driven entirely by role_permission_mapping;
 * user management has no module in the schema, so it is granted by role name
 * (Financier manages, Security views, Data Entry Operator adds customers only).
 */
@Service
public class AccessService {

    public static final String LOAN = "LOAN_DISBURSEMENT";
    public static final String COLLECTION = "COLLECTION";
    public static final String AUDIT = "AUDIT";

    public static final String VIEW = "VIEW";
    public static final String CREATE = "CREATE";
    public static final String APPROVE = "APPROVE";
    public static final String DISBURSE = "DISBURSE";
    public static final String COLLECT = "COLLECT";
    public static final String RECEIVE = "RECEIVE";

    public static final String FINANCIER = "Financier";
    public static final String COLLECTION_AGENT = "Collection Agent";
    public static final String CUSTOMER = "Customer";
    public static final String SECURITY = "Security";
    public static final String DATA_ENTRY_OPERATOR = "Data Entry Operator";

    private final RoleMasterRepository roles;
    private final ModuleMasterRepository modules;
    private final PermissionMasterRepository permissionMaster;
    private final RolePermissionMappingRepository mappings;

    public AccessService(RoleMasterRepository roles, ModuleMasterRepository modules,
                         PermissionMasterRepository permissionMaster, RolePermissionMappingRepository mappings) {
        this.roles = roles;
        this.modules = modules;
        this.permissionMaster = permissionMaster;
        this.mappings = mappings;
    }

    /** The user's grants as "MODULE_CODE:PERMISSION_CODE" strings. */
    public Set<String> permissions(UserInfo user) {
        Map<String, String> moduleCodes = modules.findAll().stream()
                .collect(Collectors.toMap(ModuleMaster::getPkModuleId, ModuleMaster::getModuleCode));
        Map<String, String> permCodes = permissionMaster.findAll().stream()
                .collect(Collectors.toMap(PermissionMaster::getPkPermissionId, PermissionMaster::getPermissionCode));
        Set<String> result = new LinkedHashSet<>();
        for (RolePermissionMapping m : mappings.findByMapOrgIdAndMapRoleId(user.getUserOrgId(), user.getUserRoleId())) {
            String module = moduleCodes.get(m.getMapModuleId());
            String perm = permCodes.get(m.getMapPermissionId());
            if (module != null && perm != null) result.add(module + ":" + perm);
        }
        return result;
    }

    public boolean can(UserInfo user, String module, String permission) {
        return permissions(user).contains(module + ":" + permission);
    }

    public void require(UserInfo user, String module, String permission) {
        if (!can(user, module, permission)) {
            throw ApiException.forbidden("Your role does not have " + permission + " permission on " + module + ".");
        }
    }

    public RoleMaster role(UserInfo user) {
        return roles.findById(user.getUserRoleId())
                .orElseThrow(() -> ApiException.forbidden("Your account has no valid role."));
    }

    public String roleName(UserInfo user) {
        return roles.findById(user.getUserRoleId()).map(RoleMaster::getRoleName).orElse("");
    }

    public Map<String, RoleMaster> rolesById(String orgId) {
        return roles.findByRoleOrgIdOrderByPkRoleId(orgId).stream()
                .collect(Collectors.toMap(RoleMaster::getPkRoleId, Function.identity()));
    }

    public String customerRoleId(String orgId) {
        return roles.findFirstByRoleOrgIdAndRoleName(orgId, CUSTOMER)
                .map(RoleMaster::getPkRoleId)
                .orElseThrow(() -> ApiException.badRequest("This organisation has no Customer role."));
    }

    public boolean isCustomer(UserInfo user) { return CUSTOMER.equals(roleName(user)); }
    public boolean isSecurity(UserInfo user) { return SECURITY.equals(roleName(user)); }
    public boolean isDataEntryOperator(UserInfo user) { return DATA_ENTRY_OPERATOR.equals(roleName(user)); }

    public boolean canManageUsers(UserInfo user) { return FINANCIER.equals(roleName(user)); }

    public boolean canAddCustomer(UserInfo user) {
        String role = roleName(user);
        return FINANCIER.equals(role) || DATA_ENTRY_OPERATOR.equals(role);
    }

    public boolean canViewUsers(UserInfo user) {
        String role = roleName(user);
        return FINANCIER.equals(role) || SECURITY.equals(role) || DATA_ENTRY_OPERATOR.equals(role);
    }
}
