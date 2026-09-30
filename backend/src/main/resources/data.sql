-- Dev seed data (H2). Same rows as the legacy app/js/data.js: ORG001 from
-- etfdb_dev.sql, plus the Data Entry Operator role/user and demo loans/collections.
-- Passwords are plain 'test' as in the dump; the API also accepts {bcrypt} hashes.

INSERT INTO org_info (pk_org_id, org_name, org_email, status, created_user, updated_user) VALUES
('ORG001', 'Madurai Finance', 'admin@maduraifinance.com', 'ACTIVE', 'SYSTEM', 'SYSTEM');

INSERT INTO module_master (pk_module_id, module_name, module_code, created_user, updated_user) VALUES
('MOD001', 'Loan Disbursement', 'LOAN_DISBURSEMENT', 'SYSTEM', 'SYSTEM'),
('MOD002', 'Collection',        'COLLECTION',        'SYSTEM', 'SYSTEM'),
('MOD003', 'Audit',             'AUDIT',             'SYSTEM', 'SYSTEM');

INSERT INTO permission_master (pk_permission_id, permission_name, permission_code, created_user, updated_user) VALUES
('PERM001', 'View',     'VIEW',     'SYSTEM', 'SYSTEM'),
('PERM002', 'Create',   'CREATE',   'SYSTEM', 'SYSTEM'),
('PERM003', 'Approve',  'APPROVE',  'SYSTEM', 'SYSTEM'),
('PERM004', 'Disburse', 'DISBURSE', 'SYSTEM', 'SYSTEM'),
('PERM005', 'Collect',  'COLLECT',  'SYSTEM', 'SYSTEM'),
('PERM006', 'Receive',  'RECEIVE',  'SYSTEM', 'SYSTEM'),
('PERM007', 'Monitor',  'MONITOR',  'SYSTEM', 'SYSTEM');

INSERT INTO role_master (pk_role_id, role_org_id, role_name, role_description, created_user, updated_user) VALUES
('ROLE001', 'ORG001', 'Financier',           'Approves and disburses loans to customers',                        'SYSTEM', 'SYSTEM'),
('ROLE002', 'ORG001', 'Collection Agent',    'Collects repayments from customers',                               'SYSTEM', 'SYSTEM'),
('ROLE003', 'ORG001', 'Customer',            'Receives loan amount from Financier',                              'SYSTEM', 'SYSTEM'),
('ROLE004', 'ORG001', 'Security',            'Monitors legal and illegal financial activities',                  'SYSTEM', 'SYSTEM'),
('ROLE060', 'ORG001', 'Data Entry Operator', 'Registers new customers and submits loan applications for review', 'SYSTEM', 'SYSTEM');

INSERT INTO role_permission_mapping (pk_mapping_id, map_org_id, map_role_id, map_module_id, map_permission_id, created_user, updated_user) VALUES
('MAP001', 'ORG001', 'ROLE001', 'MOD001', 'PERM001', 'SYSTEM', 'SYSTEM'),
('MAP002', 'ORG001', 'ROLE001', 'MOD001', 'PERM002', 'SYSTEM', 'SYSTEM'),
('MAP003', 'ORG001', 'ROLE001', 'MOD001', 'PERM003', 'SYSTEM', 'SYSTEM'),
('MAP004', 'ORG001', 'ROLE001', 'MOD001', 'PERM004', 'SYSTEM', 'SYSTEM'),
('MAP005', 'ORG001', 'ROLE001', 'MOD003', 'PERM001', 'SYSTEM', 'SYSTEM'),
('MAP006', 'ORG001', 'ROLE002', 'MOD002', 'PERM001', 'SYSTEM', 'SYSTEM'),
('MAP007', 'ORG001', 'ROLE002', 'MOD002', 'PERM005', 'SYSTEM', 'SYSTEM'),
('MAP008', 'ORG001', 'ROLE002', 'MOD003', 'PERM001', 'SYSTEM', 'SYSTEM'),
('MAP009', 'ORG001', 'ROLE003', 'MOD001', 'PERM001', 'SYSTEM', 'SYSTEM'),
('MAP010', 'ORG001', 'ROLE003', 'MOD001', 'PERM006', 'SYSTEM', 'SYSTEM'),
('MAP011', 'ORG001', 'ROLE003', 'MOD002', 'PERM001', 'SYSTEM', 'SYSTEM'),
('MAP012', 'ORG001', 'ROLE004', 'MOD001', 'PERM001', 'SYSTEM', 'SYSTEM'),
('MAP013', 'ORG001', 'ROLE004', 'MOD001', 'PERM007', 'SYSTEM', 'SYSTEM'),
('MAP014', 'ORG001', 'ROLE004', 'MOD002', 'PERM001', 'SYSTEM', 'SYSTEM'),
('MAP015', 'ORG001', 'ROLE004', 'MOD002', 'PERM007', 'SYSTEM', 'SYSTEM'),
('MAP016', 'ORG001', 'ROLE004', 'MOD003', 'PERM001', 'SYSTEM', 'SYSTEM'),
('MAP017', 'ORG001', 'ROLE004', 'MOD003', 'PERM007', 'SYSTEM', 'SYSTEM'),
('MAP018', 'ORG001', 'ROLE060', 'MOD001', 'PERM001', 'SYSTEM', 'SYSTEM'),
('MAP019', 'ORG001', 'ROLE060', 'MOD001', 'PERM002', 'SYSTEM', 'SYSTEM');

INSERT INTO user_info (pk_user_id, user_org_id, user_name, password, user_email, user_role_id, status, created_user, updated_user) VALUES
('USR001', 'ORG001', 'Ravi Kumar', 'test', 'ravi.kumar@maduraifinance.com', 'ROLE001', 'ACTIVE', 'SYSTEM', 'SYSTEM'),
('USR002', 'ORG001', 'Priya Devi', 'test', 'priya.devi@maduraifinance.com', 'ROLE002', 'ACTIVE', 'SYSTEM', 'SYSTEM'),
('USR003', 'ORG001', 'Murugan K',  'test', 'murugan.k@maduraifinance.com',  'ROLE003', 'ACTIVE', 'SYSTEM', 'SYSTEM'),
('USR004', 'ORG001', 'Suresh V',   'test', 'suresh.v@maduraifinance.com',   'ROLE004', 'ACTIVE', 'SYSTEM', 'SYSTEM'),
('USR020', 'ORG001', 'Kavitha M',  'test', 'kavitha.m@maduraifinance.com',  'ROLE060', 'ACTIVE', 'SYSTEM', 'SYSTEM');

INSERT INTO loan_info (pk_loan_id, loan_org_id, loan_user_id, loan_amount, interest_rate, tenure_months, purpose,
                       application_date, approval_date, disbursement_date, due_date, outstanding_amount, status, created_user, updated_user) VALUES
('LOAN001', 'ORG001', 'USR001', 50000.00, 12.50, 12, 'Personal loan',           '2026-07-01', '2026-07-02', '2026-07-03', '2027-07-03', 41093.50, 'DISBURSED', 'SYSTEM', 'SYSTEM'),
('LOAN002', 'ORG001', 'USR003', 25000.00, 10.50,  6, 'Business expansion loan', '2026-07-05', '2026-07-06', '2026-07-07', '2027-01-07', 20500.00, 'DISBURSED', 'SYSTEM', 'SYSTEM'),
('LOAN003', 'ORG001', 'USR003', 15000.00, 11.00,  9, 'Two-wheeler loan',        '2026-07-10', NULL,         NULL,         NULL,         NULL,     'PENDING',   'SYSTEM', 'SYSTEM');

INSERT INTO loan_collection (pk_collection_id, collection_org_id, collection_loan_id, collection_user_id, collection_amount, collection_date,
                             payment_mode, reference_no, collected_by_user_id, remarks, status, created_user, updated_user) VALUES
('COLL001', 'ORG001', 'LOAN001', 'USR001', 4453.25, '2026-08-01', 'UPI',  'UPI-TXN-98213', 'USR002', 'First EMI payment',  'SUCCESS', 'SYSTEM', 'SYSTEM'),
('COLL002', 'ORG001', 'LOAN001', 'USR001', 4453.25, '2026-09-01', 'CASH', NULL,            'USR002', 'Second EMI payment', 'SUCCESS', 'SYSTEM', 'SYSTEM'),
('COLL003', 'ORG001', 'LOAN002', 'USR003', 4500.00, '2026-07-20', 'UPI',  'UPI-TXN-55210', 'USR002', 'First installment',  'SUCCESS', 'SYSTEM', 'SYSTEM');

INSERT INTO audit_log (pk_audit_id, audit_org_id, audit_datetime, audit_user_id, audit_user_name, action, details) VALUES
('AUD00001', 'ORG001', '2026-07-02 05:26:22', 'USR001', 'Ravi Kumar', 'CREATE_LOAN', 'Created loan LOAN001 for Ravi Kumar - ₹50,000.00'),
('AUD00002', 'ORG001', '2026-07-02 05:31:34', 'USR002', 'Priya Devi', 'COLLECT',     'Collected ₹4,453.25 against LOAN001 (UPI)');
