-- 스테이징 라벨 테이블 신설.
-- generator 의 적재(첫 INSERT 대상)이자 admin 검수/promote 의 식별 단위(label)이다.
-- ⚠ status / created_at 은 generator 가 INSERT 하지 않으므로 DB DEFAULT 가 필수다.
CREATE TABLE IF NOT EXISTS staging_label (
    id          bigint        NOT NULL,
    label       varchar(32)   NOT NULL UNIQUE,
    unit_id     bigint        NOT NULL,
    description varchar(255)  NOT NULL,
    status      varchar(20)   NOT NULL DEFAULT 'PENDING',
    created_at  timestamp     NOT NULL DEFAULT now(),
    CONSTRAINT staging_label_pkey PRIMARY KEY (id),
    CONSTRAINT staging_label_status_check CHECK (status IN ('PENDING', 'COMPLETED'))
);

-- child staging.label -> staging_label.label FK. (V4 child 테이블은 label varchar(32) 보유)
ALTER TABLE lesson_staging  ADD CONSTRAINT fk_lesson_staging_label  FOREIGN KEY (label) REFERENCES staging_label(label);
ALTER TABLE problem_staging ADD CONSTRAINT fk_problem_staging_label FOREIGN KEY (label) REFERENCES staging_label(label);
ALTER TABLE option_staging  ADD CONSTRAINT fk_option_staging_label  FOREIGN KEY (label) REFERENCES staging_label(label);
ALTER TABLE answer_staging  ADD CONSTRAINT fk_answer_staging_label  FOREIGN KEY (label) REFERENCES staging_label(label);
