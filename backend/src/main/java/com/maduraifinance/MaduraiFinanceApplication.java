package com.maduraifinance;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;

// Login is handled by AuthController against user_info, so the default
// in-memory user (and its generated password) is not wanted.
@SpringBootApplication(exclude = UserDetailsServiceAutoConfiguration.class)
public class MaduraiFinanceApplication {

    public static void main(String[] args) {
        SpringApplication.run(MaduraiFinanceApplication.class, args);
    }
}
