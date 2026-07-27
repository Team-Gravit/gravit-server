# [PLAN-468] 마이페이지 요약 조회 API 분할

> 이슈: #468
> 브랜치: refactor/468-split-mypage-summary-api

## 목표
`GET /api/v1/my-pages/summaries` 하나가 학습 요약, 올해 일별 학습 이력, 조회 가능 연도 목록 셋을 묶어 내려주고 있어, 한 조회만 실패해도 마이페이지 요약 화면 전체가 빈다.
#464와 같은 방식으로 화면 섹션 단위로 나눈다. 학습 요약은 `/learning/summaries`로 옮겨 요약만 내려주고, 과거 학습 이력 섹션은 기존 `/learning/history`가 연도 목록까지 함께 내려 한 요청으로 자립하게 한다.
요약 경로를 `/summaries`에서 `/learning/summaries`로 옮기는 것은 #464에서 만든 `/learning/*` 계층과 정렬하기 위해서다. 응답 형태가 어차피 바뀌어 클라이언트 수정이 필요하므로 경로도 함께 맞춘다.

## 영향 범위
### 신규 파일
- 없음 - 두 응답 DTO(`LearningSummaryResponse`, `LearningHistoryResponse`)는 이미 존재하며 그대로 재사용한다

### 수정 파일
- `src/main/java/gravit/code/learning/dto/response/LearningHistoryResponse.java` - `List<Integer> years` 필드 추가, `of` 파라미터 3개로 확장
- `src/main/java/gravit/code/learning/facade/LearningFacade.java` - `getMyPageSummary` 반환 타입 축소와 private 메서드 2개 인라인 흡수, `getMyPageLearningHistory`가 연도 목록 산정을 맡음
- `src/main/java/gravit/code/user/controller/MyPageController.java` - `getMyPageSummary`의 매핑 경로를 `/learning/summaries`로 옮기고 반환 타입 변경
- `src/main/java/gravit/code/user/controller/docs/MyPageControllerDocs.java` - 두 메서드의 반환 타입, description, 404 응답 재배치

### 삭제 파일
- `src/main/java/gravit/code/learning/dto/response/MyPageSummaryResponse.java` - 세 조회를 묶던 래퍼. 분할 후 사용처가 없다

> `LearningFacade`의 필드는 하나도 지우지 않는다. `userService`는 연도 목록 산정이 `getMyPageLearningHistory`로 옮겨가며 계속 쓴다.

## 구현 계획

### 1. Entity / Flyway
불필요 - DB 스키마 변경 없음. 기존 쿼리를 그대로 쓴다.

### 2. Repository
불필요 - `LessonSubmissionRepository`, `DailyLearningRecordRepository`, `LessonRepository`, `UserRepository` 모두 변경 없음.

### 3. Service
변경 없음. 아래 여섯 메서드를 지금과 똑같이 호출한다. 호출 주체만 두 Facade 메서드로 갈라진다.

- 요약: `LearningProgressRateService.getLearningRankPercentile`, `LessonSubmissionQueryService.getCompletedLessonCount` / `getTotalLearningHours` / `getAverageAccuracy`, `LessonQueryService.getTotalLessonCount`
- 이력: `DailyLearningRecordService.getDailySolvedCounts`, `LessonSubmissionQueryService.getPeakLearningHour`, `UserService.getUser`

### 4. Facade
**유지.** 분할 후에도 두 메서드 모두 3개 이상의 서로 다른 도메인 Service를 조합하므로 `facade.md`의 "여러 Service를 조합하는 비즈니스 로직" 그대로다. #464에서 Facade를 걷어냈던 것과 달리, 여기서는 Controller가 계속 `LearningFacade`에 위임한다.

private 헬퍼 `getLearningSummary`, `getLearningHistory`는 각각 호출처가 하나로 줄어드니 public 메서드 본문으로 흡수하고 삭제한다.

```java
@Transactional(readOnly = true)
public LearningSummaryResponse getMyPageSummary(long userId) {
    int rankPercentile = learningProgressRateService.getLearningRankPercentile(userId);
    int completedLessonCount = lessonSubmissionQueryService.getCompletedLessonCount(userId);
    int totalLessonCount = lessonQueryService.getTotalLessonCount();
    double totalLearningHours = lessonSubmissionQueryService.getTotalLearningHours(userId);
    int averageAccuracy = lessonSubmissionQueryService.getAverageAccuracy(userId);

    return LearningSummaryResponse.of(
            rankPercentile,
            completedLessonCount,
            totalLessonCount,
            totalLearningHours,
            averageAccuracy
    );
}

@Transactional(readOnly = true)
public LearningHistoryResponse getMyPageLearningHistory(
        long userId,
        int year
) {
    List<DailySolvedCountResponse> dailySolvedCounts = dailyLearningRecordService.getDailySolvedCounts(userId, year);
    int peakLearningHour = lessonSubmissionQueryService.getPeakLearningHour(userId);

    int currentYear = LocalDate.now(TimeZoneConst.KST).getYear();
    int signUpYear = userService.getUser(userId).getCreatedAt().getYear();
    List<Integer> availableYears = IntStream.rangeClosed(signUpYear, currentYear)
            .boxed()
            .toList();

    return LearningHistoryResponse.of(
            dailySolvedCounts,
            peakLearningHour,
            availableYears
    );
}
```

정리할 import: `MyPageSummaryResponse`. `LocalDate`, `TimeZoneConst`, `IntStream`, `DailySolvedCountResponse`는 계속 쓰므로 남긴다.
`getLearningDetail`은 손대지 않는다.

### 5. DTO
`LearningHistoryResponse`에 연도 목록을 더한다. 기존 두 필드의 이름과 `@Schema`는 그대로 두어 이력 데이터 자체의 형태는 바뀌지 않게 한다.

```java
@Builder(access = AccessLevel.PRIVATE)
public record LearningHistoryResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        List<DailySolvedCountResponse> dailySolvedCounts,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int peakLearningHour,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        List<Integer> years
) {
    public static LearningHistoryResponse of(
            List<DailySolvedCountResponse> dailySolvedCounts,
            int peakLearningHour,
            List<Integer> years
    ) { ... }
}
```

`MyPageSummaryResponse`는 삭제한다. `LearningSummaryResponse`는 손대지 않는다.

### 6. Controller
`MyPageController`의 의존성은 그대로 둔다. `getMyPageSummary`의 매핑 경로와 반환 타입을 바꾼다.

| HTTP | 경로 (변경 전 → 후) | 응답 (변경 전 → 후) |
|---|---|---|
| GET | `/api/v1/my-pages/summaries` → `/api/v1/my-pages/learning/summaries` | `MyPageSummaryResponse` → `LearningSummaryResponse` |
| GET | `/api/v1/my-pages/learning/history` (유지) | `LearningHistoryResponse` (years 필드 추가) |

```java
@GetMapping("/learning/summaries")
public ResponseEntity<LearningSummaryResponse> getMyPageSummary(@AuthenticationPrincipal LoginUser loginUser){
    return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getMyPageSummary(loginUser.getId()));
}
```

메서드 선언 위치는 `/learning/*` 엔드포인트들과 같은 묶음으로 옮겨, `getMyPageBanner` 다음이 아니라 `getMyPageWeakConcepts` 앞에 둔다.
`getMyPageLearningHistory`의 본문은 그대로다. import에서 `MyPageSummaryResponse`를 빼고 `LearningSummaryResponse`를 넣는다.

### 7. API 문서
`MyPageControllerDocs`에서 두 메서드의 문서를 고친다. 404 응답이 반대로 옮겨가는 것이 핵심이다.

- `getMyPageSummary`: 반환 타입을 `LearningSummaryResponse`로 바꾸고, description을 `"마이페이지 학습 요약(상위 백분위, 완료 레슨 수, 총 학습 시간, 평균 정답률)을 조회합니다"`로 교체한다. **유저 조회 404(`USER_4041`)를 제거한다** - 분할 후 이 경로는 유저를 조회하지 않는다(집계 쿼리만 탄다). 200 + 500만 남는다.
- `getMyPageLearningHistory`: description을 `"지정한 연도의 일별 풀이 수, 피크 학습 시간과 조회 가능 연도 목록을 조회합니다"`로 교체하고, **유저 조회 404(`USER_4041`)를 추가한다** - 가입 연도를 얻기 위해 `userService.getUser`를 타게 되었다. 예시 값은 기존 배너 문서의 `{"error" : "USER_4041", "message" : "존재하지 않는 유저입니다."}`를 그대로 쓴다.

성공 응답 description은 각각 `"✅ 마이페이지 학습 요약 조회 성공"`, `"✅ 마이페이지 학습 이력 조회 성공"`으로 지금 값을 유지한다.

### 8. 서비스 정책
변경 없음. `learning.md`의 "학습 기록 조회 가능 연도는 가입 연도부터 올해까지다"가 그대로 유지된다. 산정 기준이 아니라 전달 위치만 바뀐다.

## 결정 필요 (Decisions needed)
- [x] `/learning/history`의 `year` 파라미터 필수 여부 - A: `required = false`로 바꿔 미지정 시 KST 현재 연도를 기본값으로 쓴다(초기 진입이 한 요청으로 끝나고, 올해 판정 기준이 서버 KST로 통일된다. Facade 파라미터가 `Integer`가 되고 null 분기가 생긴다) / B: 지금처럼 필수 유지(클라이언트가 올해를 계산해 넣는다. 서버 코드 변경 없음)
  → **B 채택.** `year`는 지금처럼 필수로 둔다. 클라이언트가 조회 연도를 항상 명시한다.

## 검증
- 신규 테스트 없음. 조회 로직과 산정 기준이 그대로고 전달 단위만 바뀐다.
- 기존(회귀 확인용, 수정 불필요):
  - `LearningFacadeIntegrationTest` - `getLearningDetail`만 검증하므로 영향 없음
  - `LessonSubmissionQueryServiceIntegrationTest`, `DailyLearningRecordServiceIntegrationTest` - 호출되는 조회 메서드들의 기존 케이스
- `./gradlew build`로 삭제한 `MyPageSummaryResponse` 참조와 `LearningHistoryResponse.of` 호출부(2파라미터 → 3파라미터)가 남지 않았는지 확인

## Deviation Log
- `MyPageController.java`: 계획의 "메서드 선언 위치를 `getMyPageWeakConcepts` 앞으로 옮긴다"는 실제로 이동이 없었다 - 이유: `getMyPageSummary`가 이미 `getMyPageBanner`와 `getMyPageWeakConcepts` 사이에 있어 계획이 지목한 자리와 같은 슬롯이었다. 매핑 경로만 바꾸면 `/learning/*` 묶음과 붙는다
