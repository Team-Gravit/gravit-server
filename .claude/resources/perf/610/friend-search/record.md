# [PERF-610] GET /api/v1/friends/search

> 이슈: #610
> 브랜치: refactor/610-friend-search-statistics
> PR: #617
> 계획서: `.claude/resources/plans/PLAN-610.md` (측정 M0~M6)
> 대상 디렉토리: `.claude/resources/perf/610/friend-search/`

이 기록은 `optimize-performance` 스킬이 아니라 10월 재측정 하네스(`benchmark/`, gitignore 대상)로 쟀다. 하네스는 k6 대신 앱 HTTP 부하(8클라이언트 60초), `EXPLAIN (ANALYZE, BUFFERS)`, pgbench 쓰기, auto_explain으로 잰다. 숫자의 원본은 측정 대장(my-employment `측정/그래빗-벤치/측정-대장.md`, "친구 검색 표현식 통계 (#610 · 2026-11-12~)" 절 86행)과 `logs/{테스트ID}/`다. 노션 정리: "2026-11-12/ 친구 검색 표현식 통계 측정 (#610)".

## 진행 상태

| 측정 | 내용 | 상태 |
|---|---|---|
| M0 | 하네스 `after-stats` variant, 확장 통계 가드 | ✅ |
| M1 | 정확도 | ✅ |
| M2 | 실행 계획 · 깨끗한 상태 | ✅ |
| M3 | 실행 계획 · 앱 갱신 재현 상태 | ✅ |
| M4 | HTTP ABBA 5회 | ✅ |
| M5 | 쓰기 30초 ABBA 5회 | ✅ |
| M6 | 앱이 실제로 쓰는 계획 | ✅ |

## 대상

- 엔드포인트: `GET /api/v1/friends/search?queryText={q}&page={n}`
- 쿼리: `FriendsNicknameSearchQuerySql`(nick_c: 포함 검색 있음, nick_nc: 없음), `FriendsHandleSearchQuerySql`. 검색어 하나로 정확 일치 → 접두 → 포함 버킷을 차례로 채운다
- 변경: `V53__add_users_nickname_lower_stats.sql` 하나. `CREATE STATISTICS st_users_nickname_lower_c ON (lower(nickname) COLLATE "C") FROM users` + `ANALYZE users`. 쿼리, 인덱스, 코드는 그대로다
  - 측정 당시 번호는 V51이었다. 콘텐츠 확장(#621)이 V51을 먼저 써서 `8a5e911b`에서 V53으로 바꿨고, 파일 내용은 같다. 하네스 출력 원문(`app-plan-1.txt` 머리글 등)에는 V51로 남아 있다
- 비교
  - `after` (`-0`): 코드 `f07ee5f6`, 인덱스 V28, 통계 없음. 10월 개선 후 상태
  - `after-stats` (`-1`): `after`와 쿼리, jar가 같고 DB에 V53 통계만 더한 상태. `f07ee5f6`부터 HEAD까지 `friend` 패키지 코드는 바뀌지 않았다

## 환경과 데이터

- 로컬 docker `gravit-postgres-bench`(PostgreSQL 15.18, shared_buffers 128MB), 앱 jar `f07ee5f6`, HikariCP 60
- 시드: 1만, 10만, 30만, 40만, 100만(+고정 경계 케이스 96, 탈퇴 3%). 결정적 생성기라 시드 통계가 10월과 바이트 단위로 같다(`X-S-*`). 스키마는 V1~V50(V53 통계는 상태에서만 추가)
- 환경 점검 `X-E-20261112-run2`: AC 전원, pgbench -S 105,704 TPS(직전 대비 -1.7%). 측정 중 load average 2.2~9.9 (10월 2.4~4.2), 회차마다 기록
- 앱 갱신 재현 상태: HTTP 측정이 인증하는 139명의 `last_accessed_at` 갱신 + `VACUUM ANALYZE users`. `last_accessed_at` 인덱스 때문에 non-HOT 갱신이 되고, VACUUM이 index cleanup을 건너뛰어 일부 페이지가 all-visible이 아니게 된다(10만 이상 11페이지, 1만은 재현 안 됨). 실제 서비스가 늘 이 상태다

## 판정 기준 (실행 전 고정)

- 100만에서 깨끗한 상태와 갱신 상태 모두 `코딩`, `김`, `raread`(정확 일치 0건) 1페이지가 닉네임 인덱스를 타고 1ms 미만
- `민준`, `james`, 핸들 검색은 "차이 없음" 이상
- 정확도 0/21 유지

## 결과

### M1 · 정확도 (`F-C-{10k,100k,300k,1m}-after-stats`)

결과 오류 0/21, 페이지 간 중복 0, 누락 0, 정책(바이트 순) 불일치 0/21. 네 규모 모두 결과와 응답 샘플이 `F-C-*-after`와 같다.

### M2 · 실행 계획, 깨끗한 상태 (`F-P-*-after-stats` ↔ 10월 `F-P-*-after`)

1페이지 warm, 읽은 페이지 / p50

| 규모 | 코딩 -0 | 코딩 -1 | 김 -0 | 김 -1 | raread -0 | raread -1 |
|---|---|---|---|---|---|---|
| 30만 | 21p · 0.206ms | 21p · 0.215ms | 21p · 0.163ms | 21p · 0.167ms | 36p · 0.231ms | 36p · 0.245ms |
| 40만 | 8,787p · 57.448ms | 21p · 0.218ms | 8,787p · 57.809ms | 21p · 0.171ms | 8,801p · 60.637ms | 35p · 0.268ms |
| 100만 | 22,017p · 180.661ms | 15p · 0.219ms | 22,024p · 177.443ms | 21p · 0.174ms | 22,037p · 179.362ms | 35p · 0.256ms |

1만, 10만은 두 상태가 같다(19~32p, 0.16~0.25ms).

### M3 · 실행 계획, 앱 갱신 재현 상태 (`F-PU-*`)

| 규모 | 코딩 -0 | 코딩 -1 | 김 -0 | 김 -1 | raread -0 | raread -1 |
|---|---|---|---|---|---|---|
| 10만 | 21p · 0.204ms | 21p · 0.213ms | 22p · 0.166ms | 22p · 0.174ms | 32p · 0.231ms | 32p · 0.231ms |
| 30만 | 6,823p · 43.633ms | 21p · 0.207ms | 6,824p · 43.057ms | 22p · 0.172ms | 6,838p · 47.357ms | 36p · 0.246ms |
| 40만 | 9,020p · 60.034ms | 21p · 0.199ms | 9,021p · 59.443ms | 22p · 0.169ms | 9,034p · 59.809ms | 35p · 0.238ms |
| 100만 | 22,190p · 171.109ms | 15p · 0.219ms | 22,197p · 188.311ms | 22p · 0.172ms | 22,210p · 189.573ms | 35p · 0.235ms |

- `-0`의 상한(기본키 전체 스캔으로 바뀌는 규모)은 깨끗한 상태 30만~40만, 갱신 상태 10만~30만이다. `-1`은 두 상태 모두 100만까지 닉네임 인덱스다
- `민준`, `james`는 추정이 정확해지며 기본키 순서 경로(11건 채우면 멈춤)를 고르는 규모가 앞당겨졌다. 10만 갱신 상태 `민준` 0.304 → 0.453ms, `james` 0.388 → 0.300ms. 30만 이상은 `-0`도 같은 계획이다
- 계획 원본: `query-plan-0.txt`, `query-plan-1.txt` (100만 갱신 상태 `코딩`, `김`)

### M4 · HTTP (`F-HU-*`, 비교 화면 `V-F-HU` → `http-abba-view.txt`)

규모마다 ABBA 10회(회차 사이 60초 휴식), 각 60초, 8클라이언트, 검색어 7개 무작위 1페이지, 앱 갱신 재현 상태. 5회 범위가 겹치지 않을 때만 "차이 있음".

| 규모 | TPS 중앙값 -0 → -1 | 전체 p95 중앙값 -0 → -1 |
|---|---|---|
| 1만 | 2,949.2 → 3,035.8 (차이 없음) | 6.139 → 5.065ms (차이 없음) |
| 10만 | 1,237.0 → 1,216.5 (차이 없음) | 29.6 → 29.9ms (차이 없음) |
| 30만 | 350.0 → 520.3 (×1.5) | 83.8 → 83.9ms (차이 없음) |
| 100만 | 108.5 → 191.4 (×1.8) | 273.5 → 273.6ms (차이 없음) |

검색어별 p95 중앙값 -0 → -1 (✱ 범위 겹치지 않음)

| 검색어 | 30만 | 100만 |
|---|---|---|
| 김 | 57.5 → 2.871ms ✱ | 240.3 → 5.646ms ✱ |
| 코딩 | 18.1 → 17.7ms | 96.2 → 64.0ms ✱ |
| raread | 90.9 → 93.9ms ✱ | 323.9 → 295.1ms ✱ |
| 민준 | 3.644 → 2.937ms ✱ | 6.711 → 6.679ms |
| james | 3.922 → 3.167ms ✱ | 7.663 → 7.984ms |
| @ab, @qqbench1 | 3.0~3.8ms, 개선 ✱ | 약 6.0ms, 차이 없음 |

- `-0`은 10월 기준값(`V-F-HS` 100만: 코딩 101.9, 김 234.2, raread 324.8ms)을 재현했다
- 전체 p95가 그대로인 것은 꼬리를 `raread`가 정하기 때문이다. `코딩`, `raread`가 EXPLAIN(0.2ms대)보다 훨씬 느린 이유는 M6
- 이상치: 100만 `-1` r1만 TPS 794.8(나머지 184.6~193.3). 일반 계획 전환이 덜 일어난 회차로 추정하나 확인하지 않았다
- 하네스 한계: 회차마다 같은 139행을 다시 갱신해 all-visible 아닌 페이지가 누적됐다(100만 11 → 27페이지). ABBA라 두 상태가 고르게 겪었고 `-0` 10회는 105.5~109.4 TPS로 안정적이었다

### M5 · 쓰기 30초, 100만 (`F-W30-1m-*`, 비교 화면 `V-F-W30S` → `write-abba-view.txt`)

TPS 중앙값 11,616.7 ↔ 11,533.7, p50 0.650 ↔ 0.653ms, p99 1.030 ↔ 1.002ms, WAL 6,899 ↔ 6,918 B/건. 전부 차이 없음. 통계는 ANALYZE 때만 계산되어 쓰기 경로에 비용이 없다.

### M6 · 앱이 실제로 쓰는 계획 (`F-AP-*-run2` → `app-plan-{n}.txt`, `app-plan-requests-{n}.csv`)

실제 앱 + 이 DB에만 auto_explain(analyze, json). 검색어 7개 × 50회 순차(350건), 앱 갱신 재현 상태. 계획에 검색어 값이 상수로 있으면 custom, 없으면 generic.

100만, DB 실행 시간 p50

| 검색어 (SQL) | 실행된 계획 | -0 custom | -0 generic | -1 custom | -1 generic |
|---|---|---|---|---|---|
| 김 (nick_nc) | 50회 모두 custom | 174.1ms | — | 0.056ms | — |
| 코딩 (nick_c) | custom 3 → generic 47 | 188.0ms | 31.8ms | 0.198ms | 30.4ms |
| raread (nick_c) | custom 2 → generic 48 | 205.2ms | 136.6ms | 0.119ms | 108.8ms |
| 민준, james (nick_c) | custom 2 → generic 48 | 0.2~0.4ms | 1.1~1.9ms | 0.2~1.2ms | 1.1~2.0ms |
| 핸들 | 50회 모두 custom | 약 0.1ms | — | 약 0.07ms | — |

- nick_c SQL(코딩, 민준, james, raread 공용)은 16번째 요청부터 generic이다. nick_nc, 핸들 SQL은 끝까지 custom이었다
- 통계 효과는 custom 계획에만 있다. `김`의 HTTP 개선(240 → 5.6ms)이 이것이다
- generic이 느린 이유(`query-plan-1.txt`의 F-AP 계획): 값을 모르니 접두 `LIKE p.q_prefix`를 인덱스 범위로 못 바꿔 닉네임 인덱스를 처음부터 훑는다(코딩 29만 행 필터 제거, 28.8ms). 포함 `ILIKE`도 trigram GIN 대신 닉네임 인덱스 전체를 훑는다(raread 32만 행 제거, 73ms). V53과 무관한 문제다

## 결론

- V53은 계획 수준의 상한(정확 일치 0건 검색어의 기본키 전체 스캔)을 없앴다. 판정 기준 세 개를 모두 충족했고 쓰기 비용은 없다
- 앱 HTTP에서는 custom 계획으로 도는 검색(`김`)에 효과가 그대로 나타난다. nick_c SQL은 일반 계획으로 바뀌어 `코딩`, `raread`의 꼬리가 남는다
- 일반 계획의 접두·포함 버킷 문제는 PLAN-610 범위 밖이라 별도 이슈로 판단한다. 후보: 접두 범위를 쿼리에 직접 넘기기, 이 쿼리만 custom 계획 강제, pgjdbc `prepareThreshold` 조정

## 파일

| 파일 | 내용 |
|---|---|
| `query-plan-0.txt`, `query-plan-1.txt` | 100만 계획 원본(JSON). F-PU 갱신 상태 `코딩`, `김` 1페이지 + F-AP 앱 계획 `코딩`, `raread`의 custom/generic |
| `http-abba-view.txt` | M4 비교 화면 `V-F-HU` 원문 |
| `write-abba-view.txt` | M5 비교 화면 `V-F-W30S` 원문 |
| `app-plan-{n}.txt` | M6 100만 실행 화면 원문 |
| `app-plan-requests-{n}.csv` | M6 100만 요청 350건별 계획 종류, 버킷 노드, DB 시간 |
