-- ─────────────────────────────────────────────────────────────────
-- Madurai Finance - Database Schema
-- Created : 2026-06-24
-- ─────────────────────────────────────────────────────────────────

-- 1. Tenant Space Management Table
CREATE TABLE `org_info` (
  `pk_org_id`        varchar(50)  NOT NULL,
  `org_name`         varchar(100) NOT NULL,
  `org_email`        varchar(50)  NOT NULL,
  `status`           varchar(10)  NOT NULL DEFAULT 'ACTIVE', -- [ACTIVE, DISABLED]
  `created_datetime` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user`     varchar(50)           DEFAULT NULL,
  `updated_datetime` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user`     varchar(50)           DEFAULT NULL,
  PRIMARY KEY (`pk_org_id`)
);

-- 2. Tenant Role Definitions Table
CREATE TABLE `role_master` (
  `pk_role_id`       varchar(50)  NOT NULL,
  `role_org_id`      varchar(50)  NOT NULL,
  `role_name`        varchar(50)  NOT NULL,
  `role_description` varchar(255)          DEFAULT NULL,
  `status`           varchar(10)  NOT NULL DEFAULT 'ACTIVE', -- [ACTIVE, DISABLED]
  `created_datetime` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user`     varchar(50)           DEFAULT NULL,
  `updated_datetime` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user`     varchar(50)           DEFAULT NULL,
  PRIMARY KEY (`pk_role_id`),
  KEY `fk_role_org_id` (`role_org_id`),
  CONSTRAINT `fk_role_org_id` FOREIGN KEY (`role_org_id`) REFERENCES `org_info` (`pk_org_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. System-Wide Shared Domain Modules
CREATE TABLE `module_master` (
  `pk_module_id`     varchar(50)  NOT NULL,
  `module_name`      varchar(50)  NOT NULL,
  `module_code`      varchar(50)  NOT NULL UNIQUE,
  `created_datetime` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user`     varchar(50)           DEFAULT NULL,
  `updated_datetime` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user`     varchar(50)           DEFAULT NULL,
  PRIMARY KEY (`pk_module_id`)
);

-- 4. Action Verb Operations Catalog
CREATE TABLE `permission_master` (
  `pk_permission_id` varchar(50)  NOT NULL,
  `permission_name`  varchar(50)  NOT NULL,
  `permission_code`  varchar(50)  NOT NULL UNIQUE,
  `created_datetime` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user`     varchar(50)           DEFAULT NULL,
  `updated_datetime` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user`     varchar(50)           DEFAULT NULL,
  PRIMARY KEY (`pk_permission_id`)
);

-- 5. Intersection Matrix Linking Role, Target and Action
CREATE TABLE `role_permission_mapping` (
  `pk_mapping_id`     varchar(50) NOT NULL,
  `map_org_id`        varchar(50) NOT NULL,
  `map_role_id`       varchar(50) NOT NULL,
  `map_module_id`     varchar(50) NOT NULL,
  `map_permission_id` varchar(50) NOT NULL,
  `created_datetime`  datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user`      varchar(50)          DEFAULT NULL,
  `updated_datetime`  datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user`      varchar(50)          DEFAULT NULL,
  PRIMARY KEY (`pk_mapping_id`),
  UNIQUE KEY `uk_tenant_security` (`map_org_id`, `map_role_id`, `map_module_id`, `map_permission_id`),
  CONSTRAINT `fk_map_org_id`        FOREIGN KEY (`map_org_id`)        REFERENCES `org_info`          (`pk_org_id`)        ON DELETE CASCADE,
  CONSTRAINT `fk_map_role_id`       FOREIGN KEY (`map_role_id`)       REFERENCES `role_master`       (`pk_role_id`)       ON DELETE CASCADE,
  CONSTRAINT `fk_map_module_id`     FOREIGN KEY (`map_module_id`)     REFERENCES `module_master`     (`pk_module_id`)     ON DELETE CASCADE,
  CONSTRAINT `fk_map_permission_id` FOREIGN KEY (`map_permission_id`) REFERENCES `permission_master` (`pk_permission_id`) ON DELETE CASCADE
);

-- 6. User Directory Profile Table
CREATE TABLE `user_info` (
  `pk_user_id`       varchar(50) NOT NULL,
  `user_org_id`      varchar(50) NOT NULL,
  `user_name`        varchar(50) NOT NULL,
  `user_email`       varchar(50) NOT NULL UNIQUE,
  `user_role_id`     varchar(50) NOT NULL,
  `status`           varchar(10) NOT NULL DEFAULT 'ACTIVE', -- [ACTIVE, DISABLED]
  `created_datetime` datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user`     varchar(50)          DEFAULT NULL,
  `updated_datetime` datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user`     varchar(50)          DEFAULT NULL,
  PRIMARY KEY (`pk_user_id`),
  CONSTRAINT `fk_user_org_id`  FOREIGN KEY (`user_org_id`)  REFERENCES `org_info`    (`pk_org_id`)  ON DELETE CASCADE,
  CONSTRAINT `fk_user_role_id` FOREIGN KEY (`user_role_id`) REFERENCES `role_master` (`pk_role_id`) ON DELETE CASCADE
);
