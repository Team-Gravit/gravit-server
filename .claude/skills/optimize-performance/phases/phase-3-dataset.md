## Phase 3. 측정 조건 구성

### 목적
데이터 규모와 카디널리티를 확정해 시드를 채우고(3-A, 이슈 공용),
부하 조건과 캐시 상태를 확정해 k6 스크립트를 만든다(3-B, 대상별).

### 선행 조건
- Phase 2 완료

### 참조 파일
- `.claude/skills/optimize-performance/template/seeds/README.md`
- `.claude/skills/optimize-performance/template/k6-script-template.js`
- `src/main/java/gravit/code/test/user/TestUserCheatCreateController.java`

---

### 3-A. 데이터셋 (이슈 공용)

> 같은 이슈의 다른 대상에서 이미 채웠으면 건너뛰고 3-B로 간다.
> 단, 이번 대상의 쿼리가 앞선 대상이 다루지 않은 테이블을 읽으면 그 테이블만 추가로 채운다.

1. 아래를 호출자에게 실행하도록 제시하고 결과를 받는다.

   ```bash
   psql -h localhost -p 5433 -U postgres -d mydb -c "
   SELECT relname, n_live_tup FROM pg_stat_user_tables ORDER BY n_live_tup DESC LIMIT 15;"
   ```

2. 목표 규모를 호출자와 확정한다.
   - Phase 1에서 확정한 쿼리가 읽는 테이블만을 대상으로 삼는다. 그 외 테이블은 다루지 않는다.
   - 정렬, 집계, 윈도우 함수가 걸린 쿼리가 있다면 해당 테이블의 목표 규모를 개별 수치로 확정한다.
   - 목표 규모는 스킬이 임의로 확정하지 않는다. 호출자와의 인터렉션을 통해 확정한다.

3. 목표 카디널리티를 호출자와 확정한다.
   - 대상 쿼리의 `WHERE`, `ORDER BY`, `GROUP BY`에 쓰이는 컬럼마다 서로 다른 값의 개수를 정한다.
   - Phase 5-B의 인덱스 설계가 이 값을 근거로 쓴다. 확정하지 않은 채 넘어가지 마라.

4. 현재 행 수가 목표 규모에 미달하는 테이블이 있다면 `template/seeds/README.md`를 Read하고,
   필요한 모듈을 골라 `.claude/resources/perf/{이슈번호}/seeds.sql`을 만든다.
   - **모듈 본문을 복사하지 마라.** 변수 블록을 쓰고 `\i`로 모듈을 불러오는 형태로만 작성한다.
   - 필요한 테이블이 기존 모듈에 없을 때만 그 테이블 블록을 `seeds.sql`에 직접 쓴다.
     같은 이슈에서 두 번 이상 쓸 것 같으면 새 모듈로 만들자고 호출자에게 제안한다.
   - 실행 명령을 호출자에게 제시하고, 모듈 말미의 검증 쿼리 결과를 받는다.

     ```bash
     psql -h localhost -p 5433 -U postgres -d mydb -f $PERF_DIR/seeds.sql
     ```

   - 검증 결과가 2번, 3번에서 확정한 값과 어긋나면 변수를 고쳐 다시 실행하게 한다.
     어긋난 채로 4번을 통과시키지 마라.

5. 확정한 목표 규모, 카디널리티, 실제 검증값을 `.claude/resources/perf/{이슈번호}/{슬러그}/record.md`의 **측정 환경**에 적는다.

---

### 3-B. 부하 스크립트 (대상별)

1. `template/k6-script-template.js`를 Read하고, 작성 규칙에 따라 스크립트를 작성한다.
   - `.claude/resources/perf/{이슈번호}/{슬러그}/test-script.js`로 파일을 생성한다.
   - `TARGET`에는 Phase 1에서 정한 슬러그를, `ENDPOINT`에는 경로를 그대로 넣는다.
   - `tokens.json`은 이슈 디렉토리에 있다. `open('../tokens.json')` 경로를 바꾸지 마라.
   - 실행은 Phase 4에서 호출자가 직접 한다.

2. 부하 조건(VU, duration)과 캐시 상태(cold / warm)를 호출자와 확정해
   스크립트의 `CONDITION` 블록과 `record.md`의 **측정 환경**에 적는다.
   - 같은 이슈의 다른 대상과 조건을 맞출지 호출자에게 확인한다. 조건이 다르면 대상 간 비교가 불가능해진다.
   - 이후 사이클에서 이 값이 바뀌면 변경된 값과 변경 시점을 같은 항목에 덧붙인다. 기존 값을 덮어쓰지 마라.

### 출력
- `.claude/resources/perf/{이슈번호}/seeds.sql` 생성 (시드가 필요한 경우)
- `.claude/resources/perf/{이슈번호}/{슬러그}/test-script.js` 생성
- `record.md`의 측정 환경에 목표 데이터 규모, 카디널리티, 부하 조건, 캐시 상태가 기록
- `record.md`의 진행 상태의 Phase 3이 ✅로 기록

### 실패 처리
- 없음

> 다음 Phase 조건: k6 스크립트가 작성되었고 목표 규모에 도달했을 때 → Phase 4

> Skip 조건: 3-A는 이슈 공용이므로 이미 채워졌으면 건너뛴다.
> 3-B는 2회차 이상이고 스크립트가 이미 있으면 건너뛴다. 둘 다 건너뛰면 진행 상태에 ⏭️로 표기한다.
