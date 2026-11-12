# [PLAN-436] NotificationFacade 책임별 분리

> 이슈: #436
> 브랜치: refactor/436-notification-facade-split

## 목표
`NotificationFacade`가 서로 다른 4개 소비자 그룹(스케줄러 발송/이벤트·재처리 단건 알림/Inbox 조회/QA 치트)의 로직을 한 클래스에 담고 있어 가독성이 떨어진다. QA 치트 그룹은 이미 `NotificationQaFacade`로 분리 완료(#436 선행 커밋). 이번 계획은 남은 두 그룹(스케줄러 발송, Inbox 조회)을 각각 전용 Facade로 분리하고, 이벤트·재처리 단건 알림 그룹만 `NotificationFacade` 이름을 유지하도록 정리한다. 이슈의 "가칭" 이름은 `NotificationBatchFacade`(스케줄러 발송), `NotificationInboxFacade`(Inbox 조회)로 확정한다.

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/notification/facade/NotificationBatchFacade.java` — 스케줄러 발송 6개 메서드
- `src/main/java/gravit/code/notification/facade/NotificationInboxFacade.java` — Inbox 조회(`getInbox`) + 응답 조립
- `src/test/java/gravit/code/notification/facade/NotificationInboxFacadeIntegrationTest.java` — 기존 `NotificationFacadeIntegrationTest`의 `GetInbox` nested 클래스 이관

### 수정 파일
- `src/main/java/gravit/code/notification/facade/NotificationFacade.java` — 스케줄러 발송 6개 + Inbox 조회 관련 코드 제거, 이벤트/재처리 단건 알림 4개 메서드만 유지
- `src/main/java/gravit/code/notification/support/NotificationPushSender.java` — `pushToUsers`/`pushEach`/`broadcastToAll` 추가(기존 `pushToUser`와 동일하게 `NotificationFacade`의 private 헬퍼를 이관)
- `src/main/java/gravit/code/notification/batch/NotificationScheduler.java` — `NotificationFacade` → `NotificationBatchFacade` 주입 교체
- `src/main/java/gravit/code/notification/controller/NotificationController.java` — `NotificationFacade` → `NotificationInboxFacade` 주입 교체
- `src/test/java/gravit/code/notification/facade/NotificationSchedulerFacadeIntegrationTest.java` — `NotificationBatchFacadeIntegrationTest.java`로 이름 변경, `NotificationFacadeIntegrationTest`의 `SendSeasonEndingReminders`/`SendSeasonResetAlerts` nested 클래스 흡수
- `src/test/java/gravit/code/notification/facade/NotificationFacadeIntegrationTest.java` — `SendSeasonEndingReminders`/`SendSeasonResetAlerts`/`GetInbox` nested 클래스 제거, `NotifyUser`/`NotifyInApp`만 유지하고 미사용 필드(`SeasonFixture`, `FriendFixture`, `CongratulationRepository` 등) 정리

## 구현 계획
> `RetryTarget`들(`FollowedRetryTarget`, `InquiryAnsweredRetryTarget`)과 `SocialFacade`는 이벤트/재처리 단건 알림 그룹만 사용하므로 변경 없음 (import 유지).

1. **NotificationPushSender 확장** (`notification/support/NotificationPushSender.java`)
   - `pushToUsers(List<Long> userIds, Map<String, String> data, Supplier<String> messageSupplier)` — `NotificationFacade.pushToUsers` 그대로 이관
   - `pushEach(Map<Long, String> messageByUserId, Map<String, String> data)` — `NotificationFacade.pushEach` 그대로 이관
   - `broadcastToAll(Map<String, String> data, String message)` — `NotificationFacade.broadcastToAll` 그대로 이관
   - 기존 필드(`FcmTokenQueryService`, `FcmService`)로 충분, 필드 추가 불필요

2. **NotificationBatchFacade 신규** (`notification/facade/NotificationBatchFacade.java`)
   - `@Facade` + `@RequiredArgsConstructor`
   - 필드: `LearningQueryService`, `UserAccessService`, `NotificationMessageProvider`, `NotificationService`, `SeasonService`, `NotificationPushSender`, `Clock`
   - 메서드(기존 `NotificationFacade`에서 시그니처·본문 그대로 이관, `push*` 호출부만 `notificationPushSender.push*`로 교체):
     - `void sendConsecutiveLearningWarnings()`
     - `void sendDailyIncompleteReminders()`
     - `void sendInactivityReminders()`
     - `void sendNewContentAlerts(long unitId)`
     - `void sendSeasonEndingReminders()`
     - `void sendSeasonResetAlerts()`

3. **NotificationInboxFacade 신규** (`notification/facade/NotificationInboxFacade.java`)
   - `@Facade` + `@RequiredArgsConstructor`
   - 필드: `NotificationQueryService`, `FriendService`, `UserService`, `CongratulationService`, `TimeAgoFormatter`
   - 메서드(기존 `NotificationFacade`에서 시그니처·본문 그대로 이관):
     - `@Transactional(readOnly = true) List<NotificationResponse> getInbox(long userId)`
     - `private NotificationResponse toResponse(Notification, Set<Long>, Map<Long, UserSummaryResponse>, Set<Long>)`
     - `private NotificationActor toActor(UserSummaryResponse)`

4. **NotificationFacade 축소** (`notification/facade/NotificationFacade.java`)
   - 스케줄러 발송 6개 메서드, `getInbox`/`toResponse`/`toActor`, `broadcastToAll`/`pushToUsers`/`pushEach` 삭제
   - 남는 필드: `NotificationService`, `NotificationPushSender`만 유지 (`LearningQueryService`, `UserAccessService`, `FcmTokenQueryService`, `FcmService`, `NotificationMessageProvider`, `TimeAgoFormatter`, `NotificationQueryService`, `FriendService`, `SeasonService`, `UserService`, `CongratulationService`, `Clock` 전부 제거)
   - 남는 메서드: `notifyUserInApp`, `notifyUsersInApp`, `notifyUser`(3-arg/4-arg), `notifyUsers`(3-arg/4-arg) — 기존 시그니처·본문 그대로

5. **Controller**
   - `NotificationController`: 필드 `NotificationFacade notificationFacade` → `NotificationInboxFacade notificationInboxFacade`, `getInbox` 호출부 갱신

6. **Scheduler**
   - `NotificationScheduler`: 필드 `NotificationFacade notificationFacade` → `NotificationBatchFacade notificationBatchFacade`, 5개 호출부 갱신 (`sendNewContentAlerts`는 현재 스케줄러에서 미사용 — 그대로 유지)

## 결정 필요 (Decisions needed)
없음 — Facade 이름(`NotificationBatchFacade`, `NotificationInboxFacade`)은 이슈의 가칭을 그대로 확정.

## 검증
- 대상 테스트:
  - `NotificationBatchFacadeIntegrationTest`(이름 변경) — 기존 `ConsecutiveLearningWarning`/`DailyIncomplete`/`Inactivity` + 이관된 `SendSeasonEndingReminders`/`SendSeasonResetAlerts`
  - `NotificationFacadeIntegrationTest`(축소) — `NotifyUser`/`NotifyInApp`만 남은 상태로 통과
  - `NotificationInboxFacadeIntegrationTest`(신규) — 이관된 `GetInbox` 시나리오 전부 통과
  - `NotificationEventListenerIntegrationTest`, `SocialFacadeIntegrationTest` — `NotificationFacade` 축소가 `RetryTarget`/`SocialFacade` 소비자에 영향 없는지 회귀 확인
  - `./gradlew compileJava compileTestJava` — 컴파일 오류(미사용 import/필드) 없는지 확인
  - `./gradlew test` — 전체 통과 확인

## Deviation Log
- `NotificationInboxFacadeIntegrationTest.java`: 계획은 기존 `GetInbox` nested 클래스를 그대로 이관하는 것이었으나, 새 파일이 Inbox 조회 시나리오 전용이라 `@Nested class GetInbox`로 한 번 더 감싸는 게 불필요해 테스트 메서드를 top-level 클래스로 평탄화 — 이유: 파일이 이미 단일 책임(Inbox 조회)만 다루므로 nested 래핑이 군더더기
- `NotificationFacade.java`: 계획엔 없던 추가 정리로, `notifyUser` 3-arg 오버로드와 `notifyUsers`(3-arg/4-arg) 전부 삭제 — 이유: 분리 작업 중 확인해보니 `notifyUsers`는 프로덕션·테스트 어디에서도 호출되지 않는 죽은 코드였고, `notifyUser` 3-arg는 실사용처(`InquiryAnsweredRetryTarget`)가 항상 4-arg만 호출해 존재 의미가 없었음. `NotificationFacadeIntegrationTest`의 `NotifyUser` nested 클래스 호출부도 4-arg로 갱신
