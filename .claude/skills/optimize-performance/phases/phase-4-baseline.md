## Phase 4. 기준선 측정

### 목적
기준선을 측정하고, 그 결과를 소비 가능한 형태로 가공해 호출자에게 제시한다.
병목이 어디인지는 호출자가 판정한다.

### 선행 조건
- Phase 3 완료
- `.claude/resources/perf/{이슈번호}/{슬러그}/test-script.js` 존재

### 참조 파일
- `.claude/skills/optimize-performance/template/query-stats-template.txt`

### 절차

1. 아래 순서로 실행하도록 제시한다. **측정 실행은 호출자가 한다.** 순서를 바꾸지 마라.

   이 블록은 대상 하나만 잰다. 다른 대상의 스크립트를 이어서 돌리게 하지 마라.
   `pg_stat_statements`는 인스턴스 전역이라 리셋 없이 다음 대상을 재면 통계가 섞이고,
   `per_req`의 분모(`requests`)가 이 대상의 것이므로 요청당 쿼리 수가 틀린 값이 된다.
   (`SKILL.md`의 **대상 진행 규칙**)

   ```bash
   # 새 터미널이면 먼저:
   #   export PERF_DIR=.claude/resources/perf/{이슈번호}
   #   export TARGET_DIR=$PERF_DIR/{슬러그}

   # 1) 토큰 발급 (통계 리셋 전에 끝낸다. 이슈 공용이므로 이미 있으면 건너뛴다)
   seq {USER_ID_START} {USER_ID_START + USER_COUNT - 1} \
     | while read -r id; do
         curl -s -X POST "localhost:8080/api/v1/test/users/login?userId=$id" | jq -r '.accessToken // empty'
       done \
     | jq -R -s 'split("\n") | map(select(length > 0))' > $PERF_DIR/tokens.json

   # 2) 워밍업 (JIT, 커넥션 풀). 이 실행의 결과는 쓰지 않는다.
   k6 run -e PHASE=warmup $TARGET_DIR/test-script.js

   # 3) 캐시 비우기 - Phase 3에서 cold를 택한 경우에만 실행한다
   #    {캐시 제어 수단}은 record.md 측정 환경에 적어둔 값을 그대로 쓴다
   {캐시 제어 수단} -n 0 FLUSHDB

   # 4) 쿼리 통계 리셋
   psql -h localhost -p 5433 -U postgres -d mydb -c "SELECT pg_stat_statements_reset();"

   # 5) 측정 부하
   k6 run -e PHASE=measure \
     -e SUMMARY_OUT=$TARGET_DIR/k6-test-summary-0.json \
     $TARGET_DIR/test-script.js

   # 6) 쿼리 통계 수집 (요청 수를 분모로 넘겨 요청당 호출 수까지 뽑는다)
   REQS=$(jq -r '.requests' $TARGET_DIR/k6-test-summary-0.json)

   psql -h localhost -p 5433 -U postgres -d mydb -A -F ' | ' -c "
   SELECT calls,
          round(calls::numeric / $REQS, 2)                               AS per_req,
          round(mean_exec_time::numeric, 2)                              AS mean_ms,
          round(total_exec_time::numeric, 2)                             AS total_ms,
          round(100 * total_exec_time / sum(total_exec_time) OVER (), 1) AS pct,
          round(rows::numeric / NULLIF(calls, 0), 1)                     AS rows_per_call,
          query
   FROM pg_stat_statements
   WHERE query NOT LIKE '%pg_stat_statements%'
   ORDER BY total_exec_time DESC LIMIT 20;" \
   | tee $TARGET_DIR/query-stats-summary-0.txt
   ```

   - `-A -F ' | '`를 빼지 마라. 정렬 출력은 쿼리 원문을 잘라 리포지토리 메서드를 식별할 수 없게 만든다.

2. 실행이 끝나면 아래 두 파일을 Read로 읽는다.

   | 산출물 | 파일 |
   |---|---|
   | k6 요약 | `.claude/resources/perf/{이슈번호}/{슬러그}/k6-test-summary-0.json` |
   | 쿼리 통계 | `.claude/resources/perf/{이슈번호}/{슬러그}/query-stats-summary-0.txt` |

   - 터미널 출력을 붙여넣게 하지 마라. 파일이 없으면 원인을 확인하고 재실행을 요청한다. 추정으로 채우지 마라.
   - k6 요약에는 스크립트가 선별해 내보낸 값만 있다. 담기지 않은 지표가 필요해지면 재측정해야 한다.
   - `checks_rate`가 1이 아니면 `checks[]`에서 어떤 항목이 깨졌는지 먼저 확인한다.
     데이터 검증 check가 깨진 측정은 진단에 쓰지 마라.

3. `query-stats-summary-0.txt`를 가공본으로 다시 쓴다.
   `template/query-stats-template.txt`를 Read하고 작성 규칙을 따른다.

   - 1차 출력을 읽어 **같은 경로에 덮어쓴다.** 1차 출력을 따로 보존하지 않는다.
   - 각 쿼리를 어느 코드가 날렸는지 Grep으로 찾아 **출처** 칸을 채운다.
     Phase 1에서 확정한 예상 쿼리 목록이 1차 후보다. 목록에 없는 쿼리는 인증 필터, 인터셉터, 이벤트 리스너를 의심한다.
   - 출처를 특정하지 못한 쿼리는 `미상`으로 두고 넘어간다. 그럴듯한 이름을 지어내지 마라.
   - **판정을 쓰지 마라.** 이 파일에는 사실만 남긴다.

4. 가공된 두 파일의 내용을 호출자에게 제시하고 **병목 판정을 묻는다.**
   `SKILL.md`의 **분석 주도 규칙**을 따른다.

   - 제시할 것: 응답시간 분포, 처리량, check 결과, 쿼리별 요청당 호출 수와 총 시간 비중.
   - 물을 것: "요청당 쿼리 수와 시간이 쏠린 지점을 보고, 병목의 성격을 어떻게 판단하십니까?"
   - 결론을 먼저 말하지 마라. 아래 표는 호출자가 막혔을 때 꺼내는 재료다.

   | 관측 | 진단 | 유력한 기법 |
   |---|---|---|
   | 특정 쿼리 1건이 느리고 호출 수는 예상대로 | 쿼리 자체 비효율 | 인덱스, 쿼리 재작성 |
   | 쿼리는 빠른데 호출 수가 요청당 N배 | N+1 | fetch join, DTO projection, batch size |
   | 쿼리 효율적이고 호출도 적은데 API가 느림 | DB 밖 문제 | 직렬화, 외부 호출, 이벤트 처리 |
   | 매 요청이 같은 결과를 다시 계산 | 불필요한 재조회 | 캐싱 |
   | 단건은 빠른데 VU를 올리면 급락 | 자원 경합 | 커넥션 풀, 트랜잭션 범위 축소 |

5. 호출자의 판정에 대해 타당성을 확인한다.
   - Phase 1의 예상 쿼리 목록과 실제 `per_req`가 어긋난 지점이 있으면 반드시 짚는다.
   - 시간 비중이 낮은 쿼리를 병목으로 지목했으면 `pct` 수치로 반례를 든다.

6. 확정된 판정과 근거를 `.claude/resources/perf/{이슈번호}/{슬러그}/record.md`의 **기준선**에 남긴다.
   근거에는 관측된 수치를 쓴다. 판정의 주체가 호출자였다는 사실은 따로 적지 않는다.

### 출력
- `.claude/resources/perf/{이슈번호}/tokens.json` 생성
- `.claude/resources/perf/{이슈번호}/{슬러그}/k6-test-summary-0.json` 생성
- `.claude/resources/perf/{이슈번호}/{슬러그}/query-stats-summary-0.txt` 생성 (가공본)
- `record.md`의 **기준선** 표와 쿼리 통계, 진단이 채워짐
- `record.md`의 진행 상태의 Phase 4가 ✅로 기록

### 실패 처리
- 에러율이 높거나 데이터 검증 check가 깨져 측정이 무의미하면, 원인을 짚어 스크립트나 시드를 수정한 후 재측정하도록 안내한다. 실패한 측정치로 진단하지 않는다.

> 다음 Phase 조건: 병목의 성격이 판정되었고 근거 수치가 기록되었을 때 → Phase 5

> Skip 조건: 없음 (필수 Phase)
