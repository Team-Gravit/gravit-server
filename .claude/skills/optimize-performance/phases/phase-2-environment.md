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

5. 확인 결과를 `.claude/resources/perf/{이슈번호}/record.md`의 **측정 환경**에 기록한다.
   - 커넥션 풀 크기는 `application-perf.yml`의 `maximum-pool-size`를 Read로 읽어 적는다.
   - 캐시 제어 수단(`redis-cli` / `docker exec`)도 반드시 적는다. Phase 4와 8이 이 명령을 그대로 쓴다.

### 출력
- `.claude/resources/perf/{이슈번호}/record.md`의 측정 환경에 프로파일, 커넥션 풀 크기, 캐시 제어 수단이 기록
- `.claude/resources/perf/{이슈번호}/record.md`의 진행 상태의 Phase 2가 ✅로 기록

### 실패 처리
- 없음

> 다음 Phase 조건: 2번의 다섯 항목이 모두 통과했을 때 → Phase 3

> Skip 조건: 없음 (필수 Phase)
