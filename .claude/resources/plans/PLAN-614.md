# [PLAN-614] 화면 명세에 필요한 응답 필드 추가

> 이슈: #614
> 브랜치: feat/614-spec-response-fields

## 목표
기능 명세 3건(NOTC-02 공지사항 상세, MY-04 마이그래빗 소셜, QUIZ-08 성장 알림)이 화면에 보여 줄 값을 서버 응답에 추가한다.
기존 필드의 이름, 순서, 의미와 API 경로는 바꾸지 않고 필드만 끝에 추가한다.

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/notice/dto/response/NoticeNeighborResponse.java` - 이전, 다음 공지 `id`, `title`
- `src/test/java/gravit/code/notice/fixture/NoticeFixture.java` - 상태, 고정 여부, 게시일을 지정해 공지를 저장하는 fixture
- `src/test/java/gravit/code/notice/service/NoticeQueryServiceIntegrationTest.java` - 이전, 다음 공지 테스트

### 수정 파일
- NOTC-02
  - `notice/dto/response/NoticeDetailResponse.java` - 끝에 `prev`, `next` 추가, `from(notice)`를 `of(notice, prev, next)`로 변경
  - `notice/repository/NoticeRepository.java` - `findNewerNeighbor`, `findOlderNeighbor` 추가
  - `notice/service/NoticeQueryService.java` - `getNoticeDetail`에서 이전, 다음 공지 조회
  - `notice/controller/docs/NoticeQueryControllerDocs.java` - 상세 조회 설명, 200 예시
  - `.claude/spec/service-policy/notice.md` - 이전, 다음 공지 규칙
- MY-04
  - `social/repository/sql/RecommendUserQuerySql.java` - 대표 닉네임 서브쿼리 추가
  - `social/dto/internal/RecommendCandidateDto.java` - `mutualFollowPreviewNickname` 추가
  - `social/repository/custom/RecommendUserRepositoryImpl.java` - RowMapper
  - `social/dto/response/RecommendUserResponse.java` - 끝에 `mutualFollowPreviewNickname` 추가
  - `social/facade/SocialFacade.java` - 매핑
  - `social/controller/docs/SocialControllerDocs.java` - `mutualFollowCount` 설명 오기 정정, 새 필드 설명, 예시
  - `src/test/java/gravit/code/social/service/RecommendUserServiceIntegrationTest.java`, `src/test/java/gravit/code/social/facade/SocialFacadeIntegrationTest.java` - 테스트 추가
  - `.claude/spec/service-policy/friend-social.md` - 대표 닉네임 규칙
- QUIZ-08
  - `learning/dto/internal/ConsecutiveSolvedDto.java` - `isUpdated()` 추가
  - `lesson/dto/internal/LessonSubmissionSavedDto.java` - `isStreakUpdated`, `consecutiveSolvedDays` 추가
  - `lesson/facade/LessonFacade.java` - 트랜잭션 결과에 두 값을 실어 응답으로 전달
  - `lesson/dto/response/LessonSubmissionSaveResponse.java` - 끝에 `isStreakUpdated`, `consecutiveSolvedDays` 추가
  - `lesson/controller/docs/LessonControllerDocs.java` - 레슨 결과 저장 설명
  - `src/test/java/gravit/code/lesson/facade/LessonFacadeIntegrationTest.java` - 테스트 추가
  - `.claude/spec/service-policy/learning.md` - 제출 응답의 연속 학습일 갱신 알림 규칙

## 구현 계획

### NOTC-02 공지 상세 이전, 다음 공지
- 대상: `PUBLISHED`, `pinned = false`, 삭제되지 않은 공지 (JPQL이라 `@SQLRestriction`이 자동 적용)
- 순서: `publishedAt`, 같으면 `id`. 사용자 목록 정렬(`NoticeQueryService.NOTICE_LIST_SORT`)과 같은 기준
- 방향: `prev` = 바로 더 최근 공지, `next` = 바로 더 오래된 공지 (최신순 목록에서 위 칸이 이전, 아래 칸이 다음)
- 고정 공지 상세는 쿼리 없이 둘 다 null

1. **Repository**: `NoticeRepository`
   - `Optional<NoticeNeighborResponse> findNewerNeighbor(NoticeStatus status, LocalDateTime publishedAt, long id)`
     - `WHERE n.status = :status AND n.pinned = false AND (n.publishedAt > :publishedAt OR (n.publishedAt = :publishedAt AND n.id > :id))`
     - `ORDER BY n.publishedAt ASC, n.id ASC LIMIT 1`
   - `Optional<NoticeNeighborResponse> findOlderNeighbor(...)` - 부등호와 정렬 방향만 반대
   - 이름은 화면 용어가 아니라 시간 방향으로 짓는다. 화면 매핑은 서비스에만 둔다
   - 인덱스 추가 없음. 공지는 어드민만 써서 수십에서 수백 건이고 기존 목록 쿼리도 인덱스 없이 돈다
2. **Service**: `NoticeQueryService.getNoticeDetail(long noticeId)`
   - 공지 조회 뒤 `pinned`면 `NoticeDetailResponse.of(notice, null, null)`
   - 아니면 `findNewerNeighbor` 결과를 `prev`, `findOlderNeighbor` 결과를 `next`로 넘긴다 (`orElse(null)`)
3. **Facade**: 불필요 - 단일 Service
4. **DTO**
   - `NoticeNeighborResponse(long id, String title)` - JPQL 생성자 표현식 대상이라 표준 생성자, 필드마다 `@Schema`
   - `NoticeDetailResponse` - `publishedAt` 뒤에 `NoticeNeighborResponse prev`, `NoticeNeighborResponse next` 추가. `@Schema`에 "없으면 null", `nullable = true`
   - 팩토리 `from(Notice)` → `of(Notice, NoticeNeighborResponse, NoticeNeighborResponse)`. 호출처는 `NoticeQueryService` 하나 (어드민은 별도 DTO)
5. **Controller**: 변경 없음 (`GET /api/v1/notice/{noticeId}`). Docs 설명에 이전, 다음 규칙을 적고 200 예시를 추가한다
6. **Policy**: `notice.md`에 "공지 상세에는 바로 더 최근에 게시된 공지를 이전 공지로, 바로 더 오래전에 게시된 공지를 다음 공지로 함께 준다. 고정 공지는 이 순서에서 빠지고, 고정 공지 상세에는 이전, 다음 공지가 없다"

### MY-04 함께 아는 친구 대표 닉네임
- 대표: 함께 아는 친구(내가 팔로우하는 사람 중 추천 대상을 팔로우하는 사람) 중 내가 가장 최근에 팔로우한 사람 (`f_my_following.id DESC`). `friends.created_at`은 nullable이라 `id`를 쓴다
- 탈퇴 처리된 사람(`users.deleted_at IS NOT NULL`)은 대표에서 뺀다. `mutualFollowCount`는 바꾸지 않는다
- 함께 아는 친구가 없으면 null. 함께 아는 친구가 모두 탈퇴 유예 중이면 count가 1 이상이어도 null

1. **Repository**: `RecommendUserQuerySql`
   - `MUTUAL_FOLLOW_PREVIEW_NICKNAME_SUBQUERY` 상수 추가. `friends f_my_following JOIN users u_mutual` + `EXISTS(f_follows_cand)` + `ORDER BY f_my_following.id DESC LIMIT 1` → `AS mutual_follow_preview_nickname`
   - `SAME_SORT_ORDER_SQL`, `ADJACENT_SORT_ORDER_SQL`의 SELECT에 기존 count 서브쿼리 뒤로 붙인다
   - `RecommendUserRepositoryImpl.MAPPER`에 `rs.getString("mutual_follow_preview_nickname")`
2. **Service**: 변경 없음
3. **Facade**: `SocialFacade.getRecommendedUsers` 매핑에 `c.mutualFollowPreviewNickname()` 전달
4. **DTO**
   - `RecommendCandidateDto` - 끝에 `String mutualFollowPreviewNickname`
   - `RecommendUserResponse` - 끝에 `String mutualFollowPreviewNickname` (`@Schema` description, nullable), `of`에 파라미터 추가
5. **Controller**: 변경 없음. Docs의 `mutualFollowCount` 설명을 "내가 팔로우하는 사람 중 추천 유저를 팔로우하는 사람 수"로 정정하고, 새 필드 설명과 예시를 추가한다
6. **Policy**: `friend-social.md` 함께 팔로우 수 불릿 뒤에 대표 닉네임 규칙

### QUIZ-08 레슨 제출 연속 학습일 갱신 여부
1. **DTO**
   - `ConsecutiveSolvedDto.isUpdated()` - `after > before`
   - `LessonSubmissionSavedDto` - 끝에 `boolean isStreakUpdated`, `int consecutiveSolvedDays`
   - `LessonSubmissionSaveResponse` - 끝에 `@JsonProperty("isStreakUpdated") boolean isStreakUpdated`, `int consecutiveSolvedDays`. `create`에 파라미터 2개 추가
2. **Facade**: `LessonFacade.saveLessonSubmission`
   - 트랜잭션 람다 반환을 `new LessonSubmissionSavedDto(submissionId, isLevelUp, consecutiveSolvedDto.isUpdated(), consecutiveSolvedDto.after())`로 바꾼다
   - `LessonSubmissionSaveResponse.create`에 두 값을 넘긴다
   - 연속 학습일 갱신은 이미 같은 트랜잭션의 쓰기이고 두 값은 그 쓰기의 결과라 쿼리가 늘지 않는다
3. **Controller**: 변경 없음. Docs 설명의 "재제출은 보상이 없으므로 두 값 모두 false" 문장을 레벨업, 승급에 한정하고, 연속 학습일은 재제출이어도 그날 첫 학습이면 갱신된다고 적는다
4. **Policy**: `learning.md` 연속 학습일 절에 "레슨을 제출해 연속 학습일이 오르면 제출 응답으로 알리고, 오른 뒤의 연속 학습일을 함께 준다. 같은 날 두 번째 제출부터는 오르지 않았다고 알린다"

## 결정 필요 (Decisions needed)
- [x] 이전 공지 방향 - 이전 = 더 최근, 다음 = 더 오래된
- [x] 고정 공지 상세의 이전, 다음 - 둘 다 null
- [x] 연속 학습일 값 동봉 - `consecutiveSolvedDays` 추가
- [x] 대표 닉네임 규칙 - 내가 가장 최근에 팔로우한 사람
- [x] 이슈, 브랜치 구성 - 이슈 1개, 브랜치 1개, 건마다 커밋

## 검증
- `NoticeQueryServiceIntegrationTest` (신규)
  - 중간 공지는 바로 더 최근 공지를 이전으로, 바로 더 오래된 공지를 다음으로 준다
  - 가장 최근 공지는 이전 공지가 없다
  - 가장 오래된 공지는 다음 공지가 없다
  - 고정 공지 상세는 이전, 다음 공지가 모두 없다
  - 고정 공지는 다른 공지의 이전, 다음에서 빠진다
  - 임시 저장, 보관, 삭제된 공지는 이전, 다음에서 빠진다
  - 게시일이 같으면 id로 순서를 정한다
- `RecommendUserServiceIntegrationTest` 추가
  - 함께 아는 친구가 없으면 대표 닉네임은 null이다
  - 함께 아는 친구가 여럿이면 내가 가장 최근에 팔로우한 사람의 닉네임을 준다
  - 탈퇴한 함께 아는 친구는 대표에서 빠지고 count에는 남는다
- `SocialFacadeIntegrationTest` 추가: 추천 응답에 대표 닉네임이 담긴다
- `LessonFacadeIntegrationTest` 추가
  - 그날 첫 제출이면 연속 학습일 갱신으로 응답하고 일수가 1 오른다
  - 같은 날 두 번째 제출이면 갱신이 아니고 일수는 그대로다
  - 재제출이어도 그날 첫 학습이면 갱신으로 응답한다
- 추천 쿼리 `EXPLAIN (VERBOSE)`로 대표 닉네임 서브쿼리가 뽑힌 후보에만 실행되고 friends 인덱스를 타는지 확인
- 전체: `./gradlew test`

## Deviation Log
- `NoticeFixture`: 임시 저장 공지에도 리플렉션으로 게시일을 넣는 `게시일이_있는_임시_저장_공지`를 둠 - 이유: 게시일이 null이면 상태 조건이 없어도 비교식에서 빠지므로, 상태 조건을 실제로 검증하려면 게시일이 이웃 사이에 있어야 한다
- 테스트 이름: `SocialFacadeIntegrationTest`는 `추천_응답에_함께_아는_친구_수와_대표_닉네임이_담긴다`, `LessonFacadeIntegrationTest` 3건은 이름에 `연속_학습일`을 넣음 - 이유: 같은 Nested 안 기존 테스트(레벨업, 승급)와 구분
- 같은 날 두 번째 제출 테스트: 오늘 학습한 Learning을 미리 저장하지 않고 실제로 두 번 제출함 - 이유: 명세 경계(같은 날 두 번째 제출)를 그대로 재현
- EXPLAIN 검증: 로컬 측정 DB가 없어 임시 PostgreSQL 15 컨테이너에 users, friends, user_league, league와 운영 인덱스(V2, V28, V35)만 만들고 합성 데이터(유저 2만, 팔로우 약 60만, 내 팔로잉 210, 같은 티어 후보 2,001)로 측정함
  - 두 서브쿼리 모두 `loops=8`로 뽑힌 후보에만 실행되고, friends는 `ix_friends_follower_followee`를 탐 (PK 역방향 스캔 없음)
  - 실행 시간: 기존 약 7ms → 변경 후 약 11ms (5회, 첫 회 제외). 증가분 중 약 3ms는 users 해시 생성(플래너 선택)이라 users가 크게 늘면 재측정 대상
