# [PLAN-550] 레슨 결과 응답에 레벨 XP 경계값 추가

> 이슈: #550
> 브랜치: feat/550-level-xp-boundary

## 목표
레슨 결과 조회(`GET /api/v1/lessons/results/{lessonSubmissionId}`)가 반환하는 `LessonResultResponse.userLevelResponse`에 현재 레벨의 XP 구간인 `minXp`, `maxXp`를 추가한다. 지금은 `currentLevel`, `nextLevel`, `xp`만 있어 프론트엔드가 결과 화면의 XP 프로그래스 바 구간을 알 수 없다.

응답 예 (3레벨, 누적 XP 250)

```json
{
  "leagueName": "브론즈",
  "userLevelResponse": {
    "currentLevel": 3,
    "nextLevel": 4,
    "xp": 250,
    "minXp": 200,
    "maxXp": 400
  },
  "unitSummaryResponse": { ... }
}
```

최고 레벨 (10레벨, 누적 XP 5000)이면 `"minXp": 3700, "maxXp": 5000`이다.

## 배치 기준
- **필드는 `UserLevelResponse`에 둔다.** 이슈 발의 때 확정했다. 레벨 관련 값(`currentLevel`, `nextLevel`, `xp`)이 이미 여기 모여 있다. `UserLevelResponse`를 만드는 곳은 `UserService.getUserLevel` 한 곳, 담는 곳은 `LessonResultResponse` 한 곳이라 다른 API 응답은 바뀌지 않는다
- **`minXp`는 현재 레벨의 시작 XP(`Level.getStartXp()`), `maxXp`는 다음 레벨의 시작 XP(`Level.getEndXp()`)다.** `service-policy/user.md`의 레벨 구간 정의를 그대로 노출할 뿐이라 정책은 바뀌지 않는다
- **최고 레벨이면 `maxXp`는 현재 `xp`다.** `Level.getEndXp()`는 최고 레벨에서 예외를 던진다. 메인페이지, 프로필에 쓰는 `UserLevel.getUserLevelDetail()`의 `maxXp`와 같은 규칙이고, 프로그래스 바가 가득 찬다(`user.md`: 최고 레벨 진행률은 항상 100%)
- **최고 레벨에 막 도달해 `xp`가 3700이면 `minXp`와 `maxXp`가 모두 3700이다.** 프론트가 `(xp - minXp) / (maxXp - minXp)`로 계산하면 0으로 나누게 된다. `maxXp`의 `@Schema` 설명에 "최고 레벨(`currentLevel == nextLevel`)이면 현재 xp와 같다"를 적어, 프론트가 최고 레벨을 따로 판별해 가득 찬 바로 그리게 한다. 프론트에 전달할 사항이다
- **계산은 `UserLevelResponse.create` 안에서 한다.** 이미 `nextLevel`을 이 팩토리에서 `Level` enum으로 계산하고 있다. 팩토리 시그니처(`create(int level, int xp)`)는 그대로라 `UserService`는 바꾸지 않는다
- **레벨은 `Level.fromLevel(level)`로 구한다.** 기존 `nextLevel` 계산, `UserLevel.getUserLevelDetail()`의 `maxXp` 계산과 같은 기준이다. `fromLevel`을 한 번만 호출해 `nextLevel`, `minXp`, `maxXp` 계산에 함께 쓴다
- **`UserLevel.getUserLevelDetail()`과의 최고 레벨 분기 중복은 정리하지 않는다.** 한 줄짜리 삼항식 두 곳이고, 합치려면 `UserLevel`, `Level`까지 손대야 해 이번 범위를 넘는다
- **`xp`의 `@Schema` 예시값을 `100`에서 `250`으로 고친다.** 3레벨 예시와 맞지 않는 값이다(3레벨은 200부터). 새 필드 예시(`200`, `400`)와 한 화면에서 읽히도록 맞춘다
- **`LessonControllerDocs`는 바꾸지 않는다.** 200 응답에 예시 JSON이 없고 스키마를 DTO에서 가져온다
- **Service, Facade, Controller 코드는 바꾸지 않는다.** 모두 `UserLevelResponse`를 그대로 넘기기만 한다

## 영향 범위
### 신규 파일
- 없음

### 수정 파일
- `src/main/java/gravit/code/user/dto/response/UserLevelResponse.java` - `minXp`, `maxXp` 컴포넌트 추가, `create`에서 계산, `xp` 예시값 수정

## 구현 계획
1. **Entity / Flyway**: 변경 없음
2. **Repository**: 변경 없음
3. **Service**: 변경 없음 - `UserService.getUserLevel(long userId)`는 `UserLevelResponse.create(level, xp)`를 그대로 호출한다
4. **Facade**: 불필요 - `LessonFacade.getLessonResult`는 이미 `userService.getUserLevel`의 결과를 `LessonResultResponse.create`에 넘기고 있어 바꿀 것이 없다
5. **DTO**: `UserLevelResponse`
   - 컴포넌트 추가 (`xp` 뒤에 순서대로, 컴포넌트 사이 빈 줄)
     ```java
     @Schema(
             description = "현재 레벨 시작 경험치",
             example = "200",
             requiredMode = Schema.RequiredMode.REQUIRED
     )
     int minXp,

     @Schema(
             description = "다음 레벨 시작 경험치 (최고 레벨이면 현재 경험치와 동일)",
             example = "400",
             requiredMode = Schema.RequiredMode.REQUIRED
     )
     int maxXp
     ```
   - `xp`의 `@Schema` `example`을 `"100"` → `"250"`
   - `create(int level, int xp)` 본문
     ```java
     Level currentLevel = Level.fromLevel(level);

     return UserLevelResponse.builder()
             .currentLevel(level)
             .nextLevel(currentLevel.next().getLevel())
             .xp(xp)
             .minXp(currentLevel.getStartXp())
             .maxXp(currentLevel.isMax() ? xp : currentLevel.getEndXp())
             .build();
     ```
6. **Controller**: 변경 없음 - `GET /api/v1/lessons/results/{lessonSubmissionId}` → `LessonController.getLessonResult`

## 결정 필요 (Decisions needed)
- 없음

## 검증
- 대상 테스트: `UserLevelResponseTest` (`src/test/java/gravit/code/user/dto/response/`)
  - 기존 `중간_레벨이면_다음_레벨은_현재보다_하나_높다` (`create(3, 250)`): `minXp` 200, `maxXp` 400 단언 추가
  - 기존 `최고_레벨이면_존재하지_않는_다음_레벨_대신_현재_레벨을_반환한다` (`create(10, 5000)`): `minXp` 3700, `maxXp` 5000 단언 추가
  - 추가 후보: 구간 시작 XP와 같을 때 (`create(3, 200)` → `minXp` 200, `maxXp` 400), 최고 레벨에 막 도달했을 때 (`create(10, 3700)` → `minXp`, `maxXp` 모두 3700)
- `LessonFacadeIntegrationTest.GetLessonResult`는 `userLevelResponse` 값을 단언하지 않아 필드 추가로 깨지지 않는다. 이슈 작업 항목에 적었지만 갱신은 필요 없다

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
