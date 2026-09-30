package com.maduraifinance.service;

import org.springframework.stereotype.Component;

import java.util.Collection;

/**
 * Generates the schema's prefixed sequential keys (LOAN004, USR021, AUD00003).
 * Not safe under concurrent inserts; a clash is rejected by the primary key.
 */
@Component
public class IdGenerator {

    public String next(String prefix, int width, Collection<String> existingIds) {
        int max = 0;
        for (String id : existingIds) {
            if (id == null || !id.startsWith(prefix)) continue;
            try {
                max = Math.max(max, Integer.parseInt(id.substring(prefix.length())));
            } catch (NumberFormatException ignored) {
                // Non-numeric suffix: not part of the sequence.
            }
        }
        return prefix + String.format("%0" + width + "d", max + 1);
    }
}
