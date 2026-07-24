## Phase 8. 재측정과 검증

### 목적
동일 조건으로 재측정해 개선 효과를 수치로 확정하고, 사이클을 계속할지 판정한다.

### 선행 조건
- Phase 7 완료
- 애플리케이션이 변경된 코드로 재기동

### 참조 파일
- 없음

### 절차

1. **Phase 4와 완전히 동일한 조건**으로 재측정하도록 아래를 제시한다.
   스크립트, VU, duration, 데이터 규모, 풀 크기, 캐시 상태를 하나도 바꾸지 마라.

   ```bash
   # 새 터미널이면 먼저: export PERF_DIR=.claude/resources/perf/{이슈번호}

   # 1) 워밍업. 이 실행의 결과는 쓰지 않는다.
   k6 run -e PHASE=warmup $PERF_DIR/test-script.js

   # 2) 캐시 비우기 - Phase 3에서 cold를 택한 경우에만 실행한다 (Phase 4와 같아야 한다)
   redis-cli -h localhost -p 6379 FLUSHALL

   # 3) 쿼리 통계 리셋
   psql -h localhost -p 5433 -U postgres -d mydb -c "SELECT pg_stat_statements_reset();"

   # 4) 측정 부하 (Phase 3의 스크립트를 그대로 쓴다)
   k6 run -e PHASE=measure \
     -e SUMMARY_OUT=$PERF_DIR/k6-test-summary-{n}.json \
     $PERF_DIR/test-script.js

   # 5) 쿼리 통계 수집
   psql -h localhost -p 5433 -U postgres -d mydb -c "
   SELECT calls, round(mean_exec_time::numeric,2) AS mean_ms,
          round(total_exec_time::numeric,2) AS total_ms, left(query,120) AS query
   FROM pg_stat_statements
   WHERE query NOT LIKE '%pg_stat_statements%'
   ORDER BY total_exec_time DESC LIMIT 20;" \
   | tee $PERF_DIR/query-stats-{n}.txt

   # 6) 개선 후 실행계획 (Phase 6과 같은 쿼리, 같은 파라미터 값)
   psql -h localhost -p 5433 -U postgres -d mydb -c "
   EXPLAIN (ANALYZE, BUFFERS, VERBOSE) {대상 쿼리};" > /dev/null

   psql -h localhost -p 5433 -U postgres -d mydb -c "
   EXPLAIN (ANALYZE, BUFFERS, VERBOSE) {대상 쿼리};" \
   | tee -a $PERF_DIR/query-plan-{n}.txt
   ```

   - `{n}`에는 이번 사이클 적용 후의 상태 번호를 넣는다. 앞선 상태의 파일을 덮어쓰지 마라.
   - EXPLAIN에는 Phase 6 **실행계획**에 적어둔 파라미터 값을 그대로 쓴다. 값을 바꾸면 계획이 비교 불가가 된다.
   - 쓰기 부하가 포함된 시나리오면 1차 측정이 데이터를 불려놓았을 수 있다. 데이터 규모를 다시 확인한다.
   - 조건이 달라졌으면 그 사실을 기록에 명시하고, 비교 가능한 범위를 좁혀서 해석한다.

2. 실행이 끝나면 아래 파일을 Read로 읽는다. 터미널 출력을 붙여넣게 하지 마라.

   | 산출물 | 개선 후 (이번 사이클) | 개선 전 (비교 대상) |
   |---|---|---|
   | k6 요약 | `k6-test-summary-{n}.json` | `k6-test-summary-{n-1}.json` |
   | 쿼리 통계 | `query-stats-{n}.txt` | `query-stats-{n-1}.txt` |
   | 실행계획 | `query-plan-{n}.txt` | `query-plan-{n-1}.txt` |

   최초 상태와의 누적 변화가 필요하면 `-0` 파일을 함께 읽는다.

   - 요청당 쿼리 수의 분모는 Phase 4와 같다. 요약의 `requests - USER_COUNT`.
   - `checks_rate`가 Phase 4보다 떨어졌으면 응답 내용이 달라진 것이다. 수치 비교보다 이 사실을 먼저 보고한다.

3. 전후를 비교해 기록한다. **두 축을 모두 남긴다.**

   - **하드웨어 의존 증거**: p95, p99, RPS. 로컬 절대값은 신뢰하지 말고 상대 변화만 쓴다.
   - **하드웨어 독립 증거**: 요청당 쿼리 수, 검사 행 수 대 반환 행 수, 실행계획 변화, 캐시 적중률.

4. 개선이 없거나 오히려 나빠졌으면 그대로 기록한다. 수치를 유리하게 해석하지 마라.

5. Phase 5-B에 적힌 **호출자가 예상한 효과**와 실측을 대조해 보고한다.
   - 예상대로면 어떤 근거가 맞았는지 짚는다.
   - 어긋났으면 어느 가정이 틀렸는지 관측값으로 짚는다.
   - 실측 없이 "예상대로 개선되었다"고 쓰지 마라.

6. 종료를 판정한다. **개선 여부는 하드웨어 독립 증거로 판정한다.** p95나 RPS의 변화만으로 개선을 주장하거나 종료를 판정하지 마라.

   | 조건 | 판정 |
   |---|---|
   | 하드웨어 독립 증거에 변화가 없음 | 종료 |
   | Phase 6 위험 신호 표의 항목이 모두 해소됨 | 종료 |
   | 호출자가 종료를 선택 | 종료 |
   | 그 외 | 계속 |

   **판정만 하고, 계속할지는 호출자에게 확인한다.**

### 출력
- `.claude/resources/perf/{이슈번호}/k6-test-summary-{n}.json` 생성
- `.claude/resources/perf/{이슈번호}/query-stats-{n}.txt` 생성
- `.claude/resources/perf/{이슈번호}/query-plan-{n}.txt` 생성
- `.claude/resources/perf/{이슈번호}/record.md`의 사이클 {n} **개선 후 지표**와 **판정**이 채워짐
- `.claude/resources/perf/{이슈번호}/record.md`의 진행 상태의 사이클 {n} Phase 8이 ✅으로 기록

### 실패 처리
- 재측정 조건이 1차와 달라졌는데 되돌릴 수 없으면, 비교 가능한 지표만 골라 해석하고 나머지는 "조건 변경으로 비교 불가"로 명시한다.
- 개선 후 에러율이 올랐으면 수치 비교보다 원인을 먼저 보고한다.

> 다음 Phase 조건: 종료 판정이거나 호출자가 종료를 선택한 경우 → Phase 9

> 계속하는 경우 → Phase 5 (`record.md`의 진행 상태에 사이클 행을 추가하고 번호를 +1)

> Skip 조건: 없음 (필수 Phase)
