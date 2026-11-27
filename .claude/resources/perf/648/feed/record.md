# [PERF-648] GET /api/v1/social/feed

> 이슈: #648
> 브랜치: refactor/648-follower-feed-scan
> 대상 디렉토리: `.claude/resources/perf/648/feed/`

이 파일은 대상 엔드포인트 하나만 다룬다. 같은 이슈의 다른 엔드포인트는 각자의 디렉토리에 각자의 `record.md`를 가진다.

## 진행 상태

> ⏳ 미완 / ✅ 완료 / ⏭️ 건너뜀
> 재진입 시 ⏳로 표기된 가장 이른 Phase부터 재개한다.

**준비 (대상당 1회)**

| 1. 대상 | 2. 환경 | 3. 조건 | 4. 기준선 |
|---|---|---|---|
| ✅ | ✅ | ✅ | ✅ |

**사이클 (반복)**

| # | 기법 | 5. 설계 | 6. 스냅샷 | 7. 적용 | 8. 검증 |
|---|---|---|---|---|---|
| 1 | 쿼리 재작성 (`ORDER BY uf.feedId DESC`) - 개선 없음, 되돌림 | ✅ | ✅ | ✅ | ✅ |

## 대상

- 엔드포인트: `GET /api/v1/social/feed?page={n}`
- 실행 경로: `JwtAuthFilter`(`AuthTokenProvider.parseUser` → `UserRepository.findById`) → `LastAccessInterceptor` → `SocialController.getFeed` → `SocialFacade.getFeed`(`@Transactional(readOnly = true)`) → `SocialFeedService.getFeed`(`PAGE_SIZE = 4`) → `UserFeedRepository.findVisibleFeedsByUserId`, `CongratulationRepository.findActorIdsWithLimitReached`, `CongratulationRepository.findCongratulatedFeedIds`
- 예상 쿼리 목록 (요청 1회 기준)
  1. `AuthTokenProvider.parseUser` → `UserRepository.findById` (`JwtAuthFilter`) - `users` 1행 조회 (`deleted_at IS NULL`). 매 요청, 읽기 전용 트랜잭션
  2. `UserAccessService.updateLastAccessed` → `UserRepository.updateLastAccessedAt` (`LastAccessInterceptor`) - `users.last_accessed_at` 조건부 UPDATE. 매 요청, 그날 두 번째 요청부터 0행 갱신
  3. `UserDailyActivityRepository.insertIfAbsent` - `INSERT ... ON CONFLICT DO NOTHING`. 2번이 1행을 갱신했을 때만 (사용자별 그날 첫 요청)
  4. `UserFeedRepository.findVisibleFeedsByUserId` - `user_feed` JOIN `social_feed` JOIN `users`(작성자 프로필, `@SQLRestriction`의 `deleted_at IS NULL`), `WHERE uf.user_id = ? AND uf.is_hidden = false`, `ORDER BY sf.created_at DESC, sf.id DESC`, `OFFSET ? LIMIT 5` (Slice라 `PAGE_SIZE + 1`행을 읽고 count 쿼리 없음)
  5. `CongratulationRepository.findActorIdsWithLimitReached` - `congratulation`에서 `user_id = ? AND actor_id IN (…) AND created_at >= 오늘 0시`, `GROUP BY actor_id HAVING COUNT >= 3`. 4번 결과가 비어 있으면 실행하지 않음. IN 목록은 4번 결과(최대 4건)의 작성자 중복 제거
  6. `CongratulationRepository.findCongratulatedFeedIds` - `congratulation`에서 `user_id = ? AND feed_id IN (…)`. 4번 결과가 비어 있으면 실행하지 않음. IN 목록은 최대 4건
  - 지연 로딩 없음 (4번은 생성자 프로젝션, 5, 6번은 스칼라 조회)
  - 정상 상태 요청당 5개(1, 2, 4, 5, 6), 트랜잭션 3 (읽기 전용 2, 쓰기 1). 사용자별 그날 첫 요청만 6개
- 인덱스 현황: 미확인 (Phase 2의 6에서 실측)

## 측정 환경

> 값이 바뀌면 그 사실을 사이클 기록에 남긴다.

| 항목 | 값 |
|---|---|
| 프로파일 | perf (`application="gravit-perf"` 확인, 히스토그램 버킷 292개 노출). 베이스 `application.yml`은 `follower` 대상과 같은 로컬 전용 파일(`../follower/record.md` 측정 환경 참고) |
| 커넥션 풀 크기 | 60 (`application-perf.yml`의 `maximum-pool-size`, 풀 이름 `gravit-perf-pool`) |
| 데이터 규모 | 목표와 검증값 일치. `users` 시드 100,000 (id 1001~101000, 기존 3행 별도), `friends` 시드 범위 2,128,000 (`follower` 대상이 적재), `social_feed` 시드 500,000 (id 1,000,001~1,500,000), `user_feed` 시드 10,640,000 (= `friends` 2,128,000 × 5), `congratulation` 시드 200. 시드 범위 밖에 기존 `social_feed` 9행(id 9억 대, `created_at` 2025-10-27), `user_feed` 9행, `congratulation` 6행이 있으며 측정 사용자에게는 배포되지 않았다(측정 사용자의 범위 밖 피드 0) |
| 카디널리티 | `social_feed.actor_id` 100,000 (1명당 5건). `user_feed.user_id` 100,000, `feed_id` 500,000. 측정 사용자(id 1001~1100) 1명당 피드 정확히 1,500 (min = max), 그중 숨기지 않은 피드 1,425 (`is_hidden` 비율 5.00%). 나머지 사용자 1명당 105~110 (평균 105.01, 팔로잉 20 + 측정 사용자 평균 1명). `social_feed.created_at`은 365일 구간(2025-11-27 ~ 2026-11-27)에서 id 순서와 같게 증가(시드 범위 안 역전 0). `congratulation`은 측정 사용자 100명 × 2건(숨기지 않은 최신 피드), `created_at`은 시드 실행 시각(2026-11-27) |
| 부하 조건 | VU 50, 유지 1m (ramp-up 30s + 유지 1m + ramp-down 30s = 총 2m). 요청은 `page=0` 고정, 측정 사용자 100명(id 1001~1100) 토큰을 반복 번호로 순환. `follower` 대상과 같은 조건 |
| Redis 캐시 상태 | 해당 없음. 대상 API가 Redis를 읽지 않음 (그래도 Phase 4, 8 절차의 FLUSHDB는 그대로 수행) |
| DB 캐시 상태 | 제어하지 않음. warmup(VU 5, 30s) 후 측정 |
| VACUUM 방식 | `VACUUM (ANALYZE, PARALLEL 0);` (Phase 4, 8 공통). 기본 `VACUUM ANALYZE`는 병렬 인덱스 vacuum이 공유 메모리 약 64MB를 잡다가 컨테이너 `/dev/shm`(기본 64MB) 부족으로 `could not resize shared memory segment ... No space left on device` 오류로 중단됐다(2026-11-27 08:45, `user_feed`, `social_feed`, `congratulation` 미처리). 그 상태로 진행된 첫 기준선 측정은 무효로 보고 다시 쟀다 |
| 캐시 제어 수단 | `docker exec gravit-redis-local redis-cli` (로컬에 redis-cli 없음, PONG 확인) |
| 스키마 드리프트 | 이번 대상 테이블(`user_feed`, `social_feed`, `congratulation`, `users`, `user_daily_activity`)은 없음. 6)이 출력한 7개(`ix_interview_answer_concept_result_answer`, `ix_interview_answer_session`, `ix_interview_answer_wrong_concept_answer`, `ix_interview_question_category_difficulty`, `ix_interview_question_concept_question`, `ix_interview_stack_axis_stack`, `ix_interview_tech_stack_job_role`)는 `follower` 대상 때와 같은 목록으로, V40에서만 만들어지고 V41이 테이블을 `DROP TABLE`로 재생성하며 함께 사라진 것이라 실제 누락이 아님. 모두 이번 대상이 읽지 않는 `interview_*` 테이블. `pg_stat_statements` 동작 확인(count 18) |
| 시드 SQL | `../seeds.sql` (이슈 공용). 컨테이너 안 psql로 실행 (`docker cp` 후 `docker exec -w /tmp/perf ... -v ON_ERROR_STOP=1 -f`). `user.sql`, `friend.sql`은 가드로 0행, `feed.sql` 적재 포함 총 7분 11초 |
| 시드 모듈과 변수 | `user.sql`, `friend.sql`(`follower` 대상과 같은 변수), `feed.sql`(이번 대상에서 신규). `feed_id_base=1000000`, `feeds_per_actor=5`, `feed_window_days=365`, `hidden_pct=5`, `congrats_per_hot_user=2` |

## 기준선 (Baseline)

| 지표 | 값 |
|---|---|
| p95 | 1292.10753 ms (중앙값 833.7481, max 2447.4927) |
| p99 | 1700.5457579999988 ms |
| RPS | 50.72388248425837 (요청 6090건) |
| 에러율 | 0 |
| check 통과율 | 1 (데이터 검증 포함 3개 항목 6090/6090) |
| 요청당 쿼리 수 | SELECT 4 + UPDATE 1, 트랜잭션 3 (읽기 전용 2, 쓰기 1) |

### 쿼리 통계 (total_exec_time 상위)

> 전체: `query-stats-summary-0.md` / k6 요약: `k6-test-summary-0.json`
> 여기에는 진단 근거로 쓴 행만 옮긴다. 전체를 복사하지 않는다.

| 요청당 | mean_ms | total_ms | 비중 | 출처 |
|---|---|---|---|---|
| 1.00000000000000000000 | 711.6196148844017 | 4333763.454646006 | 99.94357517838404% | `UserFeedRepository.findVisibleFeedsByUserId` (행/호출 5) |
| 1.00000000000000000000 | 0.1383818898193761 | 842.7457090000003 | 0.019435075311599343% | `CongratulationRepository.findActorIdsWithLimitReached` (행/호출 0) |
| 1.00000000000000000000 | 0.08075717422003274 | 491.8111910000004 | 0.011341959305274107% | `CongratulationRepository.findCongratulatedFeedIds` (행/호출 2) |

### 진단

- 병목 성격: 쿼리 자체 비효율 (피드 조회 쿼리 1건)
- 근거: 요청당 1회라 N+1이 아니다. 이 쿼리가 DB 시간의 99.94357517838404%이고 mean 711.6196148844017 ms로 나머지 쿼리(0.14 ms 이하)와 3자리 넘게 차이 난다. 반환은 5행(`LIMIT 5`)뿐이라 읽는 양이 반환량보다 훨씬 많다고 볼 수 있다. API 중앙값 833.7481 ms 중 이 쿼리 mean이 711.6 ms다. 거르는 조건(`user_feed.user_id`, `is_hidden`)과 정렬 기준(`social_feed.created_at`, `id`)이 서로 다른 테이블에 있어, 사용자의 피드(측정 사용자 1,500건)를 모은 뒤 정렬해야 할 것으로 보인다. 읽는 범위가 사용자 피드 전체인지 테이블 전체인지는 Phase 6 실행계획으로 확인한다 (mean은 VU 50 동시 실행 중 값)
- 예상 쿼리 목록과 어긋난 지점: 없음. 정상 상태 5개(`findById`, `updateLastAccessedAt`, 피드 조회, 축하 2개)와 트랜잭션 3이 예상과 같다. 조건부 INSERT(`user_daily_activity`)는 측정 사용자가 이미 오늘 요청해 나오지 않았다. 요청 경로 밖 쿼리(`season`, `user_league` 조회 등)는 요청당 0.006회 이하

---

## 사이클 1: 쿼리 재작성

### 설계 결정

> Phase 5-B에서 호출자와 확정한 내용.

```java
// UserFeedRepository.findVisibleFeedsByUserId - ORDER BY 한 줄만 바꾼다
ORDER BY uf.feedId DESC
// 변경 전: ORDER BY sf.createdAt DESC, sf.id DESC
```

| 결정 항목 | 정한 값 | 근거 |
|---|---|---|
| 기법 | 쿼리 재작성 (정렬 기준을 거르는 테이블로 이동) | 거르는 조건(`user_feed.user_id`, `is_hidden`)과 정렬(`social_feed.created_at`, `id`)이 다른 테이블에 있어 조인 후에야 정렬할 수 있다. `user_feed` 인덱스(사이클 2 후보)는 이 정렬을 대신하지 못하므로 재작성이 먼저다. 효과를 따로 재기 위해 인덱스와 분리했다 |
| 정렬 칼럼 | `uf.feedId DESC` 단독 (동점 처리 칼럼 없음) | NOT NULL이고 한 사용자 안에서 피드마다 다르므로 단독으로 순서가 유일하게 정해진다(OFFSET 페이징 경계 안정). `social_feed.id`와 같은 값이라 지금의 동점 처리 칼럼과 같고, 첫 칼럼 `sf.created_at`과는 id와 `created_at` 순서가 어긋난 피드에서만 달라진다 |
| `uf.created_at`을 택하지 않은 이유 | - | NULL 허용이라 `DESC`에서 NULL이 맨 앞에 온다. 동점 처리 칼럼이 따로 필요하다. 화면 시각(`sf.created_at`)이 아니라 배포 시각이다 |
| 쿼리 구조 | A. 정렬만 변경, JPQL과 조인은 그대로 | 탈퇴한 작성자의 피드(`users`의 `deleted_at IS NULL`)를 조인 후 자르므로 5행 채우기와 `hasNext`가 지금과 같다. 서브쿼리로 먼저 자르는 안(B)은 탈퇴 작성자 피드가 섞이면 덜 나오고 `hasNext`가 달라진다 |
| id 순서와 `created_at` 순서 | 운영 정상 경로는 일치로 판단 | `social_feed`를 넣는 코드는 `SocialFeedService.createFeed`(`save`) 하나. `BaseEntity.onPrePersist`가 KST로 `created_at`을 찍고 IDENTITY라 INSERT가 바로 나가 id를 받는다. 동시 생성 시 수 ms 범위 역전만 가능. 재시도는 id와 시각을 함께 새로 받는다. 앱 인스턴스 1대 |
| 함께 바꿀 것 | QA 픽스처 `sql/seed/qa/04_social.sql`의 `social_feed` INSERT를 시간순으로 | `created_at`을 직접 넣고 INSERT 순서가 시간 역순이라(aux-01 STREAK D-1 → TIER D-2) 정렬 변경 후 페르소나 `social`의 피드 순서가 뒤집힌다. `@Profile("!prod")` 적재라 운영 무관, 측정 대상 코드 아님 |
| 배포 전 확인 | 운영 DB에서 id와 `created_at` 역전 건수 조회, 결과를 PR에 남김 | 수동 작업이나 과거 코드가 넣은 데이터는 코드로 확인할 수 없다 |
| 정책 | `friend-social.md`에 피드 정렬 기준 문장 추가 (PLAN-648 단계 D) | 지금 정책에 정렬 기준 문장이 없다 |

- 검토했지만 택하지 않은 안: 인덱스 추가 - 지금 정렬(`sf.created_at`)을 대신하지 못해 단독으로는 효과가 없다(사이클 2 후보) / 캐싱 - 피드 배포 시 팔로워 전원(측정 사용자 기준 1,000명), 숨김, 축하, 작성자 프로필 변경, 탈퇴까지 무효화 경로가 많다 / 서브쿼리로 먼저 자르기 - 탈퇴 작성자 피드 처리와 `hasNext`가 달라진다
- 호출자가 예상한 효과: Sort가 조인 아래(`user_feed` 바로 위)로 내려가고 `social_feed`, `users` 조회 loops가 약 1,425에서 5 수준으로 감소. mean이 수십 ms로 감소. 호출자의 첫 예상 "Sort가 top-N 정렬로 바뀐다"도 신호로 본다 (Phase 5에서는 지금도 top-N일 것이라 봤으나, Phase 6 실측 `query-plan-0.txt`에서 지금 Sort는 `quicksort`였다)

### 개선 전 지표

| 지표 | 값 |
|---|---|
| p95 / p99 | 1292.10753 / 1700.5457579999988 ms |
| RPS | 50.72388248425837 |
| 요청당 쿼리 수 | SELECT 4 + UPDATE 1, 트랜잭션 3 |
| 대상 쿼리 calls / mean_ms / total_ms | 6090 / 711.6196148844017 / 4333763.454646006 (DB 시간의 99.94357517838404%) |

부하 조건: VU 50, 유지 1m (총 2m), `user_feed` 시드 10,640,000행(측정 사용자 1인당 1,500, 숨기지 않은 것 1,425), 커넥션 풀 60. Phase 4 측정과 같다.

**실행계획**

> 원본: `query-plan-0.txt` (개선 후는 `query-plan-1.txt`)

- EXPLAIN 파라미터: `$1 = 1050`, `$2 = 5`, `$3 = false` (측정 사용자 범위 1001~1100의 가운데, `LIMIT 5`, `is_hidden`. 이후 모든 사이클에서 동일하게 사용). Query Identifier `-1832497529186848477`
- 스캔 방식: `user_feed` Parallel Bitmap Heap Scan(`ix_user_feed_user_id` Bitmap Index Scan, Heap Blocks 300) → `social_feed_pkey` Index Scan을 Nested Loop로 1,425회 → Sort(`created_at DESC, id DESC`, quicksort 171kB) → Gather Merge(워커 1, 워커 처리 0행) → `users_pkey` Index Scan 5회 → Limit 5
- actual rows 대 반환 행 수: `user_feed` 1,500행 읽음, 숨김 필터 후 1,425행을 `social_feed`에 조인해 정렬, 최종 5행 반환 (285:1)
- Rows Removed by Filter: 38 × loops 2 (총 약 75, 숨김 피드)
- shared hit / read: 6036 / 0 (약 47.2MB). 그중 `social_feed` PK 조회가 5700(1회 4페이지 × 1,425), `user_feed` 307, `users` 15
- 플래너 추정 대 실측: Bitmap Index Scan rows=2837 / actual 1500 (1.9배), 조인 결과 rows=1585 / actual 712 × 2
- Execution Time 17.777 ms (단건, 부하 중 mean 711.6 ms와 별개), Planning Time 5.684 ms
- 해석: 작업량 기준 비용은 `social_feed` PK 조회 1,425회에 있다. 쿼리가 만진 페이지의 94.4%(5700 / 6036)이고, 결과 5행을 내기 위해 1,425행을 조인한 뒤 정렬한다. 단건 시간으로는 Sort가 1.700 ms에 끝나는데 Gather Merge가 15.751 ms에 첫 행을 내 병렬 워커 기동과 조정에 약 14 ms가 쓰였다(워커는 0행 처리). 병렬 계획은 1,425행 조인을 포함한 추정 비용(19850.94) 때문에 선택된 것으로, 조인 대상이 줄면 함께 사라질지는 Phase 8에서 확인한다

- 로직 개선 추가 캡처: 변경 전 요청당 쿼리 수 SELECT 4 + UPDATE 1, 트랜잭션 3. 대상 쿼리 호출 스택 `SocialController.getFeed` → `SocialFacade.getFeed` → `SocialFeedService.getFeed` → `UserFeedRepository.findVisibleFeedsByUserId`

> 캐싱 사이클이 아니면 개선 후 지표의 캐시 행은 `-`로 둔다.

### 적용 내용

- `src/main/java/gravit/code/social/repository/UserFeedRepository.java` - `findVisibleFeedsByUserId`의 `ORDER BY sf.createdAt DESC, sf.id DESC`를 `ORDER BY uf.feedId DESC`로 변경. JPQL의 SELECT, 조인, WHERE는 그대로
- `src/main/resources/sql/seed/qa/04_social.sql` - `social_feed` INSERT의 VALUES를 시간순(aux-01 TIER D-2 → aux-01 STREAK D-1 20:30 → social LEVEL_UP D-1 21:00)으로 바꾸고 `ORDER BY f.published_at`을 붙여 IDENTITY id가 시각 순서대로 매겨지게 함. 이어지는 `user_feed`, `congratulation` INSERT는 `actor_id`와 `event_type`으로 피드를 찾으므로 영향 없음. 측정 대상 코드 아님
- 테스트 (2026-11-27): `./gradlew test` 1641건 중 2건 실패 → 이번 변경과 무관하다고 판단, 단독 재실행 통과
  - 실패: `NotificationFacadeIntegrationTest$NotifyInApp`의 `팔로우_알림은_인앱에만_저장되고_FCM은_발송되지_않는다`, `친구활동_알림은_여러_유저_인앱에만_저장된다`. 둘 다 `RedisConnectionFailureException: Unable to connect to Redis` ← `Connection initialization timed out after 1 second(s)` (테스트 Redis 컨테이너 연결 초기화 단계에서 시간 초과, 검증 단계 전)
  - 근거: 변경은 피드 조회 정렬과 QA 픽스처 SQL뿐이고 Redis 연결, 알림 경로와 무관하다. 피드 조회 테스트(`SocialFeedServiceIntegrationTest$GetFeed` 6건, `SocialFacadeIntegrationTest$GetFeed` 4건)를 포함한 social 패키지 63건은 실패 0
  - 확인: `./gradlew test --tests "gravit.code.notification.facade.NotificationFacadeIntegrationTest"` 단독 실행 4건 실패 0
  - 피드 정렬 순서를 검증하는 테스트는 아직 없다 (PLAN-648 단계 D에서 `SocialFeedServiceIntegrationTest`에 추가 예정)

### 개선 후 지표

> 원본: `k6-test-summary-1.json`, `query-stats-summary-1.md`, `query-plan-1.txt`. 조건은 Phase 4와 같다 (VU 50, 총 2m, 시드 동일, 풀 60, warmup 후, `VACUUM (ANALYZE, PARALLEL 0)`, FLUSHDB, 통계 리셋). check 6890/6890, 실패 0. Query Identifier는 `ORDER BY`가 바뀌어 -0과 다르다(`-900483650828982939`)

| 구분 | 지표 | 개선 전 | 개선 후 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 1292.10753 ms | 986.1397649999999 ms | 약 23.7% 감소 (통계 변화가 섞여 기법 효과로 볼 수 없음) |
| | p99 | 1700.5457579999988 ms | 1120.1944749999984 ms | 약 34.1% 감소 (같음) |
| | RPS | 50.72388248425837 | 57.40820804561288 | 약 1.13배 (같음) |
| 하드웨어 독립 | 요청당 쿼리 수 | SELECT 4 + UPDATE 1, 트랜잭션 3 | 같음 | 변화 없음 |
| | 대상 쿼리 total_ms | 4333763.454646006 (mean 711.6196148844017) | 4327359.730335016 (mean 628.0638215290288) | 요청 수 6090 → 6890 |
| | 검사 행 / 반환 행 | `user_feed` 1,500 읽음, 1,425행 조인, 5행 반환 | 같음 | 변화 없음 |
| | 스캔 방식 | Parallel Bitmap Heap Scan → `social_feed` NL 1425 → quicksort → Gather Merge → `users` NL 5, 6,036페이지 | Index Scan `ix_user_feed_user_id` → `social_feed` NL 1425 → `users` NL 1425 → top-N heapsort, 10,285페이지 | 정렬은 조인 아래로 내려가지 않음 |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 사이클 아님 |

- 통계 변화 확인: 두 측정 사이의 `VACUUM (ANALYZE, PARALLEL 0)`(08:52 → 09:40)로 `user_feed` 추정 rows가 2,837 → 104로 바뀌었다(`user_id` n_distinct 95,398 → 96,599). 원래 쿼리를 지금 통계로 다시 뜨면(임시 확인, 파일 미보존) 비용 추정 1343.91, 버퍼 10,288, `social_feed`와 `users` loops 1425, top-N heapsort, Execution 5.687 ms로 재작성 쿼리(1343.91, 10,285, 4.511 ms)와 같은 계획이다. 측정 사용자(1인당 1,500행)가 표본의 최빈값에 잡히는지에 따라 추정이 흔들린 것으로 보이나 `most_common_vals`는 확인하지 않았다
- 호출자 예상과 대조: "Sort가 조인 아래로 내려가고 loops가 5로 감소"는 어긋났다. `user_feed`에 `feed_id` 순서로 읽을 경로(인덱스)가 없으면 플래너는 정렬을 조인 아래로 내리지 않는다. "mean 수십 ms"도 어긋났다(628 ms). "top-N 정렬로 바뀜"은 관측됐지만 같은 통계의 원래 쿼리도 top-N이라 재작성 효과가 아니다

### 판정

- 개선 여부 (하드웨어 독립 증거 기준): 없음 - 같은 통계에서 원래 쿼리와 계획, 비용 추정, 버퍼, loops가 같다. 부하 지표 변화는 플래너 통계 변화가 섞인 것이다
- 남은 위험 신호: 검사 행 / 반환 행 1,425 : 5 (285:1), 대상 쿼리 점유율 99.94434611075538%, 플래너 추정 대 실측 104 / 1,425 (13.7배)
- 다음 사이클 진행 여부: 종료 (호출자 선택). 재작성은 인덱스(`user_feed (user_id, feed_id DESC)`)의 전제라 단독 효과가 없고, 비용은 사용자 1명의 피드 수에 비례한다. 로컬의 1인당 1,500건은 계획서 기준으로 만든 값이라 운영 규모(사용자당 피드 분포)를 보기 전에는 인덱스의 쓰기 비용과 정렬 의미 변경을 감수할 근거가 부족하다고 봤다. 코드 변경(`UserFeedRepository` 정렬, QA 픽스처 `04_social.sql`)은 되돌렸다
- 다시 검토할 때: 운영에서 `user_feed`의 사용자당 숨기지 않은 피드 수 p50, p99, max를 조회한다. p99가 수백 건을 넘거나 max가 1,000건 근처면 재작성과 인덱스를 한 사이클로 묶어 다시 진행한다. 그때는 Phase 8마다 통계가 흔들리지 않게 비교 방법(같은 통계로 원래 쿼리 재측정 또는 `SET STATISTICS` 상향)을 먼저 정한다

---

## 최종 요약

> 하드웨어 의존 증거와 독립 증거를 모두 남긴다.

| 구분 | 지표 | 최초 | 최종 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 1292.10753 ms | - | 코드 되돌림, 최종 상태 = 원본 |
| | p99 | 1700.5457579999988 ms | - | 같음 |
| | RPS | 50.72388248425837 | - | 같음 |
| 하드웨어 독립 | 요청당 쿼리 수 | SELECT 4 + UPDATE 1, 트랜잭션 3 | 같음 | 변화 없음 |
| | 검사 행 / 반환 행 | 1,425 : 5 | 같음 | 변화 없음 |
| | 스캔 방식 | `ix_user_feed_user_id` + `social_feed` NL 1425 + 정렬 | 같음 | 변화 없음 |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 사이클 없음 |

적용한 기법: 1. 쿼리 재작성 (`ORDER BY uf.feedId DESC`) - 개선 없음, 되돌림

- 종료 사유: 사이클 1 판정표의 "하드웨어 독립 증거에 변화가 없음"에 해당하고 호출자가 종료를 선택
