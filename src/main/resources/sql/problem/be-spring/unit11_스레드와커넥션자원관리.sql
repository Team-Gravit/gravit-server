-- Unit: 스레드와 커넥션 자원 관리 (Unit ID: 122)
-- Chapter: Spring (Chapter ID: 10)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (548, 122, '커넥션 풀 데드락과 실행기 큐 설정'),
       (706, 122, '외부 호출 점유와 HikariCP 설정'),
       (864, 122, '처리량 계산과 읽기 타임아웃, 피닝');

-- =====================================================
-- Lesson 548: 커넥션 풀 데드락과 실행기 큐 설정
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3467, 548, '아래 조건에서 풀 데드락을 피하려면 필요한 커넥션 풀의 최소 크기는?', '- 이 API를 동시에 처리하는 톰캣 워커 스레드는 최대 8개다.
- 요청 하나는 외부 트랜잭션에서 커넥션 1개를 잡은 상태로, 내부 REQUIRES_NEW 트랜잭션이 커넥션 1개를 더 요청한다.
- 내부 트랜잭션이 커넥션을 받지 못하면 외부 트랜잭션은 잡고 있던 커넥션을 반환하지 않고 대기한다.
- HikariCP의 데드락 회피 기준: 풀 크기 >= Tn x (Cm - 1) + 1
  (Tn = 최대 동시 스레드 수, Cm = 스레드 하나가 동시에 잡는 최대 커넥션 수)', 'OBJECTIVE'),
       (3468, 548, '아래 코드에서 IllegalStateException이 발생한 뒤의 결과로 옳은 것은?', '```java
@Service
public class ImportService {

    private final RowRepository repository;   // 스프링 데이터 JPA 리포지터리

    @Transactional
    public void importAll(List<Row> rows) {   // rows 1,000건
        rows.parallelStream().forEach(row -> repository.save(Row.toEntity(row)));
        throw new IllegalStateException("검증 실패");
    }
}
```
parallelStream의 작업은 공용 ForkJoinPool 스레드에서 실행되고, 예외는 처리되지 않고 호출자로 전파된다.', 'OBJECTIVE'),
       (3469, 548, '아래 실행기 설정을 바탕으로 옳지 않은 것은?', '@Async 전용 ThreadPoolTaskExecutor 설정

| 항목 | 값 |
| --- | --- |
| corePoolSize | 4 |
| maxPoolSize | 16 |
| queueCapacity | 지정 안 함(무제한) |
| 거부 정책 | 지정 안 함(AbortPolicy) |

ThreadPoolTaskExecutor는 core 스레드가 모두 차면 대기 작업을 큐에 넣고, 큐가 가득 찬 뒤에야 max까지 스레드를 늘린다.', 'OBJECTIVE'),
       (3470, 548, '아래 요청 처리 방식 변경에 대한 설명으로 옳은 것은?', 'Spring Boot 3.2 + JDK 21 환경의 API 서버에서 `spring.threads.virtual.enabled=true`로 톰캣 요청 처리를 가상 스레드로 전환했다. 요청 하나는 서비스 계층의 `@Transactional` 구간에서 DB 커넥션 1개를 잡으며, HikariCP `maximum-pool-size`는 10 그대로 두었다. 전환 뒤 동시 요청 300개를 넣자 스레드가 모자라 거절되던 요청은 사라졌다.', 'OBJECTIVE'),
       (3471, 548, '아래 현상의 원인이 된 스프링 부트의 JPA 관련 기본 설정을 가리키는 이름은?', '운영 중인 API 서버를 점검하며 아래를 확인했다.

- 서비스 계층의 `@Transactional` 메서드는 평균 12ms 만에 끝나는데, 요청 하나가 커넥션을 붙잡고 있는 시간은 평균 210ms로 측정된다.
- 스레드 덤프를 뜨면 응답 JSON을 직렬화하는 중인 스레드가 커넥션을 쥔 채 남아 있다.
- 이 설정 하나만 false로 바꾸자 커넥션 점유 시간이 평균 15ms로 줄었고, 대신 같은 코드에서 LazyInitializationException이 발생했다.', 'SUBJECTIVE'),
       (3472, 548, '아래 문제를 없애기 위해 이벤트 리스너에 지정한 트랜잭션 단계(phase) 값은?', '주문 서비스는 `@Transactional` 메서드 안에서 `@Async` 알림 발송을 호출한다. 운영 로그에는 두 가지가 남았다.

- 알림 스레드가 방금 만든 주문 번호로 DB를 조회했으나 행이 없어 실패한 건이 하루 수십 건.
- 결제 검증에 걸려 주문이 롤백된 날, 남아 있지 않은 주문의 알림이 이미 고객에게 발송된 건.

발송 로직을 `@TransactionalEventListener`가 붙은 별도 빈으로 옮기고 phase 값을 지정하자 두 현상이 모두 사라졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3467
(9419, 3467, '8', 'Tn을 그대로 답으로 본 것. 8개면 스레드마다 커넥션을 1개씩 쥔 채 두 번째를 기다리고, 아무도 반환하지 않아 전부 타임아웃까지 멈춘다.', false),
(9420, 3467, '9', 'Tn=8, Cm=2를 대입하면 8 x (2 - 1) + 1 = 9. 여유분 1개가 있어야 스레드 하나가 두 번째 커넥션을 받아 작업을 끝내고 커넥션 2개를 풀에 돌려줄 수 있다.', true),
(9421, 3467, '16', 'Tn x Cm으로 계산한 값. 모든 스레드가 동시에 2개씩 다 쥐어야 한다고 본 것으로, 데드락은 없지만 기준이 요구하는 최소치보다 7개 많다.', false),
(9422, 3467, '17', '기준식의 Cm - 1 자리에 Cm을 그대로 넣어 8 x 2 + 1로 계산한 값. 각 스레드가 이미 1개를 쥐고 있다는 점을 빼지 않은 것이다.', false),

-- 문제 3468
(9423, 3468, '예외로 부모 트랜잭션이 롤백되므로 저장된 행이 하나도 남지 않는다.', '자식 스레드의 저장까지 부모 트랜잭션 범위에 든다고 본 오개념. 롤백은 부모 스레드가 쥔 커넥션에서 한 작업만 되돌린다.', false),
(9424, 3468, '자식 스레드가 부모의 영속성 컨텍스트를 물려받아 flush가 커밋 시점까지 미뤄진다.', '영속성 컨텍스트도 스레드에 묶여 있어 물려받지 못한다. 자식 스레드에서 지연 로딩을 시도하면 EntityManager가 없어 LazyInitializationException이 난다.', false),
(9425, 3468, '모든 저장이 부모가 잡은 커넥션 하나를 함께 쓰므로 커넥션 사용량은 1개로 유지된다.', '커넥션 역시 ThreadLocal에 바인딩돼 공유되지 않는다. 각 저장이 커넥션을 따로 얻으므로 병렬도만큼 커넥션을 더 쓰고 풀을 압박한다.', false),
(9426, 3468, '저장이 부모 트랜잭션 밖에서 처리돼, 롤백 뒤에도 일부 행이 그대로 남는다.', '트랜잭션은 ThreadLocal에 묶여 ForkJoinPool 스레드로 전파되지 않는다. 각 save가 자체 트랜잭션으로 먼저 커밋돼 부모 롤백과 무관하게 살아남고 원자성이 깨진다.', true),

-- 문제 3469
(9427, 3469, '큐가 무제한이어도 작업이 몰리면 스레드가 16개까지 늘어 처리량도 함께 커진다.', '무제한 큐는 가득 차는 일이 없어 max까지 확장하는 조건 자체가 성립하지 않는다. 스레드는 core 4개에 머물고 maxPoolSize 16은 죽은 값이 된다.', true),
(9428, 3469, '유입 속도가 처리 속도보다 빠르면 대기 작업이 계속 쌓여 지연과 메모리 사용량이 함께 늘어난다.', '참이다. 초과분이 전부 큐로 들어가는데 상한이 없어 대기 시간이 길어지고, 쌓인 작업 객체가 힙을 차지해 메모리 사용량도 같이 오른다.', false),
(9429, 3469, '거부 정책은 큐가 가득 찬 뒤에 호출되므로 이 설정에서는 사실상 동작하지 않는다.', '참이다. 거부는 큐가 차고 스레드도 max까지 찬 뒤에 일어나는데, 무제한 큐에서는 그 조건에 도달하지 않아 AbortPolicy가 불릴 일이 없다.', false),
(9430, 3469, 'queueCapacity를 100으로 낮추면 대기 작업이 100개를 넘는 순간부터 스레드가 16개까지 늘어난다.', '참이다. 상한을 두어야 core 4개 다음에 큐 100개, 그다음 max 16개라는 확장 순서가 실제로 작동하고 maxPoolSize가 비로소 의미를 갖는다.', false),

-- 문제 3470
(9431, 3470, '커넥션 풀 크기도 가상 스레드 수에 맞춰 자동으로 늘어 커넥션 대기가 사라진다.', '전환은 톰캣과 실행기 쪽 설정일 뿐 HikariCP 풀 크기를 건드리지 않는다. maximum-pool-size가 10이므로 동시 커넥션은 여전히 10개를 넘지 못한다.', false),
(9432, 3470, '블로킹 I/O가 진행되는 동안 캐리어 스레드가 함께 묶여 기존 방식보다 동시 처리량이 줄어든다.', '가상 스레드는 블로킹 I/O를 만나면 캐리어 스레드를 반납한다. 캐리어가 묶이는 것은 synchronized 블록 안에서 블로킹할 때의 pinning 문제로, 일반 I/O 대기와 다르다.', false),
(9433, 3470, '동시에 처리되는 요청이 늘어난 만큼 커넥션을 기다리는 요청도 늘어 병목이 커넥션 풀 대기로 옮겨간다.', '스레드 수 한계는 사실상 사라지지만 풀 크기 10은 그대로다. 11번째 요청부터 HikariPool.getConnection에서 대기하므로 한계 지점이 스레드에서 커넥션으로 이동한다.', true),
(9434, 3470, '트랜잭션 동기화 정보가 ThreadLocal에서 풀려 여러 스레드가 한 트랜잭션을 함께 쓸 수 있다.', '가상 스레드에서도 트랜잭션과 커넥션은 ThreadLocal에 그대로 바인딩된다. 스레드가 달라지면 트랜잭션이 공유되지 않는다는 원칙은 변하지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1112, 3471, 'OSIV,Open Session In View,오픈 세션 인 뷰,open-in-view,spring.jpa.open-in-view', '트랜잭션이 끝난 뒤에도 영속성 컨텍스트를 컨트롤러·직렬화 단계까지 열어 두는 스프링 부트 기본값(spring.jpa.open-in-view=true)이 OSIV다. 덕분에 뷰 단계의 지연 로딩이 성공하지만, 그 시점에 커넥션을 다시 얻어 응답이 끝날 때까지 유지하므로 트랜잭션이 12ms에 끝나도 점유는 210ms가 된다. 끄면 점유가 트랜잭션 길이(15ms)로 줄고, 대신 트랜잭션 밖 지연 로딩이 LazyInitializationException으로 드러난다. 커넥션 풀 크기 부족이나 트랜잭션 전파 설정 문제와 구분할 것 — 여기서는 트랜잭션 구간이 아니라 그 바깥 구간이 커넥션을 잡고 있다. API 서버는 OSIV를 끄고 조회·변환을 트랜잭션 안에서 끝내는 편이 커넥션 효율에 유리하다.'),
       (1113, 3472, 'AFTER_COMMIT,TransactionPhase.AFTER_COMMIT,after commit,커밋 이후', '두 로그 모두 비동기 작업이 커밋보다 먼저 시작돼 생긴 일이다. @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)은 커밋이 끝난 뒤에 리스너를 실행하므로, 알림 스레드가 조회할 때 주문 행이 이미 보이고 롤백된 주문의 이벤트는 아예 발행되지 않는다. 옆 값과 비교하면 BEFORE_COMMIT은 커밋 전에 실행돼 첫 번째 문제가 그대로 남고, AFTER_ROLLBACK·AFTER_COMPLETION은 롤백된 트랜잭션에서도 실행돼 두 번째 문제를 막지 못한다. 리스너를 다른 스레드에서 돌리려면 @Async를 함께 붙이되, 그 스레드에는 부모 트랜잭션이 전파되지 않으므로 필요한 컨텍스트는 이벤트 객체에 담아 넘긴다.');

-- =====================================================
-- Lesson 706: 외부 호출 점유와 HikariCP 설정
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4415, 706, '아래 장애에서 커넥션이 모자라게 된 원인 자체를 없애는 조치로 옳은 것은?', '결제사 API가 장애로 응답을 멈춘 뒤, 주문과 무관한 상품 조회 API까지 모두 응답하지 않았다. 이때 서버 CPU 사용률은 5% 안팎이었다. 톰캣 최대 스레드는 200, HikariCP `maximum-pool-size`는 10이며, 스레드 덤프를 요약하면 아래와 같다.

| 스레드 수 | 멈춘 지점 ← 호출 경로 |
| --- | --- |
| 10 | `SocketInputStream.read` ← `PaymentClient.pay` ← `OrderService.order` |
| 190 | `HikariPool.getConnection` ← `ProductService.find`, `OrderService.order` |

10개 스레드는 모두 40초 넘게 같은 지점에 머물러 있었다.

```java
@Transactional
public void order(OrderRequest req) {
    Order order = orderRepository.save(Order.from(req));
    PaymentResult result = paymentClient.pay(order);   // 결제사 HTTP 호출
    order.confirm(result);
}
```', 'OBJECTIVE'),
       (4416, 706, '아래 코드에서 컨트롤러가 signup()을 호출했을 때의 동작으로 옳은 것은?', '`@EnableAsync`가 켜져 있고, 스레드 이름 접두사가 `mail-`인 `mailExecutor` 빈도 정상 등록돼 있다. 컨트롤러는 주입받은 `SignupService` 빈의 `signup()`을 호출한다.

```java
@Slf4j
@Service
@RequiredArgsConstructor
public class SignupService {

    private final MemberRepository memberRepository;
    private final MailClient mailClient;

    @Transactional
    public void signup(SignupRequest req) {
        Member member = memberRepository.save(Member.from(req));
        sendWelcomeMail(member.getEmail());
        log.info("가입 처리 완료");
    }

    @Async("mailExecutor")
    public void sendWelcomeMail(String email) {
        mailClient.send(email);   // SMTP 서버 응답까지 약 3초
    }
}
```', 'OBJECTIVE'),
       (4417, 706, '아래 커넥션 풀 점검 자료를 바탕으로 한 판단으로 옳지 않은 것은?', 'MySQL을 쓰는 API 서버의 HikariCP 설정을 점검한다. DB 서버는 CPU 코어 8개와 디스크 1개로 구성돼 있고, DB는 28,800초 동안 요청이 오지 않은 커넥션을 먼저 끊는다(`wait_timeout=28800`).

| 설정 | 현재 값 |
| --- | --- |
| `maximum-pool-size` | 100 |
| `max-lifetime` | 1,800,000ms |
| `leak-detection-threshold` | 0 |', 'OBJECTIVE'),
       (4418, 706, '아래 코드와 로그를 바탕으로, 감사 기록 작업의 결과로 옳은 것은?', '인증을 마친 사용자가 주문 API를 호출했다. `auditExecutor`는 스레드 이름 접두사(`audit-`) 외에는 추가 설정 없이 만든 `ThreadPoolTaskExecutor`이고, `SecurityContextHolder`의 저장 전략은 기본값이다. 로그 패턴은 MDC에 담긴 `traceId`를 함께 찍는다.

```java
@Transactional
public void placeOrder(OrderRequest req) {
    Order order = orderRepository.save(Order.from(req));
    log.info("주문 저장 id={}", order.getId());

    auditExecutor.submit(() -> {
        log.info("감사 기록 시작 id={}", order.getId());
        String user = SecurityContextHolder.getContext().getAuthentication().getName();
        auditRepository.save(new AuditLog(order.getId(), user));
    });
}
```

```
[http-nio-8080-exec-5] [traceId=a91c] 주문 저장 id=501
[audit-1] [traceId=] 감사 기록 시작 id=501
```', 'OBJECTIVE'),
       (4419, 706, '아래 설정의 ??? 자리에 들어간 클래스의 이름은?', '상품 이미지 업로드 API는 썸네일 생성을 `@Async("thumbnailExecutor")` 메서드로 넘기며, 썸네일 한 건을 만드는 데 약 2초가 걸린다. 실행기 설정은 아래와 같다.

```java
executor.setCorePoolSize(4);
executor.setMaxPoolSize(8);
executor.setQueueCapacity(100);
executor.setThreadNamePrefix("thumb-");
executor.setRejectedExecutionHandler(new ThreadPoolExecutor.???());
```

기획전 오픈 직후 업로드가 몰린 10분 동안 아래 기록이 남았다.

```
[thumb-3]                썸네일 생성 완료 productId=8812
[http-nio-8080-exec-17]  썸네일 생성 완료 productId=8840
[http-nio-8080-exec-42]  썸네일 생성 완료 productId=8841
```

- 이 시간대에 `thumb-` 스레드 8개가 모두 일하고 있었고, 큐에는 대기 작업 100개가 차 있었다.
- 작업 거부 예외(`RejectedExecutionException`, `TaskRejectedException`)는 한 건도 기록되지 않았고, 썸네일이 빠진 상품도 없었다.
- 업로드 API 응답 시간 p99가 평소 120ms에서 2.3초로 뛰었다.', 'SUBJECTIVE'),
       (4420, 706, '아래 두 훈련 사이에 값을 바꾼 설정 항목의 이름은?', 'DB 장애 대응 훈련으로 DB를 60초 동안 내렸다가 다시 올리는 일을 두 번 했다. 두 훈련 사이에는 HikariCP 설정 하나의 값만 30,000에서 2,000으로(단위 ms) 바꿨고, 톰캣 최대 스레드 200을 비롯한 나머지 설정은 그대로다.

| 관찰 항목 | 1차 훈련 (30,000) | 2차 훈련 (2,000) |
| --- | --- | --- |
| DB를 쓰는 API가 실패 응답을 내기까지 걸린 시간 | 약 30초 | 약 2초 |
| 실패할 때 남은 예외 | `SQLTransientConnectionException` | `SQLTransientConnectionException` |
| 한꺼번에 붙잡혀 있던 톰캣 스레드 수 | 200개 모두 | 20개 안팎 |
| DB를 쓰지 않는 캐시 조회 API | 함께 응답 없음 | 정상 응답 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4415
(11947, 4415, 'maximum-pool-size를 10에서 100으로 늘려, 기다리던 요청에도 커넥션이 돌아가게 한다.', '멈춘 결제 호출이 커넥션을 쥐는 구조가 그대로라 늘린 100개도 시간이 지나면 차례로 묶인다. 고갈의 원인은 풀 크기가 아니라 트랜잭션 안에서 길어진 커넥션 점유 시간이다.', false),
(11948, 4415, 'spring.jpa.open-in-view를 false로 바꿔, 응답 직렬화 단계에서 커넥션을 쥐지 않게 한다.', 'OSIV를 끄는 것은 트랜잭션이 끝난 뒤 뷰 단계에서 커넥션을 다시 잡는 문제의 처방이다. 덤프의 10개 스레드는 트랜잭션 안인 OrderService.order에서 결제 응답을 기다리고 있어 이 설정으로는 풀리지 않는다.', false),
(11949, 4415, '결제사 API 호출을 트랜잭션 밖으로 옮겨, 응답을 기다리는 동안 커넥션을 쥐지 않게 한다.', '커넥션은 트랜잭션이 끝나야 반환되므로 트랜잭션 안의 결제 호출이 멈추면 커넥션도 함께 묶인다. DB 작업만 짧은 트랜잭션으로 나누면 결제 응답을 기다리는 동안 커넥션이 풀에 돌아가고, 외부 호출 자체에도 타임아웃을 건다.', true),
(11950, 4415, 'order()에 @Async를 붙여, 톰캣 스레드는 바로 돌려주고 결제는 뒤에서 처리한다.', '작업이 실행기 스레드로 옮겨 갈 뿐, 그 스레드도 트랜잭션 안에서 결제 응답을 기다리며 커넥션을 쥔다. 커넥션을 오래 쥐는 원인은 그대로이고, 응답을 못 받은 주문 작업만 실행기 큐에 쌓인다.', false),

-- 문제 4416
(11951, 4416, '메일 발송은 mail- 스레드로 넘어가, signup()은 SMTP 응답을 기다리지 않고 끝난다.', '@Async는 프록시가 호출을 가로챌 때만 실행기로 넘어간다. signup() 안에서 부른 sendWelcomeMail()은 프록시를 거치지 않는 같은 객체 내부 호출(self-invocation)이라 비동기 처리가 적용되지 않는다.', false),
(11952, 4416, '메일 발송은 톰캣 스레드에서 그대로 실행돼, SMTP 응답을 기다린 약 3초만큼 응답이 늦어진다.', '내부 호출은 프록시가 아닌 this의 메서드를 직접 부르므로 @Async가 무시되고 동기로 실행된다. 그 3초 동안 가입 트랜잭션도 끝나지 않아 커넥션까지 붙잡힌다. 비동기로 돌리려면 발송 메서드를 별도 빈으로 분리한다.', true),
(11953, 4416, '가입 트랜잭션이 커밋된 뒤에야, mail- 스레드에서 메일 발송이 따로 시작된다.', '커밋 뒤 실행은 @TransactionalEventListener(AFTER_COMMIT) 같은 장치가 있어야 보장된다. 이 코드는 커밋 전, 트랜잭션 한가운데서 같은 스레드로 메일 발송부터 끝낸다.', false),
(11954, 4416, '메일 발송에서 예외가 나도 호출자에게 전파되지 않아, 가입은 그대로 커밋된다.', 'void @Async 메서드의 예외가 호출자에게 가지 않는 것은 실제로 다른 스레드에서 돌 때의 이야기다. 여기서는 같은 스레드의 일반 호출이라 런타임 예외가 signup()까지 전파되고 가입 트랜잭션이 롤백된다.', false),

-- 문제 4417
(11955, 4417, '코어 수 × 2 + 디스크 수 공식으로 잡은 풀 크기 시작값은 17이라, 현재 값 100은 그보다 크다.', '8 × 2 + 1 = 17로, HikariCP가 제시하는 출발점이다. 커넥션은 많을수록 좋은 것이 아니어서 현재 100은 이 값에서 시작해 부하 테스트로 줄여 볼 여지가 있다.', false),
(11956, 4417, 'leak-detection-threshold가 0이라 누수 감지가 꺼져 있어, 반환되지 않은 커넥션이 있어도 경고가 남지 않는다.', '이 설정은 0이면 꺼진 상태다. 개발·스테이징에서 5,000ms처럼 값을 주면 그 시간 넘게 반환되지 않은 커넥션을 빌려 간 위치와 함께 로그로 남겨, 닫지 않은 커넥션을 찾아낼 수 있다.', false),
(11957, 4417, '풀 크기를 200으로 더 키우면 DB 쪽 컨텍스트 스위칭이 늘어 전체 처리량이 오히려 떨어질 수 있다.', 'DB 코어는 8개 그대로인데 동시에 도는 쿼리만 늘면 컨텍스트 스위칭과 자원 경합이 커진다. 고갈의 주된 원인은 커넥션 점유 시간이라 풀 크기보다 트랜잭션 범위와 외부 호출 위치를 먼저 본다.', false),
(11958, 4417, 'max-lifetime이 wait_timeout보다 길게 잡혀 있어, DB가 먼저 끊은 커넥션을 풀이 내줄 위험이 있다.', '1,800,000ms는 1,800초(30분)로 wait_timeout 28,800초(8시간)보다 훨씬 짧다. 커넥션이 30분을 넘기기 전에 새것으로 교체되니 DB가 먼저 끊을 틈이 없다. ms와 초를 맞추지 않고 숫자만 비교하면 더 길다고 착각한다.', true),

-- 문제 4418
(11959, 4418, '인증 정보가 비어 있어 getName() 호출에서 예외가 나고, 감사 기록은 저장되지 않는다.', 'SecurityContext는 MDC처럼 ThreadLocal에 담긴다. traceId가 빈 audit-1 스레드에는 인증 정보도 없어 getAuthentication()이 null이고 NPE가 난다. submit()은 이 예외를 Future에 담아 두므로 로그 없이 조용히 실패한다.', true),
(11960, 4418, '톰캣 스레드의 인증 정보가 그대로 보여, 요청자 이름으로 감사 기록이 저장된다.', '인증 정보가 작업을 따라 넘어간다고 본 오개념. 기본 전략의 SecurityContext는 ThreadLocal에 묶여 audit-1 스레드로 전달되지 않는다. 넘기려면 DelegatingSecurityContextAsyncTaskExecutor 같은 래퍼로 실행기를 감싸야 한다.', false),
(11961, 4418, '빈 인증 정보 대신 익명 사용자(anonymousUser)가 채워져, 그 이름으로 감사 기록이 저장된다.', 'anonymousUser는 인증되지 않은 요청에서 스프링 시큐리티 필터가 톰캣 스레드에 넣어 주는 값이다. 필터를 거치지 않는 audit-1 스레드의 컨텍스트는 그냥 비어 있어 getAuthentication()이 null을 돌려준다.', false),
(11962, 4418, '감사 기록 저장이 placeOrder()의 트랜잭션에 참여해, 주문과 함께 커밋된다.', '트랜잭션도 ThreadLocal에 묶여 다른 스레드로 전파되지 않는다. 저장까지 갔더라도 audit-1 스레드의 save는 주문 트랜잭션과 따로 커밋됐을 것이고, 실제로는 그 전에 인증 정보 조회에서 예외로 멈춘다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1428, 4419, 'CallerRunsPolicy,ThreadPoolExecutor.CallerRunsPolicy,java.util.concurrent.ThreadPoolExecutor.CallerRunsPolicy,CallerRuns,Caller Runs Policy,콜러런즈폴리시,콜러 런즈 폴리시,호출자 실행 정책', '큐(100)와 최대 스레드(8)가 모두 찬 뒤 들어온 작업을 버리거나 거부하지 않고, 작업을 제출한 스레드가 직접 실행하게 하는 정책이 CallerRunsPolicy다. 이 API에서 작업을 제출한 쪽은 업로드 요청을 처리하던 톰캣 스레드라 로그에 http-nio 스레드 이름이 찍혔고, 썸네일 생성 약 2초가 응답 시간에 더해져 p99가 2.3초로 뛰었다. 작업을 잃지 않는 대신 호출자를 느리게 만들어 유입 속도를 스스로 늦추는 효과가 있다. 옆 정책과 구분하면, 기본값인 AbortPolicy는 RejectedExecutionException(스프링에서는 TaskRejectedException)을 던져 작업이 실패하고, DiscardPolicy는 새 작업을, DiscardOldestPolicy는 큐에서 가장 오래 기다린 작업을 조용히 버려 누락이 생긴다. 예외도 누락도 없이 톰캣 스레드에서 작업이 실행됐다는 기록은 CallerRunsPolicy만 가리킨다.'),
       (1429, 4420, 'connection-timeout,connectionTimeout,spring.datasource.hikari.connection-timeout,spring.datasource.hikari.connectionTimeout,connection timeout,커넥션 타임아웃,커넥션타임아웃', '풀에서 커넥션을 얻으려고 기다리는 최대 시간이 connection-timeout이고, 기본값이 30,000ms다. 1차 훈련에서는 DB가 내려가 있는 동안 요청마다 getConnection에서 30초씩 기다리다 SQLTransientConnectionException으로 실패했고, 그사이 톰캣 스레드 200개가 모두 대기에 묶여 DB와 무관한 캐시 조회 API까지 멈췄다. 2,000ms로 낮추자 요청이 2초 만에 빠르게 실패해 스레드가 금방 풀려났고, 장애가 다른 API로 번지지 않았다. 헷갈리는 옆 설정과 구분하면, max-lifetime은 커넥션 하나를 풀에 두는 최대 수명, idle-timeout은 쉬고 있는 커넥션을 정리하는 기준, validation-timeout은 커넥션이 살아 있는지 검사하는 데 쓰는 제한 시간이다. @Transactional(timeout)은 트랜잭션 실행 시간에 거는 스프링 쪽 상한으로, 커넥션을 얻기까지의 대기와는 다르다. 기본 30초는 장애 전파 시간을 길게 만들므로 수 초 수준으로 낮춰 빠르게 실패하고 알림을 받는 편이 낫다.');

-- =====================================================
-- Lesson 864: 처리량 계산과 읽기 타임아웃, 피닝
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5363, 864, '아래 조건에서 이 API가 낼 수 있는 최대 처리량(초당 요청 수)은?', '주문 조회 API 한 종류만 받는 서버에 요청을 쉬지 않고 몰아넣는 부하 테스트를 한다. CPU와 DB 자체는 병목이 아니다. 요청 하나는 처리 내내 톰캣 스레드 1개를 쓰고, OSIV가 꺼져 있어 커넥션 1개는 `@Transactional` 구간에서만 쥔다.

| 항목 | 값 |
| --- | --- |
| 톰캣 `server.tomcat.threads.max` | 200 |
| HikariCP `maximum-pool-size` | 10 |
| 요청 하나의 전체 처리 시간 (커넥션 대기가 없을 때) | 100ms |
| 그중 `@Transactional` 구간 | 40ms |', 'OBJECTIVE'),
       (5364, 864, '아래 코드와 조건에서 그 시점 이후에 일어나는 일로 옳은 것은?', 'HikariCP `maximum-pool-size`는 10, `connection-timeout`은 30,000ms다. 이벤트가 열리자 `use()` 요청 10개가 한꺼번에 들어왔고, 10개 모두 `decrease()`를 실행한 뒤 `record()`를 호출했다. 그 밖의 요청은 없다.

```java
@Service
@RequiredArgsConstructor
public class PointService {
    private final PointRepository pointRepository;
    private final PointHistoryService historyService;   // 별도 빈

    @Transactional
    public void use(Long memberId, int amount) {
        pointRepository.decrease(memberId, amount);      // UPDATE 실행
        historyService.record(memberId, amount);
    }
}

@Service
@RequiredArgsConstructor
public class PointHistoryService {
    private final PointHistoryRepository historyRepository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void record(Long memberId, int amount) {
        historyRepository.save(new PointHistory(memberId, amount));
    }
}
```', 'OBJECTIVE'),
       (5365, 864, '아래 코드에서 푸시 서버가 내려가 있는 동안 complete()를 호출한 결과로 옳은 것은?', '`@EnableAsync`가 켜져 있고 `pushExecutor` 빈이 정상 등록돼 있으며, 실행기의 스레드와 큐에는 여유가 충분하다. 비동기 예외 처리기는 따로 등록하지 않았다. 컨트롤러는 주입받은 `OrderService` 빈의 `complete()`를 호출하고, 이 시간대에 푸시 서버는 모든 요청을 실패로 돌려준다.

```java
@Service
@RequiredArgsConstructor
public class OrderService {
    private final OrderRepository orderRepository;
    private final PushService pushService;   // 별도 빈

    @Transactional
    public void complete(Long orderId) {
        Order order = orderRepository.findById(orderId).orElseThrow();
        order.complete();
        try {
            pushService.notifyCompleted(order.getMemberId());
        } catch (PushFailedException e) {    // 런타임 예외
            order.markPushFailed();          // 나중에 다시 보낼 대상으로 표시
        }
    }
}

@Service
@RequiredArgsConstructor
public class PushService {
    private final PushClient pushClient;

    @Async("pushExecutor")
    public void notifyCompleted(Long memberId) {
        pushClient.send(memberId);   // 실패하면 PushFailedException
    }
}
```', 'OBJECTIVE'),
       (5366, 864, '아래 상황에서 reserve()를 처리하던 스레드에 일어나는 일로 옳은 것은?', '배송사 HTTP 클라이언트에는 연결 타임아웃 2,000ms만 설정했고 읽기 타임아웃은 설정하지 않았다. 어느 날 배송사 서버가 TCP 연결은 정상적으로 받아 주면서 응답은 보내지 않는 상태가 됐다.

```java
@Transactional(timeout = 10)   // 초 단위
public void reserve(ReserveRequest req) {
    Reservation reservation = reservationRepository.save(Reservation.from(req));
    reservationRepository.flush();                                 // INSERT 즉시 실행
    DeliverySlot slot = deliveryClient.book(reservation.getId());  // 배송사 HTTP 호출
    reservation.assign(slot);
}
```', 'OBJECTIVE'),
       (5367, 864, '아래 세 정보를 보관하는 저장소들이 공통으로 바탕에 둔 JDK 클래스의 이름은?', '인증을 마친 사용자의 요청을 처리하는 `@Transactional` 메서드 안에서 같은 진단 코드를 두 번 실행했다. 한 번은 요청 스레드에서 바로, 한 번은 이 메서드가 `taskExecutor.submit()`으로 넘긴 작업 안에서다. 스프링 시큐리티의 저장 전략은 기본값이고, `traceId`는 요청 필터에서 MDC에 넣는다.

```java
Authentication auth = SecurityContextHolder.getContext().getAuthentication();
log.info("tx={}, user={}, traceId={}",
        TransactionSynchronizationManager.isActualTransactionActive(),
        auth == null ? null : auth.getName(),
        MDC.get("traceId"));
```

```
[http-nio-8080-exec-3] tx=true, user=kim, traceId=7f2a
[task-2]               tx=false, user=null, traceId=null
```

트랜잭션 동기화 정보, 시큐리티 컨텍스트, MDC는 각각 다른 라이브러리가 관리하지만, 세 저장소 모두 JDK의 같은 클래스 위에 만들어져 있다.', 'SUBJECTIVE'),
       (5368, 864, '아래 상황에서 처리량을 막은 현상을 가리키는 용어는?', 'Spring Boot 3.2 + JDK 21 API 서버에서 `spring.threads.virtual.enabled=true`로 요청 처리를 가상 스레드로 전환했다. 가상 스레드를 실어 나르는 캐리어 스레드는 CPU 코어 수와 같은 8개이고, HikariCP `maximum-pool-size`는 30이다. 쓰고 있던 구버전 JDBC 드라이버는 소켓에서 응답을 읽는 코드를 `synchronized` 블록 안에서 실행한다.

- DB 응답이 느려진 부하 테스트에서, 동시 요청은 수천 개인데 쿼리를 실행 중인 요청은 8개를 넘지 않았다. 커넥션 30개 중 22개 안팎은 놀고 있었고 CPU 사용률은 5% 안팎이었다.
- 스레드 덤프에서 캐리어 스레드에 올라가 실행 중인 가상 스레드는 8개뿐이었고, 8개 모두 드라이버의 소켓 읽기 지점에 머물러 있었다.
- 드라이버를 `synchronized` 대신 `ReentrantLock`을 쓰는 버전으로 올리자, 같은 부하에서 실행 중인 쿼리가 30개까지 늘었다. 드라이버는 그대로 두고 JDK만 24로 올려도 같은 효과가 났다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5363
(14475, 5363, '100', '커넥션을 요청 전체 100ms 동안 쥔다고 보고 10 ÷ 0.1초로 계산한 값. OSIV가 켜져 응답 단계까지 커넥션을 쥘 때의 계산이다. 여기서는 OSIV가 꺼져 있어 커넥션 점유는 트랜잭션 구간 40ms뿐이다.', false),
(14476, 5363, '250', '커넥션 하나가 40ms마다 요청 하나의 트랜잭션을 끝내 초당 25건, 10개면 초당 250건이다. 스레드 쪽 한계(200 ÷ 0.1초 = 2,000건)보다 훨씬 낮으므로, 두 한계 중 작은 쪽인 커넥션 풀이 처리량을 정한다.', true),
(14477, 5363, '2,000', '톰캣 스레드만 보고 200 ÷ 0.1초로 계산한 값. 초당 250건을 넘는 요청은 커넥션을 얻지 못해 대기하므로 스레드가 남아도 처리량은 커넥션 풀에서 막힌다. 스레드만 늘리면 커넥션 대기만 는다.', false),
(14478, 5363, '5,000', '스레드 200개가 모두 40ms마다 요청을 끝낸다고 보고 200 ÷ 0.04초로 계산한 값. 트랜잭션 구간에 동시에 들어갈 수 있는 요청은 커넥션 수인 10개뿐이고, 스레드는 요청 전체 100ms 동안 묶인다.', false),

-- 문제 5364
(14479, 5364, 'record()가 use()의 커넥션을 이어받아 써서, 요청 10개가 모두 곧바로 정상 처리된다.', '기존 트랜잭션에 참여하는 REQUIRED 동작과 혼동한 것. REQUIRES_NEW는 바깥 트랜잭션을 보류하고 새 커넥션으로 별도 트랜잭션을 시작하므로, 요청 하나가 커넥션을 두 개 필요로 한다.', false),
(14480, 5364, 'use()의 트랜잭션이 보류되며 커넥션을 풀에 돌려줘, record()가 차례로 커넥션을 받는다.', '보류(suspend)는 바깥 트랜잭션을 스레드에서 잠시 떼어 둘 뿐 커넥션을 풀에 반환하지 않는다. UPDATE를 실행한 바깥 트랜잭션은 커밋이나 롤백 전까지 그 커넥션을 계속 쥔다.', false),
(14481, 5364, '풀이 모자라면 HikariCP가 최대 크기를 넘겨 커넥션을 임시로 만들어 record()에 내준다.', 'maximum-pool-size는 넘을 수 없는 상한이다. 모자라면 새로 만드는 대신 connection-timeout 동안 반환을 기다리고, 그래도 못 받으면 SQLTransientConnectionException을 던진다.', false),
(14482, 5364, '어느 요청도 커넥션을 돌려주지 못한 채 멈췄다가, 30초 뒤 record()의 커넥션 획득이 실패한다.', '10개 요청이 바깥 트랜잭션용 커넥션 10개를 모두 쥔 채 두 번째 커넥션을 기다려 서로 막히는 풀 데드락이다. 반환될 커넥션이 없어 30초 뒤 예외로 끝나며, 요청마다 커넥션을 두 개 잡는 구조를 없애야 한다.', true),

-- 문제 5365
(14483, 5365, '예외가 catch 블록에서 잡혀, 주문이 재발송 대상으로 표시된 채 커밋된다.', '@Async 호출이 동기 호출처럼 예외를 돌려준다고 본 오개념. notifyCompleted()는 작업을 pushExecutor에 넘기자마자 반환되고, 예외는 그 뒤 다른 스레드에서 나므로 이 try-catch에 닿지 않는다.', false),
(14484, 5365, '예외가 ExecutionException으로 감싸여 catch를 빠져나가고, 주문 완료가 롤백된다.', 'Future.get()으로 결과를 꺼낼 때의 동작과 혼동한 것. void 메서드는 결과를 꺼낼 통로가 없어 호출자 쪽에는 어떤 예외도 올라오지 않고, complete()는 정상 커밋된다.', false),
(14485, 5365, '주문 완료는 커밋되지만 재발송 표시는 남지 않고, 예외는 실행기 쪽 오류 로그로만 남는다.', 'void @Async 메서드의 예외는 호출자에게 전파되지 않아 catch가 실행되지 않고, 기본 처리기가 로그만 남겨 실패가 조용히 묻힌다. CompletableFuture를 반환하거나 AsyncUncaughtExceptionHandler를 등록해 실패를 다뤄야 한다.', true),
(14486, 5365, '실행기가 실패한 작업을 큐에 다시 넣어, 푸시 서버가 살아나면 자동으로 발송된다.', 'ThreadPoolTaskExecutor는 실패한 작업을 재시도하지 않는다. 예외로 끝난 작업은 그대로 사라지므로, 재발송이 필요하면 실패를 기록하는 로직을 비동기 메서드 안에 직접 두어야 한다.', false),

-- 문제 5366
(14487, 5366, '응답이 올 때까지 배송사 호출에서 멈춘 채, 스레드와 커넥션을 계속 붙잡는다.', '연결은 이미 맺어져 연결 타임아웃은 지나간 단계이고, 읽기 타임아웃이 없어 응답을 기한 없이 기다린다. 트랜잭션이 끝나지 않아 커넥션도 반환되지 않으므로, 이런 요청이 쌓이면 커넥션 풀과 톰캣 스레드가 차례로 고갈된다.', true),
(14488, 5366, '10초가 지나면 트랜잭션 제한 시간에 걸려, 배송사 호출이 끊기고 롤백된다.', '트랜잭션 제한 시간은 SQL을 실행하는 시점에 확인·적용될 뿐, 진행 중인 HTTP 호출을 끊지 못한다. 호출이 풀려나기 전에는 효과가 없으므로 외부 호출에는 읽기 타임아웃을 따로 걸어야 한다.', false),
(14489, 5366, '2초가 지나면 연결 타임아웃에 걸려, 배송사 호출이 예외로 끝나고 롤백된다.', '연결 타임아웃은 TCP 연결을 맺기까지의 대기 한도다. 배송사 서버가 연결은 받아 줬으므로 이 한도는 이미 통과했고, 연결 뒤 응답을 기다리는 구간은 읽기 타임아웃이 맡는다.', false),
(14490, 5366, '응답을 기다리는 동안 커넥션은 풀에 돌아가, 다른 요청이 그 커넥션을 쓸 수 있다.', '커넥션은 트랜잭션이 끝나야 반환된다. DB를 쓰지 않는 구간이어도 트랜잭션 안이라면 커넥션은 그대로 묶여 있어, 외부 호출은 트랜잭션 밖으로 빼는 편이 낫다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1744, 5367, 'ThreadLocal,java.lang.ThreadLocal,Thread Local,스레드 로컬,스레드로컬,ThreadLocal 클래스,스레드 로컬 변수', 'ThreadLocal은 같은 변수라도 스레드마다 값을 따로 두게 하는 JDK 클래스다. 스프링의 TransactionSynchronizationManager는 커넥션과 트랜잭션 동기화 정보를, SecurityContextHolder는 기본 전략에서 인증 정보를, 로깅 라이브러리의 MDC는 traceId 같은 로그 컨텍스트를 모두 ThreadLocal에 담는다. 그래서 요청 스레드(exec-3)에서는 세 값이 보이지만, 실행기의 task-2 스레드로 넘어가면 그 스레드 몫의 저장 공간은 비어 있어 tx=false, user=null, traceId=null이 찍힌다. 트랜잭션이 스레드 경계를 넘지 못해 @Async나 parallelStream 안의 작업이 호출자 트랜잭션에 참여하지 못하는 것도 같은 이유다. 헷갈리는 옆 개념과 구분하면, InheritableThreadLocal은 스레드를 새로 만들 때 부모 값을 복사해 주는 하위 클래스지만 미리 만들어 둔 풀 스레드에는 효과가 없고, 이 세 저장소의 기본 설정에서는 쓰이지 않는다. 값을 넘기려면 TaskDecorator나 DelegatingSecurityContextAsyncTaskExecutor로 실행 직전에 복사하고, 작업이 끝나면 비워야 한다.'),
       (1745, 5368, '피닝,pinning,핀닝,고정,피닝 현상,가상 스레드 피닝,가상 스레드 고정,virtual thread pinning,캐리어 스레드 고정,캐리어 고정,스레드 피닝,thread pinning,pinned', 'JDK 21에서 가상 스레드는 블로킹 I/O를 만나면 보통 캐리어 스레드에서 내려와 캐리어를 다른 가상 스레드에 넘겨준다. 그런데 synchronized 블록 안에서 블로킹하면 내려오지 못하고 캐리어를 붙든 채 기다리는데, 이를 피닝(pinning)이라 한다. 이 서버는 드라이버가 synchronized 안에서 소켓을 읽어 캐리어 8개가 모두 붙들렸고, 그래서 수천 개 가상 스레드 중 8개만 진행되며 커넥션과 CPU가 남아돌았다. ReentrantLock은 기다리는 동안 캐리어를 놓아주므로 드라이버 교체로 풀리고, JDK 24(JEP 491)는 synchronized에서도 캐리어를 놓아주도록 바뀌어 드라이버를 그대로 둬도 풀린다. 헷갈리는 옆 개념과 구분하면, 커넥션 풀 고갈은 커넥션이 모두 사용 중이라 getConnection에서 기다리는 상태인데 여기서는 커넥션 22개 안팎이 놀고 있었다. 교착 상태(deadlock)처럼 서로를 영원히 기다리는 것도 아니어서 DB 응답이 오면 진행은 된다. 가상 스레드로 바꿔도 이런 고정 문제와 커넥션 풀 크기 한계는 따로 챙겨야 한다.');
