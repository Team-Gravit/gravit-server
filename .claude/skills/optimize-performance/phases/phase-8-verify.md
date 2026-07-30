## Phase 8. 재측정과 검증

### 목적
동일 조건으로 재측정해 개선 효과를 수치로 확정하고, 사이클을 계속할지 판정한다.

### 선행 조건
- Phase 7 완료
- 애플리케이션이 변경된 코드로 재기동

### 참조 파일
- `.claude/skills/optimize-performance/template/query-stats-template.md`

### 절차

1. **Phase 4와 완전히 동일한 조건**으로 재측정하도록 아래를 제시한다.
   스크립트, VU, duration, 데이터 규모, 풀 크기, 캐시 상태를 하나도 바꾸지 마라.

   ```bash
   # 새 터미널이면 먼저:
   #   export PERF_DIR=.claude/resources/perf/{이슈번호}
   #   export TARGET_DIR=$PERF_DIR/{슬러그}

   # 1) 토큰 재발급 (통계 리셋 전에 끝낸다)
   seq {USER_ID_START} {USER_ID_START + USER_COUNT - 1} \
     | while read -r id; do
         curl -s -X POST "localhost:8080/api/v1/test/users/login?userId=$id" | jq -r '.accessToken // empty'
       done \
     | jq -R -s 'split("\n") | map(select(length > 0))' > $PERF_DIR/tokens.json

   # 2) 워밍업. 이 실행의 결과는 쓰지 않는다.
   k6 run -e PHASE=warmup $TARGET_DIR/test-script.js

   # 3) 되돌리기 - Phase 4와 같은 절차를 같은 자리에서 실행한다
   #    쓰기 엔드포인트면 워밍업이 삽입한 행을 지운다

   # 4) dead tuple 회수 + 통계 갱신 - Phase 4와 같아야 한다
   psql -h localhost -p 5433 -U postgres -d mydb -c "VACUUM ANALYZE;"

   psql -h localhost -p 5433 -U postgres -d mydb -c "
   SELECT relname, n_dead_tup, last_vacuum, last_analyze
   FROM pg_stat_user_tables
   WHERE relname IN ({대상 쿼리가 읽고 쓰는 테이블})
   ORDER BY relname;"

   # 5) 캐시 비우기 - Phase 3에서 cold를 택한 경우에만 실행한다 (Phase 4와 같아야 한다)
   {캐시 제어 수단} -n 0 FLUSHDB

   # 6) 쿼리 통계 리셋
   psql -h localhost -p 5433 -U postgres -d mydb -c "SELECT pg_stat_statements_reset();"

   # 7) 측정 부하 (Phase 3의 스크립트를 그대로 쓴다)
   k6 run -e PHASE=measure \
     -e SUMMARY_OUT=$TARGET_DIR/k6-test-summary-{n}.json \
     $TARGET_DIR/test-script.js

   # 8) 쿼리 통계 수집
   #    수집 단계에서 반올림하지 않는다. 반올림은 대화에서 표로 제시할 때만 한다.
   #    REQS 가드를 빼지 마라. 요청 0건이면 per_req의 분모가 0이 되어 division by zero로 수집이 중단된다.
   REQS=$(jq -r '.requests // empty' $TARGET_DIR/k6-test-summary-{n}.json)

   if ! [ "$REQS" -gt 0 ] 2>/dev/null; then
     echo "요청 수가 '$REQS'다. 측정이 실패했으므로 통계를 수집하지 않는다. 원인을 확인하고 재측정하라."
   else
   psql -h localhost -p 5433 -U postgres -d mydb -A -F ' | ' -c "
   SELECT calls,
          calls::numeric / $REQS                              AS per_req,
          mean_exec_time                                      AS mean_ms,
          total_exec_time                                     AS total_ms,
          100 * total_exec_time / sum(total_exec_time) OVER () AS pct,
          rows::numeric / NULLIF(calls, 0)                    AS rows_per_call,
          query
   FROM pg_stat_statements
   WHERE query NOT LIKE '%pg_stat_statements%'
   ORDER BY total_exec_time DESC LIMIT 20;" \
   | tee $TARGET_DIR/query-stats-summary-{n}.md
   fi

   # 9) 개선 후 실행계획 (Phase 6과 같은 쿼리, 같은 파라미터 값)
   psql -h localhost -p 5433 -U postgres -d mydb > /dev/null <<'SQL'
   BEGIN;
   EXPLAIN (ANALYZE, BUFFERS, VERBOSE) {대상 쿼리};
   ROLLBACK;
   SQL

   psql -h localhost -p 5433 -U postgres -d mydb <<'SQL' | tee -a $TARGET_DIR/query-plan-{n}.txt
   BEGIN;
   EXPLAIN (ANALYZE, BUFFERS, VERBOSE) {대상 쿼리};
   ROLLBACK;
   SQL
   ```

   - 이 블록도 대상 하나만 잰다. 다른 대상의 스크립트를 이어서 돌리게 하지 마라. (`SKILL.md`의 **대상 진행 규칙**)
   - `{n}`에는 이번 사이클 적용 후의 상태 번호를 넣는다. 앞선 상태의 파일을 덮어쓰지 마라.
   - EXPLAIN에는 Phase 6 **실행계획**에 적어둔 파라미터 값을 그대로 쓴다. 값을 바꾸면 계획이 비교 불가가 된다.
   - Phase 6과 마찬가지로 `BEGIN`과 `ROLLBACK`을 빼지 마라.
   - **되돌리기와 `VACUUM ANALYZE`를 Phase 4와 같은 자리에서 같은 방식으로 실행한다.** 하나라도 어긋나면 전후 비교가 아니라
     서로 다른 조건의 두 측정을 비교하게 된다. dead tuple이 남은 상태와 회수된 상태는 같은 INSERT의 단가를 2배 이상 벌린다.
   - 쓰기 부하가 포함된 시나리오면 1차 측정이 데이터를 불려놓았을 수 있다. 데이터 규모를 다시 확인한다.
   - 조건이 달라졌으면 그 사실을 기록에 명시하고, 비교 가능한 범위를 좁혀서 해석한다.

2. 실행이 끝나면 아래 파일을 Read로 읽는다. 터미널 출력을 붙여넣게 하지 마라.

   | 산출물 | 개선 후 (이번 사이클) | 개선 전 (비교 대상) |
   |---|---|---|
   | k6 요약 | `k6-test-summary-{n}.json` | `k6-test-summary-{n-1}.json` |
   | 쿼리 통계 | `query-stats-summary-{n}.md` | `query-stats-summary-{n-1}.md` |
   | 실행계획 | `query-plan-{n}.txt` | `query-plan-{n-1}.txt` |

   최초 상태와의 누적 변화가 필요하면 `-0` 파일을 함께 읽는다.

   - `checks_rate`가 Phase 4보다 떨어졌으면 응답 내용이 달라진 것이다. 수치 비교보다 이 사실을 먼저 보고한다.

3. 두 산출물을 가공본으로 다시 쓴다.

   - `query-stats-summary-{n}.md`: `template/query-stats-template.md`의 작성 규칙을 따라 같은 경로에 덮어쓴다.
     헤더의 **직전 상태 대비** 줄에 `{n-1}` 파일과의 델타를 적는다.
   - `k6-test-summary-{n}.json`: 최상위에 `delta_vs_prev` 객체를 덧붙인다. 다른 필드는 손대지 마라.

     ```json
     "delta_vs_prev": {
       "from": "k6-test-summary-{n-1}.json",
       "rps": { "before": 37.31, "after": 82.44 },
       "duration_p95_ms": { "before": 1734.5, "after": 612.8 },
       "duration_p99_ms": { "before": 2887.8, "after": 941.2 }
     }
     ```

     `before`와 `after`에는 각 파일에 적힌 값을 **그대로** 옮긴다. 자릿수를 줄이지 마라.
   - `query-plan-{n}.txt`는 원본 그대로 둔다.

4. 전후를 비교해 제시하고 **개선 여부 판정을 호출자에게 묻는다.** `SKILL.md`의 **분석 주도 규칙**을 따른다.
   제시할 때 **두 축을 모두 남긴다.**

   - **하드웨어 의존 증거**: p95, p99, RPS. 로컬 절대값은 신뢰하지 말고 상대 변화만 쓴다.
   - **하드웨어 독립 증거**: 요청당 쿼리 수, 검사 행 수 대 반환 행 수, 실행계획 변화, 캐시 적중률.
   - 실행계획을 노드별 표로 제시할 때는 **Phase 6의 칼럼 설명 표를 함께 붙인다.** 표만 던지지 마라.
   - 물을 것: "이 변화가 기법의 효과라고 보십니까, 아니면 측정 편차라고 보십니까?"
   - 개선이 없거나 오히려 나빠졌으면 그대로 제시한다. 수치를 유리하게 해석하지 마라.

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
- `.claude/resources/perf/{이슈번호}/{슬러그}/k6-test-summary-{n}.json` 생성 (`delta_vs_prev` 포함)
- `.claude/resources/perf/{이슈번호}/{슬러그}/query-stats-summary-{n}.md` 생성 (가공본)
- `.claude/resources/perf/{이슈번호}/{슬러그}/query-plan-{n}.txt` 생성 (원본 유지)
- `record.md`의 사이클 {n} **개선 후 지표**와 **판정**이 채워짐
- `record.md`의 진행 상태의 사이클 {n} Phase 8이 ✅으로 기록

### 실패 처리
- 재측정 조건이 1차와 달라졌는데 되돌릴 수 없으면, 비교 가능한 지표만 골라 해석하고 나머지는 "조건 변경으로 비교 불가"로 명시한다.
- 개선 후 에러율이 올랐으면 수치 비교보다 원인을 먼저 보고한다.

> 다음 Phase 조건: 종료 판정이거나 호출자가 종료를 선택한 경우 → Phase 9

> 계속하는 경우 → Phase 5 (`record.md`의 진행 상태에 사이클 행을 추가하고 번호를 +1)

> Skip 조건: 없음 (필수 Phase)
