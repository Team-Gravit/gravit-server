## Phase 2. 측정 환경 검증

### 목적
측정값을 왜곡하는 설정은 없는지, 쿼리 단위 관측 도구와 캐시 제어 수단이 유효한지 확인한다.

**게이트.** 하나라도 충족하지 못하면 다음 Phase로 넘어가지 마라. 호출자에게 조치를 요청한다.

### 선행 조건
- Phase 1 완료

### 참조 파일
- `src/main/resources/application-perf.yml`

### 절차

1. perf 프로파일로 기동하도록 호출자에게 제시한다. 별도 터미널에서 실행하게 하고, 기동 완료를 확인받은 뒤 2번으로 간다.

   ```bash
   ./gradlew bootRun --args='--spring.profiles.active=perf'
   ```

2. 아래를 **적힌 순서대로** 실행하도록 제시하고 결과를 받는다. 3)은 요청이 한 번 들어온 뒤에만 값이 잡히므로 2)를 건너뛰지 마라.

   ```bash
   # 1) perf 프로파일로 떠 있는가 (application 태그가 gravit-perf여야 한다)
   curl -s localhost:8080/actuator/prometheus | grep -m1 'application='

   # 2) 미터 등록용 1회 요청
   curl -s -o /dev/null -w '%{http_code}\n' localhost:8080/actuator/health

   # 3) 응답시간 히스토그램이 노출되는가 (0이면 SLO 버킷 설정이 안 붙은 것)
   curl -s localhost:8080/actuator/prometheus | grep -c http_server_requests_seconds_bucket

   # 4) pg_stat_statements가 살아있는가
   psql -h localhost -p 5433 -U postgres -d mydb -c "SELECT count(*) FROM pg_stat_statements;"

   # 5) 캐시를 비울 수 있는가 (PONG이 나와야 한다)
   redis-cli -h localhost -p 6379 ping

   # 6) 마이그레이션이 선언한 인덱스가 실제 DB에 있는가
   #    아무것도 출력되지 않아야 한다. 출력된 이름은 있어야 하는데 없는 인덱스다
   comm -23 \
     <(comm -23 \
         <(grep -rhoE 'CREATE (UNIQUE )?INDEX (IF NOT EXISTS )?[a-z0-9_]+' src/main/resources/db/migration/ \
             | awk '{print $NF}' | sort -u) \
         <(grep -rhoE 'DROP INDEX (IF EXISTS )?[a-z0-9_]+' src/main/resources/db/migration/ \
             | awk '{print $NF}' | sort -u)) \
     <(psql -h localhost -p 5433 -U postgres -d mydb -Atc \
         "SELECT indexname FROM pg_indexes WHERE schemaname='public'" | sort)
   ```

3. 4)가 `relation "pg_stat_statements" does not exist`로 실패하면 `docker-compose-local.yml`의 postgres 서비스에 아래를 추가한 뒤 재기동하도록 안내한다.

   ```yaml
   command: postgres -c shared_preload_libraries=pg_stat_statements -c pg_stat_statements.track=all
   ```

   재기동 후:
   ```bash
   psql -h localhost -p 5433 -U postgres -d mydb -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"
   ```

4. 5)가 실패하면 `docker-compose-local.yml`의 redis 서비스 기동 상태를 확인하도록 안내한다.
   redis-cli가 없으면 대체 명령을 제시한다.

   ```bash
   docker exec gravit-redis-local redis-cli ping
   ```

5. 6)이 하나라도 출력하면 **로컬 DB가 마이그레이션이 선언한 스키마와 다르다.** 그대로 재면 없는 병목을 최적화하게 된다.
   출력된 이름을 그대로 호출자에게 보이고, 아래를 확인한 뒤 복구하도록 안내한다.

   이 검사는 **선언됐는데 없는 인덱스만** 찾는 단방향 대조다. 마이그레이션에 없는 추가 인덱스나
   이름은 같고 정의가 다른 경우는 걸러내지 못한다. 그리고 이 결과만으로 **운영 DB가 어떤 상태인지는 알 수 없다.**
   운영과의 차이가 쟁점이면 dev나 운영 DB에 같은 조회를 돌려 따로 확인한다.

   ```sql
   SELECT indexname FROM pg_indexes WHERE indexname IN ({출력된 이름들});
   ```

   - `flyway_schema_history`에 해당 마이그레이션이 success로 남아 있는지 확인한다.
     success인데 인덱스가 없으면 Flyway 밖에서 지워진 것이다.
     **누락된 인덱스를 만드는 마이그레이션 버전으로 조회한다.** 최근 몇 건만 보면 초기 버전이 걸리지 않는다.

     ```bash
     psql -h localhost -p 5433 -U postgres -d mydb -c "
     SELECT version, description, success, installed_on
     FROM flyway_schema_history WHERE version IN ({누락 인덱스를 만드는 버전들}) ORDER BY installed_rank;"
     ```

   - 복구는 해당 마이그레이션의 `CREATE INDEX` 문을 **그대로** 실행한다. 정의를 새로 쓰지 마라.
     복구 후 `ANALYZE {테이블}`로 플래너 통계를 갱신하고, 6)을 다시 돌려 출력이 비었는지 확인한다.
   - 무엇이 지웠는지는 저장소에 흔적이 남지 않는 경우가 많다. 원인을 특정하지 못해도 복구하고 진행하되,
     그 사실을 `record.md`의 **측정 환경**에 적는다. 추측을 원인으로 단정해 적지 마라.

   **게이트 통과 기준.** 원칙은 출력이 빌 때까지 복구하는 것이다.
   다만 남은 누락 인덱스가 **이번 대상의 쿼리가 읽지 않는 테이블**의 것뿐이면, 복구하지 않고 통과로 처리해도 된다.
   이때는 남은 이름과 "이번 대상이 그 테이블을 읽지 않는다"는 근거를 `record.md`의 **스키마 드리프트**에 반드시 적는다.
   근거 없이 통과시키지 마라. 다음 대상이 그 테이블을 읽으면 그 대상의 Phase 2에서 다시 걸린다.

   실행계획에 예상 밖의 Seq Scan이 나왔을 때 "플래너가 인덱스를 고르지 않았다"고 해석하기 전에
   이 검사를 먼저 통과했는지 확인하라. 인덱스가 아예 없는 경우와 구분되지 않는다.

6. 확인 결과를 `.claude/resources/perf/{이슈번호}/{슬러그}/record.md`의 **측정 환경**에 기록한다.
   - 커넥션 풀 크기는 `application-perf.yml`의 `maximum-pool-size`를 Read로 읽어 적는다.
   - 캐시 제어 수단을 실행 가능한 형태로 적는다.
     `redis-cli -h localhost -p 6379` 또는 `docker exec gravit-redis-local redis-cli` 중 5)에서 통한 쪽이다.
     Phase 4와 8이 이 문자열 뒤에 `-n 0 FLUSHDB`를 붙여 쓴다.
   - 6)의 결과를 **스키마 드리프트** 항목으로 적는다. 없으면 `없음`, 있었으면 복구한 인덱스 이름과 복구 사실을 적는다.

### 출력
- `.claude/resources/perf/{이슈번호}/{슬러그}/record.md`의 측정 환경에 프로파일, 커넥션 풀 크기, 캐시 제어 수단, 스키마 드리프트가 기록
- `.claude/resources/perf/{이슈번호}/{슬러그}/record.md`의 진행 상태의 Phase 2가 ✅로 기록

### 실패 처리
- 없음

> 다음 Phase 조건: 2번의 여섯 항목이 모두 통과했을 때 → Phase 3

> Skip 조건: 같은 이슈의 다른 대상에서 이미 통과했고, 그 사이에 애플리케이션과 컨테이너를 재기동하지 않았으며,
> DB 스키마도 그대로면 앞선 대상의 `record.md` **측정 환경**을 그대로 옮겨 적고 건너뛴다. 진행 상태에는 ⏭️로 표기한다.
> 단 그 사이에 아래 중 하나라도 있었으면 6)은 다시 확인한다. 앱을 재기동하지 않아도 DB는 바뀐다.
>
> - Phase 3-A의 시드 실행 (대량 적재 전후에 인덱스가 사라진 사례가 있다)
> - 인덱스 복구, 추가, 삭제
> - 마이그레이션 실행
> - 앞선 대상이 게이트 통과 기준의 예외(대상 밖 테이블)로 넘어갔고, 이번 대상이 그 테이블을 읽는 경우
>
> 무엇이 있었는지 확신할 수 없으면 다시 확인한다. 6)은 명령 한 줄이라 재실행 비용이 거의 없다.
