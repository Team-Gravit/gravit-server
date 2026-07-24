## Phase 6. 개선 전 스냅샷

### 목적
개선을 적용하기 전 상태를 증거로 남긴다.

### 선행 조건
- Phase 5 완료

### 참조 파일
- 없음

### 절차

1. 기법과 무관하게 공통으로 캡처한다.
   - k6 요약: p95, p99, RPS, 에러율
   - 요청당 쿼리 수, 대상 쿼리의 `calls` / `mean_exec_time` / `total_exec_time`
   - 부하 조건: VU, duration, 데이터 규모, 커넥션 풀 크기

2. EXPLAIN에 넣을 쿼리를 만든다.

   - `pg_stat_statements`의 쿼리 원문은 `$1`, `$2`로 정규화되어 있다. 그대로 EXPLAIN하면 실패한다.
   - 파라미터마다 리터럴을 대입한다. 대입값은 **부하 스크립트가 실제로 보내는 값의 범위**에서 고른다.
     - userId 계열: `USER_ID_START` ~ `USER_ID_START + USER_COUNT - 1` 사이의 값
     - 그 외: Phase 3에서 확정한 카디널리티 분포의 중앙에 있는 값
   - 값을 한쪽 끝(최솟값, 최댓값, 행이 0건인 값)으로 잡지 마라.
   - 대입한 파라미터 값을 `record.md`의 사이클 {n} **실행계획**에 적는다. 이후 모든 사이클에서 같은 값을 쓴다.

3. 대상 쿼리의 실행계획을 `query-plan-{n-1}.txt`로 캡처한다. (사이클 1이면 `query-plan-0.txt`)

   - **`query-plan-{n-1}.txt`가 이미 있고 대상 쿼리가 같으면 다시 뜨지 마라.** Read로 읽고 4번으로 간다.
   - 없거나 대상 쿼리가 직전 사이클과 다르면 아래를 제시하고 결과를 받는다. `tee -a`로 덧붙인다. 같은 상태의 다른 쿼리 계획을 덮어쓰지 마라.

   ```bash
   # 새 터미널이면 먼저: export PERF_DIR=.claude/resources/perf/{이슈번호}

   # 버퍼 캐시를 채우는 1회. 이 출력은 쓰지 않는다.
   psql -h localhost -p 5433 -U postgres -d mydb > /dev/null <<'SQL'
   BEGIN;
   EXPLAIN (ANALYZE, BUFFERS, VERBOSE) {대상 쿼리};
   ROLLBACK;
   SQL

   # 기록용 2회차
   psql -h localhost -p 5433 -U postgres -d mydb <<'SQL' | tee -a $PERF_DIR/query-plan-{n-1}.txt
   BEGIN;
   EXPLAIN (ANALYZE, BUFFERS, VERBOSE) {대상 쿼리};
   ROLLBACK;
   SQL
   ```

   `EXPLAIN ANALYZE`는 대상 쿼리를 실제로 실행한다. `BEGIN`과 `ROLLBACK`을 빼지 마라.
   시퀀스 증가와 트리거의 외부 호출은 롤백되지 않는다. 대상 쿼리가 쓰기면 그 사실을 호출자에게 알린다.

   파일을 Read로 읽는다. 터미널 출력을 붙여넣게 하지 마라.

   계획에서 아래를 뽑아 기록한다.
   - 스캔 방식 (Seq Scan / Index Scan / Bitmap Heap Scan)과 사용된 인덱스명
   - `actual rows` 대 최종 반환 행 수
   - `Rows Removed by Filter`
   - `shared hit` / `shared read` 블록 수
   - `loops` 값이 큰 노드
   - 플래너 추정(`rows=`) 대 실측(`actual rows=`) 괴리

4. 기법별로 추가 캡처한다.
   - **캐싱**: 동일 입력의 반복 호출 비율, 무효화가 필요한 쓰기 경로 목록
   - **로직 개선**: 변경 전 요청당 쿼리 수와 그 호출 스택
   - **풀, 트랜잭션**: 커넥션 획득 대기 시간, 트랜잭션 유지 구간

5. 판정은 절대 시간이 아니라 비율로 한다.

   | 지표 | 위험 신호 |
   |---|---|
   | 검사 행 수 / 반환 행 수 | 100:1 초과 |
   | 플래너 추정 대 실측 행 수 | 10배 이상 괴리 |
   | 단일 쿼리의 total_exec_time 점유율 | 30% 이상 |
   | OLTP 경로의 Seq Scan | 1만 행 이상 테이블이면 신호 |
   | 동일 쿼리의 요청당 호출 횟수 | 1회 초과면 N+1 의심 |

### 출력
- `.claude/resources/perf/{이슈번호}/query-plan-{n-1}.txt` 생성
- `.claude/resources/perf/{이슈번호}/record.md`의 사이클 {n} **개선 전 지표**와 **실행계획**이 채워짐
  (EXPLAIN에 대입한 파라미터 값 포함)
- `.claude/resources/perf/{이슈번호}/record.md`의 진행 상태의 사이클 {n} Phase 6이 ✅으로 기록

### 실패 처리
- 없음

> 다음 Phase 조건: 개선 전 지표와 실행계획이 기록되었을 때 → Phase 7

> Skip 조건: 없음 (필수 Phase)
