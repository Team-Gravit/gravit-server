# [PLAN-464] 마이페이지 학습 조회 API 분할

> 이슈: #464
> 브랜치: refactor/464-split-mypage-learning-api

## 목표
`GET /api/v1/my-pages/learning` 하나가 주간 리포트, 이번주 최다 학습 챕터, 취약 개념 세 조회를 묶어 내려주고 있어, 한 조회만 실패해도 마이페이지 학습 화면 전체가 빈다.
세 조회를 화면 섹션 단위 엔드포인트로 분리해 장애 영향 범위를 각 섹션 안에 가둔다. 응답의 구성 요소는 바꾸지 않고 전달 단위만 나눈다.

## 영향 범위
### 신규 파일
- 없음 - 세 응답 DTO(`WeeklyLearningReportResponse`, `TopChapterResponse`, `WeakConceptResponse`)는 이미 존재하며 그대로 재사용한다

### 수정 파일
- `src/main/java/gravit/code/user/controller/MyPageController.java` - `getMyPageLearning` 제거, 엔드포인트 3개 추가, `DailyLearningRecordService`와 `LessonSubmissionQueryService` 주입 추가
- `src/main/java/gravit/code/user/controller/docs/MyPageControllerDocs.java` - `getMyPageLearning` 문서 제거, 신규 메서드 3개 문서 추가
- `src/main/java/gravit/code/learning/facade/LearningFacade.java` - `getMyPageLearning`과 그 전용 private 메서드 3개(`getWeeklyLearningReport`, `getTopChapters`, `getWeakConcepts`) 제거

### 삭제 파일
- `src/main/java/gravit/code/learning/dto/response/MyPageLearningResponse.java` - 세 조회를 묶던 래퍼. 분할 후 사용처가 없다

> `LearningFacade`의 필드는 하나도 지우지 않는다. `dailyLearningRecordService`는 `getLearningHistory`가, `lessonSubmissionQueryService`는 `getLearningSummary`와 `getLearningHistory`가 계속 쓴다.

## 구현 계획

### 1. Entity / Flyway
불필요 - DB 스키마 변경 없음. 기존 쿼리를 그대로 쓴다.

### 2. Repository
불필요 - `LessonSubmissionRepository`, `DailyLearningRecordRepository` 모두 변경 없음.

### 3. Service
변경 없음. 아래 세 메서드를 그대로 호출한다. 셋 다 이미 `@Transactional(readOnly = true)`가 붙어 있어, Facade의 트랜잭션이 사라져도 각 요청이 자기 트랜잭션 하나만 연다.

- `LessonSubmissionQueryService.getWeakConcepts(long userId)` → `List<WeakConceptResponse>`
- `LessonSubmissionQueryService.getTopChapters(long userId)` → `List<TopChapterResponse>`
- `DailyLearningRecordService.getWeeklyLearningReport(long userId)` → `WeeklyLearningReportResponse`

### 4. Facade
**불필요 - 단일 Service.** 분할 후 세 엔드포인트는 각각 Service 한 개를 한 번 호출할 뿐이라, `facade.md`의 "단일 Service 호출만 필요한 경우 Facade를 만들지 마라. Controller에서 Service를 직접 주입하라"에 해당한다.
같은 패키지의 `MainPageController`가 이미 `UnitQueryService`, `MissionService`, `UserLeagueService`를 직접 주입하는 선례를 따른다.

`LearningFacade`에서 제거할 것:
```java
public MyPageLearningResponse getMyPageLearning(long userId)   // 삭제
private WeeklyLearningReportResponse getWeeklyLearningReport(long userId)  // 삭제 (위임만 하던 메서드)
private List<TopChapterResponse> getTopChapters(long userId)              // 삭제
private List<WeakConceptResponse> getWeakConcepts(long userId)            // 삭제
```
함께 정리할 import: `MyPageLearningResponse`, `TopChapterResponse`, `WeakConceptResponse`, `WeeklyLearningReportResponse`.
`LearningFacade`의 나머지 메서드(`getLearningDetail`, `getMyPageSummary`, `getMyPageLearningHistory`)는 손대지 않는다.

### 5. DTO
신규 없음. `MyPageLearningResponse`만 삭제한다. 세 응답 record의 필드와 `@Schema`는 그대로 두어 클라이언트가 보는 필드 구성이 바뀌지 않게 한다.

### 6. Controller
`MyPageController`에 의존성을 추가한다. 컨벤션대로 도메인별로 빈 줄을 두어 그룹핑한다.

```java
private final UserFacade userFacade;
private final LearningFacade learningFacade;

private final DailyLearningRecordService dailyLearningRecordService;
private final LessonSubmissionQueryService lessonSubmissionQueryService;
```

기존 `@GetMapping("/learning")` 메서드를 지우고 아래 세 개를 넣는다. `/learning/history`와 같은 계층에 둔다.

| HTTP | 경로 | 메서드 | 위임 |
|---|---|---|---|
| GET | `/api/v1/my-pages/learning/weak-concepts` | `getMyPageWeakConcepts` | `lessonSubmissionQueryService.getWeakConcepts` |
| GET | `/api/v1/my-pages/learning/weekly-report` | `getMyPageWeeklyReport` | `dailyLearningRecordService.getWeeklyLearningReport` |
| GET | `/api/v1/my-pages/learning/top-chapters` | `getMyPageTopChapters` | `lessonSubmissionQueryService.getTopChapters` |

```java
@GetMapping("/learning/weak-concepts")
public ResponseEntity<List<WeakConceptResponse>> getMyPageWeakConcepts(@AuthenticationPrincipal LoginUser loginUser){
    return ResponseEntity.status(HttpStatus.OK).body(lessonSubmissionQueryService.getWeakConcepts(loginUser.getId()));
}

@GetMapping("/learning/weekly-report")
public ResponseEntity<WeeklyLearningReportResponse> getMyPageWeeklyReport(@AuthenticationPrincipal LoginUser loginUser){
    return ResponseEntity.status(HttpStatus.OK).body(dailyLearningRecordService.getWeeklyLearningReport(loginUser.getId()));
}

@GetMapping("/learning/top-chapters")
public ResponseEntity<List<TopChapterResponse>> getMyPageTopChapters(@AuthenticationPrincipal LoginUser loginUser){
    return ResponseEntity.status(HttpStatus.OK).body(lessonSubmissionQueryService.getTopChapters(loginUser.getId()));
}
```

리스트를 래퍼 없이 그대로 내리는 것은 기존 관례를 따른 것이다(`MainPageController.getUnits`, `ChapterController.getAllChapter`).

### 7. API 문서
`MyPageControllerDocs`에서 `getMyPageLearning` 문서를 제거하고, 신규 메서드 3개를 선언한다. 기존 `getMyPageLearning` 문서와 같은 골격(200 성공 + 500 `GLOBAL_5001`)을 쓴다. 세 조회 모두 유저나 학습 정보를 다시 찾지 않아 404 케이스가 없다.

- `@Operation(summary = "마이페이지 취약 개념 조회", description = "오답률이 높은 유닛 상위 7개를 조회합니다<br>🔐 <strong>Jwt 필요</strong><br>")`
- `@Operation(summary = "마이페이지 주간 리포트 조회", description = "이번 주 요일별 학습량과 직전 3주 대비 증감을 조회합니다<br>🔐 <strong>Jwt 필요</strong><br>")`
- `@Operation(summary = "마이페이지 이번주 최다 학습 챕터 조회", description = "이번 주에 가장 많이 푼 챕터 상위 3개를 조회합니다<br>🔐 <strong>Jwt 필요</strong><br>")`

성공 응답 description은 각각 `"✅ 마이페이지 취약 개념 조회 성공"`, `"✅ 마이페이지 주간 리포트 조회 성공"`, `"✅ 마이페이지 이번주 최다 학습 챕터 조회 성공"`.

### 8. 서비스 정책
변경 없음. 산정 기준(상위 3개 챕터, 취약 유닛 7개, 월요일 시작 주간 리포트)이 그대로라 `learning.md` 수정은 필요 없다.

## 결정 필요 (Decisions needed)
- [x] 신규 엔드포인트 테스트 범위 - A: `MyPageControllerIntegrationTest` 신설(MockMvc + `@WithMockLoginUser`로 경로, 상태코드, 응답 필드 검증) / B: 기존 서비스 통합 테스트로 갈음하고 신규 테스트 없음
  → **B 채택.** 조회 로직이 그대로고 컨트롤러는 위임만 하므로, 배선 변경은 빌드로 확인한다. 이슈의 "신규 엔드포인트 테스트 작성" 항목은 이 결정으로 대체한다.

## 검증
- 신규 테스트 없음
- 기존(회귀 확인용, 수정 불필요):
  - `LessonSubmissionQueryServiceIntegrationTest` - `getTopChapters` 4케이스, `getWeakConcepts` 4케이스
  - `DailyLearningRecordServiceIntegrationTest` - `getWeeklyLearningReport` 6케이스
  - `LearningFacadeIntegrationTest` - `getMyPageLearning`을 검증하지 않으므로 영향 없음
- `./gradlew build`로 삭제한 `MyPageLearningResponse` 참조가 남지 않았는지 확인

## Deviation Log
