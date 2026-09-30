package com.maduraifinance.service;

import com.maduraifinance.domain.UserInfo;
import com.maduraifinance.repository.UserInfoRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

/**
 * Resolves the logged-in user from the session. The row is re-read on every
 * request so a user disabled mid-session loses access immediately.
 */
@Component
public class CurrentUser {

    private final UserInfoRepository users;

    public CurrentUser(UserInfoRepository users) {
        this.users = users;
    }

    public UserInfo get() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth instanceof AnonymousAuthenticationToken) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Not logged in.");
        }
        return users.findById(auth.getName())
                .filter(UserInfo::isActive)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Your session has ended. Please log in again."));
    }
}
