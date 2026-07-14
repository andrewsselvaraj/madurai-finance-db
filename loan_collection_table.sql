-- --------------------------------------------------------
-- New table: loan_collection
-- Purpose: Record amounts collected from a customer against a loan
-- Follows conventions of etfdb_dev.sql (varchar(50) prefixed PKs,
-- org_info / user_info / loan_info FKs, standard audit columns)
-- --------------------------------------------------------

--
-- Table structure for table `loan_collection`
--

CREATE TABLE `loan_collection` (
  `pk_collection_id` varchar(50) NOT NULL,
  `collection_org_id` varchar(50) NOT NULL,
  `collection_loan_id` varchar(50) NOT NULL,
  `collection_user_id` varchar(50) NOT NULL,
  `collection_amount` decimal(15,2) NOT NULL,
  `collection_date` date NOT NULL DEFAULT (CURRENT_DATE),
  `payment_mode` varchar(20) NOT NULL DEFAULT 'CASH',
  `reference_no` varchar(100) DEFAULT NULL,
  `collected_by_user_id` varchar(50) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'SUCCESS',
  `created_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user` varchar(50) DEFAULT NULL,
  `updated_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for table `loan_collection`
--
ALTER TABLE `loan_collection`
  ADD PRIMARY KEY (`pk_collection_id`),
  ADD KEY `fk_collection_org_id` (`collection_org_id`),
  ADD KEY `fk_collection_loan_id` (`collection_loan_id`),
  ADD KEY `fk_collection_user_id` (`collection_user_id`),
  ADD KEY `fk_collected_by_user_id` (`collected_by_user_id`),
  ADD KEY `idx_collection_status` (`status`),
  ADD KEY `idx_collection_date` (`collection_date`);

--
-- Constraints for table `loan_collection`
--
ALTER TABLE `loan_collection`
  ADD CONSTRAINT `fk_collection_org_id` FOREIGN KEY (`collection_org_id`) REFERENCES `org_info` (`pk_org_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_collection_loan_id` FOREIGN KEY (`collection_loan_id`) REFERENCES `loan_info` (`pk_loan_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_collection_user_id` FOREIGN KEY (`collection_user_id`) REFERENCES `user_info` (`pk_user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_collected_by_user_id` FOREIGN KEY (`collected_by_user_id`) REFERENCES `user_info` (`pk_user_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `chk_collection_payment_mode` CHECK (`payment_mode` IN ('CASH','UPI','BANK_TRANSFER','CHEQUE','CARD')),
  ADD CONSTRAINT `chk_collection_status` CHECK (`status` IN ('SUCCESS','PENDING','FAILED','REVERSED'));
