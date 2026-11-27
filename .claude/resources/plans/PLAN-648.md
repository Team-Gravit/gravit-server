# [PLAN-648] 팔로워 조회와 소셜 피드 조회 전체 스캔 해소

> 이슈: #648
> 브랜치: refactor/648-follower-feed-scan

## 목표
`friends`에 `followee_id`로 시작하는 인덱스가 없어 팔로워 목록, 팔로워 수, 피드 배포 대상 조회가 테이블 전체를 읽고, 소셜 피드 목록은 조인한 `social_feed.created_at`으로 정렬해 사용자의 피드를 전부 읽은 뒤 20건을 고른다. 두 조회를 인덱스로 끝나게 바꾸고, 정책(`friend-social.md`)이 정한 "같은 상대 중복 팔로우 불가"를 DB 유니크 제약으로 보장한다. API 요청과 응답 형식은 바꾸지 않는다.

## 진행 방식
성능 변경(대상 A, B)은 `optimize-performance` 스킬의 Phase 1~9 사이클로 진행하고, 이 계획서는 각 사이클이 다룰 범위와 예상 설계(가설)를 정한다. 기법과 최종 설계는 스킬 Phase 5에서 기준선 관측을 보고 확정하며, 가설과 달라지면 Deviation Log에 남긴다.
유니크 제약(단계 C)은 성능 변경이 아니므로 두 사이클이 끝난 뒤 별도로 구현한다.

| 단계 | 대상 | 진행 도구 | 산출물 |
|---|---|---|---|
| A | `GET /api/v1/friends/follower` (팔로워 목록) | `optimize-performance` | `perf/648/follower/`, 인덱스 마이그레이션 |
| B | `GET /api/v1/social/feed` (소셜 피드 목록) | `optimize-performance` | `perf/648/social-feed/`, 정렬 변경, 부분 인덱스 마이그레이션 |
| C | 팔로우 중복 방지 | `implement` | 중복 정리, 유니크 제약 마이그레이션, 충돌 응답, 테스트 |
| D | 정책, 테스트 마무리 | 직접 | `friend-social.md`, 테스트 |

스킬의 대상 진행 규칙(한 번에 한 API, 이번 대상의 개선만 적용)을 지키기 위해, 같은 인덱스로 좋아지는 팔로워 수 API와 피드 배포 대상 조회는 별도 대상으로 만들지 않고 대상 A의 부수 관측(전후 EXPLAIN)으로 기록한다. 결정 1 참고.

## 영향 범위
### 신규 파일
- `src/main/resources/db/migration/V54__add_friends_followee_index.sql` - 대상 A 인덱스 (번호는 적용 시점 dev 최신 + 1)
- `src/main/resources/db/migration/V55__add_user_feed_visible_index.sql` - 대상 B 부분 인덱스
- `src/main/resources/db/migration/V56__add_friends_follow_unique.sql` - 중복 팔로우 정리, 유니크 제약, 기존 인덱스 정리
- `.claude/resources/perf/648/seeds.sql` - 이슈 공용 시드 (스킬 Phase 3-A)
- `.claude/resources/perf/648/follower/` - 대상 A 측정 기록 (`record.md`, `test-script.js`, 요약, 실행계획)
- `.claude/resources/perf/648/social-feed/` - 대상 B 측정 기록

### 수정 파일
- `src/main/java/gravit/code/social/repository/UserFeedRepository.java` - `findVisibleFeedsByUserId`의 정렬을 `uf.feedId DESC`로 변경
- `src/main/java/gravit/code/friend/service/FriendService.java` - `follow`에서 유니크 제약 위반을 `FRIEND_CONFLICT`로 변환
- `src/test/java/gravit/code/friend/service/FriendServiceTest.java` - 동시 팔로우 테스트 추가
- `src/test/java/gravit/code/social/service/SocialFeedServiceIntegrationTest.java` - 피드 정렬 순서 테스트 추가
- `.claude/spec/service-policy/friend-social.md` - 피드 정렬 기준 추가 (새 정책 문장)

## 구현 계획

### 단계 A. 팔로워 목록 (`optimize-performance` 대상 `follower`)

**측정 (스킬 Phase 1~4)**
- Phase 1에서 매핑할 쿼리
  - `FriendRepository.findFollowersByFolloweeId(long followeeId, Pageable pageable)` - `WHERE f.followeeId = :followeeId`, `Sort.desc("createdAt")`, `f2` 왼쪽 조인으로 맞팔 여부
- Phase 3-A 시드 (이슈 공용, 대상 B도 같이 씀)
  - 사용자 수와 팔로우 분포: 대부분 팔로워 수십 명, 일부 사용자 팔로워 수천 명 (긴 꼬리). 측정 사용자 범위는 팔로워가 많은 쪽을 포함
  - `friends` 전체 행 수는 운영 규모 조회 결과를 기준으로 정하고, 인덱스 유무 차이가 드러나도록 최소 수십만 행
  - 대상 B용 `social_feed`, `user_feed`도 이때 함께 채운다 (팔로잉 수 x 활동 수에 비례해 사용자당 피드 수천 건이 나오는 사용자 포함)
- 부수 관측: Phase 4와 Phase 8에서 아래 두 쿼리도 같은 파라미터로 `EXPLAIN (ANALYZE, BUFFERS)`를 남긴다 (부하 테스트는 하지 않음)
  - `FriendRepository.countByFolloweeId(long userId)` (`GET /api/v1/friends/count`)
  - `FriendRepository.findFollowerIdsByFolloweeId(long followeeId)` (`SocialFacade` 피드 배포)

**예상 설계 (스킬 Phase 5에서 확정)**
- Flyway `V54__add_friends_followee_index.sql`
  ```sql
  -- V54__add_friends_followee_index.sql
  -- 팔로워 목록(followee_id 조건, created_at 역순)과 팔로워 수, 피드 배포 대상 조회를 인덱스로 처리한다
  CREATE INDEX IF NOT EXISTS ix_friends_followee_created
      ON friends (followee_id, created_at DESC) INCLUDE (follower_id);
  ```
  - `INCLUDE (follower_id)`로 팔로워 수와 피드 배포 대상 조회가 Index Only Scan이 될 수 있는지 Phase 8 부수 관측으로 확인
  - 적용 후 `ANALYZE friends` 실행 (스킬 Phase 7 안내)
- 코드 변경 없음. 쿼리와 정렬은 그대로 둔다

**검증 (스킬 Phase 8~9)**
- 팔로워 목록 실행계획에서 `Seq Scan on friends`와 `Sort`가 사라지는지
- 부수 관측 두 쿼리의 전후 Buffers, 실행 시간

### 단계 B. 소셜 피드 목록 (`optimize-performance` 대상 `social-feed`)

**측정 (스킬 Phase 1~4)**
- Phase 1에서 매핑할 쿼리
  - `UserFeedRepository.findVisibleFeedsByUserId(long userId, Pageable pageable)` - `user_feed` 조건, `social_feed`, `users` 조인, `ORDER BY sf.createdAt DESC, sf.id DESC`, OFFSET
  - 같은 요청의 나머지: `CongratulationRepository.findActorIdsWithLimitReached`, `findCongratulatedFeedIds` (이번 범위 밖, 요청당 쿼리 수 집계에만 포함)
- 시드는 단계 A에서 채운 것을 쓴다. 측정은 첫 페이지(`page=0`) 기준

**예상 설계 (스킬 Phase 5에서 확정)**
- Repository: `UserFeedRepository.findVisibleFeedsByUserId(long userId, Pageable pageable)`
  ```java
  @Query("""
          SELECT new gravit.code.social.dto.internal.SocialFeedDto(
              sf.id, sf.actorId, u.nickname, u.profileImgNumber, u.handle,
              sf.eventType, sf.eventValue, sf.createdAt
          )
          FROM UserFeed uf
          JOIN SocialFeed sf ON sf.id = uf.feedId
          JOIN User u ON u.id = sf.actorId
          WHERE uf.userId = :userId AND uf.hidden = false
          ORDER BY uf.feedId DESC
  """)
  ```
  - 근거: `social_feed.id`는 IDENTITY라 생성 순서와 같다. 정렬 컬럼이 거르는 테이블(`user_feed`)로 오면 인덱스 순서대로 읽다가 `LIMIT`에서 멈출 수 있다
  - 확인할 것: 운영 DB에서 `social_feed`의 id 순서와 `created_at` 순서가 어긋나는 행이 있는지 (`SELECT count(*) FROM social_feed a JOIN social_feed b ON a.id < b.id AND a.created_at > b.created_at` 류). QA 픽스처와 테스트 픽스처는 `created_at`을 직접 넣지 않음을 확인함
- Flyway `V55__add_user_feed_visible_index.sql`
  ```sql
  -- V55__add_user_feed_visible_index.sql
  -- 숨기지 않은 피드를 사용자별 최신순(feed_id 역순)으로 읽고 LIMIT에서 멈추게 한다
  CREATE INDEX IF NOT EXISTS ix_user_feed_visible
      ON user_feed (user_id, feed_id DESC) WHERE is_hidden = false;
  ```
  - 컬럼명은 `is_hidden`이다 (엔티티 필드는 `hidden`)
  - 기존 `ix_user_feed_user_id`는 숨김 처리(`findByUserIdAndFeedId`)와 회원 정리가 쓰므로 유지. 삭제 여부는 Phase 5에서 판단
  - 적용 후 `ANALYZE user_feed`
- Service, Facade, DTO, Controller 변경 없음

**검증 (스킬 Phase 8~9)**
- 실행계획이 `Limit → Nested Loop → Index Scan using ix_user_feed_visible`로 바뀌고 `Sort` 노드가 사라지는지
- 조인 방식이 Hash Join으로 남으면 Phase 8에서 사이클 계속 여부를 판정

### 단계 C. 팔로우 중복 방지 (`implement`)

1. **Flyway** `V56__add_friends_follow_unique.sql`
   ```sql
   -- V56__add_friends_follow_unique.sql
   -- 같은 (follower_id, followee_id) 중 가장 먼저 생긴 행만 남기고 중복을 지운다
   DELETE FROM friends f
   USING friends keep
   WHERE f.follower_id = keep.follower_id
     AND f.followee_id = keep.followee_id
     AND f.id > keep.id;

   -- 같은 상대를 중복으로 팔로우하지 못하게 DB에서 막는다
   ALTER TABLE friends
       ADD CONSTRAINT uq_friends_follower_followee UNIQUE (follower_id, followee_id);

   -- 유니크 제약의 인덱스가 같은 컬럼 순서를 가지므로 기존 인덱스를 지운다
   DROP INDEX IF EXISTS ix_friends_follower_followee;
   ```
   - 남길 행은 결정 2에 따른다
   - 마이그레이션 전 운영 중복 행 수를 확인해 PR에 남긴다: `SELECT follower_id, followee_id, count(*) FROM friends GROUP BY 1, 2 HAVING count(*) > 1`
   - 중복 팔로우가 있었다면 그 기간의 `user_feed`, 알림도 중복됐을 수 있다. 이번 범위에서는 지우지 않고 PR에 건수만 남긴다
2. **Repository**: 변경 없음. `existsByFollowerIdAndFolloweeId`, `findFollowingIdsAmong`, 팔로워 목록의 `f2` 조인은 새 유니크 인덱스를 그대로 쓴다 (컬럼 순서 동일)
3. **Service**: `FriendService.follow(long followerId, long followeeId)`
   - 기존 `existsByFollowerIdAndFolloweeId` 확인은 유지한다 (일반적인 중복 요청은 예외 없이 걸러냄)
   - `friendRepository.save(friend)`를 `try-catch (DataIntegrityViolationException e)`로 감싸 `throw new RestApiException(FRIEND_CONFLICT)`로 변환한다. `CongratulationService.congratulate`와 같은 패턴이며, IDENTITY라 `save` 시점에 INSERT가 나가 예외가 이 자리에서 난다
   - 두 진입점(`FriendController.follow`, `SocialFacade.follow`)이 모두 이 메서드를 거치므로 한 곳만 바꾼다
4. **Facade**: 불필요 - 단일 Service
5. **DTO**: 변경 없음
6. **Controller**: 변경 없음

### 단계 D. 정책, 테스트 마무리
- `friend-social.md`에 추가: "소셜 피드는 게시된 순서의 역순(최신 게시가 먼저)으로 보여준다"
- 테스트는 아래 검증 항목

## 결정 필요 (Decisions needed)
- [x] 1. 팔로워 수 API와 피드 배포 대상 조회의 측정 방식 - **확정: 대상 A의 부수 관측(전후 EXPLAIN)으로만 기록.** 같은 인덱스라 별도 대상으로 만들면 기준선이 원본이 아니게 된다
- [x] 2. 중복 팔로우 정리 시 남길 행 - **확정: 가장 작은 id.** 최초 팔로우 시각을 유지한다
- [x] 3. 대상 진행 순서 - **확정: 팔로워 목록 → 소셜 피드.** 시드를 `friends`부터 채우고 그 관계 위에 피드를 쌓는다

## 검증
- 대상 테스트
  - `FriendServiceTest`: 같은 상대에게 동시에 팔로우 요청을 보내면 한 건만 저장되고 나머지는 `FRIEND_CONFLICT` (`ExecutorService` + `CountDownLatch`로 동시 실행, 각 스레드가 별도 트랜잭션)
  - `FriendServiceTest`: 기존 팔로우, 언팔로우, 팔로워 목록 테스트가 그대로 통과
  - `SocialFeedServiceIntegrationTest.GetFeed`: 피드 여러 건을 차례로 만들면 최신 게시가 먼저 온다, 숨긴 피드는 빠진다
  - `SocialFacadeIntegrationTest`: 피드 배포와 조회 흐름이 그대로 통과
- 빌드: `./gradlew build` (H2 `flywayValidate`로 마이그레이션 이름, 순서 확인)
- 성능: `perf/648/follower/record.md`, `perf/648/social-feed/record.md`의 최종 요약 표

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)

### 2026-11-25 - 단계 A 진행 중 (사이클 1 Phase 7에서 중단)
- 대상 슬러그: 계획의 `followers` 대신 스킬 규칙(경로 마지막 세그먼트)에 따라 `follower`로 했다. 계획서의 경로 표기도 맞췄다
- 시드: 기존 모듈에 `friends`가 없어 `template/seeds/friend.sql` 모듈을 새로 만들고 시드 README에 변수를 추가했다. `perf/648/seeds.sql`은 사용자 10만, 팔로우 약 213만, 측정 사용자 100명(id 1001~1100) 팔로워 1,000명씩, 맞팔 30%
- 예상 쿼리 누락: `JwtAuthFilter`가 `AuthTokenProvider.parseUser`로 요청마다 `users`를 조회한다. 성능 영향은 미미(DB 시간 0.007%)해 범위는 그대로 둔다
- 기준선: 친구 조회 mean 2427.5ms, DB 시간 99.97%, 실행계획은 `friends` Parallel Seq Scan으로 약 212.8만 행을 읽고 999행을 내보냄
- 사이클 1 설계: 계획의 예상 설계(`ix_friends_followee_created (followee_id, created_at DESC) INCLUDE (follower_id)`, 일반 `CREATE INDEX`)와 같게 확정. `V54__add_friends_followee_index.sql` 작성까지 완료, 테스트와 재측정 전
- 진행 상태와 재개 절차는 `perf/648/follower/record.md`의 진행 상태 표와 사이클 1 적용 내용을 따른다
