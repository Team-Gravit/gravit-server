# [PLAN-575] 면접 진행 세션 1개 제한과 이전 세션 접근 예외 구분

> 이슈: #575
> 브랜치: feat/575-interview-single-session

## 목표
면접 도중 이탈한 세션이 진행 중으로 남아 다음 출제에서 문제가 밀리는 문제를 없앤다. 진행 중 세션을 사용자당 1개로 제한하고(새 세션 생성 시 기존 진행 세션 취소, DB 부분 유니크 인덱스로 보장), 진행 중이 아닌 세션에 대한 요청은 "취소됨"과 "제출됨"을 다른 에러 코드로 돌려줘 웹이 홈 이동과 리포트 이동을 구분할 수 있게 한다.

## 영향 범위
### 신규 파일
- `src/main/resources/db/migration/V48__add_interview_session_in_progress_unique.sql` - 기존 중복 진행 세션 정리 + 부분 유니크 인덱스

### 수정 파일
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - `INTERVIEW_SESSION_NOT_IN_PROGRESS`(4005) 삭제, 4025~4027 추가
- `src/main/java/gravit/code/interview/domain/InterviewSession.java` - `validateInProgress()`가 상태별 예외를 던지도록 변경, `isAbandoned()` 추가
- `src/main/java/gravit/code/interview/repository/InterviewSessionRepository.java` - 진행 중 세션 일괄 취소 쿼리 추가
- `src/main/java/gravit/code/interview/service/InterviewSessionCommandService.java` - `create`에서 기존 진행 세션 취소, 유니크 위반 변환. `submit`의 자체 진행 검사 제거
- `src/main/java/gravit/code/interview/service/InterviewSessionQueryService.java` - `getQuestions`를 진행 중 세션으로 제한
- `src/main/java/gravit/code/interview/service/InterviewAudioUploadService.java` - 진행 검사를 도메인 메서드로 교체
- `src/main/java/gravit/code/interview/service/InterviewTranscriptionCommandService.java` - 진행 검사를 도메인 메서드로 교체
- `src/main/java/gravit/code/interview/controller/docs/InterviewSessionControllerDocs.java` - 4005 예시를 4025/4026으로 교체, 생성 409에 4027 추가, 문항 조회에 409 추가
- `.claude/spec/service-policy/interview.md` - 정책 변경 (세션 생성, 출제, 취소, 세션 상태, 결과 노출, 미결 과제 P1, P4)

## 구현 계획

### 1. Flyway - `V48__add_interview_session_in_progress_unique.sql`

운영 DB에는 지금 정책(진행 중이어도 새로 생성 가능) 때문에 같은 사용자의 IN_PROGRESS가 여러 건 있을 수 있다. 정리하지 않으면 인덱스 생성이 실패해 배포가 깨진다.

```sql
-- V48__add_interview_session_in_progress_unique.sql

-- 사용자별로 가장 최근 진행 중 세션 1건만 남기고 나머지를 취소한다
UPDATE interview_session s
SET status     = 'ABANDONED',
    ended_at   = (NOW() AT TIME ZONE 'Asia/Seoul'),
    updated_at = (NOW() AT TIME ZONE 'Asia/Seoul')
WHERE s.status = 'IN_PROGRESS'
  AND EXISTS (
      SELECT 1
      FROM interview_session newer
      WHERE newer.user_id = s.user_id
        AND newer.status = 'IN_PROGRESS'
        AND (newer.started_at, newer.id) > (s.started_at, s.id)
  );

-- 진행 중 세션을 사용자당 1개로 제한한다
CREATE UNIQUE INDEX IF NOT EXISTS uq_interview_session_user_in_progress
    ON interview_session (user_id)
    WHERE status = 'IN_PROGRESS';
```

- 최신 1건을 남기는 이유: 배포 시점에 면접을 진행 중인 사용자의 세션을 끊지 않기 위해서다. 남은 1건도 그 사용자가 다음에 세션을 만들 때 취소된다
- 시각은 앱이 KST `LocalDateTime`으로 저장하므로 DB 타임존과 무관하게 `AT TIME ZONE 'Asia/Seoul'`로 맞춘다
- 부분 인덱스는 V28에 선례가 있다. 빌드의 H2 `flywayValidate`는 SQL을 실행하지 않으므로 영향이 없다

### 2. CustomErrorCode

`// Interview` 그룹 안에서:
- 삭제: `INTERVIEW_SESSION_NOT_IN_PROGRESS(CONFLICT, "INTERVIEW_4005", ...)`
- 추가 (그룹 끝, 4024 다음)
  - `INTERVIEW_SESSION_ABANDONED(CONFLICT, "INTERVIEW_4025", "중단된 면접 세션입니다.")`
  - `INTERVIEW_SESSION_ALREADY_SUBMITTED(CONFLICT, "INTERVIEW_4026", "이미 제출된 면접 세션입니다.")`
  - `INTERVIEW_SESSION_CREATE_CONFLICT(CONFLICT, "INTERVIEW_4027", "면접 세션 생성 요청이 겹쳤습니다. 다시 시도해 주세요.")`

### 3. Entity - `InterviewSession`

- 추가: `public boolean isAbandoned()` - `status == ABANDONED`
- 변경: `private void validateInProgress()` → **`public void validateInProgress()`** (결정 사항 참고, `domain.md` 예외)
  ```java
  public void validateInProgress() {
      if (isAbandoned()) {
          throw new RestApiException(INTERVIEW_SESSION_ABANDONED);
      }
      if (!isInProgress()) {
          throw new RestApiException(INTERVIEW_SESSION_ALREADY_SUBMITTED);
      }
  }
  ```
  - IN_PROGRESS가 아닌 상태는 ABANDONED 또는 제출 이후(GRADING, GRADING_FAILED, COMPLETED) 둘로 나뉘므로 두 코드로 빠짐없이 덮인다
- `startGrading`, `abandon`은 기존처럼 `validateInProgress()`를 호출하므로 수정 없음. 결과적으로 취소된 세션을 다시 취소하면 4025, 제출된 세션을 취소하면 4026이 된다
- static import에서 `INTERVIEW_SESSION_NOT_IN_PROGRESS`를 4025/4026으로 교체

### 4. Repository - `InterviewSessionRepository`

```java
@Modifying(clearAutomatically = true, flushAutomatically = true)
@Query("""
        UPDATE InterviewSession s
        SET s.status = :abandonedStatus, s.endedAt = :endedAt, s.updatedAt = :endedAt
        WHERE s.userId = :userId AND s.status = :inProgressStatus
""")
int abandonInProgressByUserId(
        @Param("userId") long userId,
        @Param("inProgressStatus") InterviewSessionStatus inProgressStatus,
        @Param("abandonedStatus") InterviewSessionStatus abandonedStatus,
        @Param("endedAt") LocalDateTime endedAt
);
```

- 엔티티를 읽어 `abandon()`을 호출하는 대신 bulk UPDATE를 쓰는 이유: IDENTITY 전략에서는 `save()`가 INSERT를 즉시 실행하지만, 더티체킹 UPDATE는 flush 때 나간다. 그래서 엔티티 방식이면 새 세션 INSERT가 기존 세션 취소보다 먼저 실행돼, **자기 자신의 기존 세션과 유니크 인덱스가 충돌**한다. bulk UPDATE는 호출 즉시 실행되므로 순서가 보장된다
- bulk UPDATE는 `@PreUpdate`를 거치지 않으므로 `updatedAt`을 직접 설정한다
- 상태 조건(`status = IN_PROGRESS`)이 도메인의 `validateInProgress` 전제조건과 같아 검증을 우회하지 않는다

### 5. Service - `InterviewSessionCommandService`

**`create(long userId, InterviewSessionCreateDto createDto)`**
1. 맨 앞에서 `interviewSessionRepository.abandonInProgressByUserId(userId, IN_PROGRESS, ABANDONED, LocalDateTime.now(clock))` 호출
2. attemptCount 계산은 그대로
3. 세션 저장을 private 메서드로 감싸 유니크 위반을 변환
   ```java
   private InterviewSession saveSession(InterviewSession session) {
       try {
           return interviewSessionRepository.save(session);
       } catch (DataIntegrityViolationException e) {
           throw new RestApiException(INTERVIEW_SESSION_CREATE_CONFLICT);
       }
   }
   ```
   - 선례: `CongratulationService`의 같은 패턴
   - 위반이 날 수 있는 저장은 세션 INSERT뿐이다. 토픽과 답안은 새 sessionId 기준이라 기존 행과 충돌하지 않으므로 감싸지 않는다
4. 이후 토픽과 답안 저장은 그대로

동시 생성 시 동작 (PostgreSQL READ COMMITTED):
- 기존 진행 세션이 있는 경우: 두 트랜잭션의 UPDATE가 같은 행을 잡아 나중 쪽이 대기한다. 먼저 쪽 커밋 후 나중 쪽은 행이 이미 ABANDONED라 0건을 갱신하고, INSERT가 먼저 쪽의 새 세션과 충돌해 4027이 된다
- 기존 진행 세션이 없는 경우: 두 INSERT가 부분 유니크 인덱스에서 직렬화되어 나중 쪽이 4027이 된다
- 웹은 4027을 받으면 다시 시도한다. 재시도하면 먼저 만들어진 세션이 취소되고 새 세션이 생긴다

**`submit(...)`**
- `validateInProgress(session)` 호출을 `session.validateInProgress()`로 교체하고, private `validateInProgress(InterviewSession)` 메서드 삭제
- `startGrading` 안에서도 검사하지만, 답안 검증보다 먼저 상태별 코드를 돌려주기 위해 앞단 호출을 유지한다

**`abandon(...)`**: 변경 없음 (도메인 `abandon()`이 상태별 예외를 던진다)

### 6. Service - `InterviewSessionQueryService`

**`getQuestions(long userId, long sessionId)`**
- 소유자 검사 다음에 `session.validateInProgress()` 추가
- 이전 세션 URL로 들어온 웹 loader가 이 호출 하나로 4025(홈)/4026(리포트)을 분기한다
- `getStatus`는 변경 없음. 모든 상태에서 조회 가능하게 유지한다

### 7. Service - `InterviewAudioUploadService`, `InterviewTranscriptionCommandService`

- `if (!session.isInProgress()) throw ...NOT_IN_PROGRESS` 블록을 `session.validateInProgress();`로 교체
- 검사 순서(소유자 → 입력 방식 → 진행 여부)는 유지
- `InterviewTranscriptionQueryService`(변환 결과 조회)는 변경 없음

### 8. Facade
불필요 - 단일 도메인(interview) Service 안에서 끝난다. `InterviewSessionFacade.create`는 수정 없음

### 9. DTO
변경 없음

### 10. Controller / Docs - `InterviewSessionControllerDocs`
Controller 변경 없음. Docs만:
- 세션 생성(409): 기존 4009 예시에 4027 예시 추가 (`examples` 배열로)
- 문항 조회: 409 응답 신설, 4025와 4026 예시
- 음성 업로드 URL 발급(409), 음성 변환 요청(409), 세션 중단(409), 답안 일괄 제출(409): 4005 예시를 4025와 4026 예시로 교체
- 각 API description에 "취소된 세션은 4025, 제출된 세션은 4026" 한 줄 추가

### 11. 정책 문서 - `interview.md`

| 위치 | 변경 |
|---|---|
| 세션 생성 (84행) | "진행 중인 세션이 있어도 새 세션을 만들 수 있다..." → 새 세션을 만들면 같은 사용자의 진행 중 세션을 취소한다. 진행 중 세션은 사용자당 최대 1개이며 DB 유니크 인덱스로 보장한다. 동시 생성은 하나만 성공하고 나머지는 4027로 거부한다. 이어하기는 지원하지 않는다 |
| 출제 (109행 근처) | 제출하지 않고 새 세션을 만들면 이전 세션은 취소되므로, 그 세션의 문제도 나온 적 없는 문제로 돌아간다는 점 추가 |
| 취소 (126~129행) | "사용자의 명시적 요청으로만" → 사용자의 명시적 요청 또는 새 세션 생성 시. 이탈 세션은 다음 세션 생성 시 취소된다 |
| 세션 상태 표 (141행) | ABANDONED의 진입 조건에 "새 세션 생성" 추가 |
| 신규 항목 (세션 상태 아래) | 진행 중이 아닌 세션에 진행 전용 요청(문항 조회, 업로드, 변환 요청, 제출, 취소)이 오면 취소 세션은 4025, 제출 이후 세션은 4026으로 거부한다 |
| 결과 노출 (238행) | 문제 목록 조회는 진행 중 세션만. 진행 중이 아닌 세션은 상태만 조회할 수 있다 |
| 미결 과제 P1 | 확정 - 진행 세션 사용자당 1개, 생성 시 기존 진행 세션 취소, 이어하기 미지원 |
| 미결 과제 P4 | 재출제 회피는 제출한 세션 기준이 된다는 점 보충 (제출하지 않고 새로 만들면 이전 문제가 돌아온다) |

## 결정 필요 (Decisions needed)
- [x] `InterviewSession.validateInProgress()`를 public으로 열지 - `domain.md`는 "검증 로직은 Entity 내부 private 메서드"다
  - **확정: public으로 연다.** 문항 조회, 업로드 URL 발급, 변환 요청은 세션 상태를 바꾸지 않아 검증을 얹을 엔티티 메서드가 없으므로, 서비스가 조회 후 `session.validateInProgress()`를 호출한다. 상태별 분기(4025/4026)는 엔티티 한 곳에만 둔다. `domain.md` 규칙의 의도적 예외다
  - 기각: private 유지 후 각 서비스가 `isAbandoned()`/`isInProgress()`로 분기를 반복 (같은 분기가 4곳에 복제됨)

## 검증
- 신규/수정 테스트
  - `InterviewSessionCommandServiceIntegrationTest`
    - 생성: 같은 사용자의 진행 중 세션이 있으면 ABANDONED가 되고 종료 시각이 기록된다 / 다른 사용자의 진행 중 세션은 그대로다 / 제출 이후 세션은 바뀌지 않는다
    - 생성: 유니크 위반이 나면 4027 (`interviewSessionRepository`를 `@MockitoSpyBean`으로 두고 `save`가 `DataIntegrityViolationException`을 던지게 실패 주입)
    - 제출, 취소: 취소된 세션 → 4025, 채점 중 세션 → 4026 (기존 4005 검증 2건 교체)
  - `InterviewSessionQueryServiceIntegrationTest`: 문항 조회 시 취소 세션 4025, 완료 세션 4026, 진행 중 세션은 정상 조회
  - `InterviewAudioUploadServiceIntegrationTest`, `InterviewTranscriptionCommandServiceIntegrationTest`: 기존 4005 검증을 4025/4026으로 교체
  - 마이그레이션: 같은 사용자의 IN_PROGRESS 2건을 저장하면 `DataIntegrityViolationException` (인덱스가 실제로 걸렸는지)
- 깨질 것으로 예상되는 기존 테스트
  - `InterviewSessionFacadeIntegrationTest.이전_세션에_나온_문제를_피해_출제한다`: 첫 세션이 두 번째 생성 때 취소되어 문제가 돌아오므로 실패한다. 첫 세션을 완료(COMPLETED) 상태로 바꾼 뒤 생성하도록 고친다
  - `InterviewSessionFacadeIntegrationTest.취소한_세션의_문제는_안_본_문제로_돌아가_먼저_출제된다`: 첫 세션도 자동 취소되어 후보가 섞이므로, 첫 세션을 완료 처리하도록 고친다
  - 같은 사용자로 `진행중_세션`을 여러 건 저장하는 테스트는 유니크 인덱스에 걸린다. 전체 테스트 실행으로 찾아 사용자 ID를 나누거나 상태를 바꾼다
- 전체: `./gradlew test`

## Deviation Log
- `V48__add_interview_session_in_progress_unique.sql`, `CustomErrorCode`, `InterviewSessionCommandService`, `InterviewSessionControllerDocs`: 부분 유니크 인덱스, 4027, `saveSession` 유니크 위반 변환을 제거 - 이유: 인덱스가 막는 것은 같은 사용자의 동시 생성 경합뿐이고, 경합이 나도 출제와 결과에 영향이 없으며 다음 생성의 일괄 취소로 정리된다. 반면 테스트 DB가 `ddl-auto: create`로 만들어져 엔티티로 부분 인덱스를 표현할 수 없어 별도 테스트 인프라가 필요했다 (사용자 결정)
- `InterviewAnswerRepository`, `InterviewAnswerQueryService`: 출제 이력 조회에서 ABANDONED뿐 아니라 IN_PROGRESS도 제외 (`findQuestionHistoriesByUserIdExcludingStatuses`) - 이유: 문제 선정이 기존 진행 세션 취소보다 먼저 실행되어, 곧 취소될 세션의 문제가 "본 문제"로 잡혀 다음 출제에서 밀렸다. 취소된 세션의 문제는 다음 출제 결정에 영향이 없어야 한다 (사용자 결정)
- `interview.md`: 위 두 변경에 맞춰 세션 생성, 출제, P1, P4 문구 수정
