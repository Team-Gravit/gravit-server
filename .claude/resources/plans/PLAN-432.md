# [PLAN-432] 트랜잭션 이벤트 리스너 phase × propagation × 동기/비동기 조합 동작 실증

> 이슈: #432
> 브랜치: analysis/432-tx-event-listener-combination

## 목표

`@TransactionalEventListener`의 `phase` × `@Transactional`의 `propagation` × `@Async` 사용 여부 5개 조합이 실제로 어떤 트랜잭션·스레드 경계에서 실행되는지를, 테스트 전용 fixture로 재현해 **데이터 잔존 / 트랜잭션 경계 / 스레드 경계 / 예외 전파 방향** 네 축으로 관찰한다.
권장 3조합이 설명대로 동작하는지, 안티패턴 2조합이 실제로 부작용을 내는지를 실행 가능한 증거로 남긴다. 프로덕션 코드는 변경하지 않는다.

## 영향 범위

### 신규 파일

모두 `src/test/java/gravit/code/experiment/txevent/` 하위. 프로덕션 소스는 한 줄도 건드리지 않는다.

| 경로 | 역할 |
| --- | --- |
| `fixture/ExperimentRecord.java` | 실험용 `@Entity`. `id`(IDENTITY) + `tag`. 쓰기가 실제로 커밋됐는지 판별하는 유일한 관찰 대상 |
| `fixture/ExperimentRecordRepository.java` | `JpaRepository<ExperimentRecord, Long>`. `existsByTag` |
| `fixture/ExperimentEvent.java` | 이벤트 계약 인터페이스 + 조합별 중첩 `record` 5종 |
| `fixture/ExperimentPublisher.java` | `@Transactional` 원본 트랜잭션 보유자. 원본 행 저장 후 이벤트 발행 |
| `fixture/ExecutionTrace.java` | 실행 시점의 스레드명·트랜잭션명·활성 여부 스냅샷 `record` |
| `fixture/TraceRecorder.java` | 스레드 안전 관찰 수집기 (trace / error / flag) |
| `fixture/ExperimentGate.java` | 안티패턴 2 전용. 원본 트랜잭션을 미커밋 상태로 붙잡아 두는 래치 |
| `listener/BeforeCommitSyncRequiredListener.java` | 권장 ① |
| `listener/AfterCommitSyncNewTxListener.java` | 권장 ② |
| `listener/AfterCommitAsyncNewTxListener.java` | 권장 ③ |
| `listener/AfterCommitSyncRequiredListener.java` | 안티패턴 ④ |
| `listener/BeforeCommitAsyncNewTxListener.java` | 안티패턴 ⑤ (+ 게이트 리스너) |
| `ExperimentFixtureConfig.java` | `@TestConfiguration`. 위 빈들 + `experimentAsync` Executor 등록 |
| `RecommendedCombinationIntegrationTest.java` | 권장 3조합 검증 |
| `AntiPatternCombinationIntegrationTest.java` | 안티패턴 2조합 검증 |

### 수정 파일

- `build.gradle` (112~114행) — `test` 태스크에 `excludeTags 'experiment'` 추가, `experimentTest` 태스크 신설
- `.github/workflows/ci-common.yml` — **수정 불필요**. `./gradlew --info test`가 태그 제외로 자동 스킵된다

## 구현 계획

### 1. Entity / Flyway

**Flyway 마이그레이션 불필요.** test 프로파일이 `ddl-auto: create` + `flyway.enabled: false`이므로(`src/test/resources/application-test.yml:9,22`) 엔티티만 정의하면 `experiment_record` 테이블이 컨텍스트 기동 시 생성된다. `DatabaseCleaner`가 `pg_tables`를 동적으로 훑어 TRUNCATE하므로 정리도 자동이다.

```java
@Entity
@Table(name = "experiment_record")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ExperimentRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String tag;

    private ExperimentRecord(String tag) { this.tag = tag; }

    public static ExperimentRecord create(String tag) { return new ExperimentRecord(tag); }
}
```

`GenerationType.IDENTITY`로 고정한다 (프로덕션 엔티티 29곳 전부 IDENTITY). IDENTITY는 `persist()` 시점에 INSERT를 즉시 발행하므로, 안티패턴 ④에서 "INSERT는 실행됐는데 커밋되지 않아 유실"되는 경로가 그대로 재현된다.

> **부작용 (수용)**: `gravit.code` 하위 `@Entity`·`Repository`는 엔티티/리포지토리 스캔 대상이라 모든 통합 테스트 컨텍스트에 등록된다. `ddl-auto: create`라 빈 테이블 하나가 더 생길 뿐이고, 테스트 소스는 jar에 포함되지 않으므로 프로덕션 영향은 없다.

### 2. Repository

```java
public interface ExperimentRecordRepository extends JpaRepository<ExperimentRecord, Long> {
    boolean existsByTag(String tag);
}
```

### 3. 이벤트 — 조합별로 타입을 분리한다

5개 리스너가 한 이벤트를 공유하면 전부 발화해 조합을 격리할 수 없다. 인터페이스 + 중첩 record로 한 파일에 모은다.

```java
public interface ExperimentEvent {

    String originTag();
    String listenerTag();
    boolean listenerThrows();

    record BeforeCommitSyncRequired(String originTag, String listenerTag, boolean listenerThrows) implements ExperimentEvent {}
    record AfterCommitSyncNewTx(String originTag, String listenerTag, boolean listenerThrows) implements ExperimentEvent {}
    record AfterCommitAsyncNewTx(String originTag, String listenerTag, boolean listenerThrows) implements ExperimentEvent {}
    record AfterCommitSyncRequired(String originTag, String listenerTag, boolean listenerThrows) implements ExperimentEvent {}
    record BeforeCommitAsyncNewTx(String originTag, String listenerTag, boolean listenerThrows) implements ExperimentEvent {}
}
```

### 4. 관찰용 fixture

`ExecutionTrace` — 실행 시점 스냅샷. **`getCurrentTransactionName()`이 조합을 가르는 핵심 신호**다. 원본 트랜잭션에 참여하면 발행자 메서드의 FQN이, 신규 트랜잭션이면 리스너 메서드의 FQN이 담긴다.

```java
public record ExecutionTrace(
        String label,
        String threadName,
        String transactionName,
        boolean actualTransactionActive,
        boolean synchronizationActive
) {
    public static ExecutionTrace here(String label) {
        return new ExecutionTrace(
                label,
                Thread.currentThread().getName(),
                TransactionSynchronizationManager.getCurrentTransactionName(),
                TransactionSynchronizationManager.isActualTransactionActive(),
                TransactionSynchronizationManager.isSynchronizationActive()
        );
    }
}
```

`TraceRecorder` — 비동기 리스너가 다른 스레드에서 쓰므로 전부 동시성 컬렉션.

```java
public class TraceRecorder {

    private final Map<String, ExecutionTrace> traces = new ConcurrentHashMap<>();
    private final Map<String, Throwable> errors = new ConcurrentHashMap<>();
    private final Map<String, Boolean> flags = new ConcurrentHashMap<>();

    public void capture(String label);              // traces.put(label, ExecutionTrace.here(label))
    public void captureError(String label, Throwable error);
    public void putFlag(String key, boolean value);

    public ExecutionTrace trace(String label);
    public Optional<Throwable> error(String label);
    public boolean flag(String key);
    public void reset();
}
```

`ExperimentGate` — 안티패턴 ⑤ 전용. `CountDownLatch`를 `volatile`로 들고 `reset()`에서 새로 만든다.

```java
public class ExperimentGate {
    private volatile CountDownLatch listenerRead = new CountDownLatch(1);

    public void signalListenerRead();
    public boolean awaitListenerRead(long timeout, TimeUnit unit);   // InterruptedException 삼키고 false 반환
    public void reset();
}
```

### 5. 원본 트랜잭션 보유자

```java
public class ExperimentPublisher {

    private final ExperimentRecordRepository repository;
    private final ApplicationEventPublisher eventPublisher;
    private final TraceRecorder recorder;

    @Transactional
    public void publish(ExperimentEvent event) {
        recorder.capture("origin");

        repository.save(ExperimentRecord.create(event.originTag()));

        eventPublisher.publishEvent(event);
    }
}
```

원본 행을 **먼저 저장**해야 안티패턴 ⑤에서 비동기 리스너가 "커밋 전이라 안 보이는" 것을 관찰할 수 있다.

### 6. 리스너 5종

모든 리스너는 `recorder.capture("listener")` → `repository.save(listenerTag)` → `listenerThrows`면 `IllegalStateException`을 던지는 동일 골격이다. 조합마다 **어노테이션만 다르다.** 이게 조합 외 변수를 통제한다는 뜻이다.

| # | 클래스 | 어노테이션 |
| --- | --- | --- |
| ① | `BeforeCommitSyncRequiredListener` | `@TransactionalEventListener(BEFORE_COMMIT)` + `@Transactional(REQUIRED)` |
| ② | `AfterCommitSyncNewTxListener` | `@TransactionalEventListener(AFTER_COMMIT)` + `@Transactional(REQUIRES_NEW)` |
| ③ | `AfterCommitAsyncNewTxListener` | `@Async("experimentAsync")` + `@TransactionalEventListener(AFTER_COMMIT)` + `@Transactional(REQUIRES_NEW)` |
| ④ | `AfterCommitSyncRequiredListener` | `@TransactionalEventListener(AFTER_COMMIT)` + `@Transactional(REQUIRED)` |
| ⑤ | `BeforeCommitAsyncNewTxListener` | `@Async("experimentAsync")` + `@TransactionalEventListener(BEFORE_COMMIT)` + `@Transactional(REQUIRES_NEW)` |

비동기(③⑤)는 예외가 `@Async`에 삼켜져 사라지므로, **기록 후 재던지기**로 삼켜지는 경로 자체를 보존한다.

```java
try {
    ...
    if (event.listenerThrows()) throw new IllegalStateException("listener failed");
} catch (Exception e) {
    recorder.captureError("listener", e);
    throw e;
}
```

⑤는 리스너 한 개로는 부족하다. `@Async`가 즉시 반환하면 원본은 곧장 커밋해버려 "커밋 전"이라는 창이 사라진다. **같은 클래스에 게이트 리스너를 하나 더 둔다.**

```java
public class BeforeCommitAsyncNewTxListener {

    @Order(1)
    @Async("experimentAsync")
    @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handle(ExperimentEvent.BeforeCommitAsyncNewTx event) {
        try {
            recorder.capture("listener");
            recorder.putFlag("originVisibleToListener", repository.existsByTag(event.originTag()));
            repository.save(ExperimentRecord.create(event.listenerTag()));

            if (event.listenerThrows()) throw new IllegalStateException("listener failed");
        } catch (Exception e) {
            recorder.captureError("listener", e);
            throw e;
        } finally {
            gate.signalListenerRead();
        }
    }

    // @Order(1)이 비동기 위임 후 즉시 반환하므로, 원본 스레드를 여기서 붙잡아
    // 비동기 리스너가 "원본 미커밋 상태"를 관찰할 창을 연다.
    @Order(2)
    @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
    public void holdOriginUncommitted(ExperimentEvent.BeforeCommitAsyncNewTx event) {
        gate.awaitListenerRead(2, TimeUnit.SECONDS);
    }
}
```

- `@Order`는 메서드에 붙이면 `ApplicationListenerMethodAdapter`가 읽어 리스너 순서를 정한다.
- `@Async`는 메서드 단위이므로 `holdOriginUncommitted`는 원본 스레드에서 동기 실행된다.
- `signalListenerRead()`를 `finally`에 두어 예외 케이스에서도 게이트가 반드시 풀린다. `awaitListenerRead`는 타임아웃을 둬 데드락을 막는다.
- `originVisibleToListener`는 **false**여야 한다. 별도 스레드의 `REQUIRES_NEW`는 별도 커넥션이고, 원본 INSERT는 아직 미커밋이라 READ_COMMITTED에서 보이지 않는다.

### 7. `@TestConfiguration`

```java
@TestConfiguration(proxyBeanMethods = false)
public class ExperimentFixtureConfig {

    @Bean TraceRecorder traceRecorder();
    @Bean ExperimentGate experimentGate();
    @Bean ExperimentPublisher experimentPublisher(...);
    @Bean BeforeCommitSyncRequiredListener ...;   // 5종
    ...

    @Bean(name = "experimentAsync")
    public Executor experimentAsyncExecutor() {   // corePoolSize 2 / maxPoolSize 4 / prefix "ExperimentAsync-"
    }
}
```

- `@TestConfiguration`은 Spring Boot의 `TypeExcludeFilter`가 컴포넌트 스캔에서 제외하므로, **`@Import`한 테스트에서만** 리스너가 등록된다. 다른 통합 테스트 컨텍스트를 오염시키지 않는다.
- `@Async`는 프로덕션 `AsyncConfig`의 `@EnableAsync`가 이미 켜두었다. 전용 Executor를 따로 두는 이유는 ⑤의 게이트 핸드셰이크가 프로덕션 풀 포화에 걸려 굶지 않게 하고, 스레드명 접두사로 스레드 경계를 명확히 assert하기 위함이다.
- `@Transactional`/`@Async` 프록시가 CGLIB로 걸리므로 fixture 클래스·메서드를 `final`로 두지 마라.

### 8. 테스트

두 클래스 모두 `@TCSpringBootTest` + `@Import(ExperimentFixtureConfig.class)` + `@Tag("experiment")`.
**테스트 메서드에 `@Transactional`을 절대 붙이지 마라.** 붙이면 롤백되어 `AFTER_COMMIT`이 발화하지 않고, 검증 조회도 같은 트랜잭션 안에서 이뤄져 "실제로 커밋됐는가"를 판별할 수 없다. 검증 조회(`existsByTag`)는 테스트에 트랜잭션이 없으므로 각각 새 트랜잭션에서 실행되어 커밋된 상태만 본다.

`@BeforeEach`에서 `recorder.reset()` / `gate.reset()`.

#### `RecommendedCombinationIntegrationTest`

| `@Nested` | 시나리오 | 핵심 assert |
| --- | --- | --- |
| ① BEFORE_COMMIT + 동기 + REQUIRED | 정상 | 원본·리스너 행 **둘 다 존재** / `listener.transactionName() == origin.transactionName()` (동일 tx 참여) / 스레드 동일 |
| | 리스너 예외 | `publish()`가 예외를 던짐 / 원본·리스너 행 **둘 다 부재** (원자적 롤백) |
| ② AFTER_COMMIT + 동기 + REQUIRES_NEW | 정상 | 둘 다 존재 / `transactionName` **다름** (신규 tx) / 스레드 동일 |
| | 리스너 예외 | ~~`publish()`가 예외를 던짐(요청 스레드로 전파)~~ → **실측 결과 전파되지 않음**. 아래 "관측 결과 ②" 참조 |
| ③ AFTER_COMMIT + 비동기 + REQUIRES_NEW | 정상 | Awaitility로 대기 후 둘 다 존재 / `transactionName` 다름 / 스레드명이 `ExperimentAsync-` 로 시작 |
| | 리스너 예외 | `publish()`가 **예외를 던지지 않음** / 원본 행 생존 / `recorder.error("listener")` 존재 (삼켜짐 증명) |

#### `AntiPatternCombinationIntegrationTest`

| `@Nested` | 핵심 assert |
| --- | --- |
| ④ AFTER_COMMIT + 동기 + REQUIRED | `publish()` 예외 없음 / **원본 행 존재 + 리스너 행 부재** (예외 없이 쓰기 유실) / `listener.actualTransactionActive() == true` 이면서 `listener.transactionName() == origin.transactionName()` → **이미 커밋된 원본 트랜잭션에 참여했다는 직접 증거** |
| ⑤ BEFORE_COMMIT + 비동기 + REQUIRES_NEW (정상) | 스레드 다름 / `transactionName` 다름 / `flag("originVisibleToListener") == false` → **"커밋 전 실행"이 무의미함** |
| ⑤ (리스너 예외) | `publish()` 예외 없음 / **원본 행 생존** → ①과 대조되어 **"원본 개입" 보장이 사라졌음** |

> ④는 DB·드라이버 거동에 따라 예외 없는 쓰기 유실이 아니라 예외로 나타날 수도 있다. 계획 단계에서 결과를 단정하지 말고, **먼저 실행해 실제 거동을 관찰한 뒤 그 거동을 assert로 고정**하고 분석에 기록한다. 어느 쪽이든 "리스너 행이 남지 않는다"는 결론은 동일하므로, 행 부재를 1차 단언으로 두고 예외 발생 여부는 `recorder.error("listener")`로 부수 기록한다.

### 9. CI 제외 — `build.gradle`

```groovy
tasks.named('test') {
    useJUnitPlatform {
        excludeTags 'experiment'
    }
}

tasks.register('experimentTest', Test) {
    group = 'verification'
    description = '트랜잭션 이벤트 리스너 조합 실증 테스트 (CI 기본 실행 제외)'

    testClassesDirs = sourceSets.test.output.classesDirs
    classpath = sourceSets.test.runtimeClasspath

    useJUnitPlatform {
        includeTags 'experiment'
    }

    shouldRunAfter tasks.named('test')
    testLogging { showStandardStreams = true }
}
```

`experimentTest`는 `check`/`build`에 연결하지 않는다. CI(`ci-common.yml:25`)는 `./gradlew --info test`를 그대로 돌리므로 태그 제외만으로 스킵된다 — 워크플로 수정 불필요. 로컬 실행은 `./gradlew experimentTest`.

## 결정 필요 (Decisions needed)

- [x] **fixture 빈 등록 방식** — `@TestConfiguration` + `@Import` (`@Component` 스캔 아님).
  `@Component`면 모든 통합 테스트 컨텍스트에 안티패턴 리스너가 상주한다. `@Import`는 컨텍스트를 포크시켜 Testcontainer가 하나 더 뜨지만, CI에서 제외되는 실험이라 비용은 로컬에 한정된다. 격리를 택한다.
- [x] **`excludeTags`를 `test` 태스크에 건다** — 로컬 `./gradlew test`에서도 제외된다. CI에만 거는 방식(`-P` 플래그)보다 단순하고, 실험은 명시적으로 `experimentTest`로만 돌리는 게 의도에 맞다.
- [x] **테스트 클래스 분리** — 권장/안티패턴 2개로 나눈다. 이슈의 표 구조와 1:1 대응하고, PR 분석 본문에서 인용하기 쉽다.
- [x] **ID 생성 전략** — `IDENTITY` 한 케이스 (이슈 확정 사항).

## 검증

- 대상 테스트: `RecommendedCombinationIntegrationTest` (3조합 × 정상/예외 = 6 시나리오), `AntiPatternCombinationIntegrationTest` (3 시나리오)
- 실행: `./gradlew experimentTest --info`
- CI 제외 확인: `./gradlew test --dry-run`에 실험 테스트가 포함되지 않아야 한다
- 프로덕션 무변경 확인: `git diff --stat`이 `src/main/` 을 건드리지 않아야 한다
- 관찰 결과(스레드명·트랜잭션명·행 잔존·예외 방향)를 조합별로 정리해 PR 본문 분석의 근거로 남긴다

## 관측 결과

### 관측 결과 ② — AFTER_COMMIT 리스너의 예외는 요청 스레드로 전파되지 않는다 (이슈 본문 표 정정)

이슈 본문과 계획서 모두 "AFTER_COMMIT + 동기 + REQUIRES_NEW는 예외 발생 시 요청 스레드로 전파되어 응답에 반영된다"고 적었으나, **실측 결과 거짓이다.** 예외는 삼켜지고 ERROR 로그만 남는다.

```
ERROR o.s.t.s.TransactionSynchronizationUtils : TransactionSynchronization.afterCompletion threw exception
java.lang.IllegalStateException: listener failed
```

근거 (spring-tx 6.2.16 바이트코드 확인):

1. `TransactionalApplicationListenerSynchronization`이 구현하는 메서드는 `beforeCommit(boolean)`과 `afterCompletion(int)` 둘뿐이다. **`afterCommit()`은 구현하지 않는다.**
   따라서 `@TransactionalEventListener(AFTER_COMMIT)`은 `afterCommit()`이 아니라 `afterCompletion(STATUS_COMMITTED)` 경로로 실행된다.
2. `TransactionSynchronizationUtils.invokeAfterCommit`에는 예외 테이블(catch 블록)이 **0개** → 예외가 그대로 전파된다.
   `TransactionSynchronizationUtils.invokeAfterCompletion`에는 `catch (Throwable)`이 있어 **로깅 후 삼킨다.**

즉 `afterCommit()`에 직접 등록한 raw `TransactionSynchronization`이라면 전파되지만, `@TransactionalEventListener(AFTER_COMMIT)`은 그 경로를 타지 않는다.

**따라야 할 결론**

- "후속 작업의 성패를 사용자 응답에 반영" 이라는 상황은 **AFTER_COMMIT으로는 달성할 수 없다.** 응답에 반영하려면 BEFORE_COMMIT을 쓰거나, 리스너가 아니라 원본 트랜잭션 이후의 명시적 호출로 처리해야 한다.
- 동기 AFTER_COMMIT과 비동기 AFTER_COMMIT의 실질적 차이는 "예외가 응답에 반영되는가"가 아니라 **요청 스레드 점유 여부(= 응답 지연)와 리스너 간 실행 순서 보장**이다.
- 프로덕션 영향: `NotificationEventListener`(AFTER_COMMIT + 동기 + REQUIRES_NEW)의 실패는 **요청에 드러나지 않고 ERROR 로그로만 남는다.** 알림 유실을 인지하려면 로그 알람이나 재처리 경로가 필요하다.

또한 이 발견으로 **안티패턴 ④의 판별 지표를 재검토해야 한다.** `triggerAfterCompletion`은 `invokeAfterCompletion` 호출 직전에 `TransactionSynchronizationManager.clearSynchronization()`을 부른다. 따라서 AFTER_COMMIT 리스너 실행 시점에는 동기화가 이미 해제되어 있어, ④(`REQUIRED`)에서도 `isNewSynchronization()`이 참이 되어 `transactionName`이 리스너 메서드명으로 갱신될 가능성이 높다.
계획서 §8의 "④는 `transactionName`이 원본과 같다"는 지표는 ④ 구현 시 **실측으로 재확인**하고, 어긋나면 다른 판별 지표(예: 리스너가 쓴 행의 유실 여부, `EntityManager` 동일성)로 교체한다.

### 관측 결과 ④ — Spring은 리스너 메서드에 직접 붙인 경우만 막는다 (호출하는 메서드까지는 못 막는다)

리스너 메서드에 `@TransactionalEventListener(AFTER_COMMIT)` + `@Transactional(propagation = REQUIRED)`를 붙이면 **컨텍스트가 기동조차 하지 않는다.**

```
IllegalStateException: @TransactionalEventListener method must not be annotated with
@Transactional unless when declared as REQUIRES_NEW or NOT_SUPPORTED
  at RestrictedTransactionalEventListenerFactory.createApplicationListener
```

`RestrictedTransactionalEventListenerFactory` (Spring 6.1+, `AbstractTransactionManagementConfiguration`이 항상 등록):

```java
if (adapter.getTransactionPhase() != TransactionPhase.BEFORE_COMMIT) {
    Transactional txAnn = findMergedAnnotation(method, Transactional.class);
    if (txAnn == null) txAnn = findMergedAnnotation(type, Transactional.class);
    if (txAnn != null) {
        Propagation propagation = txAnn.propagation();
        if (propagation != REQUIRES_NEW && propagation != NOT_SUPPORTED) {
            throw new IllegalStateException(...);
        }
    }
}
```

읽어낼 것:

1. **BEFORE_COMMIT은 이 검증 대상에서 제외된다.** 그래서 조합 ①(BEFORE_COMMIT + REQUIRED)은 정상 기동한다. Spring이 ①을 정당한 조합으로 인정한다는 뜻이다.
2. AFTER_COMMIT / AFTER_ROLLBACK / AFTER_COMPLETION에서 `@Transactional`을 쓰려면 `REQUIRES_NEW` 아니면 `NOT_SUPPORTED`여야 한다. 즉 **권장 조합 ②③은 Spring이 강제하는 유일한 선택지**다.
3. **그러나 이 검증은 리스너 메서드·클래스에 붙은 어노테이션만 본다.** 리스너가 *무엇을 호출하는지*는 보지 않는다.
   `@TransactionalEventListener(AFTER_COMMIT)` (`@Transactional` 없음) → `@Transactional(REQUIRED)` 서비스 호출은 검증을 그대로 통과하며, 안티패턴 ④가 성립한다.
   **이 레포의 프로덕션 리스너들이 정확히 이 형태다** (`LearningEventListener` → `LearningCommandService`). 현재는 전부 BEFORE_COMMIT이라 안전하지만, phase만 AFTER_COMMIT으로 바꾸면 컴파일도 기동도 정상인 채로 쓰기가 유실된다.
   `SimpleJpaRepository`의 메서드에도 `@Transactional`이 붙어 있으므로, 리스너에서 리포지토리를 직접 호출하기만 해도 같은 일이 벌어진다.

따라서 ④의 재현은 `@Transactional(REQUIRED)`를 리스너가 호출하는 `ExperimentRecordWriter`에 두는 방식으로 구성했다. 이게 실전에서 실제로 마주치는 형태다.

부수적으로, 리스너 진입 시점(`listener-entry`)의 스레드 상태가 "이미 커밋이 끝났는데도 남아 있는 원본 트랜잭션"을 직접 보여준다.
`triggerAfterCompletion`이 `invokeAfterCompletion` 직전에 `clearSynchronization()`을 부르지만 `cleanupAfterCompletion`은 그 뒤에 실행되므로,

- `isSynchronizationActive()` → **false** (동기화는 이미 해제)
- `isActualTransactionActive()` → **true** (트랜잭션은 살아있다고 보고)
- `getCurrentTransactionName()` → 원본 그대로 (`clearSynchronization`은 이름을 지우지 않는다)
- `EntityManagerHolder` → 여전히 바인딩됨

REQUIRED는 바로 이 구간에서 "기존 트랜잭션이 있다"고 판단해 참여한다.

### 관측 결과 ④-b — 유실의 실제 기전: INSERT는 롤백된 게 아니라 **발행조차 되지 않는다**

`ExperimentRecordWriter.write()`가 자기 트랜잭션 안에서 방금 쓴 행을 재조회하게 해 확인했다(`listenerWriteVisibleInSameTx`).

**예측**: 같은 커넥션이니 커밋 전이어도 자기가 쓴 행은 보일 것이다(`true`). → INSERT는 DB에 도달했고 커넥션 반납 시 롤백됐다.
**실측**: **`false`.** 자기 커넥션에서조차 안 보인다. INSERT가 DB에 도달한 적이 없다.

근본 원인은 **Spring과 Hibernate가 트랜잭션 상태를 다르게 판단하는 것**이다. AFTER_COMMIT 콜백 구간에서:

| | 판단 |
| --- | --- |
| Spring `TransactionSynchronizationManager.isActualTransactionActive()` | **true** (그래서 REQUIRED가 참여한다) |
| Hibernate `SharedSessionContractImplementor.isTransactionInProgress()` | **false** (원본 `EntityTransaction`은 이미 commit됨) |

Hibernate가 트랜잭션이 없다고 보면 두 가지가 연쇄한다 (hibernate-core 6.6.42 바이트코드 확인):

1. `DefaultPersistEventListener`는 `saveWithGeneratedId(..., requiresImmediateIdAccess = false)`로 호출한다. `AbstractSaveEventListener`는 `EventSource.isTransactionInProgress()`를 물어 identity insert를 **지연**시키고(`EntityIdentityInsertAction.isDelayed`, `DelayedPostInsertIdentifier`), `ActionQueue`에만 넣는다.
   → `em.persist()`가 INSERT를 즉시 발행하지 않는다. (JPA의 `persist`는 트랜잭션 밖 호출이 합법이라 예외도 없다.)
2. `SessionImpl.autoFlushIfRequired`는 첫 줄이 `if (!isTransactionInProgress()) return false;` 다.
   → 이어지는 `existsByTag` 조회가 auto-flush를 유발하지 못해, 큐에 든 INSERT가 실행되지 않는다.

그리고 참여(non-new) 트랜잭션이라 두 번째 커밋도 flush도 없다. 결국 `EntityManager`가 닫히면서 `ActionQueue`에 담긴 INSERT째로 사라진다.

**세 지표가 함께 "예외 없는 쓰기 유실"을 정의한다**

- `listenerWriteVisibleInSameTx` → **false** (INSERT가 발행조차 되지 않았다)
- 바깥 트랜잭션의 `existsByTag` → **false** (당연히 없다)
- `traceRecorder.error(LISTENER)` → **비어있다** (그 과정에 예외가 하나도 없었다)

`catch (Exception)`이 `write()`의 예외까지 잡으므로, error가 비어있다는 것은 프레임워크가 아무것도 던지지 않았다는 뜻이다.

> **유실의 정확한 의미는 이렇다.** 커넥션이 살아있어 쓰기가 실행됐다가 롤백되는 게 아니다. Hibernate 세션이 이미 트랜잭션 종료 상태라 **쓰기 명령이 메모리 큐에서 나가지도 못하고 폐기**된다. 롤백 로그조차 남지 않는다.

## Deviation Log

### 조합 ① (BEFORE_COMMIT + 동기 + REQUIRED)

- `fixture/TraceRecorder.java`: `ORIGIN` / `LISTENER` 라벨을 `public static final` 상수로 선언 — 이유: 매직스트링 금지 컨벤션(`common.md`). 리스너·발행자·테스트 세 곳이 같은 라벨을 공유한다.
- `fixture/ExperimentEvent.java`: `LISTENER_FAILURE_MESSAGE` 상수를 인터페이스에 선언 — 이유: 리스너 5종과 테스트가 같은 예외 메시지를 공유하므로 계약에 두는 게 맞다.
- `fixture/TraceRecorder.java`: 계획에 없던 `traces()` 접근자 추가 — 이유: 이슈의 목적이 "내 눈으로 확인"이므로 테스트 `@AfterEach`에서 수집된 trace를 `[TRACE]` 로 출력한다.
- 구현 순서: 사용자 요청에 따라 조합 ①→⑤를 한 단계씩 구현·관측한다. `ExperimentGate`, `experimentAsync` Executor, 나머지 리스너 4종은 해당 단계에서 추가한다 (계획 내용 변경 아님, 투입 시점만 분할).

### 조합 ② (AFTER_COMMIT + 동기 + REQUIRES_NEW)

- `listener/AfterCommitSyncNewTxListener.java`: 계획에서 ⑤ 전용이던 `originVisibleToListener` flag를 ②에도 기록 — 이유: ②는 `true`(원본 커밋 후 실행), ⑤는 `false`(원본 미커밋)로 정확히 대조된다. 같은 `REQUIRES_NEW`인데 phase만 달라 가시성이 갈린다는 걸 한 지표로 보여준다.
- `fixture/TraceRecorder.java`: `ORIGIN_VISIBLE_TO_LISTENER` flag 키 상수와 `flags()` 접근자 추가 — 이유: 위 flag를 리스너·테스트가 공유하고, `@AfterEach`에서 `[FLAG ]` 로 출력하기 위함.
- `listener/AfterCommitSyncNewTxListener.java`: 계획에 없던 `try/catch` + `captureError` + 재던지기 추가 — 이유: 예외가 `invokeAfterCompletion`에 삼켜져 테스트에서 관측 불가능하므로, 기록 후 재던져 삼켜지는 경로를 보존해야 한다.
- `RecommendedCombinationIntegrationTest`: ②의 예외 케이스 단언을 `assertThatThrownBy` → `assertThatCode(...).doesNotThrowAnyException()` + `traceRecorder.error(LISTENER)` 검증으로 교체 — 이유: **계획의 예측이 실측과 달랐다.** 위 "관측 결과 ②" 참조.

### 조합 ③ (AFTER_COMMIT + 비동기 + REQUIRES_NEW)

- `ExperimentFixtureConfig`: `EXPERIMENT_ASYNC_EXECUTOR` / `EXPERIMENT_ASYNC_THREAD_PREFIX` 를 `public static final` 로 노출 — 이유: Executor 정의와 테스트의 스레드명 단언이 같은 문자열을 공유한다.
- `listener/AfterCommitAsyncNewTxListener.java`: `originVisibleToListener` flag를 ③에도 기록 — 이유: ②(같은 스레드·다른 트랜잭션)와 ③(다른 스레드·다른 트랜잭션)이 모두 `true`임을 보여, ⑤의 `false`가 스레드 때문이 아니라 **phase 때문**임을 분리해낸다.
- `fixture/TraceRecorder.java`: `errors()` 접근자 추가 — 이유: `@AfterEach`에서 `[ERROR]` 로 출력해 삼켜진 예외를 눈으로 확인한다.

### 조합 ④ (AFTER_COMMIT + 동기 + REQUIRED, 안티패턴)

- `fixture/ExecutionTrace.java`: `entityManagerId` 필드 추가, `here(label, EntityManagerFactory)` 로 시그니처 변경 — 이유: **"관측 결과 ②"에서 예고한 지표 교체.** `transactionName`은 ④에서 새 트랜잭션인 것처럼 갱신되어 판별에 쓸 수 없다. `TransactionSynchronizationManager.getResource(emf)`로 얻은 `EntityManagerHolder`의 `EntityManager` 인스턴스 동일성이 "같은 트랜잭션(=같은 커넥션)에 참여했는가"를 직접 말해준다. 계획서 §8이 예비해 둔 대안 그대로다.
- `fixture/TraceRecorder.java`: `EntityManagerFactory` 주입 (`@RequiredArgsConstructor`) — 이유: 위 지표를 얻으려면 조회 키가 필요하다. 리스너 쪽 호출부(`capture(label)`)는 그대로다.
- `RecommendedCombinationIntegrationTest`: ①에 `entityManagerId` 동일, ②③에 상이 단언 추가 — 이유: ④의 "동일"이 무엇과 대조되는지 없으면 증거가 되지 못한다.
- `AntiPatternCombinationIntegrationTest`: ④는 예외를 던지지 않는 시나리오만 둔다 — 이유: 안티패턴의 핵심은 "정상 경로인데도 쓰기가 사라진다"이며, 예외 시나리오는 어차피 `invokeAfterCompletion`이 삼켜 ②와 구분되지 않는다.
- **`fixture/ExperimentRecordWriter.java` 신규 추가, ④ 리스너에서 `@Transactional` 제거** — 이유: **계획대로 짜면 컨텍스트가 기동하지 않는다.** `RestrictedTransactionalEventListenerFactory`가 AFTER_COMMIT 리스너의 non-REQUIRES_NEW `@Transactional`을 거부한다. 위 "관측 결과 ④" 참조. REQUIRED를 리스너가 호출하는 서비스로 옮겨 프로덕션과 같은 형태로 재현한다.
- `fixture/TraceRecorder.java`: `LISTENER_ENTRY` 라벨 추가 — 이유: `@Transactional` 진입 전 스레드 상태를 찍어야 "동기화는 해제됐는데 트랜잭션은 살아있다고 보고되는" 구간이 드러난다.
- `AntiPatternCombinationIntegrationTest`: `리스너_진입_시점의_스레드에는_커밋이_끝난_원본_트랜잭션이_그대로_남아있다()` 테스트 추가 — 이유: 위 창을 직접 단언한다.
- `fixture/ExecutionTrace.java`: `hibernateTransactionInProgress` 필드 추가 (`em.unwrap(SharedSessionContractImplementor.class).isTransactionInProgress()`) — 이유: **`listenerWriteVisibleInSameTx`가 예측(true)과 달리 false로 나왔다.** 그 원인이 "Spring은 트랜잭션이 살아있다고 보고, Hibernate는 끝났다고 본다"는 상태 불일치임을 드러내는 단일 설명 변수다. ①②③에서는 `true`, ④에서만 `false`. 위 "관측 결과 ④-b" 참조.
- `AntiPatternCombinationIntegrationTest`: 테스트명을 `리스너의_INSERT가_DB에_도달하고도_...` → `리스너의_쓰기가_INSERT조차_발행되지_못한_채_예외_하나_없이_사라진다` 로 변경 — 이유: 실측이 기전을 뒤집었다.

### 조합 ⑤ (BEFORE_COMMIT + 비동기 + REQUIRES_NEW, 안티패턴)

- `fixture/ExperimentGate.java`, `listener/BeforeCommitAsyncNewTxListener.java`: 계획서 §6 설계 그대로 구현. `@Order(1)` 비동기 리스너 + `@Order(2)` 게이트 리스너.
  `@Order`가 실제로 콜백 순서를 지배함을 확인했다: `ApplicationListenerMethodAdapter.resolveOrder(Method)`가 메서드의 `@Order`를 읽고, `TransactionSynchronizationManager.getSynchronizations()`가 `OrderComparator.sort()`로 정렬해 반환한다.
- 게이트 타임아웃을 계획서의 2초 → **5초**로 상향 — 이유: 타임아웃이 먼저 끝나면 원본이 커밋되어 `originVisibleToListener`가 true로 뒤집히는 위양성(flaky)이 난다. 넉넉히 잡아도 정상 경로에서는 즉시 통과한다.
- `AntiPatternCombinationIntegrationTest.setUp()`에 `experimentGate.reset()` 추가 — 이유: 래치가 열린 채로 다음 테스트에 넘어가면 게이트가 즉시 통과되어 관찰 창이 닫힌다.
- ⑤는 `@Transactional(REQUIRES_NEW)`를 리스너 메서드에 직접 붙여도 된다 — `RestrictedTransactionalEventListenerFactory`의 검증은 BEFORE_COMMIT을 건너뛰고, REQUIRES_NEW는 애초에 허용 목록이다. **Spring은 ⑤를 막지 못한다.**
- `TraceRecorder.GATE_HELD_UNTIL_LISTENER_READ` flag 추가, `holdOriginUncommitted`가 `awaitListenerRead`의 반환값을 기록 — 이유: 실험의 **전제 자체를 검증되지 않은 채로 두고 있었다.** 게이트가 신호가 아니라 타임아웃으로 풀리면 원본이 먼저 커밋되어 `originVisibleToListener`가 true로 뒤집힐 수 있다. 두 테스트 모두 이 flag를 `isTrue()`로 먼저 단언한다.

> **⑤의 시간 순서는 `await`가 아니라 래치가 만든다.**
> `publish()`는 동기 호출이라 반환 시점에 원본은 이미 커밋되어 있다. 그러나 `holdOriginUncommitted`는 `triggerBeforeCommit` 안에서 실행되므로 `doCommit`보다 앞서고, 여기서 대기하는 동안 원본은 확실히 미커밋이다.
> 비동기 리스너는 그 창에서 조회·기록하고 `finally`에서 래치를 내린다. 따라서 `originVisibleToListener`가 **기록되는 순간**이 원본 커밋 이전임이 보장된다.
> 테스트의 `await(...)`는 순서를 만들지 않는다. 비동기 리스너의 *자기 트랜잭션*이 커밋됐는지(`existsByTag(LISTENER_TAG)`)를 기다리는 별개의 관심사다.
>
> 예외 케이스에서도 게이트가 필요하다. 게이트가 없으면 원본이 먼저 커밋된 뒤 리스너가 실패할 수 있고, 그러면 "커밋 전에 실패했는데도 원본이 커밋된다"는 명제가 성립하지 않는다.
