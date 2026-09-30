package com.maduraifinance.domain;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;

import java.time.LocalDateTime;

/** The created_/updated_ columns shared by every etfdb_dev table. */
@MappedSuperclass
public abstract class AuditColumns {

    @Column(updatable = false)
    private LocalDateTime createdDatetime;
    @Column(updatable = false)
    private String createdUser;
    private LocalDateTime updatedDatetime;
    private String updatedUser;

    @PrePersist
    void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        if (createdDatetime == null) createdDatetime = now;
        updatedDatetime = now;
    }

    @PreUpdate
    void onUpdate() {
        updatedDatetime = LocalDateTime.now();
    }

    /** Records the acting user in created_user (new rows only) and updated_user. */
    public void touchedBy(String userId) {
        if (createdDatetime == null) createdUser = userId;
        updatedUser = userId;
    }

    public LocalDateTime getCreatedDatetime() { return createdDatetime; }
    public String getCreatedUser() { return createdUser; }
    public LocalDateTime getUpdatedDatetime() { return updatedDatetime; }
    public String getUpdatedUser() { return updatedUser; }
}
