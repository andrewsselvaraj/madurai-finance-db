-- --------------------------------------------------------
-- New table: loan_info
-- Purpose: Organization gives a loan to a user (borrower)
-- Follows conventions of etfdb_dev.sql (varchar(50) prefixed PKs,
-- org_info / user_info FKs, standard audit columns)
-- --------------------------------------------------------

--
-- Table structure for table `loan_info`
--

CREATE TABLE `loan_info` (
  `pk_loan_id` varchar(50) NOT NULL,
  `loan_org_id` varchar(50) NOT NULL,
  `loan_user_id` varchar(50) NOT NULL,
  `loan_amount` decimal(15,2) NOT NULL,
  `interest_rate` decimal(5,2) NOT NULL DEFAULT 0.00,
  `tenure_months` int NOT NULL,
  `purpose` varchar(255) DEFAULT NULL,
  `application_date` date NOT NULL DEFAULT (CURRENT_DATE),
  `approval_date` date DEFAULT NULL,
  `disbursement_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `outstanding_amount` decimal(15,2) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `created_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user` varchar(50) DEFAULT NULL,
  `updated_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for table `loan_info`
--
ALTER TABLE `loan_info`
  ADD PRIMARY KEY (`pk_loan_id`),
  ADD KEY `fk_loan_org_id` (`loan_org_id`),
  ADD KEY `fk_loan_user_id` (`loan_user_id`),
  ADD KEY `idx_loan_status` (`status`);

--
-- Constraints for table `loan_info`
--
ALTER TABLE `loan_info`
  ADD CONSTRAINT `fk_loan_org_id` FOREIGN KEY (`loan_org_id`) REFERENCES `org_info` (`pk_org_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_loan_user_id` FOREIGN KEY (`loan_user_id`) REFERENCES `user_info` (`pk_user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chk_loan_status` CHECK (`status` IN ('PENDING','APPROVED','DISBURSED','CLOSED','REJECTED'));

--
-- Sample data (optional — remove if not needed)
--
-- INSERT INTO `loan_info`
--   (`pk_loan_id`, `loan_org_id`, `loan_user_id`, `loan_amount`, `interest_rate`,
--    `tenure_months`, `purpose`, `application_date`, `approval_date`,
--    `disbursement_date`, `due_date`, `outstanding_amount`, `status`,
--    `created_user`, `updated_user`)
-- VALUES
--   ('LOAN001', 'ORG001', 'USR001', 50000.00, 12.50, 12, 'Personal loan',
--    '2026-07-01', '2026-07-02', '2026-07-03', '2027-07-03', 50000.00, 'DISBURSED',
--    'SYSTEM', 'SYSTEM');
