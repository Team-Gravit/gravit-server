-- 시드 SQL 템플릿.
-- {테이블}, {건수} 자리를 채워 .claude/resources/perf/{이슈번호}/seeds.sql 로 저장한다.
--
-- 실행: psql -h localhost -p 5433 -U postgres -d mydb -f $PERF_DIR/seeds.sql
-- 실행은 호출자가 한다. 스킬은 명령어만 제시한다.
--
-- ── 작성 규칙 ──────────────────────────────────────────────
-- 1. Phase 1의 쿼리 목록에 나온 테이블만 채운다. 그 외 테이블은 건드리지 않는다.
-- 2. generate_series 기반 대량 INSERT로 작성한다. 행 단위 반복 INSERT로 작성하지 않는다.
-- 3. FK 의존 순서대로 블록을 배치한다. 부모 테이블이 먼저다.
-- 4. 재실행해도 중복이 쌓이지 않게 작성한다. ON CONFLICT DO NOTHING 또는 삽입 범위를 고정한 조건을 쓴다.
-- 5. id를 명시 삽입했으면 시퀀스를 보정한다.
-- 6. 마지막에 ANALYZE를 돌린다.
-- 7. userId 범위(시작값, 건수)를 k6 스크립트의 USER_ID_START, USER_COUNT와 일치시킨다.
-- 8. /api/v1/test/users/create 를 대량 시드에 쓰지 않는다.
-- 9. Phase 3에서 확정한 목표 카디널리티대로 값을 만든다.
--    WHERE, ORDER BY, GROUP BY에 쓰이는 컬럼은 서로 다른 값의 개수를 명시적으로 통제한다.
--    (예: 목표 카디널리티가 20이면 `(i % 20)`, 균등하지 않은 분포가 필요하면 `(i % 20) * (i % 3)` 형태)
--    한 값에 전 행이 몰리거나 전 행이 서로 다른 값을 갖게 두지 않는다.
-- 10. 검증 쿼리에 행 수와 함께 9번 컬럼들의 카디널리티를 포함시킨다.
-- ──────────────────────────────────────────────────────────

BEGIN;

-- 1) {부모 테이블}: {건수}건
INSERT INTO {부모테이블} (id, {컬럼들})
SELECT i,
       {컬럼식 - 예: 'user' || i}
FROM generate_series({시작값}, {시작값 + 건수 - 1}) AS i
ON CONFLICT (id) DO NOTHING;

-- 2) {자식 테이블}: 부모당 {n}건
INSERT INTO {자식테이블} ({FK컬럼}, {컬럼들})
SELECT p.id,
       {컬럼식}
FROM {부모테이블} p
CROSS JOIN generate_series(1, {n}) AS j
ON CONFLICT DO NOTHING;

-- 시퀀스 보정 (id를 명시 삽입한 테이블마다)
SELECT setval(pg_get_serial_sequence('{테이블}', 'id'),
              (SELECT COALESCE(max(id), 1) FROM {테이블}));

COMMIT;

-- 통계 갱신
ANALYZE {테이블};

-- 검증: 목표 규모와 카디널리티에 도달했는지 확인한다. 이 결과를 record.md의 측정 환경에 적는다.
SELECT '{테이블}'                    AS table_name,
       count(*)                      AS rows,
       count(DISTINCT {조건컬럼})    AS {조건컬럼}_cardinality,
       count(DISTINCT {정렬컬럼})    AS {정렬컬럼}_cardinality
FROM {테이블};
