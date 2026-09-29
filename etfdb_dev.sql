-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 06, 2026 at 03:36 AM
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
-- Table structure for table `loan_collection`
--

CREATE TABLE `loan_collection` (
  `pk_collection_id` varchar(50) NOT NULL,
  `collection_org_id` varchar(50) NOT NULL,
  `collection_loan_id` varchar(50) NOT NULL,
  `collection_user_id` varchar(50) NOT NULL,
  `collection_amount` decimal(15,2) NOT NULL,
  `collection_date` date NOT NULL DEFAULT (curdate()),
  `payment_mode` varchar(20) NOT NULL DEFAULT 'CASH',
  `reference_no` varchar(100) DEFAULT NULL,
  `collected_by_user_id` varchar(50) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'SUCCESS',
  `created_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user` varchar(50) DEFAULT NULL,
  `updated_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user` varchar(50) DEFAULT NULL
) ;

--
-- Dumping data for table `loan_collection`
--

INSERT INTO `loan_collection` (`pk_collection_id`, `collection_org_id`, `collection_loan_id`, `collection_user_id`, `collection_amount`, `collection_date`, `payment_mode`, `reference_no`, `collected_by_user_id`, `remarks`, `status`, `created_datetime`, `created_user`, `updated_datetime`, `updated_user`) VALUES
('COLL001', 'ORG001', 'LOAN001', 'USR001', '4453.25', '2026-08-01', 'UPI', 'UPI-TXN-98213', 'USR002', 'First EMI payment', 'SUCCESS', '2026-07-02 05:31:34', 'SYSTEM', '2026-07-02 05:31:34', 'SYSTEM');

-- --------------------------------------------------------

--
-- Table structure for table `loan_info`
--

CREATE TABLE `loan_info` (
  `pk_loan_id` varchar(50) NOT NULL,
  `loan_org_id` varchar(50) NOT NULL,
  `loan_user_id` varchar(50) NOT NULL,
  `loan_amount` decimal(15,2) NOT NULL,
  `interest_rate` decimal(5,2) NOT NULL DEFAULT '0.00',
  `tenure_months` int NOT NULL,
  `purpose` varchar(255) DEFAULT NULL,
  `application_date` date NOT NULL DEFAULT (curdate()),
  `approval_date` date DEFAULT NULL,
  `disbursement_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `outstanding_amount` decimal(15,2) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `created_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user` varchar(50) DEFAULT NULL,
  `updated_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user` varchar(50) DEFAULT NULL
) ;

--
-- Dumping data for table `loan_info`
--

INSERT INTO `loan_info` (`pk_loan_id`, `loan_org_id`, `loan_user_id`, `loan_amount`, `interest_rate`, `tenure_months`, `purpose`, `application_date`, `approval_date`, `disbursement_date`, `due_date`, `outstanding_amount`, `status`, `created_datetime`, `created_user`, `updated_datetime`, `updated_user`) VALUES
('LOAN001', 'ORG001', 'USR001', '50000.00', '12.50', 12, 'Personal loan', '2026-07-01', '2026-07-02', '2026-07-03', '2027-07-03', '50000.00', 'DISBURSED', '2026-07-02 05:26:22', 'SYSTEM', '2026-07-02 05:26:22', 'SYSTEM');

-- --------------------------------------------------------

--
-- Table structure for table `module_master`
--

CREATE TABLE `module_master` (
  `pk_module_id` varchar(50) NOT NULL,
  `module_name` varchar(50) NOT NULL,
  `module_code` varchar(50) NOT NULL,
  `created_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user` varchar(50) DEFAULT NULL,
  `updated_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `module_master`
--

INSERT INTO `module_master` (`pk_module_id`, `module_name`, `module_code`, `created_datetime`, `created_user`, `updated_datetime`, `updated_user`) VALUES
('MOD001', 'Loan Disbursement', 'LOAN_DISBURSEMENT', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MOD002', 'Collection', 'COLLECTION', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MOD003', 'Audit', 'AUDIT', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MOD004', 'Project Management', 'PROJECT_MANAGEMENT', '2026-06-27 18:16:25', 'JOSHEETHA', '2026-06-27 18:16:25', 'JOSHEETHA'),
('MOD005', 'Employee Management', 'EMPLOYEE_MANAGEMENT', '2026-06-27 18:16:25', 'JOSHEETHA', '2026-06-27 18:16:25', 'JOSHEETHA'),
('MOD007', 'Project Management', 'PROJECT MANAGEMENT', '2026-06-27 18:29:46', 'SANJAY', '2026-06-27 18:29:46', 'SANJAY'),
('MOD008', 'Employee Management', 'EMPLOYEE MANAGEMENT', '2026-06-27 18:29:46', 'SANJAY', '2026-06-27 18:29:46', 'SANJAY'),
('MOD009', 'Bug Tracking', 'BUG TRACKING', '2026-06-27 18:29:46', 'SANJAY', '2026-06-27 18:29:46', 'SANJAY'),
('MOD010', 'Shipment Management', 'SHIPMENT_MANAGEMENT', '2026-06-28 10:24:58', 'SRI RAM', '2026-06-28 10:24:58', 'SRI RAM'),
('MOD011', 'Warehouse Management', 'WAREHOUSE_MANAGEMENT', '2026-06-28 10:24:58', 'SRI RAM', '2026-06-28 10:24:58', 'SRI RAM'),
('MOD012', 'Inventory Management', 'INVENTORY_MANAGEMENT', '2026-06-28 10:24:58', 'SRI RAM', '2026-06-28 10:24:58', 'SRI RAM'),
('MOD013', 'Fleet Management', 'FLEET_MANAGEMENT', '2026-06-28 10:24:58', 'SRI RAM', '2026-06-28 10:24:58', 'SRI RAM'),
('MOD014', 'Customer KYC Management', 'CUSTOMER_KYC_MANAGEMENT', '2026-06-28 10:43:36', 'VARUN', '2026-06-28 10:43:36', 'VARUN'),
('MOD015', 'Credit Assessment', 'CREDIT_ASSESSMENT', '2026-06-28 10:43:36', 'VARUN', '2026-06-28 10:43:36', 'VARUN'),
('MOD016', 'EMI Management', 'EMI_MANAGEMENT', '2026-06-28 10:43:36', 'VARUN', '2026-06-28 10:43:36', 'VARUN'),
('MOD017', 'Loan Recovery Management', 'LOAN_RECOVERY_MANAGEMENT', '2026-06-28 10:43:36', 'VARUN', '2026-06-28 10:43:36', 'VARUN'),
('MOD018', 'Organization Management', 'ORGANIZATION_MANAGEMENT', '2026-06-28 16:41:46', 'Jeevika', '2026-06-28 16:41:46', 'Jeevika'),
('MOD019', 'Student Management', 'STUDENT_MANAGEMENT', '2026-06-28 16:46:19', 'KISHORE', '2026-06-28 16:46:19', 'KISHORE'),
('MOD020', 'Teacher Management', 'TEACHER_MANAGEMENT', '2026-06-28 16:46:19', 'KISHORE', '2026-06-28 16:46:19', 'KISHORE'),
('MOD021', 'Attendance Management', 'ATTENDANCE_MANAGEMENT', '2026-06-28 16:46:19', 'KISHORE', '2026-06-28 16:46:19', 'KISHORE'),
('MOD022', 'Examination Management', 'EXAMINATION_MANAGEMENT', '2026-06-28 16:46:19', 'KISHORE', '2026-06-28 16:46:19', 'KISHORE'),
('MOD023', 'Fee Management', 'FEE_MANAGEMENT', '2026-06-28 16:46:19', 'KISHORE', '2026-06-28 16:46:19', 'KISHORE');

-- --------------------------------------------------------

--
-- Table structure for table `org_info`
--

CREATE TABLE `org_info` (
  `pk_org_id` varchar(50) NOT NULL,
  `org_name` varchar(100) NOT NULL,
  `org_email` varchar(50) NOT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'ACTIVE',
  `created_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user` varchar(50) DEFAULT NULL,
  `updated_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `org_info`
--

INSERT INTO `org_info` (`pk_org_id`, `org_name`, `org_email`, `status`, `created_datetime`, `created_user`, `updated_datetime`, `updated_user`) VALUES
('ORG001', 'Madurai Finance', 'admin@maduraifinance.com', 'ACTIVE', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('ORG005', 'VARUN FINANCE COMPANY', 'varun@gmail.com', 'ACTIVE', '2026-06-26 14:57:56', 'VARUN', '2026-06-26 14:57:56', 'VARUN'),
('ORG006', 'Jo Technologies', 'jo@gmail.com', 'ACTIVE', '2026-06-25 16:45:30', 'JOSHEETHA', '2026-06-25 16:45:30', 'JOSHEETHA'),
('ORG007', 'Sanjay Software Pvt Ltd', 'Sanjay@gmail.com', 'ACTIVE', '2026-06-25 21:01:10', 'SANJAY', '2026-06-25 21:04:34', 'SANJAY'),
('org008', 'KISHORE SCHOOL MANAGEMENT', 'kishore@gmail.com', 'ACTIVE', '2026-06-26 15:12:29', 'KISHORE', '2026-06-26 15:12:29', 'KISHORE'),
('org009', 'SRIRAM_LOGISTICS', 'sriram@gmail.com', 'ACTIVE', '2026-06-26 15:34:40', 'SRI RAM', '2026-06-26 15:34:40', 'SRI RAM'),
('ORG025', 'Jeevika Technologies', 'jeevika25s@gmail.com', 'ACTIVE', '2026-06-28 15:45:08', 'Jeevika', '2026-06-28 15:45:08', 'Jeevika');

-- --------------------------------------------------------

--
-- Table structure for table `permission_master`
--

CREATE TABLE `permission_master` (
  `pk_permission_id` varchar(50) NOT NULL,
  `permission_name` varchar(50) NOT NULL,
  `permission_code` varchar(50) NOT NULL,
  `created_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user` varchar(50) DEFAULT NULL,
  `updated_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `permission_master`
--

INSERT INTO `permission_master` (`pk_permission_id`, `permission_name`, `permission_code`, `created_datetime`, `created_user`, `updated_datetime`, `updated_user`) VALUES
('PERM001', 'View', 'VIEW', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('PERM002', 'Create', 'CREATE', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('PERM003', 'Approve', 'APPROVE', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('PERM004', 'Disburse', 'DISBURSE', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('PERM005', 'Collect', 'COLLECT', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('PERM006', 'Receive', 'RECEIVE', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('PERM007', 'Monitor', 'MONITOR', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('PERM008', 'Assign Task', 'ASSIGN TASK', '2026-06-27 18:31:14', 'SANJAY', '2026-06-27 18:35:48', 'SANJAY'),
('PERM009', 'Submit Code', 'SUBMIT CODE', '2026-06-27 18:31:14', 'SANJAY', '2026-06-27 18:35:59', 'SANJAY'),
('PERM010', 'Review Code', 'REVIEW CODE', '2026-06-27 18:31:14', 'SANJAY', '2026-06-27 18:36:07', 'SANJAY'),
('PERM011', 'Deploy Build', 'DEPLOY BUILD', '2026-06-27 18:31:14', 'SANJAY', '2026-06-27 18:36:16', 'SANJAY'),
('PERM101', 'Manage Projects', 'MANAGE_PROJECTS', '2026-06-27 18:30:17', 'JOSHEETHA', '2026-06-27 18:30:17', 'JOSHEETHA'),
('PERM102', 'Develop Software', 'DEVELOP_SOFTWARE', '2026-06-27 18:30:17', 'JOSHEETHA', '2026-06-27 18:30:17', 'JOSHEETHA'),
('PERM103', 'Test Applications', 'TEST_APPLICATIONS', '2026-06-27 18:30:17', 'JOSHEETHA', '2026-06-27 18:30:17', 'JOSHEETHA'),
('PERM104', 'Deploy Applications', 'DEPLOY_APPLICATIONS', '2026-06-27 18:30:17', 'JOSHEETHA', '2026-06-27 18:30:17', 'JOSHEETHA'),
('PERM105', 'Track Shipment', 'TRACK_SHIPMENT', '2026-06-28 10:24:17', 'SRI RAM', '2026-06-28 10:24:17', 'SRI RAM'),
('PERM106', 'Manage Inventory', 'MANAGE_INVENTORY', '2026-06-28 10:24:17', 'SRI RAM', '2026-06-28 10:24:17', 'SRI RAM'),
('PERM107', 'Assign Delivery', 'ASSIGN_DELIVERY', '2026-06-28 10:24:17', 'SRI RAM', '2026-06-28 10:24:17', 'SRI RAM'),
('PERM108', 'Manage Fleet', 'MANAGE_FLEET', '2026-06-28 10:24:17', 'SRI RAM', '2026-06-28 10:24:17', 'SRI RAM'),
('PERM109', 'Verify Customer KYC', 'VERIFY_KYC', '2026-06-28 10:38:16', 'VARUN', '2026-06-28 10:38:16', 'VARUN'),
('PERM110', 'Approve Credit Limit', 'APPROVE_CREDIT_LIMIT', '2026-06-28 10:38:16', 'VARUN', '2026-06-28 10:38:16', 'VARUN'),
('PERM111', 'Generate EMI Schedule', 'GENERATE_EMI_SCHEDULE', '2026-06-28 10:38:16', 'VARUN', '2026-06-28 10:38:16', 'VARUN'),
('PERM112', 'Process Loan Closure', 'PROCESS_LOAN_CLOSURE', '2026-06-28 10:38:16', 'VARUN', '2026-06-28 10:38:16', 'VARUN'),
('PERM113', 'View Credit Report', 'VIEW_CREDIT_REPORT', '2026-06-28 10:38:16', 'VARUN', '2026-06-28 10:38:16', 'VARUN'),
('PERM114', 'Update Customer Risk Score', 'UPDATE_RISK_SCORE', '2026-06-28 10:38:16', 'VARUN', '2026-06-28 10:38:16', 'VARUN'),
('PERM115', 'Manage Students', 'MANAGE_STUDENTS', '2026-06-28 16:45:38', 'KISHORE', '2026-06-28 16:45:38', 'KISHORE'),
('PERM116', 'Manage Teachers', 'MANAGE_TEACHERS', '2026-06-28 16:45:38', 'KISHORE', '2026-06-28 16:45:38', 'KISHORE'),
('PERM117', 'Manage Attendance', 'MANAGE_ATTENDANCE', '2026-06-28 16:45:38', 'KISHORE', '2026-06-28 16:45:38', 'KISHORE'),
('PERM118', 'Manage Exams', 'MANAGE_EXAMS', '2026-06-28 16:45:38', 'KISHORE', '2026-06-28 16:45:38', 'KISHORE'),
('PERM119', 'Manage Fees', 'MANAGE_FEES', '2026-06-28 16:45:38', 'KISHORE', '2026-06-28 16:45:38', 'KISHORE'),
('PERM122', 'Delete Organization', 'DELETE_ORGANIZATION', '2026-06-28 16:49:23', 'Jeevika', '2026-06-28 16:49:23', 'Jeevika'),
('PERM123', 'Update Organization', 'UPDATE_ORGANIZATION', '2026-06-28 16:48:37', 'Jeevika', '2026-06-28 16:48:37', 'Jeevika'),
('PERM124', 'View Organization', 'VIEW_ORGANIZATION', '2026-06-28 16:47:32', 'Jeevika', '2026-06-28 16:47:32', 'Jeevika'),
('PERM125', 'Create Organization', 'CREATE_ORGANIZATION', '2026-06-28 16:46:07', 'Jeevika', '2026-06-28 16:46:07', 'Jeevika');

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
('ROLE030', 'ORG008', 'Receptionist', 'Handles admissions and visitor enquiries', 'ACTIVE', '2026-06-28 16:43:41', 'KISHORE', '2026-06-28 16:43:41', 'KISHORE');

-- --------------------------------------------------------

--
-- Table structure for table `role_permission_mapping`
--

CREATE TABLE `role_permission_mapping` (
  `pk_mapping_id` varchar(50) NOT NULL,
  `map_org_id` varchar(50) NOT NULL,
  `map_role_id` varchar(50) NOT NULL,
  `map_module_id` varchar(50) NOT NULL,
  `map_permission_id` varchar(50) NOT NULL,
  `created_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user` varchar(50) DEFAULT NULL,
  `updated_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `role_permission_mapping`
--

INSERT INTO `role_permission_mapping` (`pk_mapping_id`, `map_org_id`, `map_role_id`, `map_module_id`, `map_permission_id`, `created_datetime`, `created_user`, `updated_datetime`, `updated_user`) VALUES
('MAP001', 'ORG001', 'ROLE001', 'MOD001', 'PERM001', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP002', 'ORG001', 'ROLE001', 'MOD001', 'PERM002', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP003', 'ORG001', 'ROLE001', 'MOD001', 'PERM003', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP004', 'ORG001', 'ROLE001', 'MOD001', 'PERM004', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP005', 'ORG001', 'ROLE001', 'MOD003', 'PERM001', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP006', 'ORG001', 'ROLE002', 'MOD002', 'PERM001', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP007', 'ORG001', 'ROLE002', 'MOD002', 'PERM005', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP008', 'ORG001', 'ROLE002', 'MOD003', 'PERM001', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP009', 'ORG001', 'ROLE003', 'MOD001', 'PERM001', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP010', 'ORG001', 'ROLE003', 'MOD001', 'PERM006', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP011', 'ORG001', 'ROLE003', 'MOD002', 'PERM001', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP012', 'ORG001', 'ROLE004', 'MOD001', 'PERM001', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP013', 'ORG001', 'ROLE004', 'MOD001', 'PERM007', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP014', 'ORG001', 'ROLE004', 'MOD002', 'PERM001', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP015', 'ORG001', 'ROLE004', 'MOD002', 'PERM007', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP016', 'ORG001', 'ROLE004', 'MOD003', 'PERM001', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM'),
('MAP017', 'ORG001', 'ROLE004', 'MOD003', 'PERM007', '2026-06-24 06:06:42', 'SYSTEM', '2026-06-24 06:06:42', 'SYSTEM');

-- --------------------------------------------------------

--
-- Table structure for table `user_info`
--

CREATE TABLE `user_info` (
  `pk_user_id` varchar(50) NOT NULL,
  `user_org_id` varchar(50) NOT NULL,
  `user_name` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `user_email` varchar(50) NOT NULL,
  `user_role_id` varchar(50) NOT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'ACTIVE',
  `created_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_user` varchar(50) DEFAULT NULL,
  `updated_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_user` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `user_info`
--

INSERT INTO `user_info` (`pk_user_id`, `user_org_id`, `user_name`, `password`, `user_email`, `user_role_id`, `status`, `created_datetime`, `created_user`, `updated_datetime`, `updated_user`) VALUES
('USR001', 'ORG001', 'Ravi Kumar', 'test', 'ravi.kumar@maduraifinance.com', 'ROLE001', 'ACTIVE', '2026-06-24 06:06:42', 'SYSTEM', '2026-07-02 04:18:40', 'SYSTEM'),
('USR002', 'ORG001', 'Priya Devi', 'test', 'priya.devi@maduraifinance.com', 'ROLE002', 'ACTIVE', '2026-06-24 06:06:42', 'SYSTEM', '2026-07-02 04:18:44', 'SYSTEM'),
('USR003', 'ORG001', 'Murugan K', 'test', 'murugan.k@maduraifinance.com', 'ROLE003', 'ACTIVE', '2026-06-24 06:06:42', 'SYSTEM', '2026-07-02 04:18:51', 'SYSTEM'),
('USR004', 'ORG001', 'Suresh V', 'test', 'suresh.v@maduraifinance.com', 'ROLE004', 'ACTIVE', '2026-06-24 06:06:42', 'SYSTEM', '2026-07-02 04:18:54', 'SYSTEM'),
('USR005', 'ORG007', 'Sanjay', 'test', 'sanjay@sanjaysoftware.com', 'ROLE005', 'ACTIVE', '2026-06-30 15:35:43', 'SANJAY', '2026-07-02 04:19:17', 'SANJAY'),
('USR006', 'ORG007', 'Varun', 'test', 'Varin@sanjaysoftware.com', 'ROLE006', 'ACTIVE', '2026-06-30 15:35:43', 'SANJAY', '2026-07-02 04:19:17', 'SANJAY'),
('USR007', 'ORG007', 'Josheetha', 'test', 'Jo@sanjaysoftware.com', 'ROLE007', 'ACTIVE', '2026-06-30 15:35:43', 'SANJAY', '2026-07-02 04:19:17', 'SANJAY'),
('USR008', 'ORG007', 'Joseph Vijay', 'test', 'Vijay@sanjaysoftware.com', 'ROLE008', 'ACTIVE', '2026-06-30 15:35:43', 'SANJAY', '2026-07-02 04:19:17', 'SANJAY'),
('USR009', 'ORG005', 'Aarav Sharma', 'test', 'aarav.sharma@gmail.com', 'ROLE019', 'ACTIVE', '2026-07-02 15:12:17', 'VARUN', '2026-07-02 15:12:42', NULL),
('USR010', 'ORG005', 'Priya Nair', 'test', 'priya.nair@gmail.com', 'ROLE020', 'ACTIVE', '2026-07-02 15:12:17', 'VARUN', '2026-07-02 15:12:55', NULL),
('USR011', 'ORG005', 'Rohan Verma', 'test', 'rohan.verma@gmail.com', 'ROLE021', 'ACTIVE', '2026-07-02 15:12:17', 'VARUN', '2026-07-02 15:13:24', NULL),
('USR012', 'ORG005', 'Ananya Reddy', 'test', 'ananya.reddy@gmail.com', 'ROLE022', 'ACTIVE', '2026-07-02 15:12:17', 'VARUN', '2026-07-02 15:13:32', NULL);

--
-- Indexes for dumped tables
--

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
-- Indexes for table `loan_info`
--
ALTER TABLE `loan_info`
  ADD PRIMARY KEY (`pk_loan_id`),
  ADD KEY `fk_loan_org_id` (`loan_org_id`),
  ADD KEY `fk_loan_user_id` (`loan_user_id`),
  ADD KEY `idx_loan_status` (`status`);

--
-- Indexes for table `module_master`
--
ALTER TABLE `module_master`
  ADD PRIMARY KEY (`pk_module_id`),
  ADD UNIQUE KEY `module_code` (`module_code`);

--
-- Indexes for table `org_info`
--
ALTER TABLE `org_info`
  ADD PRIMARY KEY (`pk_org_id`);

--
-- Indexes for table `permission_master`
--
ALTER TABLE `permission_master`
  ADD PRIMARY KEY (`pk_permission_id`),
  ADD UNIQUE KEY `permission_code` (`permission_code`);

--
-- Indexes for table `role_master`
--
ALTER TABLE `role_master`
  ADD PRIMARY KEY (`pk_role_id`),
  ADD KEY `fk_role_org_id` (`role_org_id`);

--
-- Indexes for table `role_permission_mapping`
--
ALTER TABLE `role_permission_mapping`
  ADD PRIMARY KEY (`pk_mapping_id`),
  ADD UNIQUE KEY `uk_tenant_security` (`map_org_id`,`map_role_id`,`map_module_id`,`map_permission_id`),
  ADD KEY `fk_map_role_id` (`map_role_id`),
  ADD KEY `fk_map_module_id` (`map_module_id`),
  ADD KEY `fk_map_permission_id` (`map_permission_id`);

--
-- Indexes for table `user_info`
--
ALTER TABLE `user_info`
  ADD PRIMARY KEY (`pk_user_id`),
  ADD UNIQUE KEY `user_email` (`user_email`),
  ADD KEY `fk_user_org_id` (`user_org_id`),
  ADD KEY `fk_user_role_id` (`user_role_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `loan_collection`
--
ALTER TABLE `loan_collection`
  ADD CONSTRAINT `fk_collected_by_user_id` FOREIGN KEY (`collected_by_user_id`) REFERENCES `user_info` (`pk_user_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_collection_loan_id` FOREIGN KEY (`collection_loan_id`) REFERENCES `loan_info` (`pk_loan_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_collection_org_id` FOREIGN KEY (`collection_org_id`) REFERENCES `org_info` (`pk_org_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_collection_user_id` FOREIGN KEY (`collection_user_id`) REFERENCES `user_info` (`pk_user_id`) ON DELETE CASCADE;

--
-- Constraints for table `loan_info`
--
ALTER TABLE `loan_info`
  ADD CONSTRAINT `fk_loan_org_id` FOREIGN KEY (`loan_org_id`) REFERENCES `org_info` (`pk_org_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_loan_user_id` FOREIGN KEY (`loan_user_id`) REFERENCES `user_info` (`pk_user_id`) ON DELETE CASCADE;

--
-- Constraints for table `role_master`
--
ALTER TABLE `role_master`
  ADD CONSTRAINT `fk_role_org_id` FOREIGN KEY (`role_org_id`) REFERENCES `org_info` (`pk_org_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `role_permission_mapping`
--
ALTER TABLE `role_permission_mapping`
  ADD CONSTRAINT `fk_map_module_id` FOREIGN KEY (`map_module_id`) REFERENCES `module_master` (`pk_module_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_map_org_id` FOREIGN KEY (`map_org_id`) REFERENCES `org_info` (`pk_org_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_map_permission_id` FOREIGN KEY (`map_permission_id`) REFERENCES `permission_master` (`pk_permission_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_map_role_id` FOREIGN KEY (`map_role_id`) REFERENCES `role_master` (`pk_role_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_info`
--
ALTER TABLE `user_info`
  ADD CONSTRAINT `fk_user_org_id` FOREIGN KEY (`user_org_id`) REFERENCES `org_info` (`pk_org_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_user_role_id` FOREIGN KEY (`user_role_id`) REFERENCES `role_master` (`pk_role_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
