-- --------------------------------------------------------
-- Run once against etfdb_dev (after etfdb_dev.sql, loan_info_table.sql,
-- loan_collection_table.sql) before starting the API with the "mysql" profile.
-- Adds what the Spring Boot app needs beyond the original schema.
-- --------------------------------------------------------

-- 1. Audit trail (was kept in browser localStorage by the old demo app)
CREATE TABLE IF NOT EXISTS `audit_log` (
  `pk_audit_id` varchar(50) NOT NULL,
  `audit_org_id` varchar(50) NOT NULL,
  `audit_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `audit_user_id` varchar(50) DEFAULT NULL,
  `audit_user_name` varchar(50) DEFAULT NULL,
  `action` varchar(50) NOT NULL,
  `details` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`pk_audit_id`),
  KEY `idx_audit_org_datetime` (`audit_org_id`, `audit_datetime`),
  CONSTRAINT `fk_audit_org_id` FOREIGN KEY (`audit_org_id`) REFERENCES `org_info` (`pk_org_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. Customer "Acknowledge Receipt" of a disbursed loan
ALTER TABLE `loan_info` ADD COLUMN `received_date` date DEFAULT NULL AFTER `outstanding_amount`;

-- 3. Data Entry Operator role for ORG001 (VIEW + CREATE on Loan Disbursement)
INSERT IGNORE INTO `role_master` (`pk_role_id`, `role_org_id`, `role_name`, `role_description`, `status`, `created_user`, `updated_user`) VALUES
('ROLE060', 'ORG001', 'Data Entry Operator', 'Registers new customers and submits loan applications for review', 'ACTIVE', 'SYSTEM', 'SYSTEM');

INSERT IGNORE INTO `role_permission_mapping` (`pk_mapping_id`, `map_org_id`, `map_role_id`, `map_module_id`, `map_permission_id`, `created_user`, `updated_user`) VALUES
('MAP018', 'ORG001', 'ROLE060', 'MOD001', 'PERM001', 'SYSTEM', 'SYSTEM'),
('MAP019', 'ORG001', 'ROLE060', 'MOD001', 'PERM002', 'SYSTEM', 'SYSTEM');

INSERT IGNORE INTO `user_info` (`pk_user_id`, `user_org_id`, `user_name`, `password`, `user_email`, `user_role_id`, `status`, `created_user`, `updated_user`) VALUES
('USR020', 'ORG001', 'Kavitha M', 'test', 'kavitha.m@maduraifinance.com', 'ROLE060', 'ACTIVE', 'SYSTEM', 'SYSTEM');
