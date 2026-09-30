package com.maduraifinance.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "user_info")
public class UserInfo extends AuditColumns {

    public static final String ACTIVE = "ACTIVE";
    public static final String DISABLED = "DISABLED";

    @Id
    private String pkUserId;
    private String userOrgId;
    private String userName;
    private String password;
    private String userEmail;
    private String userRoleId;
    private String status;

    public boolean isActive() { return ACTIVE.equals(status); }

    public String getPkUserId() { return pkUserId; }
    public void setPkUserId(String pkUserId) { this.pkUserId = pkUserId; }
    public String getUserOrgId() { return userOrgId; }
    public void setUserOrgId(String userOrgId) { this.userOrgId = userOrgId; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public String getUserRoleId() { return userRoleId; }
    public void setUserRoleId(String userRoleId) { this.userRoleId = userRoleId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
