## Phase 4. 기준선 측정

### 목적
기준선 측정 결과를 받아 병목이 어디서 발생하는지 판정한다.

### 선행 조건
- Phase 3 완료
- `.claude/resources/perf/{이슈번호}/test-script.js` 존재

### 참조 파일
- 없음

### 절차

1. 아래 순서로 실행하도록 제시한다. **측정 실행은 호출자가 한다.** 순서를 바꾸지 마라.

   ```bash
   # 새 터미널이면 먼저: export PERF_DIR=.claude/resources/perf/{이슈번호}

   # 1) 토큰 발급 (통계 리셋 전에 끝낸다)
   seq {USER_ID_START} {USER_ID_START + USER_COUNT - 1} \
     | while read -r id; do
         curl -s -X POST "localhost:8080/api/v1/test/users/login?userId=$id" | jq -r '.accessToken // empty'
       done \
     | jq -R -s 'split("\n") | map(select(length > 0))' > $PERF_DIR/tokens.json

   # 2) 워밍업 (JIT, 커넥션 풀). 이 실행의 결과는 쓰지 않는다.
   k6 run -e PHASE=warmup $PERF_DIR/test-script.js

   # 3) 캐시 비우기 - Phase 3에서 cold를 택한 경우에만 실행한다
   #    {캐시 제어 수단}은 record.md 측정 환경에 적어둔 값을 그대로 쓴다
   {캐시 제어 수단} -n 0 FLUSHDB

   # 4) 쿼리 통계 리셋
   psql -h localhost -p 5433 -U postgres -d mydb -c "SELECT pg_stat_statements_reset();"

   # 5) 측정 부하
   k6 run -e PHASE=measure \
     -e SUMMARY_OUT=$PERF_DIR/k6-test-summary-0.json \
     $PERF_DIR/test-script.js

   # 6) 쿼리 통계 수집 (total_exec_time 기준 정렬)
   psql -h localhost -p 5433 -U postgres -d mydb -c "
   SELECT calls, round(mean_exec_time::numeric,2) AS mean_ms,
          round(total_exec_time::numeric,2) AS total_ms, left(query,120) AS query
   FROM pg_stat_statements
   WHERE query NOT LIKE '%pg_stat_statements%'
   ORDER BY total_exec_time DESC LIMIT 20;" \
   | tee $PERF_DIR/query-stats-0.txt
   ```

2. 실행이 끝나면 아래 두 파일을 Read로 읽는다.

   | 산출물 | 파일 |
   |---|---|
   | k6 요약 | `.claude/resources/perf/{이슈번호}/k6-test-summary-0.json` |
   | 쿼리 통계 | `.claude/resources/perf/{이슈번호}/query-stats-0.txt` |

   - 터미널 출력을 붙여넣게 하지 마라. 원본은 파일로만 주고받는다.
   - 파일이 없으면 원인을 확인하고 재실행을 요청한다. 추정으로 채우지 마라.
   - k6 요약에는 스크립트가 선별해 내보낸 값만 있다. 필드는 아래와 같다.
     - `requests`, `rps`, `failed_rate`, `checks_rate`
     - `checks[]` - 항목별 `name` / `passes` / `fails`
     - `duration_ms`, `waiting_ms` - 각각 `med` / `p95` / `p99` / `max`
     - `bytes_received`
   - `checks_rate`가 1이 아니면 `checks[]`에서 어떤 항목이 깨졌는지 먼저 확인한다. 데이터 검증 check가 깨진 측정은 진단에 쓰지 마라.

3. 요청당 쿼리 수를 계산한다.
   - 분모는 요약의 `requests`다. 측정 프로세스는 대상 API만 호출한다.
   - `mean_exec_time`이 아니라 `total_exec_time`으로 판단한다.
   - 요청당 호출 횟수를 Phase 1의 예상 쿼리 목록과 대조한다.

4. 아래 표로 병목의 성격을 판정한다.

   | 관측 | 진단 | 유력한 기법 |
   |---|---|---|
   | 특정 쿼리 1건이 느리고 호출 수는 예상대로 | 쿼리 자체 비효율 | 인덱스, 쿼리 재작성 |
   | 쿼리는 빠른데 호출 수가 요청당 N배 | N+1 | fetch join, DTO projection, batch size |
   | 쿼리 효율적이고 호출도 적은데 API가 느림 | DB 밖 문제 | 직렬화, 외부 호출, 이벤트 처리 |
   | 매 요청이 같은 결과를 다시 계산 | 불필요한 재조회 | 캐싱 |
   | 단건은 빠른데 VU를 올리면 급락 | 자원 경합 | 커넥션 풀, 트랜잭션 범위 축소 |

5. 판정과 근거를 `.claude/resources/perf/{이슈번호}/record.md`의 **기준선**에 남긴다. 근거에는 관측된 수치를 쓴다.

### 출력
- `.claude/resources/perf/{이슈번호}/tokens.json` 생성
- `.claude/resources/perf/{이슈번호}/k6-test-summary-0.json` 생성
- `.claude/resources/perf/{이슈번호}/query-stats-0.txt` 생성
- `.claude/resources/perf/{이슈번호}/record.md`의 **기준선** 표와 쿼리 통계, 진단이 채워짐
- `.claude/resources/perf/{이슈번호}/record.md`의 진행 상태의 Phase 4가 ✅로 기록

### 실패 처리
- 에러율이 높거나 데이터 검증 check가 깨져 측정이 무의미하면, 원인을 짚어 스크립트나 시드를 수정한 후 재측정하도록 안내한다. 실패한 측정치로 진단하지 않는다.

> 다음 Phase 조건: 병목의 성격이 판정되었고 근거 수치가 기록되었을 때 → Phase 5

> Skip 조건: 없음 (필수 Phase)
