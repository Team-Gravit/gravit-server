# [REQ-015] 알림 시스템 명세(notification-req.md v2) 정합화

## 개요
`notification-req.md` **v2(2026-06-30)** 명세 대비 현재 dev 브랜치 알림 구현의 불일치를 모두 명세 기준으로 맞춘다.

v2의 가장 큰 변화는 **알림 채널 모델 전면 개편**이다.
- (v1) 알림별로 "앱 푸시 / 인앱 박스 / 인앱 애니메이션" 중 **하나의 채널로만 배타적 발송**
- (v2) **애니메이션 3종(3.4·3.5·3.6)을 제외한 모든 알림은 기본적으로 인앱 알림 박스로 발송**하고, 그중 시간 민감성이 높은 일부만 **앱 푸시까지 추가 발송**한다. 웹은 인앱만 지원(웹 푸시 미지원).

이 변경으로 인해 v1 기준으로 작성됐던 기존 항목 일부(특히 "푸시 전용 알림의 인앱 박스 적재 제거")는 **방향이 반대로 바뀐다.**

> **범위 제외**
> - 인앱 애니메이션으로 처리되는 3.4(레벨업)·3.5(연속학습 달성)·3.6(리그 티어 승급)은 알림이 아니므로 대상이 아니다(현재도 `NotificationType`에 없음).
> - 프론트 전용 항목(알림함 빈 상태 텍스트, 팔로우 버튼 토글 UI 전환, 새 레슨 딥링크)은 백엔드 작업 범위 밖이며 명세 확인/협의 사항으로만 기록한다.

---

## 1. [핵심] 알림 채널 모델 v2 정합화

명세 §3 채널 매트릭스 기준으로 각 알림의 발송 채널을 맞춘다. `NotificationType` 기준 매핑은 아래와 같다.

| 명세 § | NotificationType | v2 목표 채널 | 현재 동작 | 필요 변경 |
| --- | --- | --- | --- | --- |
| 3.1 | `CONSECUTIVE_LEARNING_WARNING` | 인앱 + 푸시 | 푸시 only | **인앱 박스 적재 추가** |
| 3.2 | `DAILY_INCOMPLETE` | 인앱 + 푸시 | 푸시 only | **인앱 박스 적재 추가** |
| 3.3 | `INACTIVITY` | 인앱 + 푸시 | 푸시 only | **인앱 박스 적재 추가** |
| 3.7 | `SEASON_ENDING` | 인앱 + 푸시 | 인앱 + 푸시 | 유지 (레이아웃만 분리) |
| 3.8 | `SEASON_RESET` | 인앱 + 푸시 | 인앱 + 푸시 | 유지 (발송 시점만 변경) |
| 3.9 | `FOLLOW` | 인앱 only | 인앱 + 푸시 | **푸시 제거** |
| 3.10 | `CONGRATULATION` | 인앱 only | 인앱 + 푸시 | **푸시 제거** |
| 3.11 | `FRIEND_ACTIVITY` | 인앱 only | 인앱 + 푸시 | **푸시 제거** |
| 3.12 | `NOTICE` | 인앱 only | 인앱 only | 유지 (레이아웃만 분리) |
| 3.13 | `NEW_CONTENT` | 인앱 only | 푸시 only | **푸시 제거 + 인앱 박스 적재로 전환** |

### 1-1. 인앱 박스 적재 추가 (3.1·3.2·3.3)
- 현재 `NotificationFacade.sendConsecutiveLearningWarnings/sendDailyIncompleteReminders/sendInactivityReminders`는 `pushToUsers`로 **푸시만** 발송하고 인앱 박스에는 저장하지 않는다.
- 푸시 발송에 더해 **각 대상 유저의 알림함에도 동일 알림을 저장**한다.
- ⚠️ 메시지가 유저별로 다르므로 단일 메시지 브로드캐스트(`notifyAllUsers`)나 동일 메시지 일괄(`notifyUsers(..., message)`)로는 부족하다.
  - 3.1: 유저별 연속일수(`consecutiveWarning(days)`) → 유저별 메시지
  - 3.2: 유저별 랜덤 문구(`randomDailyIncomplete()`) → 유저별 메시지
  - 3.3: 마일스톤 그룹 단위 동일 문구 → 그룹별 일괄 저장 가능
  - 유저별 메시지를 한 번에 저장하는 경로(예: `NotificationService.notify`를 유저별로 호출 또는 `(userId, message)` 쌍 일괄 저장 메서드 추가)가 필요하다.
- ⚠️ **데이터량 영향**: 매일 21시 전체 대상 유저에게 알림 row가 적재되므로 `notification` 테이블 증가량이 크게 늘어난다. 보관/조회 정책(아래 4번)과 `user_id, created_at` 인덱스 점검을 함께 진행한다.

### 1-2. 푸시 제거 (3.9·3.10·3.11)
- `FOLLOW`/`CONGRATULATION`은 `NotificationFacade.notifyUser`, `FRIEND_ACTIVITY`는 `notifyUsers`를 거치며 현재 **인앱 저장 + 푸시**를 모두 수행한다(`notify*` 내부에서 `pushToUser(s)` 호출).
- 이 3종은 인앱 only이므로 **푸시 호출을 제거**하고 인앱 저장만 남긴다.
- `notifyUser`/`notifyUsers`가 다른 알림(범위상 현재는 `INQUIRY_ANSWERED`)에도 쓰이므로, 푸시 동반 여부를 알림 성격에 맞게 분리해야 한다(인앱 only 저장 경로 vs 인앱+푸시 경로).
  - **`INQUIRY_ANSWERED`(문의 답변)는 현행(인앱+푸시) 그대로 유지한다.** 명세 항목이 없고 추후 기능 자체가 삭제될 수 있어 본 작업에서 건드리지 않는다.

### 1-3. 푸시 → 인앱 전환 (3.13 새 콘텐츠)
- 현재 `sendNewContentAlerts/sendNewContentToUser`는 FCM 푸시 broadcast만 수행한다.
- v2에서는 인앱 only이므로 **푸시를 제거하고 전체 활성 유저 알림함 적재(`notifyAllUsers`)로 전환**한다. (메시지 동일하므로 broadcast insert 사용 가능)

---

## 2. [3.8] 시즌 종료 + 새 시즌 알림 발송 시점 변경
- 명세: ~~시즌 종료 즉시~~ → **시즌 종료 다음날 오전 9시** 발송. (자정 종료 시 즉시 발송하면 새벽 푸시가 발생하는 문제 회피)
- 현재 `NotificationEventListener.handleSeasonRolledOver`가 `SeasonRolledOverEvent` 커밋 직후(롤오버 시점, 사실상 자정) `sendSeasonResetAlerts`를 즉시 호출한다.
- **즉시 발송을 분리**해 다음날 오전 9시에 발송되도록 변경한다(예: 롤오버 이벤트에서 즉시 발송하지 않고, 별도 스케줄러로 "전날 종료된 시즌이 있으면 오전 9시 발송" 처리).
- 소프트 리셋 결과(시작 티어/LP)는 알림이 아닌 첫 접속 팝업으로 노출 → 현재도 알림에 미포함이므로 유지.

---

## 3. 카피·레이아웃 정합화 (헤드라인/서브텍스트 분리)

v2는 일부 알림을 **헤드라인 + 서브텍스트** 2단 구조로 명시한다. 현재 알림은 단일 `message` 필드만 가지므로 **서브텍스트 필드 추가가 선행**되어야 한다.

### 3-1. 서브텍스트 필드 추가 (스키마 변경)
- `Notification` 엔티티에 `sub_text`(nullable) 추가.
- Flyway 마이그레이션으로 `notification.sub_text VARCHAR` 컬럼 추가(**다음 버전: `V25__add_notification_sub_text.sql`**, 현재 최신 V24).
- `NotificationRepository.insertForAllActiveUsers`에 서브텍스트 파라미터 추가, 유저별 저장 경로에도 서브텍스트 전달.
- `NotificationResponse`에 `subText` 필드 추가.

### 3-2. 대상 알림별 카피 (v2 §4 그대로)
| 알림 | 헤드라인(message) | 서브텍스트(sub_text) |
| --- | --- | --- |
| 3.1 `CONSECUTIVE_LEARNING_WARNING` | `N일 연속학습이 끊길 위기예요!` | `오늘 학습하면 계속 이어갈 수 있어요` |
| 3.7 `SEASON_ENDING` (7일 전) | `시즌이 일주일 뒤 끝나요!` | `지금이 티어 올릴 마지막 기회예요 💪` |
| 3.7 `SEASON_ENDING` (3일 전) | `시즌 종료가 3일 앞으로 다가왔어요!` | `마지막까지 달려봐요 🔥` |
| 3.12 `NOTICE` | `새로운 공지사항이 있어요` (고정) | `{공지 제목}` (동적) |

- **3.1**: 현재 `consecutiveWarning` = `"오늘 학습을 하지 않으면 %d일 연속학습이 끊겨요!"` (단일·문구 상이) → 명세 헤드라인으로 교체 + 서브텍스트 추가.
- **3.7**: 현재 `SEASON_ENDING_MILESTONES`가 헤드+서브를 한 문장으로 합쳐 둠 → `SeasonEndingMilestone`을 (headline, subText) 구조로 분리하고 `sendSeasonEndingReminders`에서 두 필드를 각각 전달.
- **3.12**: 현재 `noticePublished` = `"[공지] {제목}"` 단일 → 헤드라인 고정 문구 + 서브텍스트(제목)로 분리. 액션 버튼 `공지 보러가기`(`GO_TO_NOTICE`) 유지.

---

## 4. [§5] 알림함 조회 정책 — 30일 이내 · 최신 30건
- 알림 목록 조회는 **생성 후 30일 이내** 알림만, **최신 30건**까지 반환한다(미노출만으로 명세 충족, 물리 삭제 배치는 범위 밖).
- 구현: `NotificationRepository` 조회에 `created_at >= (now - 30일)` 조건 + `LIMIT 30` + `created_at DESC, id DESC` 정렬.
- 명세는 "최신 30건 단일 목록"이므로 **기존 페이지네이션(20건 Slice)을 제거**하고 단일 목록으로 응답한다.
  - `NotificationQueryService.getNotifications`(현재 `PAGE_SIZE=20` Slice), `NotificationFacade.getInbox`, `NotificationController`/`NotificationDocs`의 `page` 파라미터, `SliceResponse` 응답 구조 변경 동반.

---

## 5. [§5] 시간 표기(timeAgo) — v2 표 그대로
| 구간 | 표기 |
| --- | --- |
| 1시간 이내 | `N분 전` |
| 1시간 ~ 24시간 | `N시간 전` |
| 어제(1일) | `어제` |
| 2일 ~ 6일 | `N일 전` |
| 7일 ~ 30일 | `N주 전` (N = 일수 / 7 의 정수부) |

- 현재 `TimeAgoFormatter`: `방금 전` 존재, 1일을 `1일 전`으로, 7일 이상을 `7일 전`으로 고정 → 명세 불일치.
  - `방금 전` 제거(명세에 없음), 1일은 `어제`, 7~30일은 `N주 전`으로 변경.
- ⚠️ `TimeAgoFormatter`는 `SocialFeedResponse`도 사용한다(`NotificationResponse`와 공유). 소셜 피드 표기에 영향을 주지 않도록 **알림 전용 포맷 메서드/포맷터를 분리**해 적용한다(공유 유틸 직접 수정 금지). 소셜 피드 표기 변경은 본 요구사항 범위 밖.

---

## 6. [3.3] 장기 미접속 — 120일 추가 및 문구 정합
- `INACTIVITY_MILESTONES`에 **120일** 마일스톤을 추가하고, **120일째 발송을 마지막으로 종료**한다(121일 이후 추가 알림 없음). 현재는 7/14/30/60/90까지만 존재.
- 7/14/30일 문구를 명세 그대로 교체(현재 문구는 v1 캐주얼 버전):
  - 7일: `벌써 일주일이 지났어요 😢 Gravit이 기다리고 있어요!`
  - 14일: `14일이 지났어요. 슬슬 돌아올 때가 된 것 같은데요? 👀`
  - 30일: `한 달 동안 보고 싶었어요 😭 지금 돌아와도 늦지 않아요!`
- 60/90/120일은 명세상 **문구 미정** → 마일스톤 구조만 두고 확정 문구는 추후 반영(placeholder). 현재 60/90 문구도 명세에 없는 v1 문구이므로 placeholder 처리. (아래 "미정" 참고)

---

## 7. [3.9] 팔로우 알림 액션 버튼 — `UNFOLLOW` 제거 확정
- 명세: 내가 팔로우하지 않은 유저가 팔로우 → **맞팔로우**(`FOLLOW_BACK`) / 이미 팔로우한 유저가 팔로우 → **버튼 없음(`NONE`)**.
- **결정**: 알림 탭에서는 "맞팔로우 취소(UNFOLLOW)"를 더 이상 노출하지 않는다. 따라서:
  - `NotificationFacade.toResponse`에서 이미 팔로우한 경우 분기를 `NONE`으로 변경(현재 `UNFOLLOW` 반환).
  - `NotificationActionType.UNFOLLOW`를 **제거**한다(알림 탭 외 사용처 없음 확인 필요).
  - `NotificationResponse`의 `actionType` Schema 설명에서 `UNFOLLOW` 표기 제거.
- 맞팔로우 후 토글 UI 전환은 명세상 클라이언트 영역이며, 알림 탭에 별도 actionType을 내려주지 않는다.

---

## 8. [정리] 미사용 `VERSION` 타입 제거
- v2에서 기존 "3.13 버전 관리"가 명세에서 완전히 삭제됨. 트리거 없이 `NotificationType.VERSION`(+ 마이그레이션 CHECK 제약의 `'VERSION'`)에만 남아있음 → 제거한다.
- 실제 생성된 적이 없어 데이터 영향 없음. CHECK 제약은 새 Flyway 버전에서 `VERSION` 제외하고 재정의(V24 제약 갱신 방식과 동일 패턴, 적용된 V24는 수정 금지).

---

## 9. [푸시 플랫폼] 안드로이드 전용 푸시 발송 — `platform` 컬럼 추가
명세: "웹은 인앱만 지원(웹 푸시 미지원)", "앱 푸시(AOS 추가 발송)". 따라서 푸시는 **안드로이드 토큰에만** 발송해야 한다.

### 현재 상태
- `FcmToken`은 `userId · deviceId · token`만 보유하고 **플랫폼을 식별할 필드가 없다.**
- 토큰 문자열만으로 web/android를 신뢰성 있게 구분할 수 없다(추론 비권장).
- 푸시 발송 경로(`FcmTokenQueryService.getAllTokens`, `getTokensByUserIds`)는 플랫폼 무관하게 전체 토큰을 반환한다.

### 구현 방식 (확정: `platform` 컬럼 명시)
1. `FcmToken`에 `platform` 필드 추가 — **enum `Platform { ANDROID, WEB }`**, `@Enumerated(STRING)`, **nullable**.
2. 등록 API 변경: `RegisterFcmTokenRequest`에 `platform` 추가(필수, `@NotNull`). 클라이언트가 등록 시 플랫폼을 명시. `FcmTokenCommandService`/`FcmToken.create`에 platform 전달. (신규/갱신 토큰은 항상 platform을 가진다)
3. Flyway: `fcm_token.platform VARCHAR(255) NULL + CHECK(platform IN ('ANDROID','WEB'))` 컬럼 추가(V26 등).
   - **기존 row 백필하지 않는다(NULL 유지).** 재로그인 시 FCM 토큰이 재발급되며 platform이 채워지므로, 기존 NULL 토큰은 자연 소멸한다.
   - CHECK 제약은 NULL을 허용하도록 작성(`platform IS NULL OR platform IN (...)` 형태, 또는 표준 `IN` 제약은 NULL을 통과시키므로 그대로 사용 가능).
4. 푸시 조회 메서드를 **ANDROID 한정**으로 변경:
   - `findAllTokens()` → `WHERE platform = 'ANDROID'` (또는 `findAndroidTokens()` 신설).
   - `findByUserIdIn(...)` → `platform = 'ANDROID'` 조건 추가.
   - `platform = 'ANDROID'` 비교는 **NULL을 자동 제외**하므로, 백필 안 된 기존 토큰은 재로그인 전까지 푸시 대상에서 빠진다(의도된 동작).
   - 이 메서드들은 현재 푸시 발송에만 쓰이므로 in-place 필터링이 안전(조회/존재확인 경로 `checkFcmTokenExist`는 영향 없음).
5. iOS 추가 시점에는 `Platform`에 `IOS` 추가 + CHECK 제약 갱신 마이그레이션 필요(현재 범위 밖).

---

## 미정 / 추후 확인
- **3.3 60·90·120일 확정 문구**: 문구는 추후 추가. 본 작업에서는 **마일스톤 구조(60/90/120 슬롯)만 잡고**, 60·90·120은 문구 미정으로 두되 나중에 문구만 채우면 동작하도록 구성한다(코드/스케줄 변경 없이 메시지만 추가 가능한 구조).
- **3.13 새 레슨 딥링크**: 프론트 협의 후 확정(미확정).
- **알림함 빈 상태(Empty State)**: 텍스트 노출 정책으로 프론트 전용. 백엔드 영향 없음.

### 결정 완료
- **§9 안드로이드 전용 푸시**: `platform` 컬럼 추가 방식(Option A). enum `{ANDROID, WEB}`, nullable. 기존 row는 백필하지 않고 NULL 유지(재로그인 시 재발급되어 채워짐). 푸시는 `platform = 'ANDROID'`로 필터(NULL 제외).
- **`UNFOLLOW` 제거**: 알림 탭에서 맞팔로우 취소 미노출 → `NotificationActionType.UNFOLLOW` 제거 확정(§7).
- **`INQUIRY_ANSWERED`**: 현행(인앱+푸시) 유지, 본 작업 범위 밖(추후 삭제 가능).

---

## 참고
- 명세 원본: `notification-req.md` (v2, 2026-06-30)
- 관련 패키지: `notification` (+ `global/util`, `social/facade`, `season`, `fcm`)
- 관련 클래스:
  - 채널/발송: `NotificationFacade`, `NotificationService`, `NotificationScheduler`, `NotificationEventListener`, `SocialFacade`(3.10·3.11 트리거)
  - 카피/마일스톤: `NotificationMessageProvider`, `SeasonEndingMilestone`, `InactivityMilestone`
  - 조회/응답: `NotificationQueryService`, `NotificationRepository`, `NotificationController`/`NotificationDocs`, `NotificationResponse`
  - 도메인/표기: `Notification`, `NotificationType`, `NotificationActionType`, `TimeAgoFormatter`(알림 전용 분리)
  - 푸시 플랫폼: `FcmToken`, `FcmTokenRepository`, `FcmTokenQueryService`, `RegisterFcmTokenRequest`, `FcmTokenCommandService`
- DB 변경 (다음 Flyway 버전 V25~, 현재 최신 V24):
  - `notification.sub_text` 컬럼 추가
  - `notification` type CHECK 제약에서 `VERSION` 제거
  - `fcm_token.platform` 컬럼 추가(nullable + CHECK, 백필 없음) — §9
