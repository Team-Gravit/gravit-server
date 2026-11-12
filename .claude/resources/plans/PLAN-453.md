# [PLAN-453] 오답노트 물리 삭제를 상태 전환으로 변경

> 이슈: #453
> 브랜치: refactor/453-wrong-answered-note-resolve

## 목표

`WrongAnsweredNote`를 "현재 틀린 상태인가"만 담는 존재 여부 테이블에서, 오답 이력을 남기는 상태 테이블로 바꾼다.
`BaseEntity` 상속으로 시각 정보를 남기고 `wrongCount`, `resolvedAt`을 추가해, 삭제 API가 행을 지우는 대신 `resolvedAt`을 기록하도록 전환한다.
조회는 `resolvedAt IS NULL` 필터를 더해 현재 화면 동작을 그대로 유지한다.

## 영향 범위

### 신규 파일
- `src/main/resources/db/migration/V30__convert_wrong_answered_note_to_resolvable.sql` — created_at, updated_at, wrong_count, resolved_at 추가

### 수정 파일
- `src/main/java/gravit/code/wrongAnsweredNote/domain/WrongAnsweredNote.java` — `BaseEntity` 상속, `wrongCount`, `resolvedAt` 필드와 상태 전환 메서드 추가
- `src/main/java/gravit/code/wrongAnsweredNote/repository/WrongAnsweredNoteRepository.java` — `deleteByProblemIdAndUserId` 제거, 조회 2건에 미극복 필터 추가
- `src/main/java/gravit/code/wrongAnsweredNote/service/WrongAnsweredNoteService.java` — `saveWrongAnsweredNote`에 재오답 처리 추가, `deleteWrongAnsweredProblem` → `resolveWrongAnsweredNote`
- `src/main/java/gravit/code/wrongAnsweredNote/controller/WrongAnsweredNoteController.java` — 변경된 Service 메서드명으로 호출 교체
- `src/test/java/gravit/code/wrongAnsweredNote/fixture/WrongAnsweredNoteFixture.java` — 극복된 노트, 누적 오답 노트 픽스처 추가
- `src/test/java/gravit/code/wrongAnsweredNote/service/WrongAnsweredNoteServiceUnitTest.java` — 삭제 검증을 상태 전환 검증으로 교체
- `src/test/java/gravit/code/wrongAnsweredNote/service/WrongAnsweredNoteServiceIntegrationTest.java` — 행 존속, 재오답 복귀, 극복분 조회 제외 시나리오 추가

### 확인만 하고 변경하지 않는 파일
- `src/main/java/gravit/code/wrongAnsweredNote/controller/WrongAnsweredNoteControllerDocs.java` — HTTP 계약(DELETE, 204)이 그대로라 시그니처 변경 없음. `@Operation` 설명 문구만 "오답노트에서 내림"으로 다듬는다
- `src/main/java/gravit/code/problem/service/ProblemSubmissionCommandService.java` — `saveWrongAnsweredNote` 호출부 시그니처가 유지되므로 변경 없음
- `src/main/java/gravit/code/lesson/facade/LessonFacade.java` — `checkWrongAnsweredProblemExists` 시그니처가 유지되므로 변경 없음
- `src/test/java/gravit/code/problem/service/ProblemSubmissionCommandServiceIntegrationTest.java` — 오답 생성/미생성만 검증하므로 통과 예상. 실행으로 확인한다

## 구현 계획

### 1. Entity / Flyway

**`WrongAnsweredNote`** — `BaseEntity` 상속으로 전환

```java
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class WrongAnsweredNote extends BaseEntity {

    private static final int INITIAL_WRONG_COUNT = 1;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "problem_id", nullable = false)
    private long problemId;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Column(name = "wrong_count", nullable = false)
    private int wrongCount;

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;
    ...
}
```

- `create(long problemId, long userId)` — `wrongCount = INITIAL_WRONG_COUNT`, `resolvedAt`은 채우지 않는다(미극복)
- `markWrong()` 추가 — `wrongCount++`, `resolvedAt = null`. 극복 처리된 문제를 다시 틀리면 오답노트로 복귀시킨다
- `resolve()` 추가 — 이미 `resolvedAt`이 있으면 그대로 두고 반환한다. 없으면 `LocalDateTime.now(TimeZoneConst.KST)`를 채운다. 중복 호출로 극복 시점이 뒤로 밀리지 않게 하기 위함이다
- `isResolved()` 추가 — `resolvedAt != null`. 테스트와 `resolve()` 내부 가드에서 쓴다

> `createdAt`, `updatedAt`은 `BaseEntity`의 `@PrePersist`, `@PreUpdate`가 채운다. 별도 필드를 만들지 않는다.

**`V30__convert_wrong_answered_note_to_resolvable.sql`**

```sql
-- V30__convert_wrong_answered_note_to_resolvable.sql
-- 오답노트를 물리 삭제 대상에서 극복 여부를 남기는 상태 테이블로 전환

-- BaseEntity 공통 컬럼. 기존 행은 최초 오답 시점을 알 수 없어 NULL을 허용한다
ALTER TABLE wrong_answered_note
    ADD COLUMN created_at TIMESTAMP(6),
    ADD COLUMN updated_at TIMESTAMP(6);

-- 같은 문제를 몇 번 틀렸는지 누적한다. 기존 행은 최소 1회 오답이므로 1로 채운다
ALTER TABLE wrong_answered_note
    ADD COLUMN wrong_count INTEGER NOT NULL DEFAULT 1;

-- NULL이면 오답노트에 노출되고, 값이 있으면 극복 처리되어 노출되지 않는다
-- 기존 행은 전부 미극복 상태이므로 NULL로 둔다
ALTER TABLE wrong_answered_note
    ADD COLUMN resolved_at TIMESTAMP(6);
```

> `wrong_count`의 `DEFAULT 1`은 백필용이자 롤링 배포 안전장치다. 구버전 인스턴스가 이 컬럼을 모른 채 INSERT해도 실패하지 않는다.

### 2. Repository — `WrongAnsweredNoteRepository`

| 메서드 | 변경 |
|---|---|
| `findByProblemIdAndUserId` | 변경 없음. 극복 여부와 무관하게 행을 찾아야 재오답 복귀와 극복 처리 양쪽에 쓸 수 있다 |
| `findWrongAnsweredProblemDetailByUnitIdAndUserId` | `WHERE` 절에 `AND wan.resolvedAt IS NULL` 추가 |
| `countByUnitIdAndUserId` | `WHERE` 절에 `AND wan.resolvedAt IS NULL` 추가 |
| `deleteByProblemIdAndUserId` | **삭제**. 물리 삭제 경로를 남겨두면 상태 전환을 우회할 수 있다 |

조회 쿼리 변경 후 `WHERE` 절:

```
WHERE wan.userId = :userId AND u.id = :unitId AND wan.resolvedAt IS NULL
```

```
WHERE u.id = :unitId AND wan.userId = :userId AND wan.resolvedAt IS NULL
```

### 3. Service — `WrongAnsweredNoteService`

`saveWrongAnsweredNote(long userId, long problemId)` — 기존 행이 있으면 재오답 처리한다

```java
@Transactional
public void saveWrongAnsweredNote(
        long userId,
        long problemId
) {
    WrongAnsweredNote wrongAnsweredNote = wrongAnsweredNoteRepository.findByProblemIdAndUserId(problemId, userId)
            .map(WrongAnsweredNote::markWrong)
            .orElseGet(() -> WrongAnsweredNote.create(problemId, userId));

    wrongAnsweredNoteRepository.save(wrongAnsweredNote);
}
```

- `markWrong()`이 `this`를 반환하게 해 `map`으로 이어 쓴다
- 기존에는 찾은 행을 그대로 다시 저장하는 무의미한 호출이었다. 이제 오답 횟수가 누적된다

`deleteWrongAnsweredProblem` → `resolveWrongAnsweredNote(long userId, long problemId)`로 이름과 동작을 함께 바꾼다

```java
@Transactional
public void resolveWrongAnsweredNote(
        long userId,
        long problemId
) {
    wrongAnsweredNoteRepository.findByProblemIdAndUserId(problemId, userId)
            .ifPresent(WrongAnsweredNote::resolve);
}
```

- 대상 행이 없으면 아무것도 하지 않는다. 현재 `deleteByProblemIdAndUserId`도 없는 행에 대해 조용히 통과했고, DELETE 요청은 멱등해야 하므로 404를 새로 던지지 않는다
- 영속 상태 엔티티의 dirty checking으로 반영되므로 `save` 호출을 두지 않는다
- `getAllWrongAnsweredProblemInUnit`, `checkWrongAnsweredProblemExists`는 시그니처와 본문 모두 변경 없다. Repository 쿼리 필터만으로 미극복 건만 세어진다

### 4. Facade

불필요 — `WrongAnsweredNoteFacade`는 조회 조합만 담당하며 이번 변경에 닿지 않는다.

### 5. DTO

변경 없음 — `WrongAnsweredNoteDeleteRequest`(problemId), `ProblemDetailResponse`, `WrongAnsweredProblemsResponse` 모두 그대로 쓴다.
`wrongCount`는 이번 이슈에서 집계 데이터를 쌓기만 하고 응답에 노출하지 않는다.

### 6. Controller

`DELETE /api/v1/wrong-answered-notes` — 경로, 메서드명, 요청 본문, 204 응답 모두 유지한다.
본문 한 줄만 교체한다.

```java
wrongAnsweredNoteService.resolveWrongAnsweredNote(loginUser.getId(), request.problemId());
```

`WrongAnsweredNoteControllerDocs`의 `@Operation` 설명을 "특정 문제를 오답노트에서 내립니다. 기록은 남으며 다시 틀리면 오답노트로 복귀합니다."로 다듬는다.

## 범위 밖 (후속 과제)

- **정답 재제출 시 자동 극복** — 이슈에 명시한 대로 제외한다. 현재 정답 처리 경로에 오답노트를 건드리는 코드가 없다
- **`wrong_answered_note` 인덱스** — 이 테이블에는 지금 인덱스가 하나도 없다. `(user_id, resolved_at)` 부분 인덱스가 조회에 유리하지만, 스키마 의미 전환과 인덱스 튜닝을 한 PR에 섞지 않는다
- **`(problem_id, user_id)` 유니크 제약** — 현재도 제약이 없어 중복 행이 생기면 `findByProblemIdAndUserId`가 터진다. 기존 문제이며 이번 변경이 악화시키지 않는다
- **`wrongCount` 기반 취약 개념 집계 API** — 데이터를 쌓는 것까지가 이번 범위다

## 결정 필요 (Decisions needed)

없음 — 필드 구성(`lastWrongAt` 제외)과 자동 극복 제외는 이슈 발의 단계에서 확정했다.

## 검증

**단위 테스트** — `WrongAnsweredNoteServiceUnitTest`

- `SaveWrongAnsweredNote`
  - 기존 노트가 없으면 새로 생성한다 (유지)
  - 기존 노트가 있으면 wrongCount가 증가한 채 저장된다 (기존 "중복 생성하지 않는다"를 대체)
  - 극복된 노트를 다시 틀리면 resolvedAt이 해제된 채 저장된다 (신규)
- `ResolveWrongAnsweredNote` (기존 `DeleteWrongAnsweredProblem` 대체)
  - 노트가 있으면 resolvedAt이 채워진다
  - 노트가 없으면 예외 없이 통과한다
  - `deleteByProblemIdAndUserId`를 더 이상 호출하지 않는다

**통합 테스트** — `WrongAnsweredNoteServiceIntegrationTest`

- 삭제 API 경로 실행 후 행이 남아 있고 `resolvedAt`이 채워진다 (기존 `isEmpty()` 단언을 뒤집는다)
- 극복된 노트는 `getAllWrongAnsweredProblemInUnit` 결과에서 빠진다
- 극복된 노트만 있으면 `checkWrongAnsweredProblemExists`가 false다
- 같은 문제를 두 번 틀리면 행은 1개이고 `wrongCount`가 2다
- 극복 후 다시 틀리면 조회 목록에 복귀한다

**픽스처** — `WrongAnsweredNoteFixture`

- `극복된_오답노트(long problemId, long userId)` 추가 — `ReflectionTestUtils`로 `resolvedAt` 주입
- `누적_오답노트(long problemId, long userId, int wrongCount)` 추가

**회귀 확인**

- `ProblemSubmissionCommandServiceIntegrationTest` — 오답 시 노트 생성, 정답 시 미생성 단언이 그대로 통과하는지 실행으로 확인
- `WrongAnsweredNoteFacadeIntegrationTest`, `LessonFacadeUnitTest` — 시그니처 변경이 없어 통과 예상
- `./gradlew build` — Flyway validate 포함

## Deviation Log

- `WrongAnsweredNoteServiceUnitTest`: 계획의 "`deleteByProblemIdAndUserId`를 더 이상 호출하지 않는다" 테스트를 넣지 않았다 — 이유: Repository에서 메서드를 제거해 컴파일러가 이미 보장하며, 존재하지 않는 메서드는 `verify`로 검증할 수 없다. 대신 "이미 극복된 노트는 극복 시각이 밀리지 않는다"로 `resolve()` 가드를 검증한다
- `WrongAnsweredNoteServiceIntegrationTest`: 계획에 없던 "극복된 문제는 오답 문제 목록에서 빠진다"를 `ResolveWrongAnsweredNote`에 넣었다 — 이유: 극복 처리와 조회 필터가 한 시나리오로 이어져야 "화면 동작 유지"가 실제로 증명된다
- 마이그레이션 번호를 V29에서 V30으로 변경 — 이유: `origin/dev`에 V28이 두 개(`V28__add_friend_search_indexes.sql` #451, `V28__convert_lesson_submission_to_history.sql` #450) 있어 `flywayValidate`가 이미 깨져 있었다. 충돌 해소로 #450 파일이 V29를 차지한다
- `V28__convert_lesson_submission_to_history.sql` → `V29__convert_lesson_submission_to_history.sql` 재번호 (계획 범위 밖) — 이유: dev의 기존 파손을 풀지 않으면 이 브랜치에서 빌드 검증 자체가 불가능하다. #451이 먼저 머지되어 이미 적용됐을 수 있는 반면 #450 파일은 머지 직후부터 빌드가 깨져 어디에도 적용된 적이 없어, 옮겨도 `flyway_schema_history`와 어긋나지 않는다
