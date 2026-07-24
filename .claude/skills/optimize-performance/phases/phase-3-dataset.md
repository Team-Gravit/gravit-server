## Phase 3. 측정 조건 구성

### 목적
데이터 규모, 카디널리티, 부하 조건, 캐시 상태를 확정하고, 시드 SQL과 k6 스크립트를 작성한다.

### 선행 조건
- Phase 2 완료

### 참조 파일
- `.claude/skills/optimize-performance/template/seeds-template.sql`
- `.claude/skills/optimize-performance/template/k6-script-template.js`
- `src/main/java/gravit/code/test/user/TestUserCheatCreateController.java`

### 절차

1. 아래를 호출자에게 실행하도록 제시하고 결과를 받는다.

   ```bash
   psql -h localhost -p 5433 -U postgres -d mydb -c "
   SELECT relname, n_live_tup FROM pg_stat_user_tables ORDER BY n_live_tup DESC LIMIT 15;"
   ```

2. 목표 규모를 호출자와 확정한다.
   - Phase 1에서 나열한 쿼리가 읽는 테이블만을 대상으로 삼는다. 그 외 테이블은 다루지 않는다.
   - 정렬, 집계, 윈도우 함수가 걸린 쿼리가 Phase 1 목록에 있다면, 해당 테이블의 목표 규모를 개별 수치로 확정한다.
   - 목표 규모는 스킬이 임의로 확정하지 않는다. 호출자와의 인터렉션을 통해 확정한다.

3. 목표 카디널리티를 호출자와 확정한다.
   - 대상 쿼리의 `WHERE`, `ORDER BY`, `GROUP BY`에 쓰이는 컬럼마다 서로 다른 값의 개수를 정한다.
   - Phase 5-B의 인덱스 설계가 이 값을 근거로 쓴다. 확정하지 않은 채 넘어가지 마라.
   - 확정한 값을 `.claude/resources/perf/{이슈번호}/record.md`의 **측정 환경**에 적는다.

4. 현재 행 수가 목표 규모에 미달하는 테이블이 있다면, `template/seeds-template.sql`을 Read하고, 작성 규칙에 따라 시드 SQL을 작성한다.
   - `.claude/resources/perf/{이슈번호}/seeds.sql`로 파일을 생성한다.
   - 3번에서 확정한 카디널리티를 검증 쿼리에 포함시킨다.
   - 실행 명령을 호출자에게 제시하라.

5. `template/k6-script-template.js`를 Read하고, 작성 규칙에 따라 k6 스크립트를 작성한다.
   - `.claude/resources/perf/{이슈번호}/test-script.js`로 파일을 생성한다.
   - 실행은 Phase 4에서 호출자가 직접 한다.

6. 부하 조건(VU, duration, 목표 데이터 규모)과 캐시 상태(cold / warm)를 호출자와 확정해
   `.claude/resources/perf/{이슈번호}/record.md`의 **측정 환경**에 적는다.
   - 이후 사이클에서 이 값이 바뀌면 변경된 값과 변경 시점을 같은 항목에 덧붙인다. 기존 값을 덮어쓰지 마라.

### 출력
- `.claude/resources/perf/{이슈번호}/test-script.js` 생성
- `.claude/resources/perf/{이슈번호}/seeds.sql` 생성 (시드가 필요한 경우)
- `.claude/resources/perf/{이슈번호}/record.md`의 측정 환경에 목표 데이터 규모, 카디널리티, 부하 조건, 캐시 상태가 기록
- `.claude/resources/perf/{이슈번호}/record.md`의 진행 상태의 Phase 3이 ✅로 기록

### 실패 처리
- 없음

> 다음 Phase 조건: k6 스크립트가 작성되었고 목표 규모에 도달했을 때 → Phase 4

> Skip 조건: 2회차 이상이고 스크립트와 데이터가 이미 준비되어 있으면 건너뛰고 Phase 4로 간다. 진행 상태에는 ⏭️로 표기한다.
