package com.maduraifinance.web.dto;

import jakarta.validation.constraints.NotBlank;

import java.util.List;

public final class AuthDtos {

    private AuthDtos() {}

    public record LoginRequest(@NotBlank(message = "Email is required.") String email,
                               @NotBlank(message = "Password is required.") String password) {}

    /** The logged-in user plus everything the UI needs to decide what to show. */
    public record Me(String id, String name, String email,
                     String orgId, String orgName,
                     String roleId, String roleName,
                     List<String> permissions,
                     boolean canManageUsers, boolean canAddCustomer, boolean canViewUsers,
                     boolean dataEntryOperator) {}

    public record DemoAccount(String email, String name, String roleId, String roleName) {}
}
