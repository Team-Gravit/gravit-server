# [PLAN-498] 연속 학습일 정산 방식 단순화

> 이슈: #498
> 브랜치: refactor/498-consecutive-days-batch

## 목표

연속 학습일 정산에서 두 가지 과잉 구현을 걷어낸다. 전 유저 `Learning` 엔티티를 적재하는 배치를 단일 벌크 `UPDATE`로 바꾸고, 지키는 것보다 잃는 게 큰 낙관적 락을 제거한다.

## 배경

### 왜 벌크 UPDATE 한 발로 대체 가능한가

`Learning.updateConsecutiveDays()`의 분기는 다음 두 갈래다.

| 진입 상태 | `today_solved` | `consecutive_solved_days` |
|---|---|---|
| `todaySolved = true` | `false`로 내림 | 유지 |
| `todaySolved = false` | `false` 유지 | `0`으로 초기화 |

두 갈래 모두 결과의 `today_solved`가 `false`다. 분기는 `consecutive_solved_days`에만 남고 `CASE` 한 개로 표현된다. SQL의 `SET` 우변은 모두 갱신 전 행 값을 기준으로 평가되므로, 같은 문장에서 `today_solved`를 `false`로 내리면서 `CASE WHEN today_solved ...`로 갱신 전 값을 읽는 것이 안전하다.

### 왜 낙관적 락을 제거하는가

`learning.user_id`가 UNIQUE라 한 행에 동시 접근 가능한 주체는 (a) 같은 유저의 동시 요청, (b) 자정 배치, 둘뿐이다. 유저 간 경합은 구조적으로 불가능하다.

**케이스 A - 같은 유저의 동시 레슨 제출** (더블탭, 재시도, 두 기기)

- 락 없음: 양쪽이 `todaySolved=false, days=5`를 읽고 양쪽이 `6`을 쓴다. 최종 `6`으로, `연속 학습일은 하루에 한 번만 오른다` 정책과 일치한다.
- 락 있음: 한쪽이 `OptimisticLockException`. 이 지점이 `LessonFacade:94`의 `transactionTemplate.execute` 안이라 레슨 제출, 문제 제출, 오답노트, XP가 통째로 롤백된다.

**케이스 B - 자정 배치와 제출이 겹칠 때**

- 락 없음: 유저의 갱신 전 값 쓰기가 배치의 초기화를 덮어써 그 유저 연속일수가 하루치 후하게 남고, 다음 날 밤 자동 수렴한다.
- 락 있음: 유저의 레슨 제출이 통째로 실패한다.

두 케이스 모두 락이 막는 건 틀린 값이 아니라 요청 자체다. 낙관적 락은 올바른 값을 계산해주지 않고 거절할 뿐인데, 거절의 대가가 레슨 제출 유실이고 거절하지 않았을 때의 오차는 자기수렴한다. 이 근거는 트래픽이 늘어도 뒤집히지 않는다.

정황도 같은 방향이다. `Learning`은 코드베이스에서 `@Version`을 가진 유일한 엔티티고, `version` 값을 읽는 비즈니스 코드가 없으며, 도입 커밋이 `hotfix: 누락된 version 어노테이션 추가`(765fd99c, 1줄)로 `V1__init_tables.sql`부터 있던 `NOT NULL` 컬럼을 메우려 붙은 것이지 동시성 설계의 결과가 아니다.

### 감수하는 것

락을 빼면 `planetConquestRate`에 lost update가 생긴다. 동시 제출 시 두 트랜잭션이 모두 증가 전 정복률을 계산해 저장할 수 있다. 다음 제출 때 재계산되어 수렴하고, 락이 있어도 이 값이 맞게 되는 게 아니라 요청이 실패할 뿐이므로 받아들인다.

## 영향 범위

### 신규 파일

- `src/main/resources/db/migration/V39__relax_learning_version.sql` — `learning.version`에 `DEFAULT 0` 부여

### 수정 파일

- `src/main/java/gravit/code/learning/domain/Learning.java` — `@Version version` 필드와 빌더의 `this.version = 0L` 제거, 호출자가 사라지는 `updateConsecutiveDays()` 제거
- `src/main/java/gravit/code/learning/repository/LearningRepository.java` — 벌크 UPDATE `resetConsecutiveDays()` 추가, `@Lock(OPTIMISTIC) findAll()` 오버라이드 제거
- `src/main/java/gravit/code/learning/service/LearningCommandService.java` — `updateConsecutiveDays()` 본문을 벌크 UPDATE 호출로 교체, 갱신 행 수 로깅 추가
- `src/test/java/gravit/code/learning/service/LearningCommandServiceIntegrationTest.java` — 정산 회귀 테스트 추가
- `.claude/spec/service-policy/learning.md` — 정책 변경 없음. 수정하지 않는다 (아래 "정책 확인" 참조)

## 구현 계획

### 1. Entity / Flyway

**`V39__relax_learning_version.sql` 신규 작성**

```sql
-- V39__relax_learning_version.sql

-- Learning의 낙관적 락을 제거하면서 @Version 매핑이 사라진다.
-- 컬럼을 지금 드롭하면 rollback-prod가 예전 이미지를 되돌릴 때
-- Flyway는 되감기지 않아 예전 코드의 learning INSERT/UPDATE가 전부 깨진다.
-- 이번엔 기본값만 주어 매핑 없는 INSERT가 NOT NULL을 만족하게 하고,
-- 컬럼 드롭은 배포 안정화 확인 후 후속 이슈로 분리한다.
ALTER TABLE learning
    ALTER COLUMN version SET DEFAULT 0;
```

- 컬럼은 `NOT NULL`을 유지한다. 신규 코드는 `version`을 매핑하지 않으므로 INSERT 문에서 빠지고 `DEFAULT 0`이 채운다.
- 기존 행은 손대지 않는다. 값이 남아 있어도 읽는 코드가 없다.
- 롤백 시 예전 이미지는 `version`을 명시적으로 쓰므로 그대로 동작한다.

**`Learning.java` 수정**

```java
// 제거
@Version
@Column(nullable = false)
private long version;

// 빌더 본문에서 제거
this.version = 0L;

// 제거 - src 전체에서 호출자가 사라진다
public void updateConsecutiveDays(){ ... }
```

`jakarta.persistence.Version` import를 함께 지운다. `updateLearningStatus()`는 그대로 둔다.

`updateConsecutiveDays()`를 남기면 같은 규칙이 엔티티와 쿼리 두 곳에 중복 존재하게 되므로 제거한다. 이 메서드의 진리표는 아래 회귀 테스트가 대신 붙든다.

### 2. Repository

`LearningRepository`에 추가:

```java
@Modifying(clearAutomatically = true)
@Query(value = """
    UPDATE learning
    SET consecutive_solved_days = CASE WHEN today_solved THEN consecutive_solved_days ELSE 0 END,
        today_solved            = FALSE
    WHERE today_solved = TRUE OR consecutive_solved_days <> 0
    """, nativeQuery = true)
int resetConsecutiveDays();
```

- `version` 증가 없음. 낙관적 락을 제거하므로 배치가 버전을 만질 이유가 없다.
- `WHERE` 절은 갱신 대상 축소용이다. 이미 `today_solved = false`이고 `consecutive_solved_days = 0`인 행(장기 미학습 유저)은 갱신해도 값이 같아 쓰기와 WAL만 낭비한다. 결과는 동일하고 갱신 행 수만 줄어든다.
- 반환값은 갱신 행 수. 배치 관측에 쓴다.
- 인덱스는 추가하지 않는다. 전 행을 훑는 배치라 Seq Scan이 유리하고, 하루 1회 실행에 부분 인덱스 유지 비용을 얹을 이유가 없다.

`LearningRepository`에서 제거:

```java
@Lock(LockModeType.OPTIMISTIC)
List<Learning> findAll();
```

유일한 호출자가 `updateConsecutiveDays()`였다 (`TestScenarioController`는 `findByUserId`만 쓴다). `jakarta.persistence.LockModeType`, `org.springframework.data.jpa.repository.Lock` import를 함께 지운다. `java.util.List`는 `findConsecutiveAtRiskUsers`, `findDailyIncompleteUserIds`가 계속 쓰므로 남긴다.

### 3. Service

`LearningCommandService`에 `@Slf4j`를 붙이고 `updateConsecutiveDays()`를 교체한다.

```java
@Transactional
public void updateConsecutiveDays(){
    int resetCount = learningRepository.resetConsecutiveDays();

    log.info("연속 학습일 정산 완료 - 갱신 행 수: {}", resetCount);
}
```

- `@Transactional`은 유지한다. 단일 문장이라 트랜잭션 길이가 행 수와 무관하게 고정된다.
- `java.util.List` import를 지운다. `Learning`은 `createLearning`이 계속 쓰므로 남긴다.
- `MissionService.assignChunk`가 청크 결과를 `log.info`로 남기는 것과 같은 결로 배치 관측 지점을 남긴다.

### 4. Facade

불필요 - 단일 도메인 Service. `LearningScheduler`는 그대로 `LearningCommandService.updateConsecutiveDays()`를 호출하며 변경 없다. `LessonFacade`도 `updateLearningStatus` 시그니처가 그대로라 변경 없다.

### 5. DTO

없음. `ConsecutiveSolvedDto`는 그대로다.

### 6. Controller

없음. 스케줄러 전용 경로다.

## 정책 확인

`.claude/spec/service-policy/learning.md`의 해당 항목:

> 연속 학습일은 매일 자정 직후에 정산한다. 그날 학습하지 않았으면 0으로 초기화하고, 학습했으면 다음 날 판정을 위해 표시만 지운다.

벌크 UPDATE의 결과가 이 문장과 정확히 일치한다. 낙관적 락 제거도 사용자에게 드러나는 규칙을 바꾸지 않는다 (동시 제출 시 연속일수가 1만 오르는 것은 기존 정책 그대로다). **정책 변경 없음 - 정책 파일은 손대지 않는다.**

21시 알림 배치(`NotificationScheduler.sendConsecutiveLearningWarnings`)가 쓰는 `findConsecutiveAtRiskUsers`는 `todaySolved`, `consecutiveSolvedDays`를 조회만 하고 실행 시각(21:00)이 정산 시각(00:01)과 겹치지 않으므로 영향 없다.

## 배포 시 주의

- 배포는 `docker-compose up -d --no-deps --force-recreate` 단일 컨테이너 재생성이라 구/신 버전이 동시에 뜨는 구간이 없다. V39는 신규 컨테이너 기동 시 적용된다.
- `rollback-prod.yml`은 예전 이미지를 pull해 재생성하며 Flyway를 되감지 않는다. V39가 `DEFAULT`만 주고 컬럼을 남기는 이유가 이것이다. **후속 이슈에서 컬럼을 드롭하기 전에 이 배포가 안정적으로 돌고 있음을 확인해야 한다.**
- `ddl-auto`는 dev/prod 모두 `none`이라 매핑 없는 잔여 컬럼이 문제되지 않는다. 로컬 `application.yml`은 `update`지만 Hibernate `update`는 컬럼을 드롭하지 않는다.

## 결정 필요 (Decisions needed)

- [x] 낙관적 락을 이번 이슈에서 함께 제거할지 - **제거한다.** 벌크 UPDATE의 `version = version + 1`이 `@Version` 때문에만 존재하는 줄이라, 분리하면 썼다 지우게 된다
- [x] `version` 컬럼 드롭 시점 - **2단계.** 이번 V39는 `DEFAULT 0`만 주고, 컬럼 드롭은 배포 안정화 확인 후 후속 이슈로 분리한다 (롤백 호환)

## 검증

대상: `LearningCommandServiceIntegrationTest`에 `@Nested @DisplayName("연속 학습일을 정산할 때")` 추가.

| 시나리오 | 검증 |
|---|---|
| `오늘_학습한_유저는_연속일수가_유지되고_표시만_지워진다()` | `todaySolved=true, days=5` 저장 → 정산 → `todaySolved=false`, `days=5` |
| `오늘_미학습_유저는_연속일수가_0으로_초기화된다()` | `todaySolved=false, days=5` 저장 → 정산 → `todaySolved=false`, `days=0` |
| `이미_초기화된_유저는_갱신하지_않는다()` | `todaySolved=false, days=0` 저장 → `resetConsecutiveDays()` 반환값이 해당 행을 세지 않음 |
| `여러_유저를_한_번에_정산한다()` | 위 세 상태를 섞어 저장 → 한 번 호출로 각각 기대값대로 갱신, 반환값 확인 |
| `같은_날_두_번_제출해도_연속일수는_한_번만_오른다()` | `updateLearningStatus`를 연속 2회 호출 → `days`가 1만 증가. 락 제거 후에도 정책이 유지되는지 확인 |

작성 시 유의:
- 테스트 클래스는 `@Transactional`이 아니므로 저장과 재조회가 각각 별도 트랜잭션이다. 벌크 UPDATE 이후 `findByUserId`로 다시 읽으면 DB 실제 값이 온다.
- `LearningFixture.오늘_학습한_학습(id, userId, days)`은 `ReflectionTestUtils`로 `id`를 박아두므로 `save` 시 IDENTITY와 충돌할 수 있다. `Learning.create(userId)` 저장 후 `setField`로 상태를 바꿔 다시 `save`하거나, 픽스처에 id 미지정 변형을 추가하는 쪽으로 잡는다 (구현 시 확정).
- 회귀 방향은 "벌크 UPDATE가 제거되는 엔티티 분기와 같은 결과를 내는가"다.
- **테스트는 V39를 검증하지 못한다.** `application-test.yml`이 `ddl-auto: create` + `flyway.enabled: false`라 테스트 스키마는 엔티티에서 생성되며 `version` 컬럼 자체가 없다. V39의 `DEFAULT 0`은 배포 대상 스키마에서만 의미가 있으므로, 마이그레이션은 `./gradlew build`의 `flyway validate`와 dev 배포로 확인한다.

전체 실행: `./gradlew build` (flyway validate 포함) → `./gradlew test`

## Deviation Log

- `LearningFixture.java`: `저장_전_학습(userId, todaySolved, consecutiveDays)` 픽스처를 추가했다 — 이유: 계획서가 "구현 시 확정"으로 남긴 항목. 기존 `오늘_학습한_학습`은 `ReflectionTestUtils`로 `id`를 박아둬 `save()` 시 IDENTITY와 충돌하므로, id를 세팅하지 않는 변형이 필요했다
- `LearningCommandServiceIntegrationTest.java`: `resetConsecutiveDays()`를 직접 호출하는 두 테스트를 `TransactionTemplate.execute`로 감쌌다 — 이유: `@Modifying` 쿼리는 트랜잭션을 요구해 테스트에서 레포지토리를 바로 부르면 `TransactionRequiredException`이 난다. 갱신 행 수 반환값을 검증해야 해서 `@Transactional` 서비스 경유로는 대체할 수 없었다
