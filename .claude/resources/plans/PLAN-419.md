# [PLAN-419] 코드 컨벤션 위반 사례 전수 교정

> 이슈: #419
> 브랜치: refactor/419-code-convention-cleanup

## 목표

`.claude/rules/code-convention/`에 문서화된 규칙(common/domain/dto/facade/service/repository)과 실제 코드 사이의 괴리를 해소한다. 엔티티 생성자, KST 시간대 상수, 성공 응답 표기, DTO record, Builder 접근 제어, 예외 처리, Service 어노테이션 등 10개 카테고리·약 70개 파일을 컨벤션에 맞게 교정한다. 테스트 코드(`src/test`)는 범위에서 제외한다.

이 작업은 신규 기능이 아니라 기존 코드를 문서화된 규칙에 맞추는 전수 교정이므로, 아래 "구현 계획"은 레이어 순서 대신 이슈의 작업 카테고리 순으로 구성한다.

## 영향 범위

### 신규 파일
없음 — 전부 기존 파일 수정

### 수정 파일 (카테고리별 개수)
- 엔티티 생성자 표준화: 1개 (`Bookmark`)
- KST 시간대 상수 통일: 14개
- 포맷 잡티 정리: bookmark 도메인 3개 (`Bookmark`, `BookmarkController`, `BookmarkService`)
- 성공 응답 표기 통일: 34개 컨트롤러 / 93개 호출부 (ok·noContent·badRequest·notFound·accepted·internalServerError 6종)
- DTO record 전환: 11개 (Swagger 전용 stub 5개 + OAuth UserInfo 6개)
- Builder 접근 제어(`AccessLevel.PRIVATE`) 추가: 16개 직접 + ErrorResponse(팩토리 추가 후 private, 프로덕션 5곳 교체) + Report(팩토리 추가 후 private, **테스트 4곳 교체**)
- 예외 처리 교정: 1개 (`Season`, HTTP 500→409 동작 변경 수반) + `CustomErrorCode` 1건 추가
- Service 어노테이션 교정: 1개 (`AuthTokenProvider`)
- 기타 객체 생성 규칙 정리: 1개 (`UserLevel`, 호출부 1곳 `User.java:85`)
- ControllerDocs 위치 검증: 변경 없음 (admin/user/auth 이미 `controller/docs/`로 분리됨 — 회귀 확인만)
- 테스트 수정(예외적 허용): `report/fixture/ReportFixture.java`, `admin/service/AdminReportServiceIntegrationTest.java`, `admin/service/AdminDashboardServiceIntegrationTest.java` — Report 빌더 private화에 따른 정적 팩토리 호출로 교체

## 구현 계획

### 1. 엔티티 생성자 표준화 — `Bookmark`

`src/main/java/gravit/code/bookmark/domain/Bookmark.java`
- import `lombok.RequiredArgsConstructor` → `lombok.NoArgsConstructor`
- 클래스 선언부 `@RequiredArgsConstructor(access = AccessLevel.PROTECTED)` → `@NoArgsConstructor(access = AccessLevel.PROTECTED)`
  - final 필드가 없어 현재도 실질적으로 no-arg 생성자를 생성하므로 동작 변화 없음. 표기만 표준화.

### 2. KST 시간대 상수 통일 (14개 파일)

모든 파일에 `import gravit.code.global.consts.TimeZoneConst;` 추가. 로컬 `ZoneId` 상수 선언을 삭제하고 사용처를 `TimeZoneConst.KST`로 교체한다. 파일 내에 `ZoneId` 타입을 상수 외 용도로 더 쓰는 곳이 없으면 `import java.time.ZoneId;`도 제거한다.

| 파일 | 현재 | 변경 |
|---|---|---|
| `unit/service/UnitQueryService.java:24,59` | `private static final ZoneId KST = ZoneId.of("Asia/Seoul");` 선언 후 `LocalDate.now(KST)` | 선언 삭제, `LocalDate.now(TimeZoneConst.KST)` |
| `auth/token/JwtProvider.java:41,52,71` | `SEOUL_ZONE` 상수 선언 후 2곳에서 사용 | 선언 삭제, `ZonedDateTime.now(TimeZoneConst.KST)` 2곳 |
| `admin/domain/staging/StagingLabel.java:75` | `.createdAt(LocalDateTime.now(ZoneId.of("Asia/Seoul")))` | `.createdAt(LocalDateTime.now(TimeZoneConst.KST))` (로컬 상수 없이 인라인이므로 바로 교체) |
| `admin/domain/audit/AuditLog.java:27,65` | `SEOUL` 상수 선언 후 사용 | 선언 삭제, `LocalDateTime.now(TimeZoneConst.KST).truncatedTo(MICROS)` |
| `notice/domain/Notice.java:39,151,157` | `SEOUL` 상수 선언 후 2곳에서 사용 | 선언 삭제, 2곳 `TimeZoneConst.KST`로 교체 |
| `social/service/SocialFeedService.java:32,73` | `SEOUL` 상수 선언 후 사용 | 선언 삭제, `LocalDate.now(TimeZoneConst.KST)` |
| `social/service/CongratulationService.java:23,36` | `SEOUL` 상수 선언 후 사용 | 선언 삭제, `LocalDate.now(TimeZoneConst.KST)` |
| `social/domain/UserFeed.java:65` | `LocalDateTime.now(ZoneId.of("Asia/Seoul"))` | `LocalDateTime.now(TimeZoneConst.KST)` (인라인 직접 교체) |
| `report/domain/Report.java:59` | `LocalDateTime.now(ZoneId.of("Asia/Seoul"))` | `LocalDateTime.now(TimeZoneConst.KST)` (인라인 직접 교체) |
| `global/util/TimeAgoFormatter.java:10,17` | `KST` 상수 선언 후 사용 | 선언 삭제, `LocalDateTime.now(TimeZoneConst.KST)` |
| `global/config/TimeConfig.java:14` | `return Clock.system(ZoneId.of("Asia/Seoul"));` | `return Clock.system(TimeZoneConst.KST);` |
| `global/entity/BaseEntity.java:27,31,38` | `SEOUL` 상수 선언 후 2곳에서 사용 | 선언 삭제, 2곳 `TimeZoneConst.KST`로 교체 |
| `bookmark/domain/Bookmark.java:38` | `LocalDateTime.now(ZoneId.of("Asia/Seoul"))` | `LocalDateTime.now(TimeZoneConst.KST)` (1번 항목과 함께 처리) |
| `global/consts/TimeZoneConst.java` | 변경 없음 (기준 상수 정의 파일) | — |

### 3. 포맷 잡티 정리 — bookmark 도메인 3개 파일

`bookmark/domain/Bookmark.java:28`
- `@Column(name = "user_id",  nullable = false)` → `@Column(name = "user_id", nullable = false)` (이중 공백 제거)

`bookmark/controller/BookmarkController.java`
- L34 `){` → `) {`
- L42 `){` → `) {`
- L50 `@Valid@RequestBody` → `@Valid @RequestBody`
- L44, L53은 4번 항목(ResponseEntity 표준화)에서 함께 처리

`bookmark/service/BookmarkService.java`
- L26 `){` → `) {`
- L61 `){` → `) {`

### 4. 성공 응답 표기 통일 (34개 컨트롤러)

총 34개 파일·93개 호출부. 상태코드는 전부 보존되므로(200/204/400/404/202/500 그대로) **API 스펙(응답 상태·바디) 변화 없음** — 표기만 표준화.

변환 규칙 (`.claude/rules/code-convention/controller.md`):
- `ResponseEntity.ok(X)` → `ResponseEntity.status(HttpStatus.OK).body(X)`
- `ResponseEntity.ok().build()` → `ResponseEntity.status(HttpStatus.OK).build()`
- `ResponseEntity.ok().headers(h).body(x)` → `ResponseEntity.status(HttpStatus.OK).headers(h).body(x)`
- `ResponseEntity.noContent().build()` → `ResponseEntity.status(HttpStatus.NO_CONTENT).build()`
- `ResponseEntity.badRequest().build()` → `ResponseEntity.status(HttpStatus.BAD_REQUEST).build()`
- `ResponseEntity.notFound().build()` → `ResponseEntity.status(HttpStatus.NOT_FOUND).build()` — `UserDataCleanController:36`, `CSNoteController:72`
- `ResponseEntity.accepted().build()` → `ResponseEntity.status(HttpStatus.ACCEPTED).build()` — `UserDeletionController:28`
- `ResponseEntity.internalServerError().build()` → `ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()` — `CSNoteController:86`
- 각 파일에 `import org.springframework.http.HttpStatus;` 없으면 추가

대상 파일 (도메인별, `grep -rnE 'ResponseEntity\.(ok|noContent|badRequest|notFound|accepted|internalServerError)' src/main/java`로 정확한 라인 재확인 후 적용):
- `friend/controller/FriendController.java`
- `bookmark/controller/BookmarkController.java` (3번 항목과 함께 처리)
- `wrongAnsweredNote/controller/WrongAnsweredNoteController.java`
- `inquiry/controller/InquiryController.java`
- `test/notification/controller/TestNotificationController.java`
- `test/user/UserDataCleanController.java`
- `test/qa/TestScenarioController.java`
- `test/user/UserCheatCreateController.java`
- `test/season/SeasonCleanController.java`
- `auth/controller/OAuthController.java` (`ok`, `badRequest` 둘 다 포함)
- `notification/controller/NotificationController.java`
- `problem/controller/ProblemController.java`
- `admin/controller/AdminProblemController.java`
- `admin/controller/AdminChapterController.java`
- `admin/controller/AdminStagingController.java`
- `admin/controller/AdminDashboardController.java`
- `admin/controller/AdminLessonController.java`
- `admin/controller/AdminMeController.java`
- `admin/controller/AdminNoticeController.java`
- `admin/controller/AdminInquiryController.java`
- `admin/controller/AdminUserController.java`
- `admin/controller/AdminReportController.java`
- `admin/controller/AdminUnitController.java`
- `user/controller/MyPageController.java`
- `user/controller/UserDeletionController.java`
- `user/controller/MainPageController.java`
- `user/controller/UserController.java`
- `userLeague/controller/UserLeagueController.java`
- `league/controller/LeagueController.java`
- `csnote/controller/CSNoteController.java`
- `social/controller/SocialController.java`
- `fcm/controller/FcmTokenController.java`
- `report/controller/ReportController.java`
- `userLeagueHistory/controller/LeagueHistoryController.java`

### 5. ControllerDocs 위치 검증 (교정 없음)

컨트롤러가 2개 이상인 도메인은 `admin`(11개), `user`(4개), `auth`(3개)뿐이며 셋 다 이미 `controller/docs/`로 분리되어 있음을 확인함. 이번 작업으로 새로 컨트롤러가 추가되지 않으므로 회귀 없음 — 코드 변경 불필요.

### 6. DTO record 전환

**6-1. Swagger 문서 전용 stub 클래스 5개** — 실제로 인스턴스화되지 않고 `@Schema(implementation = X.class)`로만 참조되는 것을 호출부 조사로 확인함 (`SliceResponse<T>`/`PageResponse<T>` 제네릭의 Swagger 표현용). class + public 필드 → record + `@Schema`로 전환. `@Builder`/정적 팩토리는 불필요(인스턴스화되지 않음).

- `friend/dto/response/FollowerSliceResponse.java` — `record FollowerSliceResponse(boolean hasNextPage, List<FollowerResponse> contents)`
- `friend/dto/response/SearchUserSliceResponse.java` — `record SearchUserSliceResponse(boolean hasNextPage, List<SearchUserDto> contents)`
- `social/dto/response/SocialFeedSliceResponse.java` — `record SocialFeedSliceResponse(boolean hasNextPage, List<SocialFeedResponse> contents)`
- `inquiry/dto/response/InquirySummaryPageResponse.java` — `record InquirySummaryPageResponse(int page, int totalPages, boolean hasNext, long totalElements, List<InquirySummaryResponse> contents)`
- `notice/dto/response/NoticeSummaryPageResponse.java` — `record NoticeSummaryPageResponse(int page, int totalPages, boolean hasNext, long totalElements, List<NoticeSummaryResponse> contents)`

각 record는 클래스 레벨 `@Schema(description = "...")`는 유지하고, 컴포넌트별 `@Schema(...)`는 기존 속성 그대로 유지, dto.md 규칙대로 컴포넌트 사이 빈 줄 삽입.

**6-2. OAuth UserInfo 구현체 6개** — `new XxxUserInfo(...)` 호출부(`strategy/`, `strategy/android/`, `OAuthAndroidController`)를 확인해 record 전환 시 생성자 시그니처가 유지되면 호출부 변경이 불필요함을 검증함. `OAuthUserInfo` 인터페이스 메서드는 record 본문에서 그대로 override 가능.

- `auth/dto/oauth/KakaoUserInfo.java` → `public record KakaoUserInfo(Map<String, Object> attributes) implements OAuthUserInfo { ... }` (lombok `@RequiredArgsConstructor` 제거, 기존 override 메서드 4개 그대로 유지)
- `auth/dto/oauth/GoogleUserInfo.java` → 동일 패턴, `record GoogleUserInfo(Map<String, Object> attributes)`
- `auth/dto/oauth/NaverUserInfo.java` → `record NaverUserInfo(Map<String, Object> attributes)` + compact 생성자로 기존 변환 로직 유지:
  ```java
  public NaverUserInfo {
      attributes = (Map<String, Object>) attributes.get("response");
  }
  ```
- `auth/dto/oauth/android/KakaoAndroidUserInfo.java` → `record KakaoAndroidUserInfo(Map<String, Object> claims) implements OAuthUserInfo`, `PROVIDER`/`CLAIM_*` static final 상수와 override 메서드 4개는 그대로 유지, lombok 제거
- `auth/dto/oauth/android/GoogleAndroidUserInfo.java` → 동일 패턴, `record GoogleAndroidUserInfo(Map<String, Object> claims)`
- `auth/dto/oauth/android/NaverAndroidUserInfo.java` → `record NaverAndroidUserInfo(String providerId, String email, String nickname) implements OAuthUserInfo`, override 메서드에서 `this.providerId` 등을 컴포넌트 접근자(`providerId()` 대신 파라미터명 그대로 참조 가능하므로) 그대로 반환하도록 조정

> ⚠️ 검증 결과: 18개 중 2개(`ErrorResponse`, `Report`)는 외부에서 `.builder()`(제네릭 witness `.<T>builder()` 포함)를 호출하므로 단순 private화 시 컴파일이 깨진다. 아래처럼 나눠 처리한다.

**7-A. 외부 빌더 호출 없는 16개 — 어노테이션만 교체**

`@Builder` → `@Builder(access = AccessLevel.PRIVATE)`. 아래 domain 9개는 이미 `import lombok.AccessLevel;`이 있어 어노테이션 한 줄만, dto 7개는 `import lombok.AccessLevel;` 추가가 함께 필요하다.

- domain (import 이미 있음): `friend/domain/Friend.java`, `inquiry/domain/Inquiry.java`, `inquiry/domain/InquiryAnswer.java`, `user/domain/User.java`, `userLeague/domain/UserLeague.java`, `league/domain/League.java`, `notice/domain/Notice.java`, `season/domain/Season.java`, `userLeagueHistory/domain/UserLeagueHistory.java`
- dto (import 추가 필요): `friend/dto/response/FriendResponse.java`, `inquiry/dto/response/InquiryDetailResponse.java`, `user/dto/response/UserResponse.java`, `user/dto/response/UserLevelResponse.java`, `league/dto/response/LeagueResponse.java`, `notice/dto/response/NoticeDetailResponse.java`, `global/dto/response/SliceResponse.java`

**7-B. `ErrorResponse` — 정적 팩토리 추가 후 private화 (프로덕션 5곳 교체)**

`global/exception/domain/ErrorResponse.java`는 `record ErrorResponse<T>(String error, T message)`이며, 5개 프로덕션 지점이 `ErrorResponse.<String>builder()`/`ErrorResponse.<List<String>>builder()`를 호출한다.
- ErrorResponse에 정적 팩토리 추가: `public static <T> ErrorResponse<T> of(String error, T message) { ... }` (컨벤션: Response DTO는 정적 팩토리로 생성), `@Builder` → `@Builder(access = AccessLevel.PRIVATE)` + `import lombok.AccessLevel;` 추가
- 호출부 5곳을 `ErrorResponse.of(error, message)`로 교체:
  - `global/exception/handler/GlobalExceptionHandler.java:78, 97, 104`
  - `security/exception/CustomAuthenticationEntryPoint.java:45`
  - `security/exception/CustomAccessDeniedHandler.java:41`
- 각 호출부의 `.error(x).message(y).build()` 체인을 `of(x, y)` 인자로 옮긴다. 제네릭은 `ErrorResponse.<String>of(...)` 또는 대상 타입 추론으로 처리.

**7-C. `Report` — 정적 팩토리 추가 후 private화 (테스트 4곳 교체, 승인된 예외)**

`report/domain/Report.java`의 빌더는 테스트 4곳(`ReportFixture:13,29`, `AdminReportServiceIntegrationTest:33`, `AdminDashboardServiceIntegrationTest:44`)에서 `Report.builder()`로 호출된다. 기존 `Report.create(ProblemReportSubmitRequest, long)` 팩토리는 임의 `reportType`/`content`를 못 받으므로 테스트가 빌더에 의존 중이다.
- Report에 테스트/내부 공용 정적 팩토리 추가: `public static Report of(ReportType reportType, String content, long problemId, long userId) { return Report.builder()...build(); }`, `@Builder` → `@Builder(access = AccessLevel.PRIVATE)` (import 이미 있음)
- 테스트 4곳을 `Report.of(reportType, content, problemId, userId)` 호출로 교체 (`ReflectionTestUtils.setField(report, "id", ...)`는 그대로 유지)
- 사용자 결정에 따라 "테스트 제외" 제약의 예외로, 이 3개 테스트 파일만 수정한다.

### 8. 예외 처리 교정 — `Season`

`global/exception/domain/CustomErrorCode.java`
- `// Season` 그룹(L110~113) 마지막에 새 에러코드 추가:
  ```java
  INVALID_SEASON_STATUS_TRANSITION(HttpStatus.CONFLICT, "SEASON_4093", "시즌 상태 전이가 유효하지 않습니다."),
  ```
  (기존 `BATCH_PREP_SEASON_CONFLICT`/`BATCH_ACTIVE_SEASON_CONFLICT`가 같은 그룹에서 `CONFLICT` + `SEASON_409X`를 쓰고 있어 동일 패턴을 따름)

`season/domain/Season.java`
- import 추가: `gravit.code.global.exception.domain.CustomErrorCode`, `gravit.code.global.exception.domain.RestApiException`
- L108 `throw new RuntimeException();` → `throw new RestApiException(CustomErrorCode.INVALID_SEASON_STATUS_TRANSITION);`
- 같은 파일 48행의 `@Builder`는 7-A 항목에서 함께 `access = AccessLevel.PRIVATE` 추가 처리
- ⚠️ **API 동작 변경**: 기존 `RuntimeException`은 `GlobalExceptionHandler.handleException`을 타 HTTP **500**을 반환한다. 변경 후 `RestApiException(CONFLICT)`는 HTTP **409** + 구조화된 `ErrorResponse` 바디를 반환한다. 시즌 상태 전이 실패(finalizing/activate/close 오호출)는 배치·관리자 내부 경로라 정상 운영 중 노출되지 않지만, 에러 응답 계약이 바뀌는 점을 명시한다.

### 9. Service 어노테이션 교정 — `AuthTokenProvider`

`auth/service/AuthTokenProvider.java`
- import `org.springframework.stereotype.Component` → `org.springframework.stereotype.Service`
- 클래스 선언부 `@Component` → `@Service`
- `service/` 패키지에 위치하고 단일 도메인(인증 토큰) 로직만 담당하므로 이동 없이 어노테이션만 표준 스테레오타입으로 교정. Spring 빈 등록 방식(컴포넌트 스캔)은 `@Service`도 `@Component`의 특수화이므로 동작 변화 없음.

### 10. 기타 객체 생성 규칙 — `UserLevel`

`user/domain/UserLevel.java`
- `@NoArgsConstructor` → `@NoArgsConstructor(access = AccessLevel.PROTECTED)` (import `lombok.AccessLevel` 추가)
- public 생성자(L20~26)를 `private` + `@Builder(access = AccessLevel.PRIVATE)`로 감추고, 정적 팩토리 `create(int level, int xp)` 추가
- 호출부 확인: `grep -rn "new UserLevel(" src/main/java`로 생성 지점을 찾아 `UserLevel.create(...)` 호출로 교체 (구현 단계에서 실제 호출부 개수 확정 후 반영)

## 결정 필요 (Decisions needed)

- [x] **Report `@Builder` private화 vs 테스트 제외 제약 충돌** → 결정: **빌더 private화 + 테스트 수정**. Report에 `of(...)` 정적 팩토리를 추가하고 테스트 3개 파일(4개 호출부)을 팩토리 호출로 교체한다. "테스트 제외" 제약의 승인된 예외로 처리 (항목 7-C).

## 검증

- **컴파일 검증 우선**: `./gradlew compileJava compileTestJava` — 이번 변경의 핵심 리스크(빌더 private화로 인한 main/test 컴파일 파괴, record 전환 호출부)를 DB·Docker 없이 빠르게 확인한다.
- **전체 회귀**: `./gradlew build`. 단 `build`는 Testcontainers 기반 통합 테스트를 실행하므로 **Docker 데몬이 필요**하다. `flywayValidate`(build 의존)는 H2 in-memory(`jdbc:h2:mem`) 기반이라 별도 DB는 불필요.
- **집중 확인 지점**:
  - 빌더 private화 후 `ErrorResponse.of(...)`(프로덕션 5곳)·`Report.of(...)`(테스트 4곳) 교체가 모두 반영되어 컴파일되는지
  - OAuth UserInfo record 전환 후 로그인 플로우(web 3종 + android 3종), 특히 `NaverUserInfo` compact 생성자의 `response` 키 추출 로직 보존
  - Season 상태 전이 실패 시 500→409로 바뀐 응답(신규 에러코드 `INVALID_SEASON_STATUS_TRANSITION`)
  - ResponseEntity 6종 표기 교체 후 상태코드가 기존과 동일(200/204/400/404/202/500)한지 — 단순 표기 변경이므로 응답 바디·상태코드 불변
  - Swagger stub 5종 record 전환 후 `/swagger-ui` OpenAPI 스키마가 동일 필드로 생성되는지(런타임 응답은 `SliceResponse`/`PageResponse`라 불변)

## Deviation Log
