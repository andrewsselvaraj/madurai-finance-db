-- ─────────────────────────────────────────────────────────────────
-- Madurai Finance - Seed Data
-- Created : 2026-06-24
-- ─────────────────────────────────────────────────────────────────

-- ─────────────────────────────────────────
-- 1. ORGANISATION
-- ─────────────────────────────────────────
INSERT INTO `org_info` (`pk_org_id`, `org_name`, `org_email`, `status`, `created_user`, `updated_user`)
VALUES ('ORG001', 'Madurai Finance', 'admin@maduraifinance.com', 'ACTIVE', 'SYSTEM', 'SYSTEM');


-- ─────────────────────────────────────────
-- 2. MODULES
-- ─────────────────────────────────────────
INSERT INTO `module_master` (`pk_module_id`, `module_name`, `module_code`, `created_user`, `updated_user`)
VALUES
  ('MOD001', 'Loan Disbursement', 'LOAN_DISBURSEMENT', 'SYSTEM', 'SYSTEM'),
  ('MOD002', 'Collection',        'COLLECTION',        'SYSTEM', 'SYSTEM'),
  ('MOD003', 'Audit',             'AUDIT',             'SYSTEM', 'SYSTEM');


-- ─────────────────────────────────────────
-- 3. PERMISSIONS
-- ─────────────────────────────────────────
INSERT INTO `permission_master` (`pk_permission_id`, `permission_name`, `permission_code`, `created_user`, `updated_user`)
VALUES
  ('PERM001', 'View',     'VIEW',     'SYSTEM', 'SYSTEM'),
  ('PERM002', 'Create',   'CREATE',   'SYSTEM', 'SYSTEM'),
  ('PERM003', 'Approve',  'APPROVE',  'SYSTEM', 'SYSTEM'),
  ('PERM004', 'Disburse', 'DISBURSE', 'SYSTEM', 'SYSTEM'),
  ('PERM005', 'Collect',  'COLLECT',  'SYSTEM', 'SYSTEM'),
  ('PERM006', 'Receive',  'RECEIVE',  'SYSTEM', 'SYSTEM'),
  ('PERM007', 'Monitor',  'MONITOR',  'SYSTEM', 'SYSTEM');


-- ─────────────────────────────────────────
-- 4. ROLES
-- ─────────────────────────────────────────
INSERT INTO `role_master` (`pk_role_id`, `role_org_id`, `role_name`, `role_description`, `status`, `created_user`, `updated_user`)
VALUES
  ('ROLE001', 'ORG001', 'Financier',        'Approves and disburses loans to customers',       'ACTIVE', 'SYSTEM', 'SYSTEM'),
  ('ROLE002', 'ORG001', 'Collection Agent', 'Collects repayments from customers',              'ACTIVE', 'SYSTEM', 'SYSTEM'),
  ('ROLE003', 'ORG001', 'Customer',         'Receives loan amount from Financier',             'ACTIVE', 'SYSTEM', 'SYSTEM'),
  ('ROLE004', 'ORG001', 'Security',         'Monitors legal and illegal financial activities', 'ACTIVE', 'SYSTEM', 'SYSTEM');


-- ─────────────────────────────────────────
-- 5. ROLE PERMISSION MAPPING
-- ─────────────────────────────────────────

INSERT INTO `role_permission_mapping` (`pk_mapping_id`, `map_org_id`, `map_role_id`, `map_module_id`, `map_permission_id`, `created_user`, `updated_user`)
VALUES
  -- Financier → Loan Disbursement (VIEW, CREATE, APPROVE, DISBURSE)
  ('MAP001', 'ORG001', 'ROLE001', 'MOD001', 'PERM001', 'SYSTEM', 'SYSTEM'),  -- VIEW
  ('MAP002', 'ORG001', 'ROLE001', 'MOD001', 'PERM002', 'SYSTEM', 'SYSTEM'),  -- CREATE
  ('MAP003', 'ORG001', 'ROLE001', 'MOD001', 'PERM003', 'SYSTEM', 'SYSTEM'),  -- APPROVE
  ('MAP004', 'ORG001', 'ROLE001', 'MOD001', 'PERM004', 'SYSTEM', 'SYSTEM'),  -- DISBURSE
  -- Financier → Audit (VIEW)
  ('MAP005', 'ORG001', 'ROLE001', 'MOD003', 'PERM001', 'SYSTEM', 'SYSTEM'),  -- VIEW

  -- Collection Agent → Collection (VIEW, COLLECT)
  ('MAP006', 'ORG001', 'ROLE002', 'MOD002', 'PERM001', 'SYSTEM', 'SYSTEM'),  -- VIEW
  ('MAP007', 'ORG001', 'ROLE002', 'MOD002', 'PERM005', 'SYSTEM', 'SYSTEM'),  -- COLLECT
  -- Collection Agent → Audit (VIEW)
  ('MAP008', 'ORG001', 'ROLE002', 'MOD003', 'PERM001', 'SYSTEM', 'SYSTEM'),  -- VIEW

  -- Customer → Loan Disbursement (VIEW, RECEIVE)
  ('MAP009', 'ORG001', 'ROLE003', 'MOD001', 'PERM001', 'SYSTEM', 'SYSTEM'),  -- VIEW
  ('MAP010', 'ORG001', 'ROLE003', 'MOD001', 'PERM006', 'SYSTEM', 'SYSTEM'),  -- RECEIVE
  -- Customer → Collection (VIEW)
  ('MAP011', 'ORG001', 'ROLE003', 'MOD002', 'PERM001', 'SYSTEM', 'SYSTEM'),  -- VIEW

  -- Security → Loan Disbursement (VIEW, MONITOR)
  ('MAP012', 'ORG001', 'ROLE004', 'MOD001', 'PERM001', 'SYSTEM', 'SYSTEM'),  -- VIEW
  ('MAP013', 'ORG001', 'ROLE004', 'MOD001', 'PERM007', 'SYSTEM', 'SYSTEM'),  -- MONITOR
  -- Security → Collection (VIEW, MONITOR)
  ('MAP014', 'ORG001', 'ROLE004', 'MOD002', 'PERM001', 'SYSTEM', 'SYSTEM'),  -- VIEW
  ('MAP015', 'ORG001', 'ROLE004', 'MOD002', 'PERM007', 'SYSTEM', 'SYSTEM'),  -- MONITOR
  -- Security → Audit (VIEW, MONITOR)
  ('MAP016', 'ORG001', 'ROLE004', 'MOD003', 'PERM001', 'SYSTEM', 'SYSTEM'),  -- VIEW
  ('MAP017', 'ORG001', 'ROLE004', 'MOD003', 'PERM007', 'SYSTEM', 'SYSTEM');  -- MONITOR


-- ─────────────────────────────────────────
-- 6. SAMPLE USERS (one per role)
-- ─────────────────────────────────────────
INSERT INTO `user_info` (`pk_user_id`, `user_org_id`, `user_name`, `user_email`, `user_role_id`, `status`, `created_user`, `updated_user`)
VALUES
  ('USR001', 'ORG001', 'Ravi Kumar', 'ravi.kumar@maduraifinance.com', 'ROLE001', 'ACTIVE', 'SYSTEM', 'SYSTEM'),
  ('USR002', 'ORG001', 'Priya Devi', 'priya.devi@maduraifinance.com', 'ROLE002', 'ACTIVE', 'SYSTEM', 'SYSTEM'),
  ('USR003', 'ORG001', 'Murugan K',  'murugan.k@maduraifinance.com',  'ROLE003', 'ACTIVE', 'SYSTEM', 'SYSTEM'),
  ('USR004', 'ORG001', 'Suresh V',   'suresh.v@maduraifinance.com',   'ROLE004', 'ACTIVE', 'SYSTEM', 'SYSTEM');
