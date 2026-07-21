# [PLAN-448] 문제 제출 기록을 이력 누적 구조로 전환

> 이슈: #448
> 브랜치: refactor/448-problem-submission-history

## 목표

`ProblemSubmission`을 덮어쓰기 구조에서 append-only 이력 구조로 전환한다. `BaseEntity` 상속으로 제출 시각을 확보하고 `selectedOptionId`, `submittedContent`로 제출 내용을 남겨, 지난 답안 조회와 문항 분석, 반복 학습 이력 추적이 가능하도록 만든다.

## 영향 범위

### 신규 파일
- `src/main/resources/db/migration/V27__add_submission_history_to_problem_submission.sql` - 컬럼 4개 추가 (인덱스는 후속 이슈)
- `src/main/java/gravit/code/problem/dto/internal/ProblemTypeDto.java` - 제출 검증용 (problemId, problemType) 경량 projection

### 수정 파일
- `src/main/java/gravit/code/problem/domain/ProblemSubmission.java` - `BaseEntity` 상속, 필드 2개 추가, `updateIsCorrect()` 제거
- `src/main/java/gravit/code/problem/repository/ProblemSubmissionRepository.java` - 단일 행 전제 조회 메서드 2개 제거
- `src/main/java/gravit/code/problem/repository/ProblemRepository.java` - 문제 유형 조회 projection 메서드 추가
- `src/main/java/gravit/code/problem/service/ProblemSubmissionCommandService.java` - `isFirstTry` 분기와 update 경로 제거, 신규 행 적재로 단일화, 문제 유형별 제출 내용 검증 추가
- `src/main/java/gravit/code/problem/dto/request/ProblemSubmissionRequest.java` - `selectedOptionId`, `submittedContent` 추가
- `src/main/java/gravit/code/lesson/facade/LessonFacade.java` - `saveProblemSubmissions` 호출부 인자 조정 (L83)
- `src/main/java/gravit/code/lesson/repository/LessonSubmissionRepository.java` - `findWeakLessonsByUserId`의 오답 카운트 중복 집계 보정 (L136~163)
- `src/test/java/gravit/code/problem/fixture/ProblemSubmissionFixture.java` - 팩토리 시그니처 변경 반영
- `src/test/java/gravit/code/problem/service/ProblemSubmissionCommandServiceUnitTest.java` - update 경로 테스트 제거, 누적 검증으로 교체
- `src/test/java/gravit/code/problem/service/ProblemSubmissionCommandServiceIntegrationTest.java` - 동일
- `src/test/java/gravit/code/lesson/facade/LessonFacadeUnitTest.java` - 변경된 호출 시그니처 stub 반영

### 손대지 않는 것
- `WrongAnsweredNoteService.saveWrongAnsweredNote` - 이미 `findByProblemIdAndUserId` 기반 upsert라 제출이 누적돼도 오답노트는 문제당 1행을 유지한다. 변경 불필요.
- `LessonSubmission` - `tryCount`를 올리는 단일 행 구조를 그대로 둔다. 이번 범위는 문제 제출에 한정한다.
- `CustomErrorCode.PROBLEM_SUBMISSION_NOT_FOUND` - update 경로 제거로 미사용이 되지만 enum 항목은 남긴다 (향후 조회 API에서 재사용).

## 구현 계획

### 1. Entity / Flyway

**`V27__add_submission_history_to_problem_submission.sql`**

```sql
-- V27__add_submission_history_to_problem_submission.sql
-- problem_submission에 BaseEntity 공통 컬럼 추가 (기존 행은 제출 시점 정보 부재로 NULL 허용)
ALTER TABLE problem_submission
    ADD COLUMN created_at TIMESTAMP(6),
    ADD COLUMN updated_at TIMESTAMP(6);

-- 사용자가 실제 제출한 답안 기록 (객관식은 selected_option_id, 주관식은 submitted_content)
ALTER TABLE problem_submission
    ADD COLUMN selected_option_id BIGINT,
    ADD COLUMN submitted_content   TEXT;
```

> 인덱스는 이번 마이그레이션에 넣지 않는다. `problem_submission`은 현재 인덱스가 전무하고 이력 누적으로 행 수가 늘어나므로 조회 인덱스가 필요해지지만, 인덱스 설계는 후속 이슈에서 다른 테이블과 함께 모아서 다룬다.

- 신규 컬럼은 모두 nullable이다. 기존 행에 채울 값이 없고, 객관식/주관식에 따라 둘 중 하나만 채워진다.
- `V7__add_base_entity_columns_to_lesson_submission.sql`의 선례를 그대로 따른다 (백필 없이 NULL 허용).

**`ProblemSubmission.java`**

```java
public class ProblemSubmission extends BaseEntity {

    @Column(name = "selected_option_id")
    private Long selectedOptionId;      // 객관식 제출, 주관식이면 null

    @Column(name = "submitted_content", columnDefinition = "TEXT")
    private String submittedContent;    // 주관식 제출, 객관식이면 null

    public static ProblemSubmission create(
            boolean isCorrect,
            long problemId,
            long userId,
            Long selectedOptionId,
            String submittedContent
    )
}
```

- `updateIsCorrect(boolean)` 삭제. 이력 행은 생성 후 변경하지 않는다.
- `create`의 첫 인자를 `Boolean` → `boolean`으로 정리한다 (현재 박싱 타입을 받아 필드에 언박싱 대입 중이라 null이면 NPE).

### 2. Repository

**`ProblemSubmissionRepository`** - 아래 두 메서드를 제거한다. 둘 다 "사용자+문제당 1행" 전제 위에서만 성립하며, append-only 전환 후 호출부가 사라진다.

- `Optional<ProblemSubmission> findByProblemIdAndUserId(long, long)` - 다중 행이 되어 `Optional` 반환이 깨진다 (`NonUniqueResultException`).
- `List<ProblemSubmission> findByIdInIdsAndUserId(List<Long>, long)` - update 경로 전용.

이번 범위에서 조회 API를 추가하지 않으므로 대체 메서드는 만들지 않는다. `JpaRepository` 기본 메서드만 남는다.

**`ProblemRepository`** - 제출 검증용 projection 메서드를 추가한다. `Problem.content`가 TEXT라 엔티티 전체를 로드하지 않고 필요한 두 컬럼만 가져온다.

```java
@Query("""
    SELECT new gravit.code.problem.dto.internal.ProblemTypeDto(p.id, p.problemType)
    FROM Problem p
    WHERE p.id IN (:problemIds)
""")
List<ProblemTypeDto> findProblemTypesByIds(@Param("problemIds") List<Long> problemIds);
```

**`ProblemTypeDto`** (`problem/dto/internal/`)

```java
public record ProblemTypeDto(
        long problemId,

        ProblemType problemType
) {
}
```

**`LessonSubmissionRepository.findWeakLessonsByUserId`** - 오답 카운트 서브쿼리 2곳(SELECT 절 L139~143, ORDER BY 절 L152~156)의 `COUNT(ps.id)`를 `COUNT(DISTINCT ps.problemId)`로 바꾼다.

> 변경 없이 두면: 같은 문제를 3번 틀린 사용자의 오답 수가 3으로 집계되어, 분모(레슨의 문제 수)를 넘어서고 취약도 비율이 1을 초과한다. 반복 학습을 많이 한 레슨일수록 취약 레슨 상위에 오르는 역전이 생긴다. `getWeakConcepts` (주간 리포트)가 이 값을 그대로 노출한다.

### 3. Service

**`ProblemSubmissionCommandService`**

```java
@Transactional
public void saveProblemSubmissions(
        long userId,
        List<ProblemSubmissionRequest> requests
)
```

- `isFirstTry` 파라미터를 제거한다. 최초 풀이든 재풀이든 새 행을 쌓는 동작이 동일해져 분기가 사라진다.
- `updateProblemSubmissions()`, `createProblemSubmissions()` 두 private 메서드를 하나로 합친다. 각 request를 `ProblemSubmission.create(...)`로 매핑해 `saveAll`하고, `isCorrect == false`면 `wrongAnsweredNoteService.saveWrongAnsweredNote(userId, problemId)`를 호출한다 (기존 동작 유지).
- `PROBLEM_SUBMISSION_NOT_FOUND` 검증(L73~74)이 사라진다. 기존 제출 행을 찾지 않으므로 검증 대상 자체가 없다.
- 저장 전에 `problemRepository.findProblemTypesByIds(problemIds)` 한 번으로 `Map<Long, ProblemType>`을 만들어 아래 `validateSubmissionContent()`를 각 request에 적용한다. 벌크 경로에서 문제 수만큼 조회가 늘지 않도록 조회는 1회로 고정한다.

```java
@Transactional
public void saveProblemSubmission(
        long userId,
        ProblemSubmissionRequest request
)
```

- 선조회(`findByProblemIdAndUserId`) 없이 `ProblemSubmission.create(...)` 결과를 바로 저장한다. 오답노트 저장 조건은 그대로 둔다.
- 단건 경로도 `findProblemTypesByIds(List.of(request.problemId()))`로 유형을 얻어 동일하게 검증한다. 결과가 비면 `PROBLEM_NOT_FOUND`를 던진다.

**신규 private 메서드**

```java
private void validateSubmissionContent(
        ProblemType problemType,
        ProblemSubmissionRequest request
)
```

- `OBJECTIVE`인데 `selectedOptionId == null`이면 `RestApiException(CustomErrorCode.PROBLEM_TYPE_MISMATCH)`
- `SUBJECTIVE`인데 `submittedContent`가 null이거나 공백이면 동일 예외
- 기존 `PROBLEM_TYPE_MISMATCH(HttpStatus.BAD_REQUEST, "PROBLEM_4001", "문제 유형이 요청과 일치하지 않습니다.")`를 재사용한다. `AdminProblemService`가 이미 같은 의미로 쓰고 있어 새 에러코드를 만들지 않는다.

> **배포 순서 제약**: 이 검증은 두 필드를 보내지 않는 구버전 앱 요청을 400으로 떨어뜨린다. 서버 배포 전에 클라이언트의 필드 추가 배포가 선행되어야 한다. 앱 심사, 강제 업데이트 일정과 맞물리므로 배포 전 클라이언트 팀과 순서를 합의한다.

### 4. Facade

신규 Facade 불필요. 기존 `LessonFacade` L83 호출부만 수정한다:

```java
problemSubmissionCommandService.saveProblemSubmissions(userId, request.problemSubmissionRequests());
```

- `isFirstTry`는 `lessonSubmissionCommandService.saveLessonSubmission`과 `userService.updateUserLevelByLessonSubmission`, 이벤트 발행 조건에서 계속 쓰이므로 지역 변수 자체는 유지한다.

### 5. DTO

**`ProblemSubmissionRequest`** - 컴포넌트 2개 추가:

```java
@Schema(
        description = "선택한 보기 아이디 (객관식)",
        example = "12"
)
Long selectedOptionId,

@Schema(
        description = "제출한 답안 내용 (주관식)",
        example = "프로세스는 실행 중인 프로그램이다"
)
String submittedContent
```

- 두 필드 모두 `@NotNull`을 붙이지 않는다. 객관식/주관식에 따라 채워지는 필드가 달라 Bean Validation으로는 표현할 수 없다. 검증은 문제 유형을 아는 Service에서 `validateSubmissionContent()`로 수행한다.

### 6. Controller

경로와 시그니처 변경 없음.

- `POST /api/v1/problems/results` → `ProblemSubmissionCommandService.saveProblemSubmission` (단건, 오답노트 재풀이 경로)
- `POST` 레슨 제출 → `LessonFacade.saveLessonSubmission` → `saveProblemSubmissions` (일괄)

`ProblemControllerDocs`는 request body 스키마가 필드 추가로 자동 갱신되므로 별도 수정 불필요.

## 결정 필요 (Decisions needed)

- [x] **신규 요청 필드의 검증 강도** → **문제 유형별 필수 강제**. `OBJECTIVE`는 `selectedOptionId`, `SUBJECTIVE`는 `submittedContent`를 필수로 검증하고 위반 시 `PROBLEM_TYPE_MISMATCH`(400)를 던진다. 제출 내용이 NULL인 행이 섞이는 것을 처음부터 차단한다. 대가로 클라이언트 배포가 서버 배포보다 선행되어야 한다 (위 "배포 순서 제약" 참조).
- [x] **취약 개념 통계의 오답 집계 기준** → **`COUNT(DISTINCT ps.problemId)`**. "한 번이라도 틀린 문제 수"로 집계해 기존 지표 의미와 수치를 그대로 보존한다. 서브쿼리 두 곳만 고치면 되고, 지표 정의 변경에 따른 사용자 혼란이 없다.

## 검증

- **`ProblemSubmissionCommandServiceIntegrationTest`** (14개, 전부 통과)
  - 동일 (userId, problemId) 반복 제출 시 덮어쓰지 않고 행이 누적되는지, `createdAt`이 채워지는지
  - `selectedOptionId`(객관식) / `submittedContent`(주관식)가 각각 저장되는지
  - 같은 문제를 반복해서 틀려도 오답노트는 1건만 유지되는지
  - 객관식인데 `selectedOptionId`가 null이면 `PROBLEM_TYPE_MISMATCH`
  - 주관식인데 `submittedContent`가 null 또는 공백이면 `PROBLEM_TYPE_MISMATCH`
  - 벌크 검증 실패 시 앞선 제출과 오답노트가 함께 롤백되는지
  - 존재하지 않는 문제면 `PROBLEM_NOT_FOUND`
- **`LessonFacadeUnitTest`** - 변경된 `saveProblemSubmissions(userId, requests)` stub 검증 (통과)
- **`LessonSubmissionQueryServiceIntegrationTest`** - 반복 제출한 사용자의 `getWeakConcepts` 오답 수가 DISTINCT 기준으로 집계되는지 (통과)
- `./gradlew build` (flyway validate 포함) 통과

## Deviation Log

- `src/test/java/gravit/code/problem/service/ProblemSubmissionCommandServiceUnitTest.java`: 계획의 "수정" 대신 삭제하고 커버리지를 통합 테스트로 이관 - 이유: `.claude/spec/test-convention.md`가 "모든 테스트는 통합 테스트로 작성한다. 단위 테스트(Mockito)는 쓰지 않는다"고 규정한다. 이 파일은 8개 테스트 전부가 제거된 `findByProblemIdAndUserId`, `findByIdInIdsAndUserId`, `updateIsCorrect`에 의존해 전면 재작성이 필요했고, 재작성하면 컨벤션이 금지한 Mockito 테스트를 새로 쓰는 셈이 된다.
- `ProblemSubmissionCommandService`: 계획의 `validateSubmissionContent(ProblemType, ProblemSubmissionRequest)` 앞에 조회 래퍼 `validateSubmission(ProblemSubmissionRequest, Map<Long, ProblemType>)`를 추가 - 이유: 문제 유형 조회 실패(`PROBLEM_NOT_FOUND`)와 유형별 내용 검증(`PROBLEM_TYPE_MISMATCH`)을 분리하고, 벌크 경로에서 오답노트 저장 side effect가 일어나기 전에 전체 요청 검증을 선행시키기 위함. 계획에 명시된 시그니처 자체는 그대로 유지했다.
- `src/test/java/gravit/code/problem/fixture/ProblemSubmissionFixture.java`: `정답_제출`, `오답_제출`을 `객관식_제출`, `주관식_제출`로 교체 - 이유: 제출 내용 필드가 생겨 정오답 여부만으로는 픽스처가 제출 형태를 표현하지 못한다. (현재 이 픽스처를 참조하는 테스트는 없다.)
- `src/test/java/gravit/code/lesson/service/LessonSubmissionQueryServiceIntegrationTest.java`: 기대값을 `wrongAnswerCount` 4 → 2, `wrongAnswerRate` 80 → 40으로 정정 - 이유: 계획에는 "비율이 1을 넘지 않는지 검증"만 적었으나, 기존 테스트가 이미 같은 문제(lowP2)를 3번 저장하고 4를 기대하는 형태로 중복 집계 동작을 기대값에 굳혀두고 있었다. DISTINCT 집계 전환에 맞춰 정정했다.
- `src/test/java/gravit/code/lesson/facade/LessonFacadeUnitTest.java`: 단위 테스트지만 통합 테스트로 이관하지 않고 `ProblemSubmissionRequest` 생성자 인자만 최소 수정 - 이유: 이번 변경 범위 밖이며, 시그니처 변경 외에는 깨지는 지점이 없다.
