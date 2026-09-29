-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 13, 2026 at 07:17 AM
-- Server version: 8.0.44-0ubuntu0.22.04.1
-- PHP Version: 8.1.2-1ubuntu2.22

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `etfdb_dev`
--

-- --------------------------------------------------------

--
-- Table structure for table `role_master`
--

CREATE TABLE `role_master` (
  `pk_role_id` varchar(50) NOT NULL,
  `role_org_id` varchar(50) NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `role_description` varchar(255) DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'ACTIVE',
  `created_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user` varchar(50) DEFAULT NULL,
  `updated_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `role_master`
--

INSERT INTO `role_master` (`pk_role_id`, `role_org_id`, `role_name`, `role_description`, `status`, `created_datetime`, `created_user`, `updated_datetime`, `updated_user`) VALUES
('ROLE001', 'ORG001', 'Financier', 'Approves and disburses loans to customers', 'ACTIVE', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('ROLE002', 'ORG001', 'Collection Agent', 'Collects repayments from customers', 'ACTIVE', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('ROLE003', 'ORG001', 'Customer', 'Receives loan amount from Financier', 'ACTIVE', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('ROLE004', 'ORG001', 'Security', 'Monitors legal and illegal financial activities', 'ACTIVE', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('ROLE005', 'ORG007', 'Administrator', 'Manages the entire system', 'ACTIVE', '2026-06-27 18:28:00', 'SANJAY', '2026-06-27 18:28:00', 'SANJAY'),
('ROLE006', 'ORG007', 'Project Manager', 'Manages software projects', 'ACTIVE', '2026-06-27 18:28:00', 'SANJAY', '2026-06-27 18:28:00', 'SANJAY'),
('ROLE007', 'ORG007', 'Software Developer', 'Develops and maintains applications', 'ACTIVE', '2026-06-27 18:28:00', 'SANJAY', '2026-06-27 18:28:00', 'SANJAY'),
('ROLE008', 'ORG007', 'QA Engineer', 'Tests software and ensures quality', 'ACTIVE', '2026-06-27 18:28:00', 'SANJAY', '2026-06-27 18:28:00', 'SANJAY'),
('ROLE010', 'ORG006', 'Project Manager', 'Plans and manages software development projects', 'ACTIVE', '2026-06-27 18:32:37', 'JOSHEETHA', '2026-06-27 18:39:34', 'JOSHEETHA'),
('ROLE011', 'ORG006', 'Software Developer', 'Develops and maintains software applications', 'ACTIVE', '2026-06-27 18:32:37', 'JOSHEETHA', '2026-06-27 18:39:57', 'JOSHEETHA'),
('ROLE013', 'ORG006', 'UI/UX Designer', 'Designs user interfaces and improves user experience', 'ACTIVE', '2026-06-27 18:32:37', 'JOSHEETHA', '2026-06-27 18:40:14', 'JOSHEETHA'),
('ROLE014', 'ORG006', 'DevOps Engineer', 'Handles deployment, CI/CD, and cloud infrastructure', 'ACTIVE', '2026-06-27 18:32:37', 'JOSHEETHA', '2026-06-27 18:40:27', 'JOSHEETHA'),
('ROLE015', 'org009', 'Logistics Manager', 'Manages logistics operations', 'ACTIVE', '2026-06-28 10:22:59', 'SRI RAM', '2026-06-28 10:22:59', 'SRI RAM'),
('ROLE016', 'org009', 'Warehouse Supervisor', 'Supervises warehouse activities', 'ACTIVE', '2026-06-28 10:22:59', 'SRI RAM', '2026-06-28 10:22:59', 'SRI RAM'),
('ROLE017', 'org009', 'Delivery Executive', 'Delivers shipments to customers', 'ACTIVE', '2026-06-28 10:22:59', 'SRI RAM', '2026-06-28 10:22:59', 'SRI RAM'),
('ROLE018', 'org009', 'Inventory Manager', 'Maintains inventory records', 'ACTIVE', '2026-06-28 10:22:59', 'SRI RAM', '2026-06-28 10:22:59', 'SRI RAM'),
('ROLE019', 'ORG005', 'Credit Risk Analyst', 'Evaluates loan applications and assesses customer credit risk.', 'ACTIVE', '2026-06-28 10:34:51', 'VARUN', '2026-06-28 10:34:51', 'VARUN'),
('ROLE020', 'ORG005', 'Loan Processing Officer', 'Processes loan applications and verifies required documents.', 'ACTIVE', '2026-06-28 10:34:51', 'VARUN', '2026-06-28 10:34:51', 'VARUN'),
('ROLE021', 'ORG005', 'Recovery Executive', 'Handles overdue loan collections and customer follow-up.', 'ACTIVE', '2026-06-28 10:34:51', 'VARUN', '2026-06-28 10:34:51', 'VARUN'),
('ROLE022', 'ORG005', 'Branch Operations Manager', 'Supervises daily branch operations and staff performance.', 'ACTIVE', '2026-06-28 10:34:51', 'VARUN', '2026-06-28 10:34:51', 'VARUN'),
('ROLE023', 'ORG025', 'Software Developer', 'Develops and maintains software applications.', 'ACTIVE', '2026-06-28 16:17:22', 'Jeevika', '2026-06-28 16:17:22', 'Jeevika'),
('ROLE024', 'ORG025', 'Project Manager', 'Manages software development projects.', 'ACTIVE', '2026-06-28 16:16:14', 'Jeevika', '2026-06-28 16:16:14', 'Jeevika'),
('ROLE025', 'ORG025', 'Administrator', 'Manages the entire organization and users.', 'ACTIVE', '2026-06-28 16:14:40', 'Jeevika', '2026-06-28 16:14:40', 'Jeevika'),
('ROLE026', 'ORG025', 'QA Engineer', 'Tests software and ensures application quality.', 'ACTIVE', '2026-06-28 16:18:18', 'Jeevika', '2026-06-28 16:18:18', 'Jeevika'),
('ROLE027', 'ORG008', 'Principal', 'Manages the entire school', 'ACTIVE', '2026-06-28 16:43:41', 'KISHORE', '2026-06-28 16:43:41', 'KISHORE'),
('ROLE028', 'ORG008', 'Teacher', 'Teaches students and manages classes', 'ACTIVE', '2026-06-28 16:43:41', 'KISHORE', '2026-06-28 16:43:41', 'KISHORE'),
('ROLE029', 'ORG008', 'Accountant', 'Handles school fees and accounts', 'ACTIVE', '2026-06-28 16:43:41', 'KISHORE', '2026-06-28 16:43:41', 'KISHORE'),
('ROLE030', 'ORG008', 'Receptionist', 'Handles admissions and visitor enquiries', 'ACTIVE', '2026-06-28 16:43:41', 'KISHORE', '2026-06-28 16:43:41', 'KISHORE'),
('ROLE050', 'ORG046', 'HR Manager', 'Manages employee records and HR operations', 'ACTIVE', '2026-07-08 04:39:39', 'SHYAMSUNDAR', '2026-07-08 04:39:39', 'SHYAMSUNDAR'),
('ROLE051', 'ORG046', 'Team Lead', 'Leads development team and assigns tasks', 'ACTIVE', '2026-07-08 04:39:39', 'SHYAMSUNDAR', '2026-07-08 04:39:39', 'SHYAMSUNDAR'),
('ROLE052', 'ORG046', 'Software Engineer', 'Develops and maintains software applications', 'ACTIVE', '2026-07-08 04:39:39', 'SHYAMSUNDAR', '2026-07-08 04:39:39', 'SHYAMSUNDAR');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `role_master`
--
ALTER TABLE `role_master`
  ADD PRIMARY KEY (`pk_role_id`),
  ADD KEY `fk_role_org_id` (`role_org_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `role_master`
--
ALTER TABLE `role_master`
  ADD CONSTRAINT `fk_role_org_id` FOREIGN KEY (`role_org_id`) REFERENCES `org_info` (`pk_org_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
