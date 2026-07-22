# [PLAN-444] 학습 이벤트 리스너 실패 유실 방지

> 이슈: #444
> 브랜치: refactor/444-event-listener-retry

## 목표
`LearningEventListener`, `MissionEventListener`, `DailyLearningRecordListener`가 이벤트 처리 실패 시 로그만 남기고 예외를 삼켜 재시도 수단이 없는 문제를, #434에서 도입한 재시도 큐 인프라(`RetryEventPublisher`/`RetrySweepTarget`/`RetryQueueSweeper`)로 통일한다. `DailyLearningRecordListener`의 전용 스레드풀 + `REQUIRES_NEW` 구조도 제거해 큐 기반으로 통일한다.

## 핵심 근거

### 서비스 관점: 부가 처리는 핵심 시퀀스에 영향을 주면 안 된다
- 미션 생성, 미션 진행 처리, 일일 학습 기록 적재는 회원가입(온보딩)이나 레슨 완료라는 핵심 시퀀스의 **부가적인 사후 처리**다. 이 처리가 그 순간에 실패하더라도 사용자의 회원가입이나 레슨 완료 자체는 영향을 받아서는 안 되며, 실패한 부분은 재시도 큐를 통해 나중에 복구되면 충분하다.
- `BEFORE_COMMIT` 전환은 단순히 `UnexpectedRollbackException` 같은 예외 처리 문제를 피하기 위함이 아니라, 이 "부가 처리 실패가 핵심 시퀀스에 영향을 주지 않아야 한다"는 원칙을 구조적으로 강제하기 위함이다.

### 코드 조사 결과: 현재 구조가 원칙을 위배함
- `LearningEventListener`/`MissionEventListener`는 현재 `TransactionPhase.BEFORE_COMMIT`으로 원본 트랜잭션(온보딩/레슨 완료) 안에서 실행된다.
- `MissionService.handleLessonMission` 등은 `@Transactional`이 걸려 있어, 내부에서 예외가 나면 리스너가 try-catch로 삼켜도 Spring이 이미 원본 트랜잭션을 **rollback-only로 마크**한다 → 이후 `commit()` 시점에 `UnexpectedRollbackException`이 발생하거나(트랜잭션 경계에 따라) 온보딩/레슨 완료 자체가 조용히 실패할 수 있다. 즉 부가 처리 실패가 핵심 시퀀스(회원가입/레슨완료)를 오염시키는 구조다.
- 이 사실은 이미 `UserLeagueEventListenerIntegrationTest`(66행)와 `DailyLearningRecordListenerIntegrationTest`(32-36행) 주석에 "MissionEventListener(BEFORE_COMMIT): try-catch 있지만 내부 @Transactional이 트랜잭션을 rollback-only로 마크한다"고 명시되어 있고, 두 테스트 모두 `MissionService`를 Mock으로 격리해 우회하고 있다.
- 반면 이미 마이그레이션된 `UserLeagueEventListener.createUserLeague`(동일한 `OnboardingCompletedEvent`), `SocialFeedEventListener.handleLessonCompleted`(동일한 `LessonCompletedEvent`)는 모두 `AFTER_COMMIT`을 쓴다.
- → 이슈가 요구한 "온보딩 트랜잭션과의 관계 재검토"의 결론은 **BEFORE_COMMIT → AFTER_COMMIT 전환**이다 (아래 결정 필요 항목에서 확정). 핵심 트랜잭션이 커밋된 이후에 부가 처리를 별도로 수행하고, 실패 시 재시도 큐에 적재해 사후 복구하는 방식으로 명확히 분리한다.

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/learning/infrastructure/LearningCreateRetryTarget.java` — `learning-create-retry` 큐 소비
- `src/main/java/gravit/code/mission/infrastructure/MissionLessonRetryTarget.java` — `mission-lesson-retry` 큐 소비
- `src/main/java/gravit/code/mission/infrastructure/MissionFollowRetryTarget.java` — `mission-follow-retry` 큐 소비
- `src/main/java/gravit/code/mission/infrastructure/MissionCreateRetryTarget.java` — `mission-create-retry` 큐 소비
- `src/main/java/gravit/code/dailyLearningRecord/infrastructure/DailyLearningRecordRetryTarget.java` — `daily-learning-record-retry` 큐 소비
- `src/test/java/gravit/code/learning/listener/LearningEventListenerIntegrationTest.java`
- `src/test/java/gravit/code/mission/listener/MissionEventListenerIntegrationTest.java`

### 수정 파일
- `src/main/java/gravit/code/learning/listener/LearningEventListener.java` — `AFTER_COMMIT` 전환, 재시도 큐 적재
- `src/main/java/gravit/code/mission/listener/MissionEventListener.java` — `AFTER_COMMIT` 전환, 3개 핸들러 재시도 큐 적재
- `src/main/java/gravit/code/dailyLearningRecord/listener/DailyLearningRecordListener.java` — `@Async`/`REQUIRES_NEW` 제거, 재시도 큐 적재
- `src/main/java/gravit/code/learning/service/LearningCommandService.java` — `createLearning`에 중복 생성 가드 추가
- `src/main/java/gravit/code/learning/repository/LearningRepository.java` — `existsByUserId` 추가
- `src/main/java/gravit/code/mission/service/MissionService.java` — `createMission`에 중복 생성 가드 추가
- `src/main/java/gravit/code/mission/repository/MissionRepository.java` — `existsByUserId` 추가
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` — `LEARNING_CONFLICT`, `MISSION_CONFLICT` 추가
- `src/main/java/gravit/code/global/config/AsyncConfig.java` — `dailyLearningRecordAsync` 빈 제거 (사용처 소멸)
- `src/test/java/gravit/code/dailyLearningRecord/listener/DailyLearningRecordListenerIntegrationTest.java` — 재시도 큐 적재 케이스 보강, 격리용 Mock 주석 정리
- `src/test/java/gravit/code/dailyLearningRecord/listener/DailyLearningRecordListenerUnitTest.java` — 삭제 (아래 결정 필요 항목)

## 구현 계획
> 레이어 순으로, 클래스·메서드 단위까지 구체적으로.

1. **CustomErrorCode**: `// Learning` 그룹에 `LEARNING_CONFLICT(HttpStatus.CONFLICT, "LEARNING_4091", "이미 학습 정보가 존재합니다.")` 추가. `// Mission` 그룹에 `MISSION_CONFLICT(HttpStatus.CONFLICT, "MISSION_4091", "이미 미션이 존재합니다.")` 추가.

2. **Repository**:
   - `LearningRepository.existsByUserId(long userId)` — Spring Data 쿼리 메서드
   - `MissionRepository.existsByUserId(long userId)` — Spring Data 쿼리 메서드

3. **Service**:
   - `LearningCommandService.createLearning(long userId)` — 기존 로직 앞에 `if (learningRepository.existsByUserId(userId)) throw new RestApiException(CustomErrorCode.LEARNING_CONFLICT);` 추가 (스윕에 의한 중복 재처리 시 `learning.user_id UNIQUE` 제약 위반 대신 식별 가능한 예외로 전환, `UserLeagueService.initUserLeague`와 동일 패턴)
   - `MissionService.createMission(long userId)` — 동일하게 `if (missionRepository.existsByUserId(userId)) throw new RestApiException(CustomErrorCode.MISSION_CONFLICT);` 추가
   - `MissionService.handleLessonMission`/`handleFollowMission`/`DailyLearningRecordService.handleDailyLearningRecord`는 로직 변경 없음 (리스너/RetryTarget에서만 소비)

4. **Listener 전환 (공통 패턴)**: 모든 핸들러를 `@TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)`로 변경하고, `RetryEventPublisher retryEventPublisher` 의존성을 주입한다. `RestApiException` 중 비재시도성 에러코드는 `log.error(...); return;`으로 종료하고, 그 외 예외는 `retryEventPublisher.publish(queueKey, fields)`로 큐 적재한다.

   - `LearningEventListener.createLearning(OnboardingCompletedEvent event)`
     - 비재시도: `LEARNING_CONFLICT` → `log.warn` 후 종료 (큐 적재 생략)
     - 그 외 실패: `learning-create-retry` 큐에 `{"userId": ...}` 적재

   - `MissionEventListener.handleCompleteLessonMission(LessonCompletedEvent event)`
     - 비재시도: `MISSION_NOT_FOUND`, `USER_NOT_FOUND`(경험치 지급 대상 유저 없음) → 종료
     - 그 외 실패: `mission-lesson-retry` 큐에 `{"userId", "lessonId", "learningTime", "accuracy"}` 적재

   - `MissionEventListener.handleFollowMission(FollowMissionEvent followMissionDto)`
     - 비재시도: `MISSION_NOT_FOUND`, `USER_NOT_FOUND` → 종료
     - 그 외 실패: `mission-follow-retry` 큐에 `{"userId"}` 적재

   - `MissionEventListener.createMission(OnboardingCompletedEvent event)`
     - 비재시도: `MISSION_CONFLICT` → 종료
     - 그 외 실패: `mission-create-retry` 큐에 `{"userId"}` 적재

   - `DailyLearningRecordListener.handleDailyLearningRecord(LessonCompletedEvent event)`
     - `handleDailyLearningRecord`는 `orElseGet`으로 없으면 생성하는 멱등 upsert라 `RestApiException` 분기 없음(`SocialFeedStreakRetryTarget`처럼 단순 catch-all)
     - 클래스 레벨 `@Async("dailyLearningRecordAsync")` 제거, 메서드 레벨 `@Transactional(propagation = REQUIRES_NEW)` 제거
     - 실패 시 `daily-learning-record-retry` 큐에 `{"userId"}` 적재

5. **RetrySweepTarget 구현체** (모두 `MAX_ATTEMPTS = 10`, 기존 구현체와 동일 상수):
   - `LearningCreateRetryTarget` — `queueKey()="learning-create-retry"`, `reprocess`에서 `LEARNING_CONFLICT`는 종료, 그 외 rethrow
   - `MissionLessonRetryTarget` — `queueKey()="mission-lesson-retry"`, `NON_RETRYABLE_ERRORS = Set.of(MISSION_NOT_FOUND, USER_NOT_FOUND)`
   - `MissionFollowRetryTarget` — `queueKey()="mission-follow-retry"`, 동일 `NON_RETRYABLE_ERRORS`, `reprocess`에서 `missionService.handleFollowMission(new FollowMissionEvent(userId))` 호출
   - `MissionCreateRetryTarget` — `queueKey()="mission-create-retry"`, `NON_RETRYABLE_ERRORS = Set.of(MISSION_CONFLICT)`
   - `DailyLearningRecordRetryTarget` — `queueKey()="daily-learning-record-retry"`, try-catch 없이 `dailyLearningRecordService.handleDailyLearningRecord(userId)` 직접 호출

6. **AsyncConfig**: `dailyLearningRecordAsync` `@Bean` 메서드(44-57행) 삭제. (`learningAsync`/`missionAsync`는 기존부터 미사용 상태이며 이번 이슈 범위 밖이라 유지)

7. **Facade**: 불필요 — 단일 도메인 Service만 조합

## 결정 필요 (Decisions needed)
- [x] `LearningEventListener`/`MissionEventListener`의 `TransactionPhase`를 `BEFORE_COMMIT → AFTER_COMMIT`으로 전환할지 — **확정: 전환한다.** 위 "핵심 근거" 참고 — 현재 rollback-only 마킹으로 온보딩/레슨완료 트랜잭션이 오염될 수 있는 잠재 결함을 해소하고 #434의 기존 컨벤션(`UserLeagueEventListener`)과 일치시킨다.
- [x] `DailyLearningRecordListenerUnitTest.java`(Mockito 단위 테스트) 처리 방향 — **확정: 삭제한다.** `test-convention.md`가 통합 테스트만 허용하며, 같은 시나리오를 `DailyLearningRecordListenerIntegrationTest`가 이미 커버한다.

## 검증
- `LearningEventListenerIntegrationTest`
  - `createLearning`: 정상 생성 / `LEARNING_CONFLICT`(이미 존재) 시 큐 미적재 / 일시적 오류 시 `learning-create-retry` 큐 적재
- `MissionEventListenerIntegrationTest`
  - `handleCompleteLessonMission`: 정상 처리 / `MISSION_NOT_FOUND` 시 큐 미적재 / 일시적 오류 시 `mission-lesson-retry` 큐 적재
  - `handleFollowMission`: 정상 처리 / 일시적 오류 시 `mission-follow-retry` 큐 적재
  - `createMission`: 정상 생성 / `MISSION_CONFLICT` 시 큐 미적재 / 일시적 오류 시 `mission-create-retry` 큐 적재
- `DailyLearningRecordListenerIntegrationTest`
  - 기존 "커밋 후 서비스 호출" 케이스 유지 + 일시적 오류 시 `daily-learning-record-retry` 큐 적재 케이스 추가
  - 격리용 Mock 주석을 REQUIRES_NEW 관련 서술에서 AFTER_COMMIT 기준으로 갱신
- `RetrySweepTarget` 구현체 5종은 별도 단위 테스트 없이 리스너 통합 테스트 + `RetryQueueSweeper` 기존 테스트로 간접 검증 (기존 컨벤션과 동일)

## Deviation Log
- `LearningEventListener`/`MissionEventListener`/`DailyLearningRecordListener`: 로깅 애노테이션을 `@Log4j2` → `@Slf4j`로 변경 — 이유: #434에서 도입한 재시도 인프라 리스너(`UserLeagueEventListener`/`SocialFeedEventListener`)가 모두 `@Slf4j`를 쓰므로 컨벤션 일치.
