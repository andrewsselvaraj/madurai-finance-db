package com.maduraifinance.service;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Rupee formatting for audit messages, e.g. 1234567.5 -> "₹12,34,567.50". */
public final class Money {

    private Money() {}

    public static String inr(BigDecimal value) {
        if (value == null) return "—";
        String plain = value.setScale(2, RoundingMode.HALF_UP).toPlainString();
        boolean negative = plain.startsWith("-");
        if (negative) plain = plain.substring(1);

        int dot = plain.indexOf('.');
        String whole = plain.substring(0, dot);
        String fraction = plain.substring(dot);

        // Indian grouping: last three digits, then groups of two.
        StringBuilder grouped = new StringBuilder();
        if (whole.length() <= 3) {
            grouped.append(whole);
        } else {
            String head = whole.substring(0, whole.length() - 3);
            for (int i = 0; i < head.length(); i++) {
                if (i > 0 && (head.length() - i) % 2 == 0) grouped.append(',');
                grouped.append(head.charAt(i));
            }
            grouped.append(',').append(whole.substring(whole.length() - 3));
        }
        return (negative ? "-" : "") + "₹" + grouped + fraction;
    }
}
