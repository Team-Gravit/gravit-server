-- V5__add_staging_label_with_fk.sql

-- 1) staging_label
CREATE TABLE IF NOT EXISTS staging_label
(
    id           bigint       NOT NULL,
    label        varchar(32)  NOT NULL,
    unit_id      bigint       NOT NULL,
    description  varchar(255) NOT NULL,
    label_status varchar(20)  NOT NULL DEFAULT 'PENDING',
    created_at   timestamp    NOT NULL DEFAULT NOW(),
    CONSTRAINT staging_label_pkey PRIMARY KEY (id),
    CONSTRAINT staging_label_label_key UNIQUE (label),
    CONSTRAINT staging_label_status_check
    CHECK (label_status IN ('PENDING', 'COMPLETED'))
    );

CREATE INDEX IF NOT EXISTS ix_staging_label_status
    ON staging_label (label_status);

CREATE INDEX IF NOT EXISTS ix_staging_label_unit
    ON staging_label (unit_id);

-- 2) FK 추가 (4 staging 테이블 → staging_label.label)
ALTER TABLE lesson_staging
    ADD CONSTRAINT fk_lesson_staging_label
        FOREIGN KEY (label) REFERENCES staging_label (label);

ALTER TABLE problem_staging
    ADD CONSTRAINT fk_problem_staging_label
        FOREIGN KEY (label) REFERENCES staging_label (label);

ALTER TABLE option_staging
    ADD CONSTRAINT fk_option_staging_label
        FOREIGN KEY (label) REFERENCES staging_label (label);

ALTER TABLE answer_staging
    ADD CONSTRAINT fk_answer_staging_label
        FOREIGN KEY (label) REFERENCES staging_label (label);