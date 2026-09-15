# [PLAN-546] 주간 학습 기록 요일별 상태 세분화

> 이슈: #546
> 브랜치: feat/546-weekly-learning-status

## 목표
`GET /api/v1/main-pages/weekly-record`의 요일 필드(`MONDAY`~`SUNDAY`) 값을 학습 여부 boolean에서 `{dayTiming, isCompleted}` 객체로 바꾼다. `dayTiming`은 서버 기준(KST) 오늘과 비교한 요일 시점(`PAST`, `TODAY`, `FUTURE`)이고, `isCompleted`는 그날 학습 완료 여부다. 클라이언트는 기기 시간 계산 없이 두 값을 조합해 요일 칸을 그린다.

응답 예 (2025-08-05 화요일, 월요일에 학습)

```json
{
  "consecutiveSolvedDays": 3,
  "MONDAY": { "dayTiming": "PAST", "isCompleted": true },
  "TUESDAY": { "dayTiming": "TODAY", "isCompleted": false },
  "WEDNESDAY": { "dayTiming": "FUTURE", "isCompleted": false },
  "THURSDAY": { "dayTiming": "FUTURE", "isCompleted": false },
  "FRIDAY": { "dayTiming": "FUTURE", "isCompleted": false },
  "SATURDAY": { "dayTiming": "FUTURE", "isCompleted": false },
  "SUNDAY": { "dayTiming": "FUTURE", "isCompleted": false }
}
```

## 배치 기준
- **시점과 완료 여부를 분리한다.** 상태 값 하나로 합치면 "오늘이면서 완료"를 표현하려고 우선순위 규칙이 필요하다. 둘로 나누면 서버는 사실만 내려주고, 뱃지 표현(오늘 완료를 체크로 볼지 오늘 강조로 볼지)은 클라이언트가 정한다
- **요일 키 `MONDAY`~`SUNDAY`와 `consecutiveSolvedDays`는 그대로 둔다.** 바뀌는 것은 요일 필드의 값 타입뿐이다
- **판정은 `DailyLearningRecordService`가 한다.** 주간 날짜 범위와 학습 기록 조회가 이미 이 서비스에 있고, 판정에 다른 도메인이 필요 없다. Facade는 결과를 응답에 옮기기만 한다
- **오늘 날짜는 주입받은 `Clock`으로 한 번만 구한다.** 지금은 `LocalDate.now(TimeZoneConst.KST)`라 테스트에서 오늘을 고정할 수 없다. 실제 날짜로는 월요일에 `PAST`, 일요일에 `FUTURE`가 없어 세 시점을 항상 검증할 수 없다. 테스트 고정 시계(`FixedClockConfig`, 2025-08-05 화요일)를 쓰면 월 `PAST`, 화 `TODAY`, 수~일 `FUTURE`가 된다. 주간 범위와 시점을 같은 `today`로 계산하므로 자정 경계에서도 둘이 어긋나지 않는다
- 운영 `Clock` 빈은 `Clock.system(TimeZoneConst.KST)`(`TimeConfig`)라 서버 기준 KST 판정은 그대로다
- **시점 판정은 enum `DayTiming`의 정적 메서드에 둔다.** 날짜와 오늘만으로 결정되는 규칙이다. enum은 `dailyLearningRecord/domain/`에 둔다. 응답에 쓰이는 기존 enum(`UnitProgressStatus`, `InterviewSessionStatus`)도 `{domain}/domain/`에 있다
- **enum 값은 대문자로 내보낸다.** 클라이언트로 나가는 기존 enum이 모두 대문자이고, 같은 메인페이지 `/learning`의 유닛 상태도 `"COMPLETED"`로 나간다. `@JsonValue`는 두지 않는다
- **요일 객체는 별도 파일 `DayLearningRecordResponse`로 둔다.** `dto.md`가 record 안 record 선언을 금지한다
- **`isCompleted` 키는 `@JsonProperty("isCompleted")`로 고정한다.** `LoginResponse.isOnboarded`, `ProblemDetailResponse.isBookmarked`와 같은 방식이다. PLAN-536도 record의 `is` 접두 boolean 키를 이 방식으로 고정했다
- **`FUTURE` 요일의 `isCompleted`를 따로 false로 강제하지 않는다.** 일일 학습 기록은 항상 그날 날짜로만 생기므로(`handleDailyLearningRecord`) 미래 날짜 기록이 없어 조회 결과만으로 false다
- **`getWeeklySolvedDays`는 새 메서드로 대체하고 삭제한다.** 호출부가 `DailyLearningRecordFacade:24`, `UserFacade:74` 둘뿐이고 둘 다 옮긴다
- 폐기 예정인 `GET /api/v1/users/main-page`(`UserFacade.getMainPage`)도 같은 `WeeklyLearningRecordResponse`를 쓰므로 응답이 함께 바뀐다

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/dailyLearningRecord/domain/DayTiming.java` - 오늘 기준 요일 시점 enum과 판정 규칙
- `src/main/java/gravit/code/dailyLearningRecord/dto/response/DayLearningRecordResponse.java` - 요일 하나의 시점과 완료 여부
- `src/test/java/gravit/code/user/controller/MainPageControllerIntegrationTest.java` - `/weekly-record` JSON 키와 enum 표기 고정

### 수정 파일
- `src/main/java/gravit/code/dailyLearningRecord/service/DailyLearningRecordService.java` - `Clock` 주입, `getWeeklySolvedDays`를 `getWeeklyDayRecords`로 대체
- `src/main/java/gravit/code/dailyLearningRecord/dto/response/WeeklyLearningRecordResponse.java` - 요일 필드 타입 `boolean` → `DayLearningRecordResponse`, `of` 파라미터 `Set<DayOfWeek>` → `Map<DayOfWeek, DayLearningRecordResponse>`
- `src/main/java/gravit/code/dailyLearningRecord/facade/DailyLearningRecordFacade.java` - 새 서비스 메서드 호출로 교체
- `src/main/java/gravit/code/user/facade/UserFacade.java` - deprecated `getMainPage`의 주간 기록 조립을 새 서비스 메서드로 교체
- `src/main/java/gravit/code/user/controller/docs/MainPageControllerDocs.java` - `getWeeklyRecord` description에 `dayTiming`, `isCompleted` 의미와 판정 기준 명시
- `.claude/spec/service-policy/learning.md` - 주간 학습 기록 요일 시점과 완료 여부 정책 추가 (정책 추가)
- `src/test/java/gravit/code/dailyLearningRecord/service/DailyLearningRecordServiceIntegrationTest.java` - `GetWeeklySolvedDays` 5개 테스트를 새 메서드 시나리오로 교체
- `src/test/java/gravit/code/dailyLearningRecord/facade/DailyLearningRecordFacadeIntegrationTest.java` - boolean 단언을 시점, 완료 여부 단언으로, 날짜 기준을 `Clock`으로 변경
- `src/test/java/gravit/code/user/facade/UserFacadeIntegrationTest.java` - `GetMainPage`의 요일 단언 2곳과 날짜 기준 1곳 변경

## 구현 계획

### 1. Entity / Flyway
변경 없음.

### 2. Repository
변경 없음. 기존 `DailyLearningRecordRepository.findSolvedDatesByUserIdAndDateRange(long userId, LocalDate startDate, LocalDate endDate)`를 그대로 쓴다.

### 3. Domain - `DayTiming` (신규)

`dailyLearningRecord/domain/DayTiming.java`

```java
package gravit.code.dailyLearningRecord.domain;

import java.time.LocalDate;

public enum DayTiming {
    PAST,
    TODAY,
    FUTURE;

    public static DayTiming of(
            LocalDate date,
            LocalDate today
    ) {
        if (date.isBefore(today)) {
            return PAST;
        }

        return date.isEqual(today) ? TODAY : FUTURE;
    }
}
```

### 4. Service - `DailyLearningRecordService`

필드 (Repository 다음 줄을 띄우고 프레임워크 객체)

```java
private final DailyLearningRecordRepository dailyLearningRecordRepository;

private final Clock clock;
```

`getWeeklySolvedDays(long userId)`(28행)를 삭제하고 같은 자리에 추가

```java
@Transactional(readOnly = true)
public Map<DayOfWeek, DayLearningRecordResponse> getWeeklyDayRecords(long userId) {
    LocalDate today = LocalDate.now(clock);
    LocalDate monday = today.with(DayOfWeek.MONDAY);
    LocalDate sunday = today.with(DayOfWeek.SUNDAY);

    Set<LocalDate> solvedDates = Set.copyOf(
            dailyLearningRecordRepository.findSolvedDatesByUserIdAndDateRange(userId, monday, sunday)
    );

    return monday.datesUntil(sunday.plusDays(1))
            .collect(Collectors.toUnmodifiableMap(
                    LocalDate::getDayOfWeek,
                    date -> DayLearningRecordResponse.of(DayTiming.of(date, today), solvedDates.contains(date))
            ));
}
```

- 반환 Map은 항상 월~일 7개 키를 담는다
- import 추가: `java.time.Clock`, `gravit.code.dailyLearningRecord.domain.DayTiming`, `gravit.code.dailyLearningRecord.dto.response.DayLearningRecordResponse`. `Set`, `Map`, `Collectors`, `TimeZoneConst`는 다른 메서드가 계속 쓰므로 유지
- 나머지 메서드(`getDailySolvedCounts`, `getWeeklyLearningReport`, `handleDailyLearningRecord`)의 `LocalDate.now(TimeZoneConst.KST)`는 바꾸지 않는다 (범위 밖 참고)

### 5. Facade

신규 불필요 - 기존 `DailyLearningRecordFacade`(learning + dailyLearningRecord 조합)를 그대로 쓴다.

`DailyLearningRecordFacade.getWeeklyLearningRecord`

```java
@Transactional(readOnly = true)
public WeeklyLearningRecordResponse getWeeklyLearningRecord(long userId) {
    int consecutiveSolvedDays = learningQueryService.getLearning(userId).getConsecutiveSolvedDays();

    Map<DayOfWeek, DayLearningRecordResponse> dayOfWeekToRecord = dailyLearningRecordService.getWeeklyDayRecords(userId);

    return WeeklyLearningRecordResponse.of(consecutiveSolvedDays, dayOfWeekToRecord);
}
```

- import: `java.util.Set` 제거, `java.util.Map`, `gravit.code.dailyLearningRecord.dto.response.DayLearningRecordResponse` 추가
- 트랜잭션 어노테이션은 건드리지 않는다

`UserFacade.getMainPage` (deprecated, 74~76행)

```java
Map<DayOfWeek, DayLearningRecordResponse> dayOfWeekToRecord = dailyLearningRecordService.getWeeklyDayRecords(userId);
WeeklyLearningRecordResponse weeklyLearningRecordResponse =
        WeeklyLearningRecordResponse.of(learning.getConsecutiveSolvedDays(), dayOfWeekToRecord);
```

- import: `java.util.Set` 제거(이 파일에서 다른 사용처 없음), `java.util.Map`, `gravit.code.dailyLearningRecord.dto.response.DayLearningRecordResponse` 추가

### 6. DTO

`dailyLearningRecord/dto/response/DayLearningRecordResponse.java` (신규)

```java
@Builder(access = AccessLevel.PRIVATE)
public record DayLearningRecordResponse(
        @Schema(
                description = "서버 기준(KST) 오늘과 비교한 요일 시점. PAST: 지난 요일, TODAY: 오늘, FUTURE: 오늘 이후 요일",
                example = "TODAY",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        DayTiming dayTiming,

        @Schema(
                description = "그날 학습 완료 여부. FUTURE 요일은 항상 false",
                example = "true",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @JsonProperty("isCompleted")
        boolean isCompleted
) {
    public static DayLearningRecordResponse of(
            DayTiming dayTiming,
            boolean isCompleted
    ) {
        return DayLearningRecordResponse.builder()
                .dayTiming(dayTiming)
                .isCompleted(isCompleted)
                .build();
    }
}
```

`dailyLearningRecord/dto/response/WeeklyLearningRecordResponse.java`

```java
public record WeeklyLearningRecordResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int consecutiveSolvedDays,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        DayLearningRecordResponse MONDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        DayLearningRecordResponse TUESDAY,

        // WEDNESDAY ~ SUNDAY 동일

) {
    public static WeeklyLearningRecordResponse of(
            int consecutiveSolvedDays,
            Map<DayOfWeek, DayLearningRecordResponse> dayOfWeekToRecord
    ) {
        return new WeeklyLearningRecordResponse(
                consecutiveSolvedDays,
                dayOfWeekToRecord.get(DayOfWeek.MONDAY),
                dayOfWeekToRecord.get(DayOfWeek.TUESDAY),
                dayOfWeekToRecord.get(DayOfWeek.WEDNESDAY),
                dayOfWeekToRecord.get(DayOfWeek.THURSDAY),
                dayOfWeekToRecord.get(DayOfWeek.FRIDAY),
                dayOfWeekToRecord.get(DayOfWeek.SATURDAY),
                dayOfWeekToRecord.get(DayOfWeek.SUNDAY)
        );
    }
}
```

- 생성 방식(`of` 안의 `new`)과 필드 순서는 기존 파일을 유지한다
- import: `java.util.Set` 제거, `java.util.Map` 추가 (`DayLearningRecordResponse`는 같은 패키지)

### 7. Controller

`GET /api/v1/main-pages/weekly-record → MainPageController.getWeeklyRecord` - 컨트롤러 코드는 변경 없음.

`MainPageControllerDocs.getWeeklyRecord`의 `@Operation` description

```java
@Operation(summary = "메인페이지 주간 학습 기록 조회", description = "메인페이지 주간 학습 기록(연속 학습일, 이번 주 요일별 시점과 학습 완료 여부)을 조회합니다<br>" +
        "<strong>dayTiming</strong>은 서버 기준(KST) 오늘 날짜로 판정합니다 (PAST: 지난 요일, TODAY: 오늘, FUTURE: 오늘 이후 요일)<br>" +
        "<strong>isCompleted</strong>는 그날 학습을 완료했는지 여부이며, FUTURE 요일은 항상 false입니다<br>" +
        "🔐 <strong>Jwt 필요</strong><br>")
```

- `@ApiResponses`는 바꾸지 않는다
- `UserControllerDocs`의 deprecated 메인 페이지 설명은 요일 필드를 언급하지 않으므로 수정하지 않는다

### 8. 서비스 정책

`.claude/spec/service-policy/learning.md` - 23행(주간 리포트) 바로 아래에 추가

- `메인페이지 주간 학습 기록은 이번 주 월요일부터 일요일까지 요일마다 오늘 기준 시점(지난 날, 오늘, 앞으로 올 날)과 학습 완료 여부를 함께 보여준다`
- `시점은 서버의 한국 시간 기준 오늘 날짜로 판정한다`
- `학습 완료는 그날 일일 학습 기록이 남은 날이다. 오늘 학습했으면 오늘도 완료이고, 앞으로 올 날은 항상 미완료다`

## 결정 필요 (Decisions needed)
- [x] 응답 모양 - A. 요일마다 상태 값 하나 / B. 요일마다 boolean 4개 / C. 요일마다 시점 enum + 완료 여부 boolean → **C**
- [x] 오늘 학습을 마친 경우의 표현 - C로 해소 → **`TODAY` + `isCompleted: true`**
- [x] 값 표기 - 대문자 / 소문자 → **대문자** (클라이언트로 나가는 기존 enum 규칙)
- [x] 구버전 앱 호환 - 요일 필드 교체 / 필드 추가 → **요일 필드를 새 모양으로 교체** (응답 모양 결정으로 갈음)

## 검증

**대상 테스트** (`@TCSpringBootTest`, 고정 시계 2025-08-05 화요일)

날짜 기준은 모두 `LocalDate.now(KST)` 대신 `@Autowired Clock`의 `LocalDate.now(clock)`로 바꾼다. 서비스가 고정 시계를 쓰므로 실제 날짜 기준으로 저장한 기록은 조회 주차 밖이 된다.

`DailyLearningRecordServiceIntegrationTest` > `GetWeeklySolvedDays` → `GetWeeklyDayRecords` (`@DisplayName("주간 요일별 학습 기록을 조회할 때")`)

| 시나리오 | 기대 |
|---|---|
| 학습 기록이 없음 | 7개 요일 모두 반환. 월 `PAST`, 화 `TODAY`, 수~일 `FUTURE`, 모두 `isCompleted` false |
| 월요일에 학습 | 월 `PAST` / true |
| 오늘(화요일)에 학습 | 화 `TODAY` / true |
| 지난주 월요일, 다음 주 월요일 기록만 있음 | 월 `PAST` / false |
| 다른 사용자의 이번 주 월요일 기록만 있음 | 월 `PAST` / false |

`DailyLearningRecordFacadeIntegrationTest` > `GetWeeklyLearningRecord`

| 시나리오 | 기대 |
|---|---|
| 연속 학습일 7, 월요일 학습 | `consecutiveSolvedDays` 7, 월 `PAST` / true, 화 `TODAY` / false, 수~일 `FUTURE` / false |
| 연속 학습일 3, 이번 주 학습 없음 | `consecutiveSolvedDays` 3, 모든 요일 `isCompleted` false |
| 학습 정보 없음 | `RestApiException` / `LEARNING_NOT_FOUND` (기존 유지) |

`UserFacadeIntegrationTest` > `GetMainPage`

- 122행 `LocalDate.now(KST).with(DayOfWeek.MONDAY)` → `LocalDate.now(clock).with(DayOfWeek.MONDAY)` (클래스에 `Clock`이 이미 주입돼 있음)
- 144행 `.MONDAY()).isTrue()` → `.MONDAY().isCompleted()).isTrue()`
- 175행 `.MONDAY()).isFalse()` → `.MONDAY().isCompleted()).isFalse()`

`MainPageControllerIntegrationTest` (신규, `@AutoConfigureMockMvc`)

| 시나리오 | 기대 |
|---|---|
| 학습 정보가 있는 유저가 월요일에 학습한 뒤 `GET /api/v1/main-pages/weekly-record` | 200, `$.MONDAY.dayTiming` `"PAST"`, `$.MONDAY.isCompleted` true, `$.TUESDAY.dayTiming` `"TODAY"`, `$.WEDNESDAY.dayTiming` `"FUTURE"` |

- 인증은 `AdminDashboardControllerIntegrationTest`처럼 `SecurityMockMvcRequestPostProcessors.authentication(...)`에 `LoginUser`를 담아 넘긴다. `@WithMockLoginUser`는 테스트 소스에서 주석 처리돼 있어 쓸 수 없다
- 이 테스트가 `isCompleted` 키 이름과 enum 대문자 표기를 고정한다

- 서비스 반환 타입과 DTO 필드 타입이 바뀌어 기존 세 테스트 파일은 갱신 전까지 컴파일되지 않는다
- `./gradlew test`로 전체 통과를 확인한다

## 범위 밖 (후속 작업)
- `DailyLearningRecordService`의 나머지 `LocalDate.now(TimeZoneConst.KST)` 3곳은 `Clock`으로 바꾸지 않는다. 바꾸면 주간 리포트, 연도별 기록, 일일 기록 처리 테스트의 날짜 기준도 함께 옮겨야 한다
- 재제출만 한 날은 연속 학습일이 오르지만 일일 학습 기록이 남지 않아 `isCompleted`가 false다(`learning.md` 7, 11행의 기존 정책). boolean 응답일 때도 같았다
- gravit-web `apps/legacy-web`의 `WeeklyStreak`는 `weeklyRecord?.[key]`를 truthy로만 본다. 배포 후 요일 값이 객체가 되면 지난 요일이 모두 완료로 보이므로, 서버 배포 시점을 프론트 반영과 맞춘다
- PR #545(#519 컨벤션 정리)가 `DailyLearningRecordService`(상수 추가, 주간 리포트 변수명)와 `UserFacade`(주입 필드 순서)를 수정한다. 먼저 머지되면 이 브랜치를 dev에 리베이스하고 필드 선언부 충돌을 정리한다

## Deviation Log
- `DailyLearningRecordServiceIntegrationTest.java`, `DailyLearningRecordFacadeIntegrationTest.java`, `UserFacadeIntegrationTest.java`, `MainPageControllerIntegrationTest.java`(신규): 구현 단계에서 수정, 작성하지 않음 — 이유: 테스트 코드 작성은 implement 범위 밖이라 `write-test`에서 검증 섹션대로 작성. 그 전까지 `compileTestJava`가 21건 실패함(서비스 테스트 5건은 삭제된 `getWeeklySolvedDays` 호출, Facade 테스트 14건과 UserFacade 테스트 2건은 요일 값에 대한 boolean 단언). `UserFacadeIntegrationTest` 122행의 `LocalDate.now(KST)` 날짜 기준은 컴파일은 되지만 고정 시계 주차와 달라 실행 시 실패하므로 함께 바꿔야 함
