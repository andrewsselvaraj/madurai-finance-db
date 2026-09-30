package com.maduraifinance.web.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public final class UserDtos {

    private UserDtos() {}

    public record UserRow(String id, String name, String email, String roleId, String roleName,
                          String status, boolean canToggle) {}

    public record Role(String id, String name, String description) {}

    /** roleId is ignored for Data Entry Operators, who can only add customers. */
    public record CreateUserRequest(
            @NotBlank(message = "Name is required.") @Size(max = 50) String name,
            @NotBlank(message = "Email is required.") @Email(message = "Enter a valid email.") @Size(max = 50) String email,
            String roleId,
            @NotBlank(message = "Password is required.") @Size(max = 64) String password) {}
}
