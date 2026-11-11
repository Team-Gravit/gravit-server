# [PLAN-610] 친구 검색 30만 명 이상 전체 스캔 해소

> 이슈: #610
> 브랜치: refactor/610-friend-search-statistics

## 목표
닉네임 정확 일치가 0건인 검색어(`코딩`, `김`, `raread`)는 유저 30만~40만부터 플래너가 기본키 전체 스캔으로 빠진다(100만 약 180ms). `lower(nickname)` 통계가 부분 인덱스에만 있어 플래너가 쓰지 못하기 때문이다.
`lower(nickname) COLLATE "C"` **표현식 통계**를 마이그레이션으로 추가해, 쿼리와 인덱스는 그대로 두고 100만까지 닉네임 인덱스를 타게 한다.

## 현재 코드에서 확인한 사실 (계획의 근거)
| # | 사실 | 위치 |
|---|---|---|
| F1 | 정확 일치, 접두 버킷은 `lower(nickname) COLLATE "C"`로 거르고 정렬한다. 이 식의 인덱스는 `WHERE deleted_at IS NULL` 부분 인덱스 하나뿐이다 | `FriendsNicknameSearchQuerySql`, `V28__add_friend_search_indexes.sql` |
| F2 | 부분 인덱스의 식 통계는 플래너의 선택도 추정에 쓰이지 않는다. 그래서 모든 검색어가 등치 기본값 0.5%로 추정된다(30만 기준 추정 1,456건, 실제 0건). 닉네임 인덱스 경로 비용이 추정 건수에 비례해 커지고, 30만~40만에서 기본키 경로 비용을 넘는다 | `docs/perf-remeasure/plan.md` §11 F-1 |
| F3 | 복제 DB에서 표현식 통계를 넣으면 40만 `코딩`이 추정 1,939 → 2건, 73.8 → 0.045ms가 된다. 100만 `코딩`, `김`, `raread`는 4,847 → 2건, 166~172 → 0.045~0.047ms다. `민준`, `james`는 기본키 경로를 유지한다(0.1~0.5ms). 정확 일치 버킷만 1회 잰 값이다 | 같은 문서 §11 F-1 "이미 확인한 것" |
| F4 | 현재(개선 후) HTTP p95 중앙값은 100만 기준 `코딩` 101.9ms, `김` 234.2ms, `raread` 324.8ms다. `민준` 7.8ms, `james` 9.0ms와 차이가 크다 | `benchmark/_runs/V-F-HS/output.log` |
| F5 | 식에 대한 `CREATE STATISTICS`는 PostgreSQL 14부터 된다. 로컬, 테스트 컨테이너, 벤치는 15다. 운영 DB는 compose 밖에 있어 버전이 저장소에 없다. **14 미만이면 마이그레이션이 실패하고 앱이 뜨지 않는다** | `docker-compose-local.yml`, `PostgreSQLTestContainerConfig:14`, `application-prod.yml:53` |
| F6 | `CREATE STATISTICS`는 정의만 만든다. 값은 다음 `ANALYZE` 때 채워진다. autovacuum의 자동 ANALYZE는 변경 행이 `50 + 10%`를 넘어야 돌기 때문에, 유저 테이블이 크게 바뀌지 않으면 오래 비어 있을 수 있다 | PostgreSQL 기본 `autovacuum_analyze_*` |
| F7 | 테스트는 Flyway를 끄고 `ddl-auto: create`로 스키마를 만든다. 빌드의 `flywayValidate`는 H2에서 이름과 체크섬만 본다. 마이그레이션 내용은 테스트로 검증되지 않는다 | `application-test.yml:9, 37-38`, `build.gradle:98-105` |
| F8 | 다음 번호 V51은 #608 계획서가 쓴다(`V51__add_league_point_grant.sql`, 미머지). 운영 Flyway는 `outOfOrder`가 꺼져 있어, 높은 번호가 먼저 적용되면 낮은 번호는 검증 실패로 앱이 뜨지 않는다 | `PLAN-608.md`, `application-prod.yml:53-60` |
| F9 | 앱(JDBC)이 일반 계획(generic plan)을 쓰는지 아직 확인하지 않았다. psql에서는 10만 `raread` custom 0.1ms, generic 23ms였다 | `docs/perf-remeasure/plan.md` §11 F-3 |

## 영향 범위
### 신규 파일
- `src/main/resources/db/migration/V51__add_users_nickname_lower_stats.sql` - `lower(nickname) COLLATE "C"` 표현식 통계와 `ANALYZE users`
- `.claude/resources/perf/610/` - 측정 기록

### 수정 파일
- 없음. 쿼리, 인덱스, 코드는 바꾸지 않는다
- 서비스 정책 변경 없음(`friend-social.md`의 검색 규칙과 결과 순서는 그대로다)

## 구현 계획
### STEP 1. 마이그레이션 (Flyway)
`V51__add_users_nickname_lower_stats.sql`
```sql
-- V51__add_users_nickname_lower_stats.sql

-- 닉네임 정확, 접두 검색의 선택도 추정용 표현식 통계
-- 식 인덱스가 부분 인덱스(ix_users_nickname_lower_cover)뿐이라 플래너가 그 통계를 쓰지 못해,
-- 정확 일치 0건 검색어를 0.5%로 추정하고 30만~40만부터 기본키 전체 스캔을 고른다
CREATE STATISTICS IF NOT EXISTS st_users_nickname_lower_c
    ON (lower(nickname) COLLATE "C") FROM users;

-- 통계 값을 바로 채운다. 없으면 다음 자동 ANALYZE까지 통계가 비어 있다
ANALYZE users;
```
- 식은 쿼리, 인덱스와 글자 단위로 같아야 한다(`lower(nickname) COLLATE "C"`). 콜레이션이 다르면 플래너가 통계를 맞춰 보지 못한다
- `ANALYZE`에 컬럼 목록을 주지 않는다. 컬럼을 지정하면 확장 통계가 만들어지지 않을 수 있어서, 테이블 전체로 돌린다
- `ANALYZE`는 트랜잭션 안에서 실행할 수 있다(Flyway 기본 트랜잭션 안에서 돈다). 잠금은 `SHARE UPDATE EXCLUSIVE`라 읽기와 쓰기를 막지 않는다. 표본은 기본 3만 행이라 유저 수와 상관없이 수 초 안에 끝난다

### Repository / Service / Facade / DTO / Controller
- 변경 없음. Facade 불필요

## 결정 필요 (Decisions needed)
- [x] D1. 운영 PostgreSQL 버전 - **16 확인(14 이상), 그대로 진행**. `SHOW server_version;` 결과로 확정. 14 이상이면 그대로 진행한다. 14 미만이면 이 계획을 멈추고 DB 업그레이드를 별도 이슈로 연다. `DO` 블록에서 버전을 보고 건너뛰는 방식은 쓰지 않는다. 조용히 효과가 없는 마이그레이션이 남기 때문이다
- [x] D2. 마이그레이션에 `ANALYZE users` 포함 - **포함**. 빼면 F6대로 통계가 언제 채워질지 정해지지 않는다. 운영 배포 뒤 수동 실행으로 대신할 수도 있지만, dev, 벤치, 새 환경에서 빠뜨리기 쉽다. 비용은 F6과 STEP 1대로 작다. 같은 실행으로 `users`의 다른 컬럼 통계도 새로 고쳐지지만, 이것은 자동 ANALYZE가 언제든 하는 일과 같다
- [x] D3. 마이그레이션 번호 - **V51로 두고 #608보다 먼저 머지**. 이 작업은 마이그레이션 하나와 측정이라 #608 구현보다 먼저 끝난다. V51을 쓰면 #608은 구현 때 V52로 번호를 바꾼다(아직 미구현이라 바꿀 파일은 계획서뿐이다). 어느 쪽이든 F8 때문에 **머지 순서와 번호 순서가 같아야** 한다

## 검증
### 대상 테스트
- 자동 테스트 없음. 테스트는 Flyway를 쓰지 않아 통계가 만들어지지 않는다(F7). 결과 순서와 정확도는 통계로 바뀌지 않으므로(계획만 바뀐다) 기존 테스트가 회귀를 맡는다
- 대신 아래 측정의 정확도 검증(M1)과 실행 계획 확인(M2)이 검증을 맡는다

### 측정 계획 (이력서 수치용)
기록 위치는 `.claude/resources/perf/610/`이고, 숫자는 측정 대장에 ID와 로그를 함께 올린 것만 쓴다. 10월 재측정 하네스(`benchmark/`)와 조건을 따르고, Claude가 직접 실행한다. 새 variant `after-stats`(코드 = after, 상태 = after + 통계)를 기존 `after`와 비교한다.

| ID | 무엇을 | 방법 | 전(`after`) | 후 목표(`after-stats`) |
|---|---|---|---|---|
| M0 | 하네스 준비 | `VARIANT`에 `after-stats` 추가, `guard_state`가 `pg_statistic_ext`의 통계 정의까지 확인 | - | 가드 통과 |
| M1 | 정확도 | `F-C` 4규모 | 결과 오류 0, 정책 불일치 0 | 유지 |
| M2 | 실행 계획이 바뀌는 규모 | `F-P` 1만, 10만, 30만, 40만, 100만. 정확 일치 0건 검색어 1페이지의 계획 노드, 읽은 페이지 수, 시간 | 30만~40만부터 기본키 전체 스캔 | 100만까지 닉네임 인덱스, 1ms 미만 |
| M3 | 상한 탐색 | 깨끗한 상태와 앱 갱신 재현 상태(`upper_check.sh`) 모두 100만까지 | 갱신 상태는 10만~30만부터 전환 | 두 상태 모두 100만까지 전환 없음 |
| M4 | HTTP 전후 | `V-F-HS` 형식, 1만, 10만, 30만, 100만. `after` ↔ `after-stats` ABBA 5회 중앙값 | F4 값(100만 `코딩` 101.9, `김` 234.2, `raread` 324.8ms) | 차이 기록. `민준`, `james`, 핸들 검색은 회귀 없음 |
| M5 | 쓰기 | 30초 쓰기 ABBA | - | 차이 없음 예상(통계는 `ANALYZE` 때만 갱신된다). 확인용 |
| M6 | 앱의 일반 계획 사용 | 앱 세션에서 `pg_prepared_statements.generic_plans`, 또는 `auto_explain`으로 실제 계획 확인(F9) | 확인한 적 없음 | 일반 계획을 쓴다면 그 계획도 닉네임 인덱스를 타는지 기록 |

- 판정 기준(실행 전에 고정): 100만에서 깨끗한 상태와 갱신 상태 모두 `코딩`, `김`, `raread` 1페이지가 닉네임 인덱스를 타고 1ms 미만이다. `민준`, `james`, 핸들 검색은 "차이 없음" 이상이다. 정확도 0/21을 유지한다
- M6에서 앱이 일반 계획을 쓰고, 그 계획이 여전히 전체 스캔이면 이 계획의 범위를 넘는다. 결과만 기록하고 별도 이슈로 판단한다

### 배포 체크리스트
- [x] D1 운영 버전 확인(14 이상) - 16
- [ ] D3 순서대로 머지
- [ ] 배포 뒤 운영에서 통계 생성 확인: `SELECT stxname FROM pg_statistic_ext WHERE stxname = 'st_users_nickname_lower_c';`, `SELECT n_distinct FROM pg_stats_ext_exprs WHERE statistics_name = 'st_users_nickname_lower_c';`(값이 채워졌는지)

## Deviation Log
