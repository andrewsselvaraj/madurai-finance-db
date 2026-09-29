/*
 * Seed data for the Madurai Finance demo app.
 * Sourced from etfdb_dev.sql / seed_data.sql (ORG001 - Madurai Finance).
 * A few extra loan/collection rows (marked below) were added so every
 * role (especially Customer) has data to demonstrate the workflow.
 */

const ORG = {
  pk_org_id: 'ORG001',
  org_name: 'Madurai Finance',
  org_email: 'admin@maduraifinance.com',
  status: 'ACTIVE'
};

const MODULES = [
  { pk_module_id: 'MOD001', module_name: 'Loan Disbursement', module_code: 'LOAN_DISBURSEMENT' },
  { pk_module_id: 'MOD002', module_name: 'Collection', module_code: 'COLLECTION' },
  { pk_module_id: 'MOD003', module_name: 'Audit', module_code: 'AUDIT' }
];

const PERMISSIONS = [
  { pk_permission_id: 'PERM001', permission_name: 'View', permission_code: 'VIEW' },
  { pk_permission_id: 'PERM002', permission_name: 'Create', permission_code: 'CREATE' },
  { pk_permission_id: 'PERM003', permission_name: 'Approve', permission_code: 'APPROVE' },
  { pk_permission_id: 'PERM004', permission_name: 'Disburse', permission_code: 'DISBURSE' },
  { pk_permission_id: 'PERM005', permission_name: 'Collect', permission_code: 'COLLECT' },
  { pk_permission_id: 'PERM006', permission_name: 'Receive', permission_code: 'RECEIVE' },
  { pk_permission_id: 'PERM007', permission_name: 'Monitor', permission_code: 'MONITOR' }
];

const ROLES = [
  { pk_role_id: 'ROLE001', role_org_id: 'ORG001', role_name: 'Financier', role_description: 'Approves and disburses loans to customers' },
  { pk_role_id: 'ROLE002', role_org_id: 'ORG001', role_name: 'Collection Agent', role_description: 'Collects repayments from customers' },
  { pk_role_id: 'ROLE003', role_org_id: 'ORG001', role_name: 'Customer', role_description: 'Receives loan amount from Financier' },
  { pk_role_id: 'ROLE004', role_org_id: 'ORG001', role_name: 'Security', role_description: 'Monitors legal and illegal financial activities' },
  // Added for this app (not in the original etfdb_dev.sql dump) - ID picked
  // above ROLE052 (the highest role id across the full multi-org export) to
  // avoid colliding with any real row if this ever merges back.
  { pk_role_id: 'ROLE060', role_org_id: 'ORG001', role_name: 'Data Entry Operator', role_description: 'Registers new customers and submits loan applications for review' }
];

// Straight from role_permission_mapping in etfdb_dev.sql (MAP001-MAP017)
const ROLE_PERMISSION_MAPPING = [
  { pk_mapping_id: 'MAP001', map_org_id: 'ORG001', map_role_id: 'ROLE001', map_module_id: 'MOD001', map_permission_id: 'PERM001' },
  { pk_mapping_id: 'MAP002', map_org_id: 'ORG001', map_role_id: 'ROLE001', map_module_id: 'MOD001', map_permission_id: 'PERM002' },
  { pk_mapping_id: 'MAP003', map_org_id: 'ORG001', map_role_id: 'ROLE001', map_module_id: 'MOD001', map_permission_id: 'PERM003' },
  { pk_mapping_id: 'MAP004', map_org_id: 'ORG001', map_role_id: 'ROLE001', map_module_id: 'MOD001', map_permission_id: 'PERM004' },
  { pk_mapping_id: 'MAP005', map_org_id: 'ORG001', map_role_id: 'ROLE001', map_module_id: 'MOD003', map_permission_id: 'PERM001' },

  { pk_mapping_id: 'MAP006', map_org_id: 'ORG001', map_role_id: 'ROLE002', map_module_id: 'MOD002', map_permission_id: 'PERM001' },
  { pk_mapping_id: 'MAP007', map_org_id: 'ORG001', map_role_id: 'ROLE002', map_module_id: 'MOD002', map_permission_id: 'PERM005' },
  { pk_mapping_id: 'MAP008', map_org_id: 'ORG001', map_role_id: 'ROLE002', map_module_id: 'MOD003', map_permission_id: 'PERM001' },

  { pk_mapping_id: 'MAP009', map_org_id: 'ORG001', map_role_id: 'ROLE003', map_module_id: 'MOD001', map_permission_id: 'PERM001' },
  { pk_mapping_id: 'MAP010', map_org_id: 'ORG001', map_role_id: 'ROLE003', map_module_id: 'MOD001', map_permission_id: 'PERM006' },
  { pk_mapping_id: 'MAP011', map_org_id: 'ORG001', map_role_id: 'ROLE003', map_module_id: 'MOD002', map_permission_id: 'PERM001' },

  { pk_mapping_id: 'MAP012', map_org_id: 'ORG001', map_role_id: 'ROLE004', map_module_id: 'MOD001', map_permission_id: 'PERM001' },
  { pk_mapping_id: 'MAP013', map_org_id: 'ORG001', map_role_id: 'ROLE004', map_module_id: 'MOD001', map_permission_id: 'PERM007' },
  { pk_mapping_id: 'MAP014', map_org_id: 'ORG001', map_role_id: 'ROLE004', map_module_id: 'MOD002', map_permission_id: 'PERM001' },
  { pk_mapping_id: 'MAP015', map_org_id: 'ORG001', map_role_id: 'ROLE004', map_module_id: 'MOD002', map_permission_id: 'PERM007' },
  { pk_mapping_id: 'MAP016', map_org_id: 'ORG001', map_role_id: 'ROLE004', map_module_id: 'MOD003', map_permission_id: 'PERM001' },
  { pk_mapping_id: 'MAP017', map_org_id: 'ORG001', map_role_id: 'ROLE004', map_module_id: 'MOD003', map_permission_id: 'PERM007' },

  // Data Entry Operator -> Loan Disbursement (VIEW, CREATE only - no approve/disburse)
  { pk_mapping_id: 'MAP018', map_org_id: 'ORG001', map_role_id: 'ROLE060', map_module_id: 'MOD001', map_permission_id: 'PERM001' },
  { pk_mapping_id: 'MAP019', map_org_id: 'ORG001', map_role_id: 'ROLE060', map_module_id: 'MOD001', map_permission_id: 'PERM002' }
];

// From user_info (ORG001 rows). Passwords are 'test' in the real dump - kept as-is for demo login.
const SEED_USERS = [
  { pk_user_id: 'USR001', user_org_id: 'ORG001', user_name: 'Ravi Kumar', password: 'test', user_email: 'ravi.kumar@maduraifinance.com', user_role_id: 'ROLE001', status: 'ACTIVE' },
  { pk_user_id: 'USR002', user_org_id: 'ORG001', user_name: 'Priya Devi', password: 'test', user_email: 'priya.devi@maduraifinance.com', user_role_id: 'ROLE002', status: 'ACTIVE' },
  { pk_user_id: 'USR003', user_org_id: 'ORG001', user_name: 'Murugan K', password: 'test', user_email: 'murugan.k@maduraifinance.com', user_role_id: 'ROLE003', status: 'ACTIVE' },
  { pk_user_id: 'USR004', user_org_id: 'ORG001', user_name: 'Suresh V', password: 'test', user_email: 'suresh.v@maduraifinance.com', user_role_id: 'ROLE004', status: 'ACTIVE' },
  // Added for this app - demo account for the new Data Entry Operator role.
  { pk_user_id: 'USR020', user_org_id: 'ORG001', user_name: 'Kavitha M', password: 'test', user_email: 'kavitha.m@maduraifinance.com', user_role_id: 'ROLE060', status: 'ACTIVE' }
];

// LOAN001 is the exact row from etfdb_dev.sql. LOAN002/LOAN003 are added demo
// records (assigned to the Customer-role user) so the Customer view has data.
const SEED_LOANS = [
  { pk_loan_id: 'LOAN001', loan_org_id: 'ORG001', loan_user_id: 'USR001', loan_amount: 50000.00, interest_rate: 12.50, tenure_months: 12, purpose: 'Personal loan', application_date: '2026-07-01', approval_date: '2026-07-02', disbursement_date: '2026-07-03', due_date: '2027-07-03', status: 'DISBURSED' },
  { pk_loan_id: 'LOAN002', loan_org_id: 'ORG001', loan_user_id: 'USR003', loan_amount: 25000.00, interest_rate: 10.50, tenure_months: 6, purpose: 'Business expansion loan', application_date: '2026-07-05', approval_date: '2026-07-06', disbursement_date: '2026-07-07', due_date: '2027-01-07', status: 'DISBURSED' },
  { pk_loan_id: 'LOAN003', loan_org_id: 'ORG001', loan_user_id: 'USR003', loan_amount: 15000.00, interest_rate: 11.00, tenure_months: 9, purpose: 'Two-wheeler loan', application_date: '2026-07-10', approval_date: null, disbursement_date: null, due_date: null, status: 'PENDING' }
];

// COLL001 is the exact row from etfdb_dev.sql. COLL002/COLL003 are added demo records.
const SEED_COLLECTIONS = [
  { pk_collection_id: 'COLL001', collection_org_id: 'ORG001', collection_loan_id: 'LOAN001', collection_user_id: 'USR001', collection_amount: 4453.25, collection_date: '2026-08-01', payment_mode: 'UPI', reference_no: 'UPI-TXN-98213', collected_by_user_id: 'USR002', remarks: 'First EMI payment', status: 'SUCCESS' },
  { pk_collection_id: 'COLL002', collection_org_id: 'ORG001', collection_loan_id: 'LOAN001', collection_user_id: 'USR001', collection_amount: 4453.25, collection_date: '2026-09-01', payment_mode: 'CASH', reference_no: null, collected_by_user_id: 'USR002', remarks: 'Second EMI payment', status: 'SUCCESS' },
  { pk_collection_id: 'COLL003', collection_org_id: 'ORG001', collection_loan_id: 'LOAN002', collection_user_id: 'USR003', collection_amount: 4500.00, collection_date: '2026-07-20', payment_mode: 'UPI', reference_no: 'UPI-TXN-55210', collected_by_user_id: 'USR002', remarks: 'First installment', status: 'SUCCESS' }
];

const SEED_AUDIT = [
  { pk_audit_id: 'AUD00001', org_id: 'ORG001', datetime: '2026-07-02 05:26:22', user_id: 'USR001', user_name: 'Ravi Kumar', action: 'CREATE_LOAN', details: 'Created loan LOAN001 for Ravi Kumar - ₹50,000.00' },
  { pk_audit_id: 'AUD00002', org_id: 'ORG001', datetime: '2026-07-02 05:31:34', user_id: 'USR002', user_name: 'Priya Devi', action: 'COLLECT', details: 'Collected ₹4,453.25 against LOAN001 (UPI)' }
];
