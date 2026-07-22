# [PLAN-455] 레벨 XP 구간표 중복 선언 제거

> 이슈: #455
> 브랜치: refactor/455-user-level-xp-table

## 목표
`UserLevel`의 네 곳(`calculateLevel`, `calculateLevelRate`, `getMaxXp`, `getUserLevelDetail`의 상한 10)에 흩어진 XP 구간표를 `Level` enum 한 곳으로 모아, 레벨 추가나 구간 조정 시 한 곳만 고치면 되게 한다.

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/user/domain/Level.java` — 레벨과 XP 구간의 단일 출처 enum
- `src/test/java/gravit/code/user/domain/UserLevelTest.java` — 구간 경계, 최고 레벨 진행률 검증

### 수정 파일
- `src/main/java/gravit/code/user/domain/UserLevel.java` — 구간 판단을 전부 `Level` 조회로 위임. `calculateLevel`, `getMaxXp` 제거, `calculateLevelRate`는 private으로 축소

`User`, `UserService`, `MissionService`, `UserFacade`는 `updateXp` / `getUserLevelDetail` / `getLevel`만 호출하므로 시그니처 변화가 없어 수정하지 않는다.

## 구현 계획
> 레이어 순으로, 클래스·메서드 단위까지 구체적으로. "적절히 구현한다" 같은 추상 표현 금지.

1. **Entity / Flyway**: DB 변경 없음. `level`, `xp` 컬럼과 매핑은 그대로다. 구간표는 코드 상수일 뿐 스키마가 아니므로 마이그레이션이 필요 없다.

2. **Repository**: 변경 없음.

3. **Service**: 변경 없음.

4. **Facade**: 불필요 - 도메인 객체 내부 리팩토링이라 서비스 조합이 없다.

5. **DTO**: 변경 없음. `UserLevelDetailResponse.of(level, currentXp, maxXp, levelRate)`의 필드와 값 의미가 그대로 유지된다.

6. **Controller**: 변경 없음. 응답 스펙이 바뀌지 않는다.

### 6-1. 신규 `Level` enum (`user/domain/Level.java`)

`MissionType`과 같은 패턴(`@Getter` + `@AllArgsConstructor`)을 따른다. 각 레벨은 자신의 **시작 XP만** 선언하고, 끝 XP는 다음 레벨의 시작 XP에서 파생한다. 경계값을 두 번 적지 않아 시작과 끝이 어긋날 여지 자체를 없앤다.

```java
@Getter
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public enum Level {

    LEVEL_1(1, 0),
    LEVEL_2(2, 100),
    LEVEL_3(3, 200),
    LEVEL_4(4, 400),
    LEVEL_5(5, 700),
    LEVEL_6(6, 1100),
    LEVEL_7(7, 1600),
    LEVEL_8(8, 2200),
    LEVEL_9(9, 2900),
    LEVEL_10(10, 3700);

    private final int level;
    private final int startXp;
}
```

메서드:

- `public static Level fromXp(int totalXp)` — `startXp <= totalXp`를 만족하는 마지막 상수를 반환한다. 음수 XP는 `LEVEL_1`로 떨어져 기존 `totalXp < 100 -> 1` 동작과 같다.
- `public static Level fromLevel(int level)` — `level` 값이 일치하는 상수를 반환하고, 없으면 `IllegalArgumentException`을 던진다.
- `public boolean isMax()` — `ordinal() == values().length - 1`. 상한 10이 코드에서 사라지고 enum 마지막 값으로 결정된다.
- `public int getEndXp()` — `values()[ordinal() + 1].startXp`. 최고 레벨은 상한이 없으므로 `IllegalStateException`을 던진다. 두 호출부 모두 `isMax()`로 먼저 걸러내며, 예외는 도달 불가능한 내부 불변식 위반을 드러내기 위한 방어다. 사용자에게 노출되는 오류가 아니므로 `RestApiException`을 쓰지 않는다.

`values()`는 호출마다 배열을 복제하므로 `private static final Level[] VALUES = values();`를 선언해 재사용한다.

### 6-2. `UserLevel` 수정

`calculateLevel(Integer)`와 `getMaxXp(int)`는 삭제한다. 각각 `Level.fromXp(...).getLevel()`, `Level.getEndXp()` 한 줄로 흡수되어 별도 메서드로 남길 이유가 없다.

```java
private static final double MAX_RATE = 100.0;

public UserLevelDetailResponse getUserLevelDetail() {
    Level currentLevel = Level.fromLevel(this.level);
    int maxXp = currentLevel.isMax() ? this.xp : currentLevel.getEndXp();

    return UserLevelDetailResponse.of(
            this.level,
            this.xp,
            maxXp,
            calculateLevelRate(this.xp)
    );
}

private void updateLevel(int totalXp) {
    this.level = Level.fromXp(totalXp).getLevel();
}

private double calculateLevelRate(int xp) {
    Level currentLevel = Level.fromXp(xp);
    if (currentLevel.isMax()) {
        return MAX_RATE;
    }

    int startXp = currentLevel.getStartXp();
    double rate = ((double) (xp - startXp) / (currentLevel.getEndXp() - startXp)) * MAX_RATE;
    return Math.round(rate * 10) / 10.0;
}
```

- `calculateLevelRate`는 `public` -> `private`. 전체 검색 결과 `getUserLevelDetail` 외 호출부가 없어 공개할 이유가 없다.
- `getUserLevelDetail`은 기존과 동일하게 `this.level` 기준으로 `maxXp`를 구한다(`this.xp` 기준으로 바꾸지 않는다). `level`은 `updateXp` -> `updateLevel` 경로로만 갱신되어 `xp`와 항상 일치하므로 결과는 같지만, 기준을 바꾸지 않아야 회귀 여지가 없다.
- `calculateLevel`의 반환 타입이 `Integer`였던 불필요한 박싱도 함께 사라진다.

### 6-3. 동작 보존 확인표

| 입력 | 기존 | 변경 후 |
|---|---|---|
| xp 0 | level 1, rate 0.0 | 동일 |
| xp 99 -> 100 | level 1 -> 2 | 동일 |
| xp 3699 -> 3700 | level 9 -> 10 | 동일 |
| xp 5000 (레벨 10) | rate 100.0, maxXp = xp | 동일 |
| level 9, xp 2900 | maxXp 3700, rate 0.0 | 동일 |
| **level 0 또는 11 이상 (범위 밖)** | **`getMaxXp`가 fall-through로 3700 반환, 예외 없음** | **`Level.fromLevel`이 `IllegalArgumentException`** |

마지막 행은 유일한 동작 변경이다. 기존 `getMaxXp`는 `if` 사슬을 전부 빠져나가면 `return 3700`으로 떨어져, DB에 범위 밖 레벨이 들어와도 조용히 잘못된 `maxXp`를 응답했다. 변경 후에는 예외가 올라가 `@ExceptionHandler(Exception.class)`가 `INTERNAL_SERVER_ERROR`로 응답한다.

정상 경로로는 도달할 수 없다(`level`은 `updateXp` -> `updateLevel`로만 갱신되어 항상 1~10). 도달한다면 QA 데이터 초기화, 어드민 도구, 직접 SQL 등으로 데이터가 깨진 경우이며, 깨진 데이터를 조용히 감추기보다 드러내는 편이 낫다고 판단해 이 변경을 수용한다.

## 추가 반영 (당초 범위 밖이었으나 이번 작업에 포함)
- `UserLevelResponse.create`가 `nextLevel = level + 1`로 계산해, 최고 레벨 10에서 존재하지 않는 11을 응답하고 있었다. 레슨 제출 완료 응답에 실려 나가는 값이라 유저에게 그대로 노출된다.
- 상한 판단이 `Level`로 모인 김에 같이 고친다. `Level.next()`를 추가해 최고 레벨이면 자기 자신을 반환하게 하고, `UserLevelResponse.create`가 이를 사용한다. 상한이 다시 DTO에 하드코딩되지 않도록 구간표와 같은 출처를 쓰는 것이 핵심이다.
- 응답 필드 타입과 필수 여부는 그대로다(`int nextLevel`, REQUIRED). 최고 레벨에서 11 대신 10이 나가는 값 변경만 있다.

## 결정 필요 (Decisions needed)
- [x] `Level` enum이 구간을 선언하는 방식 -> **A) `(level, startXp)`만 선언하고 끝 XP는 다음 상수에서 파생.** 경계값이 코드 전체에 한 번만 등장해 시작과 끝이 어긋날 여지가 원천 차단되고, 최고 레벨은 다음 상수가 없다는 사실로 `isMax()`가 자연히 결정된다. (이슈 본문의 `(level, startXp, endXp)` 표현에서 한 단계 더 줄인 형태)

## 검증
- 대상 테스트: `UserLevelTest` (신규, `InquiryTest`와 같은 순수 POJO 도메인 테스트 형식 - Spring 컨텍스트와 Mockito 없이 `@Nested` + `@DisplayName` + AssertJ)
  - `@DisplayName("XP로 레벨을 계산할 때")` — 구간 경계 0/99/100/3699/3700, 최고 레벨 초과 XP
  - `@DisplayName("레벨 상세를 조회할 때")` — 중간 레벨의 `maxXp`와 `levelRate`, 최고 레벨의 `maxXp == xp`와 `levelRate == 100.0`
  - `@DisplayName("XP를 누적할 때")` — `updateXp` 호출로 레벨이 올라가는지, 누적 XP가 유지되는지
- 회귀 확인: `./gradlew test --tests "*UserLevel*" --tests "*LessonFacade*" --tests "*UserServiceIntegration*"` 이후 `./gradlew build`

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
