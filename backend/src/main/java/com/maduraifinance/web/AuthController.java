package com.maduraifinance.web;

import com.maduraifinance.domain.UserInfo;
import com.maduraifinance.service.AuthService;
import com.maduraifinance.service.CurrentUser;
import com.maduraifinance.web.dto.AuthDtos;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final CurrentUser currentUser;
    private final SecurityContextRepository contextRepository = new HttpSessionSecurityContextRepository();

    public AuthController(AuthService authService, CurrentUser currentUser) {
        this.authService = authService;
        this.currentUser = currentUser;
    }

    @PostMapping("/login")
    public AuthDtos.Me login(@Valid @RequestBody AuthDtos.LoginRequest req,
                             HttpServletRequest request, HttpServletResponse response) {
        UserInfo user = authService.authenticate(req.email(), req.password());

        // Fresh session on login (session fixation protection).
        HttpSession old = request.getSession(false);
        if (old != null) old.invalidate();

        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(UsernamePasswordAuthenticationToken.authenticated(
                user.getPkUserId(), null, List.of(new SimpleGrantedAuthority("ROLE_USER"))));
        SecurityContextHolder.setContext(context);
        contextRepository.saveContext(context, request, response);

        return authService.me(user);
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(HttpServletRequest request) {
        authService.recordLogout(currentUser.get());
        HttpSession session = request.getSession(false);
        if (session != null) session.invalidate();
        SecurityContextHolder.clearContext();
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/me")
    public AuthDtos.Me me() {
        return authService.me(currentUser.get());
    }

    @GetMapping("/demo-accounts")
    public List<AuthDtos.DemoAccount> demoAccounts() {
        return authService.demoAccounts();
    }
}
