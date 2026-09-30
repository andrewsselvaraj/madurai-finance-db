-- Dev (H2, MySQL mode) schema. Mirrors etfdb_dev.sql + loan_info_table.sql +
-- loan_collection_table.sql, plus the app additions in db/mysql/app_additions.sql
-- (audit_log table, loan_info.received_date). updated_datetime is maintained by JPA.

CREATE TABLE org_info (
  pk_org_id        varchar(50)  NOT NULL,
  org_name         varchar(100) NOT NULL,
  org_email        varchar(50)  NOT NULL,
  status           varchar(10)  NOT NULL DEFAULT 'ACTIVE',
  created_datetime datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_user     varchar(50)  DEFAULT NULL,
  updated_datetime datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_user     varchar(50)  DEFAULT NULL,
  PRIMARY KEY (pk_org_id)
);

CREATE TABLE role_master (
  pk_role_id       varchar(50)  NOT NULL,
  role_org_id      varchar(50)  NOT NULL,
  role_name        varchar(50)  NOT NULL,
  role_description varchar(255) DEFAULT NULL,
  status           varchar(10)  NOT NULL DEFAULT 'ACTIVE',
  created_datetime datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_user     varchar(50)  DEFAULT NULL,
  updated_datetime datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_user     varchar(50)  DEFAULT NULL,
  PRIMARY KEY (pk_role_id),
  CONSTRAINT fk_role_org_id FOREIGN KEY (role_org_id) REFERENCES org_info (pk_org_id) ON DELETE CASCADE
);

CREATE TABLE module_master (
  pk_module_id     varchar(50) NOT NULL,
  module_name      varchar(50) NOT NULL,
  module_code      varchar(50) NOT NULL UNIQUE,
  created_datetime datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_user     varchar(50) DEFAULT NULL,
  updated_datetime datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_user     varchar(50) DEFAULT NULL,
  PRIMARY KEY (pk_module_id)
);

CREATE TABLE permission_master (
  pk_permission_id varchar(50) NOT NULL,
  permission_name  varchar(50) NOT NULL,
  permission_code  varchar(50) NOT NULL UNIQUE,
  created_datetime datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_user     varchar(50) DEFAULT NULL,
  updated_datetime datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_user     varchar(50) DEFAULT NULL,
  PRIMARY KEY (pk_permission_id)
);

CREATE TABLE role_permission_mapping (
  pk_mapping_id     varchar(50) NOT NULL,
  map_org_id        varchar(50) NOT NULL,
  map_role_id       varchar(50) NOT NULL,
  map_module_id     varchar(50) NOT NULL,
  map_permission_id varchar(50) NOT NULL,
  created_datetime  datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_user      varchar(50) DEFAULT NULL,
  updated_datetime  datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_user      varchar(50) DEFAULT NULL,
  PRIMARY KEY (pk_mapping_id),
  CONSTRAINT uk_tenant_security UNIQUE (map_org_id, map_role_id, map_module_id, map_permission_id),
  CONSTRAINT fk_map_org_id        FOREIGN KEY (map_org_id)        REFERENCES org_info (pk_org_id)                 ON DELETE CASCADE,
  CONSTRAINT fk_map_role_id       FOREIGN KEY (map_role_id)       REFERENCES role_master (pk_role_id)             ON DELETE CASCADE,
  CONSTRAINT fk_map_module_id     FOREIGN KEY (map_module_id)     REFERENCES module_master (pk_module_id)         ON DELETE CASCADE,
  CONSTRAINT fk_map_permission_id FOREIGN KEY (map_permission_id) REFERENCES permission_master (pk_permission_id) ON DELETE CASCADE
);

CREATE TABLE user_info (
  pk_user_id       varchar(50)  NOT NULL,
  user_org_id      varchar(50)  NOT NULL,
  user_name        varchar(50)  NOT NULL,
  password         varchar(100) NOT NULL,
  user_email       varchar(50)  NOT NULL UNIQUE,
  user_role_id     varchar(50)  NOT NULL,
  status           varchar(10)  NOT NULL DEFAULT 'ACTIVE',
  created_datetime datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_user     varchar(50)  DEFAULT NULL,
  updated_datetime datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_user     varchar(50)  DEFAULT NULL,
  PRIMARY KEY (pk_user_id),
  CONSTRAINT fk_user_org_id  FOREIGN KEY (user_org_id)  REFERENCES org_info (pk_org_id)    ON DELETE CASCADE,
  CONSTRAINT fk_user_role_id FOREIGN KEY (user_role_id) REFERENCES role_master (pk_role_id) ON DELETE CASCADE
);

CREATE TABLE loan_info (
  pk_loan_id         varchar(50)   NOT NULL,
  loan_org_id        varchar(50)   NOT NULL,
  loan_user_id       varchar(50)   NOT NULL,
  loan_amount        decimal(15,2) NOT NULL,
  interest_rate      decimal(5,2)  NOT NULL DEFAULT 0.00,
  tenure_months      int           NOT NULL,
  purpose            varchar(255)  DEFAULT NULL,
  application_date   date          NOT NULL DEFAULT CURRENT_DATE,
  approval_date      date          DEFAULT NULL,
  disbursement_date  date          DEFAULT NULL,
  due_date           date          DEFAULT NULL,
  outstanding_amount decimal(15,2) DEFAULT NULL,
  received_date      date          DEFAULT NULL,
  status             varchar(20)   NOT NULL DEFAULT 'PENDING',
  created_datetime   datetime      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_user       varchar(50)   DEFAULT NULL,
  updated_datetime   datetime      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_user       varchar(50)   DEFAULT NULL,
  PRIMARY KEY (pk_loan_id),
  CONSTRAINT fk_loan_org_id  FOREIGN KEY (loan_org_id)  REFERENCES org_info (pk_org_id)   ON DELETE CASCADE,
  CONSTRAINT fk_loan_user_id FOREIGN KEY (loan_user_id) REFERENCES user_info (pk_user_id) ON DELETE CASCADE,
  CONSTRAINT chk_loan_status CHECK (status IN ('PENDING','APPROVED','DISBURSED','CLOSED','REJECTED'))
);

CREATE TABLE loan_collection (
  pk_collection_id     varchar(50)   NOT NULL,
  collection_org_id    varchar(50)   NOT NULL,
  collection_loan_id   varchar(50)   NOT NULL,
  collection_user_id   varchar(50)   NOT NULL,
  collection_amount    decimal(15,2) NOT NULL,
  collection_date      date          NOT NULL DEFAULT CURRENT_DATE,
  payment_mode         varchar(20)   NOT NULL DEFAULT 'CASH',
  reference_no         varchar(100)  DEFAULT NULL,
  collected_by_user_id varchar(50)   DEFAULT NULL,
  remarks              varchar(255)  DEFAULT NULL,
  status               varchar(20)   NOT NULL DEFAULT 'SUCCESS',
  created_datetime     datetime      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_user         varchar(50)   DEFAULT NULL,
  updated_datetime     datetime      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_user         varchar(50)   DEFAULT NULL,
  PRIMARY KEY (pk_collection_id),
  CONSTRAINT fk_collection_org_id     FOREIGN KEY (collection_org_id)    REFERENCES org_info (pk_org_id)   ON DELETE CASCADE,
  CONSTRAINT fk_collection_loan_id    FOREIGN KEY (collection_loan_id)   REFERENCES loan_info (pk_loan_id) ON DELETE CASCADE,
  CONSTRAINT fk_collection_user_id    FOREIGN KEY (collection_user_id)   REFERENCES user_info (pk_user_id) ON DELETE CASCADE,
  CONSTRAINT fk_collected_by_user_id  FOREIGN KEY (collected_by_user_id) REFERENCES user_info (pk_user_id) ON DELETE SET NULL,
  CONSTRAINT chk_collection_payment_mode CHECK (payment_mode IN ('CASH','UPI','BANK_TRANSFER','CHEQUE','CARD')),
  CONSTRAINT chk_collection_status CHECK (status IN ('SUCCESS','PENDING','FAILED','REVERSED'))
);

CREATE TABLE audit_log (
  pk_audit_id     varchar(50)  NOT NULL,
  audit_org_id    varchar(50)  NOT NULL,
  audit_datetime  datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  audit_user_id   varchar(50)  DEFAULT NULL,
  audit_user_name varchar(50)  DEFAULT NULL,
  action          varchar(50)  NOT NULL,
  details         varchar(500) DEFAULT NULL,
  PRIMARY KEY (pk_audit_id),
  CONSTRAINT fk_audit_org_id FOREIGN KEY (audit_org_id) REFERENCES org_info (pk_org_id) ON DELETE CASCADE
);
CREATE INDEX idx_audit_org_datetime ON audit_log (audit_org_id, audit_datetime);
