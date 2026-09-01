# [PLAN-506] 면접 세션 라이프사이클 API 구현

> 이슈: #506
> 브랜치: feat/506-interview-session-lifecycle

## 목표
사용자가 면접을 시작해서 끝낼 때까지의 쓰기 흐름 전부를 구현한다. 기술 스택 선택지 조회, 세션 생성(질문 선별 포함), 답변 제출, 세션 종료(채점 요청 이벤트 발행), 세션 중단까지 5개 API가 대상이다.
`.claude/resources/interview-api-design.md`의 A 담당 범위이며, #503이 선점한 에러코드와 `InterviewSessionGradingRequestedEvent`를 소비한다. 채점 파이프라인과 결과 조회는 B 담당이라 범위 밖이다.

## 영향 범위

### 신규 파일

> 표시한 리포지토리 3종은 **빈 인터페이스로 이미 만들어 뒀다.** 준서와 겹쳐 만들 위험을 없애려는 선점이고, 쿼리 메서드는 구현 단계에서 붙인다.

**interviewTechStack/**
- `interviewTechStack/repository/InterviewTechStackRepository.java` (선점 완료) - 직무별 스택 목록 조회
- `interviewTechStack/repository/InterviewStackAxisRepository.java` (선점 완료) - 스택의 축별 카테고리 id 조회
- `interviewTechStack/service/InterviewTechStackQueryService.java` - 스택 목록 조회, 스택의 카테고리 id 해석
- `interviewTechStack/dto/response/InterviewTechStackResponse.java` - 스택 목록 응답
- `interviewTechStack/controller/InterviewTechStackController.java` - 1번 API
- `interviewTechStack/controller/InterviewTechStackControllerDocs.java` - Swagger 문서

**interviewQuestion/**
- `interviewQuestion/domain/InterviewDifficultyQuota.java` - 세션 레벨별 난이도 구성 프로파일
- `interviewQuestion/repository/InterviewCategoryRepository.java` (선점 완료) - 모드별 카테고리 id 조회
- `interviewQuestion/dto/internal/InterviewQuestionPoolItem.java` - 선별용 경량 프로젝션 (id, categoryId, difficulty)
- `interviewQuestion/dto/internal/SelectedInterviewQuestion.java` - 선별 결과 (questionId, content)
- `interviewQuestion/service/InterviewCategoryQueryService.java` - 공통 CS 카테고리 id 조회
- `interviewQuestion/service/InterviewQuestionSelectionService.java` - 질문 5개 선별
- `interviewQuestion/support/InterviewQuestionSelector.java` - 선별 알고리즘 본체 (DB 접근 없는 순수 로직)

**interview/**
- `interview/service/InterviewSessionCommandService.java` - 세션 생성, 검증, 상태 전환, 이벤트 발행
- `interview/service/InterviewAnswerCommandService.java` - 답변 행 선생성, 답변 제출
- `interview/facade/InterviewSessionFacade.java` - 세션 생성, 답변 제출 조합
- `interview/dto/request/InterviewSessionCreateRequest.java`
- `interview/dto/request/InterviewAnswerSubmitRequest.java`
- `interview/dto/response/InterviewSessionCreateResponse.java`
- `interview/dto/response/InterviewSessionQuestionResponse.java`
- `interview/dto/response/InterviewAnswerSubmitResponse.java`
- `interview/dto/response/InterviewSessionStatusResponse.java`
- `interview/controller/InterviewSessionController.java` - 2~5번 API
- `interview/controller/InterviewSessionControllerDocs.java` - Swagger 문서

### 수정 파일
- `src/main/java/gravit/code/interview/domain/InterviewSession.java` - `validateModeTechStack` public static 검증 추가, `create()`에서 호출
- `src/main/java/gravit/code/interview/repository/InterviewSessionRepository.java` - `existsByUserIdAndStatus` 추가
- `src/main/java/gravit/code/interview/repository/InterviewAnswerRepository.java` - `findBySessionIdAndDisplayOrder` 추가
- `src/main/java/gravit/code/interviewQuestion/repository/InterviewQuestionRepository.java` - 풀 조회, 본문 조회 2건 추가
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - `INTERVIEW_4013`, `INTERVIEW_4014` 추가 (B와 공유하는 충돌 파일이므로 선점 사실을 공유한다)
- `.claude/spec/service-policy/interview.md` - 난이도 프로파일, 질문 선별 규칙, 세션 생성 제약, 재제출 규칙 반영 (현재 "미정"으로 남은 항목을 채운다)

### 변경 없음
- Flyway 마이그레이션: V40에 테이블과 인덱스가 모두 있어 추가 없음
- `SecurityConfig`: `anyRequest().authenticated()`가 기본이라 신규 경로 등록 불필요

## 구현 계획

### 1. Entity / Flyway

DB 변경 없음. 엔티티는 아래 한 곳만 손댄다.

`InterviewSession`에 모드와 기술 스택 조합 검증을 추가한다. `InterviewCategory.validateModeAxis`와 같은 방식이되, 세션 생성 전 사전 검증에서도 같은 규칙을 써야 하므로 public static으로 노출한다.

```java
public static void validateModeTechStack(
        InterviewMode mode,
        Long techStackId
) {
    boolean hasTechStack = techStackId != null;

    if (mode == InterviewMode.JOB_SPECIFIC && !hasTechStack) {
        throw new RestApiException(CustomErrorCode.INTERVIEW_TECH_STACK_REQUIRED);
    }

    if (mode == InterviewMode.COMMON_CS && hasTechStack) {
        throw new RestApiException(CustomErrorCode.INTERVIEW_TECH_STACK_NOT_ALLOWED);
    }
}
```

`create()` 첫 줄에서 이 메서드를 호출한다. 사전 검증과 엔티티 가드가 같은 메서드를 쓰므로 규칙이 두 벌로 갈라지지 않는다.

### 2. 난이도 구성 프로파일

`interviewQuestion/domain/InterviewDifficultyQuota` - 세션 레벨이 난이도별로 몇 문항을 뽑는지 정한다. 상수 하나만 고치면 정책이 바뀌도록 enum에 가둔다.

```java
public enum InterviewDifficultyQuota {

    LOW(3, 2, 0),
    MEDIUM(1, 3, 1),
    HIGH(0, 2, 3);

    private final int lowCount;
    private final int mediumCount;
    private final int highCount;

    public static InterviewDifficultyQuota from(InterviewLevel level);

    public int countOf(InterviewDifficulty difficulty);

    public List<InterviewDifficulty> toSlots();   // 난이도 오름차순으로 펼친 5칸
}
```

- 생성자에서 `lowCount + mediumCount + highCount == InterviewSession.QUESTION_COUNT`를 검증한다. 어긋나면 클래스 로딩 시점에 터지므로 배점과 문항 수가 어긋난 채로 배포되지 않는다
- `from(level)`은 `valueOf(level.name())`으로 매핑한다. 두 enum의 상수명이 같다
- `toSlots()`는 `[LOW, MEDIUM, MEDIUM, MEDIUM, HIGH]`처럼 난이도 오름차순 5칸을 만든다. 선별 순서가 곧 출제 순서라 사용자는 쉬운 문항부터 만난다

### 3. Repository

**신규**

- `InterviewTechStackRepository extends JpaRepository<InterviewTechStack, Long>`
  ```java
  @Query("""
      select new gravit.code.interviewTechStack.dto.response.InterviewTechStackResponse(
          t.id,
          t.code,
          t.displayName
      )
      from InterviewTechStack t
      where t.jobRole = :jobRole
      order by t.sortOrder asc
      """)
  List<InterviewTechStackResponse> findAllByJobRole(@Param("jobRole") InterviewJobRole jobRole);
  ```
  `ix_interview_tech_stack_job_role (job_role, sort_order)`를 그대로 탄다.

- `InterviewStackAxisRepository extends JpaRepository<InterviewStackAxis, Long>`
  ```java
  @Query("select sa.categoryId from InterviewStackAxis sa where sa.techStackId = :techStackId")
  List<Long> findCategoryIdsByTechStackId(@Param("techStackId") long techStackId);
  ```

- `InterviewCategoryRepository extends JpaRepository<InterviewCategory, Long>`
  ```java
  @Query("select c.id from InterviewCategory c where c.mode = :mode")
  List<Long> findIdsByMode(@Param("mode") InterviewMode mode);
  ```

**수정**

- `InterviewQuestionRepository`
  ```java
  @Query("""
      select new gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolItem(
          q.id,
          q.categoryId,
          q.difficulty
      )
      from InterviewQuestion q
      where q.categoryId in :categoryIds
      """)
  List<InterviewQuestionPoolItem> findPoolByCategoryIds(@Param("categoryIds") List<Long> categoryIds);

  @Query("""
      select new gravit.code.interviewQuestion.dto.internal.SelectedInterviewQuestion(
          q.id,
          q.content
      )
      from InterviewQuestion q
      where q.id in :questionIds
      """)
  List<SelectedInterviewQuestion> findContentsByIds(@Param("questionIds") List<Long> questionIds);
  ```
  풀 조회에서 `content`(TEXT)를 빼는 것이 요점이다. 후보 전체의 본문을 읽지 않고, 확정된 5건만 두 번째 쿼리로 읽는다.

- `InterviewSessionRepository`
  ```java
  boolean existsByUserIdAndStatus(long userId, InterviewSessionStatus status);
  ```

- `InterviewAnswerRepository`
  ```java
  Optional<InterviewAnswer> findBySessionIdAndDisplayOrder(long sessionId, int displayOrder);
  ```
  `uq_interview_answer_session_order`가 인덱스를 겸한다.

### 4. 질문 선별 알고리즘

`interviewQuestion/support/InterviewQuestionSelector` - 인스턴스 상태가 없는 final 클래스, private 생성자.

```java
public static List<Long> select(
        List<InterviewQuestionPoolItem> pool,
        List<Long> requiredCategoryIds,
        InterviewDifficultyQuota quota
)
```

`requiredCategoryIds`는 **반드시 한 문항 이상 나와야 하는 카테고리** 목록이다. 직무별 모드는 축 3개의 카테고리 id가 그대로 들어가고, 공통 CS 모드는 빈 리스트를 넣어 커버리지 요구를 끈다.

공통 규칙 두 가지를 먼저 정의한다.

- **대체 난이도 순서** - 칸의 난이도로 뽑을 항목이 없을 때 찾아보는 순서다. `LOW -> MEDIUM -> HIGH`, `MEDIUM -> LOW -> HIGH`, `HIGH -> MEDIUM -> LOW` (인접 난이도 우선, 동률이면 쉬운 쪽 먼저)
- **칸(slot)** - `quota.toSlots()`가 만든 난이도 5칸. 한 문항을 뽑을 때마다 칸 하나를 소비한다

절차는 다음과 같다.

1. `pool.size() < InterviewSession.QUESTION_COUNT`면 `INTERVIEW_QUESTION_POOL_INSUFFICIENT`(4009)
2. 풀을 한 번 섞는다(`Collections.shuffle`). 이후 모든 "임의 선택"은 섞인 순서의 앞에서 꺼내는 것으로 갈음한다
3. **예약 단계** - `requiredCategoryIds`를 풀 보유 문항 수 오름차순으로 처리한다. 문항이 적은 카테고리를 먼저 확보해야 나중에 자리가 없어지지 않는다. 각 카테고리마다
   - 풀에 그 카테고리 항목이 하나도 없으면 **4009로 거절한다.** 축 하나가 비면 세션을 만들지 않는다
   - 남은 칸의 난이도 중 그 카테고리가 가진 난이도가 있으면, 그중 난이도가 낮은 칸을 소비하고 해당 난이도 항목 하나를 뽑는다
   - 없으면 남은 칸 중 난이도가 가장 낮은 칸을 소비하고, 그 칸의 대체 난이도 순서를 따라 그 카테고리 항목 하나를 뽑는다
4. **채움 단계** - 남은 칸을 난이도 오름차순으로 처리한다. 칸마다
   - 후보 = 남은 풀에서 그 난이도인 항목. 비면 대체 난이도 순서로 다시 찾고, 그래도 비면 4009
   - 후보 중 **지금까지 가장 적게 뽑힌 카테고리**의 첫 항목을 고른다. 같은 카테고리로 쏠리지 않게 하는 규칙이다
5. 확정된 5개를 **난이도 오름차순으로 재정렬해서 반환한다.** 예약 단계가 난이도 순서를 건너뛸 수 있으므로 출제 순서는 선별 순서가 아니라 여기서 정한다. 같은 난이도끼리는 선별 순서를 유지한다. 이 순서가 그대로 `displayOrder` 1~5가 된다

난이도 구성은 칸이 보장하고, 축 커버리지는 예약 단계가, 카테고리 편중 방지는 채움 단계가 맡는다.
직무별 모드는 축이 셋이라 예약 단계가 최대 3칸을 쓰고 남은 2칸을 채움 단계가 채운다. 공통 CS 모드는 예약 단계를 통째로 건너뛴다.

### 5. Service

**`InterviewTechStackQueryService`** (`@Service`, `@Transactional(readOnly = true)`)

```java
List<InterviewTechStackResponse> getTechStacks(InterviewJobRole jobRole);

List<Long> getCategoryIdsByTechStack(long techStackId);
```
- `getCategoryIdsByTechStack`은 `existsById`로 스택 존재를 먼저 확인하고 없으면 `INTERVIEW_TECH_STACK_NOT_FOUND`(4014). 이 확인이 없으면 없는 스택 id가 "질문 풀 부족(4009)"으로 둔갑한다
- 축 매핑이 아예 없어 빈 리스트가 나오는 경우는 그대로 반환한다. 그 결과는 선별 단계에서 4009로 드러난다

**`InterviewCategoryQueryService`** (`@Service`, `@Transactional(readOnly = true)`)

```java
List<Long> getCategoryIds(InterviewMode mode);
```

**`InterviewQuestionSelectionService`** (`@Service`, `@Transactional(readOnly = true)`)

```java
List<SelectedInterviewQuestion> selectQuestions(
        List<Long> categoryIds,
        InterviewLevel level,
        boolean coverAllCategories
);
```
- `categoryIds`가 비면 즉시 4009
- `coverAllCategories`면 `categoryIds`를, 아니면 빈 리스트를 `requiredCategoryIds`로 넘긴다
- 풀 조회 -> `InterviewQuestionSelector.select(...)` -> 확정된 5개 id로 본문 조회 -> **선별기가 정한 순서대로 재정렬**해서 반환. `in` 절 결과 순서는 보장되지 않으므로 id 기준 맵을 만들어 다시 세운다

**`InterviewSessionCommandService`** (`@Service`)

```java
@Transactional(readOnly = true)
void validateCreatable(long userId, InterviewSessionCreateRequest request);

@Transactional
long createSession(long userId, InterviewSessionCreateRequest request);

@Transactional(readOnly = true)
void validateAnswerable(long userId, long sessionId, InterviewInputType inputType);

@Transactional
InterviewSessionStatusResponse startGrading(long userId, long sessionId);

@Transactional
InterviewSessionStatusResponse abandon(long userId, long sessionId);
```

- `validateCreatable`: 입력 방식 지원 여부(TEXT만 허용, 아니면 `INTERVIEW_INPUT_TYPE_NOT_SUPPORTED` 4013) -> `InterviewSession.validateModeTechStack` -> `existsByUserIdAndStatus(userId, IN_PROGRESS)`면 `INTERVIEW_SESSION_ALREADY_IN_PROGRESS`(4011)
- `createSession`: `InterviewSession.create(...)` 저장 후 id 반환
- `validateAnswerable`: 세션 조회(4003) -> `session.getUserId() != userId`면 4004 -> `IN_PROGRESS`가 아니면 4005 -> `session.getInputType() != inputType`이면 4006
- `startGrading`: 위와 같은 3단 검증 후 `session.startGrading()`, 이어서 같은 트랜잭션 안에서 `publisher.publishEvent(new InterviewSessionGradingRequestedEvent(sessionId, userId))`. 미답변 문항이 남아도 막지 않는다(무응답은 0점 채점 대상)
- `abandon`: 같은 3단 검증 후 `session.abandon()`
- 세션 조회와 소유자, 상태 검증은 private 메서드(`getOwnedSession`, `validateInProgress`)로 묶어 네 메서드가 공유한다

> 경계 메모: 설계 문서 7-4-2에 따라 B가 `InterviewSessionQueryService`와 `InterviewSessionGradingService`를 만든다. A는 `InterviewSessionCommandService` 한 파일만 건드린다. 검증용 조회 메서드를 Query 서비스로 빼지 않는 이유가 이 파일 경계다.

**`InterviewAnswerCommandService`** (`@Service`)

```java
@Transactional
List<Long> createPendingAnswers(long sessionId, List<Long> questionIds);

@Transactional
InterviewAnswerSubmitResponse submit(long sessionId, int displayOrder, String content);
```

- `createPendingAnswers`: 입력 순서대로 `InterviewAnswer.createPending(sessionId, questionId, i + 1)`을 만들어 `saveAll` 호출 1회. 저장된 answerId를 입력과 같은 순서로 반환한다
  - `GenerationType.IDENTITY`는 Hibernate의 INSERT 배치를 막으므로 실제 INSERT는 5회다. 호출을 한 번으로 묶는 것이지 한 문장으로 묶는 것이 아니다
- `submit`: `findBySessionIdAndDisplayOrder`로 찾고 없으면 `INTERVIEW_ANSWER_NOT_FOUND`(4010). `answer.submit(content, null)` 호출 후 `InterviewAnswerSubmitResponse.create(answer.getId(), answer.getStatus())`
  - **공백 판정을 서비스에서 다시 하지 않는다.** `InterviewAnswer.resolveStatus`가 이미 blank를 `NO_RESPONSE`로 판정한다
  - 이미 제출된 답변에 다시 제출하면 덮어쓴다. 상태 검증은 세션의 `IN_PROGRESS`(4005)가 대신한다
  - `audioKey`는 이번 범위에서 항상 null이다. VOICE 이슈에서 파라미터를 늘린다

### 6. Facade

`interview/facade/InterviewSessionFacade` (`@Facade`, `@RequiredArgsConstructor`)

**세션 생성** - 5개 서비스를 조합하므로 Facade가 필요하다.

```java
public InterviewSessionCreateResponse createSession(
        long userId,
        InterviewSessionCreateRequest request
) {
    interviewSessionCommandService.validateCreatable(userId, request);

    List<Long> categoryIds = resolveCategoryIds(request);
    boolean coverAllCategories = request.mode() == InterviewMode.JOB_SPECIFIC;
    List<SelectedInterviewQuestion> questions =
            interviewQuestionSelectionService.selectQuestions(categoryIds, request.level(), coverAllCategories);

    return transactionTemplate.execute(status -> {
        long sessionId = interviewSessionCommandService.createSession(userId, request);

        List<Long> answerIds = interviewAnswerCommandService.createPendingAnswers(
                sessionId,
                questions.stream().map(SelectedInterviewQuestion::questionId).toList()
        );

        return InterviewSessionCreateResponse.create(sessionId, answerIds, questions);
    });
}
```

- `resolveCategoryIds`는 private 메서드. `COMMON_CS`면 `interviewCategoryQueryService.getCategoryIds(COMMON_CS)`, `JOB_SPECIFIC`이면 `interviewTechStackQueryService.getCategoryIdsByTechStack(request.techStackId())`
- 검증과 선별은 전부 읽기라 경계 밖에 둔다. `TransactionTemplate` 안에는 세션 저장과 답변 5행 저장만 들어간다
- 응답 조립을 경계 안에서 하는 이유는 두 쓰기의 결과(sessionId, answerIds)를 함께 쓰기 때문이다. 엔티티를 경계 밖으로 내보내지 않는다
- 질문 5개를 응답에 담는 것은 `facade.md`의 "쓰기 응답에는 그 쓰기로 확정된 사실만" 규칙에 걸리지 않는다. 질문 배정 자체가 이 쓰기로 확정된 사실이다

**답변 제출** - 세션 검증과 답변 갱신 2개 서비스를 조합한다.

```java
public InterviewAnswerSubmitResponse submitAnswer(
        long userId,
        long sessionId,
        int displayOrder,
        InterviewAnswerSubmitRequest request
) {
    interviewSessionCommandService.validateAnswerable(userId, sessionId, InterviewInputType.TEXT);

    return interviewAnswerCommandService.submit(sessionId, displayOrder, request.content());
}
```

쓰기가 1건뿐이라 `TransactionTemplate`을 쓰지 않는다. 경계는 `submit`이 이미 갖고 있다.

**종료와 중단은 Facade를 거치지 않는다.** 단일 서비스 위임이므로 Controller가 `InterviewSessionCommandService`를 직접 주입한다. 채점 요청 이벤트는 서비스의 `@Transactional` 안에서 발행되므로 `AFTER_COMMIT` 리스너가 폐기되지 않는다.

### 7. DTO

**Request**

- `InterviewSessionCreateRequest`
  ```java
  public record InterviewSessionCreateRequest(
          @Schema(description = "면접 모드", requiredMode = REQUIRED)
          @NotNull InterviewMode mode,

          @Schema(description = "답변 입력 방식", requiredMode = REQUIRED)
          @NotNull InterviewInputType inputType,

          @Schema(description = "세션 레벨", requiredMode = REQUIRED)
          @NotNull InterviewLevel level,

          @Schema(description = "기술 스택 아이디. 직무별 모드에서만 보낸다")
          Long techStackId
  ) {}
  ```
- `InterviewAnswerSubmitRequest`
  ```java
  public record InterviewAnswerSubmitRequest(
          @Schema(description = "답변 본문. 비우면 무응답으로 기록된다")
          @Size(max = 2000) String content
  ) {}
  ```
  `@NotBlank`를 붙이지 않는다. 빈 답변 제출은 정책상 유효한 무응답이다.

**Response** (전부 정적 팩토리 + private `@Builder`)

- `InterviewTechStackResponse(Long techStackId, String code, String displayName)` - JPQL 생성자 프로젝션 대상이라 생성자를 노출한다
- `InterviewSessionQuestionResponse(Long answerId, int displayOrder, String content)`
- `InterviewSessionCreateResponse(Long sessionId, List<InterviewSessionQuestionResponse> questions)`
  - `create(long sessionId, List<Long> answerIds, List<SelectedInterviewQuestion> questions)`에서 인덱스로 zip 하고 `displayOrder = i + 1`
- `InterviewAnswerSubmitResponse(Long answerId, InterviewAnswerStatus status)`
- `InterviewSessionStatusResponse(Long sessionId, InterviewSessionStatus status)` - 종료와 중단이 공유한다

### 8. Controller

**`InterviewTechStackController`** - `@RequestMapping("/api/v1/interview-tech-stacks")`, `InterviewTechStackQueryService` 직접 주입

| 메서드 | 경로 | 응답 |
|---|---|---|
| GET | `?jobRole={jobRole}` | 200 `List<InterviewTechStackResponse>` |

`@RequestParam("jobRole") InterviewJobRole jobRole` - 필수. 인덱스가 `(job_role, sort_order)`라 직무 없는 전체 조회는 열지 않는다.

**`InterviewSessionController`** - `@RequestMapping("/api/v1/interview-sessions")`, `InterviewSessionFacade`와 `InterviewSessionCommandService`를 함께 주입

| 메서드 | 경로 | 위임 | 응답 |
|---|---|---|---|
| POST | `` | Facade | 201 `InterviewSessionCreateResponse` |
| PATCH | `/{sessionId}/answers/{displayOrder}` | Facade | 200 `InterviewAnswerSubmitResponse` |
| PATCH | `/{sessionId}/complete` | Service | 202 `InterviewSessionStatusResponse` |
| PATCH | `/{sessionId}/abandon` | Service | 200 `InterviewSessionStatusResponse` |

- 사용자는 `@AuthenticationPrincipal LoginUser loginUser`로 받는다
- 응답은 `ResponseEntity.status(HttpStatus.XXX).body(...)`로 통일한다
- 두 Controller 모두 `{Controller}Docs` 인터페이스를 implements 한다. 문서 본문은 `write-api-docs` 스킬로 작성한다

### 9. 에러코드 추가

`CustomErrorCode`의 `// Interview` 그룹 끝(`INTERVIEW_4012` 뒤)에 2종을 잇는다.

| enum 상수 | HttpStatus | 코드 | 메시지 |
|---|---|---|---|
| `INTERVIEW_INPUT_TYPE_NOT_SUPPORTED` | `BAD_REQUEST` | `INTERVIEW_4013` | 아직 지원하지 않는 답변 입력 방식입니다. |
| `INTERVIEW_TECH_STACK_NOT_FOUND` | `NOT_FOUND` | `INTERVIEW_4014` | 존재하지 않는 면접 기술 스택입니다. |

#503이 4003~4012를 선점했으므로 그 뒤를 잇는다. B도 같은 파일을 건드리므로 4013, 4014를 A가 쓴다는 사실을 공유한다.

### 10. 서비스 정책 문서 갱신

`.claude/spec/service-policy/interview.md`를 이번 작업에서 함께 고친다.

- "난이도와 레벨" 절의 `세션 레벨이 어떤 난이도의 질문을 몇 개씩 뽑는지 - 미정`을 구성 프로파일 표로 교체한다 (하 3/2/0, 중 1/3/1, 상 0/2/3)
- "질문 선별" 절을 새로 넣는다: 직무별 모드는 축마다 한 문항 이상이 나와야 하고 한 축이라도 질문이 없으면 세션을 만들지 않는다, 그 밖에는 카테고리가 고르게 나오도록 뽑는다, 특정 난이도가 모자라면 인접 난이도로 대체한다, 출제 순서는 난이도 오름차순이다, 질문이 5개에 못 미치면 세션을 만들지 않는다
- "세션 상태" 절에 추가한다: 진행 중인 세션이 있으면 새 세션을 만들 수 없고, 중단은 사용자가 명시적으로 요청해야 한다
- "면접 모드" 절에 추가한다: 답변 입력 방식은 현재 텍스트만 제공한다
- "채점" 절에 추가한다: 진행 중인 세션에서는 답변을 다시 제출해 덮어쓸 수 있다

## API 요약

| # | 메서드 | 경로 | 성공 | 주요 실패 |
|---|---|---|---|---|
| 1 | GET | `/api/v1/interview-tech-stacks?jobRole=` | 200 | - |
| 2 | POST | `/api/v1/interview-sessions` | 201 | 4007, 4008, 4009, 4011, 4013, 4014 |
| 3 | PATCH | `/api/v1/interview-sessions/{sessionId}/answers/{displayOrder}` | 200 | 4003, 4004, 4005, 4006, 4010 |
| 4 | PATCH | `/api/v1/interview-sessions/{sessionId}/complete` | 202 | 4003, 4004, 4005 |
| 5 | PATCH | `/api/v1/interview-sessions/{sessionId}/abandon` | 200 | 4003, 4004, 4005 |

## 결정 필요 (Decisions needed)

- [x] **축별 최소 1문항을 강제한다.** 직무별 모드에서 세 축 중 한 축의 질문이 하나도 없으면 4009로 세션 생성을 거절한다. 선별 알고리즘의 예약 단계가 이 규칙을 집행한다
  - 따라오는 제약: 마스터 데이터 시딩 이슈에서 **스택마다 세 축 전부에 질문이 들어가야 한다.** 한 축이라도 비면 그 스택은 직무별 면접을 시작할 수 없다. 설계 문서 8절의 "스택 하나당 20문항 이상"이 하한선인 이유가 이것이다
- [x] **답변 본문 길이 상한은 2000자다.** `InterviewAnswerSubmitRequest.content`에 `@Size(max = 2000)`을 건다. TEXT 컬럼이라 DB 제약은 없지만 상한이 없으면 채점 LLM 토큰과 저장 비용이 무제한이 된다
- [x] **에러코드 2종(4013, 4014)을 추가한다.** VOICE 요청은 세션 생성 시점에 4013으로 막고, 없는 스택 id는 4014로 구분한다. 답변할 수 없는 세션이 남지 않게 하려는 것이다

## 준서와의 경계

분담 계획 6절의 합의를 넘어 A가 건드리는 것들이다. 착수 전에 공유한다.

| 대상 | 내용 |
|---|---|
| `CustomErrorCode` | `INTERVIEW_4013`, `INTERVIEW_4014` 2종을 A가 선점한다. 0단계 합의는 10종 일괄이었으므로 범위를 넘는다 |
| `InterviewSession` (공유 엔티티) | `validateModeTechStack` public static 추가 |
| `interviewQuestion/` (공유 패키지) | `InterviewCategoryRepository`(선점 완료), `InterviewCategoryQueryService`, `InterviewDifficultyQuota`, `support/InterviewQuestionSelector`, `dto/internal/` 2종을 A가 만든다 |
| 테스트 fixture | `interview/fixture/`, `interviewQuestion/fixture/`, `interviewTechStack/fixture/`. B-3이 재사용할 자산이라 위치와 네이밍을 먼저 알린다 |

**`gradedAnswerCount` 증분 방식(분담 계획 6-5)에 대한 A의 회신**: A가 세션을 쓰는 시점은 `startGrading()`과 `abandon()` 둘뿐이고, **둘 다 `IN_PROGRESS`에서만 허용한다.** B가 증분하는 시점은 `GRADING`이라 상태가 겹치지 않으므로 락 경합이 생기지 않는다. B는 원자적 UPDATE와 락 중 편한 쪽을 고르면 된다. 단 이 결론은 `abandon`이 `IN_PROGRESS` 한정이라는 전제 위에 있다. 이 계획서는 그 전제를 지킨다.

**미확정으로 남긴 것**: `GRADING` 상태에서 새 세션을 만들 수 있는지가 분담 계획 C-3에 없다. 이 계획서는 `IN_PROGRESS`만 차단하므로 **채점 중에는 새 면접을 시작할 수 있다.** 채점이 비동기이고 결과는 이력에서 보면 되니 이대로 두되, 막기로 하면 `existsByUserIdAndStatus` 조건을 `status in (IN_PROGRESS, GRADING)`으로 바꾼다.

## 커밋 순서

분담 계획은 A-1 / A-2 / A-3 세 이슈로 나눴으나 이 계획서는 #506 하나로 묶었다. 준서가 "A-1에서 잡은 패키지 구조를 그대로 따라간다"고 했으므로, 이슈를 합친 대신 **커밋을 나눠 조기에 푸시한다.**

1. 1번 API (기술 스택 목록) - Controller / Service / Docs 골격을 여기서 세우고 바로 푸시한다. 준서가 참고할 기준이다
2. 2번 API (세션 생성) - 난이도 프로파일, 선별기, Facade
3. 3, 4, 5번 API (답변 제출, 종료, 중단)
4. 서비스 정책 문서 갱신

## 범위 밖 (후속으로 넘기는 것)

| 항목 | 판단 |
|---|---|
| 기술 스택 목록 Redis 캐싱 | 1차 제외. 이 프로젝트에 `@Cacheable` 사용처가 0건이라 이 API 하나를 위해 캐시 추상화를 도입할 이유가 약하다. Redis는 현재 메일 인증 코드와 재시도 큐에만 쓴다 |
| 마스터 데이터 시딩 마이그레이션 | 별도 이슈. 담당은 A이고 이 이슈와 동시에 착수한다. **축별 최소 1문항을 강제하기로 했으므로 스택마다 공통, 프레임워크, 언어 세 축 전부에 질문이 있어야 한다.** 한 축이라도 비면 그 스택은 직무별 면접을 시작할 수 없다. 개념 데이터 항목은 준서에게 받는다 |
| VOICE 트랙 (스토리지 + STT) | 별도 이슈. 담당은 A. B의 7번 API가 `audioUrl` 발급을 A의 스토리지 클라이언트에 의존하므로, **1차 릴리스에서는 7번 응답의 `audioUrl`을 항상 null로 내보내는 것으로 합의한다** |
| `PLAN-500.md` Deviation Log 갱신 | 본문은 최상위 4패키지 배치로 갱신됐는데 Deviation Log만 중간 상태로 남아 있다. A가 정리한다 |

## 검증

`.claude/spec/test-convention.md`에 따라 전부 `@TCSpringBootTest` 통합 테스트로 작성한다. 마스터 데이터 시딩 마이그레이션이 아직 없으므로 테스트는 각자 fixture로 카테고리, 스택, 질문을 만든다.

**Fixture 신규**
- `src/test/java/gravit/code/interviewTechStack/fixture/InterviewTechStackFixture.java`
- `src/test/java/gravit/code/interviewQuestion/fixture/InterviewQuestionFixture.java` - 카테고리, 질문을 난이도별로 만드는 헬퍼
- `src/test/java/gravit/code/interview/fixture/InterviewSessionFixture.java`

**테스트 클래스**

| 클래스 | 시나리오 |
|---|---|
| `InterviewTechStackQueryServiceIntegrationTest` | 직무로 필터링된다, `sortOrder` 오름차순이다, 없는 스택의 카테고리 조회는 4014 |
| `InterviewQuestionSelectionServiceIntegrationTest` | 레벨별 난이도 구성이 프로파일과 일치한다, 직무별 모드에서 세 축이 모두 나온다, 한 축에 질문이 없으면 4009, 공통 CS에서 카테고리가 편중되지 않는다, 특정 난이도가 모자라면 대체 순서대로 채운다, 결과가 난이도 오름차순이다, 풀이 5개 미만이면 4009 |
| `InterviewSessionCommandServiceIntegrationTest` | 진행 중 세션이 있으면 4011, 모드와 스택 조합 위반은 4007/4008, VOICE 요청은 4013, 종료하면 `GRADING`이 되고 이벤트가 발행된다, 중단하면 `ABANDONED`와 `endedAt`이 채워진다, 남의 세션은 4004, `IN_PROGRESS`가 아니면 4005 |
| `InterviewAnswerCommandServiceIntegrationTest` | 답변 5행이 `PENDING`으로 생성된다, 제출하면 `ANSWERED`, 공백 제출은 `NO_RESPONSE`, 재제출하면 덮어쓴다, 없는 `displayOrder`는 4010 |
| `InterviewSessionFacadeIntegrationTest` | 세션 생성 시 세션 1행과 답변 5행이 함께 저장된다, 응답의 `displayOrder`가 1~5이고 질문 순서와 맞는다, 질문 풀 부족이면 세션도 답변도 저장되지 않는다 |
| `InterviewSessionControllerIntegrationTest` | `@AutoConfigureMockMvc` + `@WithMockLoginUser`로 4개 엔드포인트의 상태 코드와 응답 스키마 |
| `InterviewTechStackControllerIntegrationTest` | `jobRole` 누락 시 400, 정상 조회 200 |

예외 케이스는 전부 `errorCode`까지 검증한다.

**빌드**
- `./gradlew build` - Flyway validate 포함 전체 통과

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)

- `interviewTechStack/controller/docs/InterviewTechStackControllerDocs.java`, `interview/controller/docs/InterviewSessionControllerDocs.java`: 계획서가 적은 `controller/` 직속 대신 `controller/docs/` 하위에 두었다 - 이유: `api-docs-convention.md`가 `controller/docs/{Controller}Docs.java`를 명시하고, 코드베이스도 `controller/docs/` 29건 대 `controller/` 직속 7건으로 우세하다
- `interviewQuestion/domain/InterviewDifficultyQuota.java`: 계획서에 없던 `ascendingDifficulties()`를 public static으로 추가했다 - 이유: 난이도 오름차순이 `toSlots()`와 선별 결과 정렬 두 곳에서 쓰인다. 순서 정의가 두 벌로 갈라지지 않게 한곳에 둔다
- `interviewQuestion/domain/InterviewDifficultyQuota.java`: 구성 합계 검증에 `RestApiException`이 아니라 `IllegalStateException`을 썼다 - 이유: 사용자 요청으로 도달할 수 없는 상수 정의 오류이고 클래스 로딩 시점에 터져야 한다. API 에러코드를 부여할 성질이 아니다
- `interview/domain/InterviewAnswer.java`: 계획서에 없던 `FIRST_DISPLAY_ORDER` 상수를 엔티티에 public으로 추가했다 - 이유: 출제 순서가 1부터라는 규칙이 `InterviewAnswerCommandService`(DB 저장분)와 `InterviewSessionCreateResponse`(응답분) 두 곳에 따로 있었다. 한쪽만 바뀌면 응답의 displayOrder와 저장된 displayOrder가 어긋나고, 답변 제출 API가 displayOrder를 경로 키로 쓰므로 클라이언트가 다른 문항에 답변을 쓰게 된다
