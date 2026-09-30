package com.maduraifinance.web;

import com.maduraifinance.service.CurrentUser;
import com.maduraifinance.service.UserService;
import com.maduraifinance.web.dto.UserDtos;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class UserController {

    private final UserService userService;
    private final CurrentUser currentUser;

    public UserController(UserService userService, CurrentUser currentUser) {
        this.userService = userService;
        this.currentUser = currentUser;
    }

    @GetMapping("/users")
    public List<UserDtos.UserRow> list() {
        return userService.list(currentUser.get());
    }

    @PostMapping("/users")
    @ResponseStatus(HttpStatus.CREATED)
    public UserDtos.UserRow create(@Valid @RequestBody UserDtos.CreateUserRequest req) {
        return userService.create(currentUser.get(), req);
    }

    @PostMapping("/users/{id}/toggle-status")
    public ResponseEntity<Void> toggleStatus(@PathVariable String id) {
        userService.toggleStatus(currentUser.get(), id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/roles")
    public List<UserDtos.Role> roles() {
        return userService.roles(currentUser.get());
    }
}
