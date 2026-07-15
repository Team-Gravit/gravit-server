# [PLAN-438] main-pages 연속 학습일(consecutiveSolvedDays) 응답 위치 이동(learning→weekly-record)

> 이슈: #438
> 브랜치: hotfix/438-move-consecutive-solved-days

## 목표
연속 학습일(`consecutiveSolvedDays`)을 `GET /api/v1/main-pages/learning` 응답(`LearningDetailResponse`)에서 제거하고 `GET /api/v1/main-pages/weekly-record` 응답(`WeeklyLearningRecordResponse`)으로 옮긴다. 값 자체는 `learning` 도메인(`Learning.consecutiveSolvedDays`)에서 오고, 주간 요일 기록은 `dailyLearningRecord` 도메인에서 오므로 두 도메인 Service를 결합하는 신규 `DailyLearningRecordFacade`를 도입한다. DB 컬럼(`learning.consecutive_solved_days`)은 변경 없음 → Flyway 마이그레이션 없음.

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/dailyLearningRecord/facade/DailyLearningRecordFacade.java` — 연속 학습일(learning) + 주간 요일 기록(dailyLearningRecord) 결합해 `WeeklyLearningRecordResponse` 조립
- `src/test/java/gravit/code/dailyLearningRecord/facade/DailyLearningRecordFacadeIntegrationTest.java` — 신규 Facade 검증(연속일 결합 + 요일 기록 + Learning 미존재 404)

### 수정 파일
- `src/main/java/gravit/code/dailyLearningRecord/dto/response/WeeklyLearningRecordResponse.java` — `consecutiveSolvedDays` 필드 추가 + 정적 팩토리 `of(int, Set<DayOfWeek>)` 추가
- `src/main/java/gravit/code/dailyLearningRecord/service/DailyLearningRecordService.java` — `getWeeklyLearningRecord(long): WeeklyLearningRecordResponse` → `getWeeklySolvedDays(long): Set<DayOfWeek>`로 변경(DTO 조립 책임 제거, 조회한 요일 Set만 반환)
- `src/main/java/gravit/code/user/controller/MainPageController.java` — `/weekly-record`를 `DailyLearningRecordFacade`에 위임, `DailyLearningRecordService` 주입 제거
- `src/main/java/gravit/code/user/controller/docs/MainPageControllerDocs.java` — `getWeeklyRecord`에 404(`LEARNING_4041`) 응답·설명 보강, `getLearning` 변경 없음
- `src/main/java/gravit/code/learning/dto/response/LearningDetailResponse.java` — `consecutiveSolvedDays` record 컴포넌트 + `of()` 파라미터 제거
- `src/main/java/gravit/code/learning/facade/LearningFacade.java` — `getLearningDetail`의 `LearningDetailResponse.of(...)` 호출에서 `consecutiveSolvedDays` 인자 제거(`Learning`은 `recentSolvedChapterId` 때문에 계속 조회)
- `src/main/java/gravit/code/user/facade/UserFacade.java` — (1) private `getLearningDetail`의 `of()` 인자 제거, (2) deprecated `getMainPage`에서 없어진 서비스 메서드 대체 조립
- `src/test/java/gravit/code/dailyLearningRecord/service/DailyLearningRecordServiceIntegrationTest.java` — `GetWeeklyLearningRecordResponse` 5개 테스트를 `getWeeklySolvedDays` + `Set<DayOfWeek>` 단언으로 변경
- `src/test/java/gravit/code/learning/facade/LearningFacadeIntegrationTest.java` — `GetLearningDetail`의 `consecutiveSolvedDays()` 단언 제거
- `src/test/java/gravit/code/user/facade/UserFacadeIntegrationTest.java` — `getMainPage`의 `learningDetailResponse().consecutiveSolvedDays()` 단언을 `weeklyLearningRecordResponse().consecutiveSolvedDays()`로 이동

## 구현 계획
> 레이어 순. `Learning` 엔티티/`learning.consecutive_solved_days` 컬럼은 그대로이며, `getConsecutiveSolvedDays()` getter도 그대로 사용한다.

1. **Entity / Flyway**: 변경 없음 (컬럼 이동 아님, API 응답 위치만 이동).

2. **Repository**: 변경 없음.

3. **DTO — `WeeklyLearningRecordResponse`** (`dailyLearningRecord/dto/response/`)
   - record 컴포넌트 맨 앞에 추가: `@Schema(requiredMode = Schema.RequiredMode.REQUIRED) int consecutiveSolvedDays` (기존 7개 요일 boolean은 순서·이름 유지)
   - 정적 팩토리 추가(생성자 직접 호출 대신 컨벤션 준수):
     ```java
     public static WeeklyLearningRecordResponse of(
             int consecutiveSolvedDays,
             Set<DayOfWeek> solvedDays
     ) {
         return new WeeklyLearningRecordResponse(
                 consecutiveSolvedDays,
                 solvedDays.contains(DayOfWeek.MONDAY),
                 solvedDays.contains(DayOfWeek.TUESDAY),
                 solvedDays.contains(DayOfWeek.WEDNESDAY),
                 solvedDays.contains(DayOfWeek.THURSDAY),
                 solvedDays.contains(DayOfWeek.FRIDAY),
                 solvedDays.contains(DayOfWeek.SATURDAY),
                 solvedDays.contains(DayOfWeek.SUNDAY)
         );
     }
     ```
   - import 추가: `java.time.DayOfWeek`, `java.util.Set`

4. **Service — `DailyLearningRecordService`** (`dailyLearningRecord/service/`)
   - `getWeeklyLearningRecord(long userId)` → `getWeeklySolvedDays(long userId)`로 개명, 반환 타입 `WeeklyLearningRecordResponse` → `Set<DayOfWeek>`
   - 본문: 기존 `monday`/`sunday` 계산 + `findSolvedDatesByUserIdAndDateRange(...).stream().map(LocalDate::getDayOfWeek).collect(toUnmodifiableSet())` 까지 유지하고 그 `Set<DayOfWeek>`를 그대로 반환 (DTO 생성 부분 삭제)
   - `@Transactional(readOnly = true)` 유지, `WeeklyLearningRecordResponse` import 제거

5. **Facade — `DailyLearningRecordFacade` (신규)** (`dailyLearningRecord/facade/`)
   - `@Facade` + `@RequiredArgsConstructor`
   - 필드: `DailyLearningRecordService dailyLearningRecordService`, `LearningQueryService learningQueryService`
   - 메서드:
     ```java
     @Transactional(readOnly = true)
     public WeeklyLearningRecordResponse getWeeklyLearningRecord(long userId) {
         int consecutiveSolvedDays = learningQueryService.getLearning(userId).getConsecutiveSolvedDays();

         Set<DayOfWeek> solvedDays = dailyLearningRecordService.getWeeklySolvedDays(userId);

         return WeeklyLearningRecordResponse.of(consecutiveSolvedDays, solvedDays);
     }
     ```
   - 근거: Service는 단일 도메인만 담당(타 도메인 Service 직접 호출 금지)하므로, `learning`+`dailyLearningRecord` 결합은 Facade 책임.

6. **Facade — `LearningFacade.getLearningDetail`** (`learning/facade/`)
   - `LearningDetailResponse.of(...)` 호출에서 첫 인자 `learning.getConsecutiveSolvedDays()` 제거
   - `Learning learning = learningQueryService.getLearning(userId);`와 `learning.getRecentSolvedChapterId()`는 그대로 유지

7. **DTO — `LearningDetailResponse`** (`learning/dto/response/`)
   - record 컴포넌트 `int consecutiveSolvedDays`(+ 위의 `@Schema`) 제거
   - `of(...)`에서 `consecutiveSolvedDays` 파라미터·`.consecutiveSolvedDays(...)` 빌더 호출 제거
   - 남는 컴포넌트: `recentSolvedChapterId`, `recentSolvedChapterTitle`, `recentSolvedChapterProgressRate`, `units`

8. **Facade — `UserFacade`** (`user/facade/`) — deprecated 경로 유지 목적
   - private `getLearningDetail(long, Learning)`: `LearningDetailResponse.of(...)`에서 `learning.getConsecutiveSolvedDays()` 인자 제거
   - `getMainPage(long)`: 72번 라인 `dailyLearningRecordService.getWeeklyLearningRecord(userId)`가 사라지므로 아래로 교체(이미 지역변수 `learning` 보유):
     ```java
     Set<DayOfWeek> solvedDays = dailyLearningRecordService.getWeeklySolvedDays(userId);
     WeeklyLearningRecordResponse weeklyLearningRecordResponse =
             WeeklyLearningRecordResponse.of(learning.getConsecutiveSolvedDays(), solvedDays);
     ```
   - import 추가: `java.time.DayOfWeek`, `java.util.Set` (기존 `WeeklyLearningRecordResponse` import 유지)

9. **Controller — `MainPageController`** (`user/controller/`)
   - 필드 `DailyLearningRecordService dailyLearningRecordService` → `DailyLearningRecordFacade dailyLearningRecordFacade`로 교체(해당 서비스는 `/weekly-record`에서만 사용)
   - `getWeeklyRecord`: `dailyLearningRecordFacade.getWeeklyLearningRecord(loginUser.getId())` 위임
   - import 교체: `DailyLearningRecordService` → `DailyLearningRecordFacade`

10. **Docs — `MainPageControllerDocs.getWeeklyRecord`** (`user/controller/docs/`)
    - `@Operation` 설명에 연속 학습일 포함되도록 보강("주간 학습 기록(연속 학습일, 요일별 학습 여부)")
    - 404 `@ApiResponse` 추가: `LEARNING_4041`("학습 정보 조회에 실패하였습니다.") — weekly-record가 이제 `getLearning`에 의존하므로. `getLearning` docs는 변경 없음(설명에 연속 학습일 언급 없음)

## 결정 필요 (Decisions needed)
- [x] 연속 학습일 조립 위치 — 신규 `DailyLearningRecordFacade`로 결정. (Service의 타 도메인 호출 금지 컨벤션상 Facade가 유일한 정석. 대안인 "Controller에서 두 서비스 조합"은 Controller 비즈니스 로직 금지 위반)
- [x] weekly-record의 Learning 의존으로 인한 404 발생 — 허용으로 결정. 모든 유저는 가입 시 `LearningCommandService`가 `Learning.create`로 생성하므로 실질 발생 없음. 기존 `/learning`도 동일하게 `getLearning` 404를 가지므로 일관됨. Swagger에 404 명시.

## 검증
- 대상 테스트:
  - `DailyLearningRecordFacadeIntegrationTest`(신규) — ① 연속 학습일(예: 7)이 응답에 실린다 ② 요일별 학습 여부가 정확히 매핑된다 ③ `Learning` 미존재 시 `RestApiException(LEARNING_NOT_FOUND)`
  - `DailyLearningRecordServiceIntegrationTest`(수정) — `GetWeeklyLearningRecordResponse` 5개 시나리오를 `getWeeklySolvedDays` 호출 + `assertThat(result).contains(DayOfWeek.MONDAY)` / `doesNotContain(...)` 형태로 변경
  - `LearningFacadeIntegrationTest`(수정) — `GetLearningDetail`에서 `consecutiveSolvedDays()` 단언 2건 제거(나머지 recentSolvedChapter/units/404 단언 유지)
  - `UserFacadeIntegrationTest`(수정) — `getMainPage` 테스트의 `learningDetailResponse().consecutiveSolvedDays()` → `weeklyLearningRecordResponse().consecutiveSolvedDays()`로 이동(getMyPageBanner의 `consecutiveSolvedDays` 단언은 `MyPageBannerResponse` 소속이라 변경 없음)
  - `./gradlew compileJava compileTestJava` — 미사용 import/시그니처 오류 확인
  - `./gradlew test` — 전체 통과 확인

## Deviation Log
- `LearningFacadeIntegrationTest.java`: 계획은 `consecutiveSolvedDays()` 단언만 제거였으나, 첫 테스트의 `ReflectionTestUtils.setField(learning, "consecutiveSolvedDays", 5)`도 함께 제거 — 이유: 단언이 사라져 해당 setField가 죽은 준비 코드가 됨.
- 검증(`./gradlew test`)은 미완료 — 이유: 대상 테스트가 전부 `@TCSpringBootTest`(Testcontainers)인데 현재 환경에 Docker 데몬이 없어 실행 불가(`DockerClientProviderStrategy` NoClassDefFoundError). `./gradlew compileJava compileTestJava`는 성공. Docker 기동 후 재실행 필요.
