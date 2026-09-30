package com.maduraifinance.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * When the React build is bundled into static/ (npm run build), deep links such
 * as /loans are served index.html so client-side routing can take over.
 */
@Controller
public class SpaForwardController {

    @GetMapping({"/dashboard", "/users", "/loans", "/collections", "/audit", "/reports"})
    public String forward() {
        return "forward:/index.html";
    }
}
