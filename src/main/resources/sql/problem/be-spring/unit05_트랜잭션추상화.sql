-- Unit: 트랜잭션 추상화 (Unit ID: 116)
-- Chapter: Spring (Chapter ID: 10)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (542, 116, '전파 속성과 자기 호출, 롤백 전용 표시'),
       (700, 116, '체크 예외 롤백과 커넥션 바인딩'),
       (858, 116, '트랜잭션 매니저 선택과 NESTED 전파');

-- =====================================================
-- Lesson 542: 전파 속성과 자기 호출, 롤백 전용 표시
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3431, 542, '아래 메서드를 다른 빈에서 호출했을 때 두 계좌의 최종 잔액으로 옳은 것은?', '```java
@Service
public class TransferService {

    @Transactional
    public void transfer(Long from, Long to, long amount) {
        accountRepository.withdraw(from, amount);
        try {
            accountRepository.deposit(to, amount);   // IllegalStateException 발생
        } catch (RuntimeException e) {
            log.error("입금 실패", e);
        }
    }
}
```

초기 잔액은 from 계좌 10,000원, to 계좌 0원이고 amount는 3,000원이다.', 'OBJECTIVE'),
       (3432, 542, '아래 트랜잭션 전파 속성 비교표를 바탕으로 옳지 않은 것은?', '| 전파 속성 | 기존 트랜잭션이 있을 때 | 기존 트랜잭션이 없을 때 |
|---|---|---|
| REQUIRED | 기존 트랜잭션에 참여 | 새 트랜잭션 생성 |
| REQUIRES_NEW | 기존 트랜잭션을 보류하고 새 트랜잭션 생성 | 새 트랜잭션 생성 |
| NESTED | 세이브포인트 생성(부분 롤백 가능) | 새 트랜잭션 생성 |
| MANDATORY | 기존 트랜잭션에 참여 | 예외 발생 |
| NEVER | 예외 발생 | 트랜잭션 없이 실행 |', 'OBJECTIVE'),
       (3433, 542, '아래 조회 메서드에 대한 설명으로 옳은 것은?', '```java
@Transactional(readOnly = true)
public OrderView findOrder(Long id) {
    Order order = orderRepository.findById(id).orElseThrow();
    order.setMemo("조회됨");
    return OrderView.from(order);
}
```

이 설정에서 하이버네이트는 해당 트랜잭션의 플러시 모드를 MANUAL로 둔다.', 'OBJECTIVE'),
       (3434, 542, '아래 코드에서 sendWelcomeMail이 실행될 때의 트랜잭션 동작으로 옳은 것은?', '```java
@Service
public class UserService {

    @Transactional
    public void register(User user) {
        userRepository.save(user);
        mailService.sendWelcomeMail(user);
        throw new IllegalStateException("가입 검증 실패");
    }
}

@Service
public class MailService {

    @Async
    @Transactional
    public void sendWelcomeMail(User user) {
        mailLogRepository.save(new MailLog(user));
    }
}
```', 'OBJECTIVE'),
       (3435, 542, '아래 코드에서 REQUIRES_NEW가 적용되지 않은 원인이 된 호출 방식을 가리키는 용어는?', '```java
@Service
public class OrderService {

    @Transactional
    public void place(Order order) {
        orderRepository.save(order);
        saveHistory(order);
        validate(order);   // 여기서 RuntimeException 발생
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void saveHistory(Order order) {
        historyRepository.save(new OrderHistory(order));
    }
}
```

place가 롤백되자 주문 이력 행까지 함께 사라졌다. 커넥션 풀 지표를 살펴봐도 saveHistory 구간에서 커넥션이 하나 더 잡힌 흔적은 없었다.', 'SUBJECTIVE'),
       (3436, 542, '아래 로그의 마지막 줄과 함께 호출자에게 던져진 예외의 이름은?', '```
14:02:10.812 DEBUG o.s.orm.jpa.JpaTransactionManager - Creating new transaction with name [OrderService.place]
14:02:10.930 DEBUG o.s.orm.jpa.JpaTransactionManager - Participating in existing transaction
14:02:10.988 DEBUG c.g.order.OrderService - 재고 부족 예외를 catch 하고 주문 처리를 계속 진행
14:02:11.004 DEBUG o.s.orm.jpa.JpaTransactionManager - Participating transaction failed - marking existing transaction as rollback-only
14:02:11.120 ERROR c.g.order.OrderController - Transaction silently rolled back because it has been marked as rollback-only
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3431
(9323, 3431, 'from 계좌 10,000원, to 계좌 0원', '런타임 예외가 났으니 무조건 롤백된다는 오해. 롤백 여부는 예외가 프록시까지 전파됐는지로 판단하는데, catch로 삼킨 예외는 프록시가 알 수 없어 정상 종료로 처리된다.', false),
(9324, 3431, 'from 계좌 7,000원, to 계좌 0원', 'deposit이 던진 예외를 메서드 안에서 삼켜 프록시에 닿지 않으므로 커밋된다. 앞서 실행된 withdraw만 반영돼 돈이 증발한다. 롤백하려면 예외를 다시 던지거나 setRollbackOnly를 호출해야 한다.', true),
(9325, 3431, 'from 계좌 7,000원, to 계좌 3,000원', '커밋된다는 판단까지는 맞지만 deposit이 반영된다고 본 오해. deposit은 예외로 중단돼 입금 자체가 이뤄지지 않는다.', false),
(9326, 3431, 'from 계좌 10,000원, to 계좌 3,000원', 'catch 블록이 그 이전 작업만 되돌린다고 본 오해. 부분 롤백은 세이브포인트를 잡는 NESTED에서나 가능하고, 이 코드에는 세이브포인트가 없다.', false),

-- 문제 3432
(9327, 3432, 'REQUIRED로 선언한 메서드만 이어서 호출하면 물리 트랜잭션은 하나이고 커넥션도 하나만 점유한다.', 'REQUIRED끼리는 기존 트랜잭션에 참여하므로 논리 트랜잭션만 늘고 커넥션은 그대로다. 표와 어긋나지 않는 참인 진술이라 고를 대상이 아니다.', false),
(9328, 3432, 'NESTED로 실행한 부분만 되돌려도 바깥 트랜잭션은 이어서 커밋할 수 있다.', '세이브포인트를 잡아 두었기에 안쪽만 취소하고 바깥은 진행할 수 있다. 다만 JPA는 세이브포인트를 지원하지 않아 NESTED를 쓸 수 없다는 제약이 따로 있다.', false),
(9329, 3432, 'NEVER로 선언한 메서드는 트랜잭션 밖에서 호출하면 정상 실행되고, 트랜잭션 안에서 호출하면 예외가 난다.', '표의 NEVER 행을 그대로 만족하는 참인 진술이다. 트랜잭션이 걸리면 안 되는 작업을 강제로 지키게 할 때 쓴다.', false),
(9330, 3432, 'MANDATORY로 선언한 메서드를 트랜잭션 없이 호출하면 새 트랜잭션이 만들어져 실행된다.', '표에서 MANDATORY는 기존 트랜잭션이 없으면 예외를 던진다. 호출자의 트랜잭션 안에서만 실행되도록 강제하는 속성이라 스스로 트랜잭션을 만들지 않는다. 없을 때 새로 만드는 쪽은 REQUIRED다.', true),

-- 문제 3433
(9331, 3433, 'memo 변경은 UPDATE 문 없이 무시되고 예외도 발생하지 않는다.', '플러시 모드가 MANUAL이라 커밋 시점에 자동 플러시가 일어나지 않고, 그래서 memo 변경이 UPDATE로 나가지 않는다. readOnly는 수정 자체를 막는 장치가 아니어서 예외도 없이 조용히 사라지므로, 반영을 기대하면 원인 추적이 어렵다.', true),
(9332, 3433, '읽기 전용 트랜잭션에서 엔티티를 수정했으므로 예외가 던져지고 트랜잭션이 롤백된다.', 'readOnly는 쓰기를 막는 검증 장치가 아니라 여러 계층에 전달하는 최적화 힌트다. 스프링도 하이버네이트도 수정 코드 자체를 막지는 않는다.', false),
(9333, 3433, 'memo를 바꾼 뒤 EntityManager.flush()를 직접 호출해도 UPDATE 문은 나가지 않는다.', 'MANUAL은 자동 플러시만 끄는 모드다. flush()를 직접 부르면 그때까지 쌓인 변경이 그대로 UPDATE로 나간다. 자동으로 안 나가는 것과 아예 나갈 수 없는 것을 혼동한 오해다.', false),
(9334, 3433, '커밋 시점에 자동 플러시가 일어나 memo 변경이 DB에 반영된다.', '플러시 모드가 기본값 AUTO일 때의 동작을 그대로 적용한 오해. MANUAL이면 커밋 시 자동 플러시가 생략된다.', false),

-- 문제 3434
(9335, 3434, 'register의 트랜잭션에 참여하므로 register가 롤백되면 메일 로그도 함께 사라진다.', '전파 속성이 스레드를 넘어 이어진다고 본 오해. 트랜잭션 자원은 ThreadLocal에 묶여 있어 참여 여부는 같은 스레드 안에서만 판단된다.', false),
(9336, 3434, 'register의 트랜잭션이 잠시 보류되고, 같은 커넥션을 이어받아 새 트랜잭션이 시작된다.', 'REQUIRES_NEW의 보류·재개 동작을 다른 스레드에 옮겨 붙인 오해. 보류와 재개는 같은 스레드의 트랜잭션 자원에만 적용되고 커넥션도 공유되지 않는다.', false),
(9337, 3434, '별도 스레드가 자체 커넥션으로 독립된 트랜잭션을 열어, register가 롤백돼도 메일 로그는 남는다.', '@Async로 다른 스레드에서 실행되면 호출자의 ThreadLocal 트랜잭션 자원에 접근할 수 없다. 붙어 있는 @Transactional이 새 트랜잭션을 열고 독립적으로 커밋하므로 결과가 갈린다.', true),
(9338, 3434, 'register가 커밋을 마칠 때까지 대기했다가 커밋 성공 여부에 따라 실행된다.', '커밋 이후 실행을 보장하려면 @TransactionalEventListener의 AFTER_COMMIT 같은 장치가 필요하다. @Async 호출은 커밋 시점과 무관하게 곧바로 다른 스레드에서 시작된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1100, 3435, 'self-invocation,self invocation,selfinvocation,셀프 인보케이션,셀프인보케이션,내부 호출,내부호출,자기 호출,자기호출,자가 호출', '같은 클래스 안에서 this로 메서드를 부르면 AOP 프록시를 거치지 않아 TransactionInterceptor가 끼어들 자리가 없다. 그래서 saveHistory의 REQUIRES_NEW는 읽히지도 않고 place의 트랜잭션이 그대로 이어지며, 커넥션이 하나 더 잡히지 않은 것도 새 물리 트랜잭션이 아예 생기지 않았기 때문이다. 이력을 남기려면 별도 빈으로 분리해 프록시를 통해 호출해야 한다. 프록시가 메서드를 감쌀 수 없는 private 메서드 문제나, 예외를 catch로 삼켜 롤백 신호가 사라지는 경우와는 원인이 다르다.'),
       (1101, 3436, 'UnexpectedRollbackException,org.springframework.transaction.UnexpectedRollbackException,unexpected rollback exception,언익스펙티드 롤백 익셉션', 'REQUIRED로 참여한 논리 트랜잭션에서 예외가 나면 물리 트랜잭션 전체가 rollback-only로 표시된다. 바깥에서 그 예외를 catch해 정상 흐름으로 돌아와도 커밋 시점에 트랜잭션 매니저가 표시를 확인해 롤백한 뒤 UnexpectedRollbackException을 던진다. 예외를 잡았으니 커밋되겠지라는 기대가 통하지 않는 지점이다. 안쪽 작업만 실패하고 바깥은 살리려면 REQUIRES_NEW로 물리 트랜잭션을 분리해야 한다. 애초에 트랜잭션이 하나뿐이라 롤백 표시가 남지 않고 조용히 커밋되는 예외 삼킴 상황과 구분해야 한다.');

-- =====================================================
-- Lesson 700: 체크 예외 롤백과 커넥션 바인딩
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4379, 700, '아래 네 메서드를 트랜잭션이 없는 컨트롤러에서 한 번씩 호출한 뒤 orders 테이블에 남은 행의 수는?', '```java
public class PaymentDeclinedException extends Exception {
    public PaymentDeclinedException(String message) { super(message); }
}

@Service
public class OrderService {

    @Transactional
    public void placeA(Order order) throws PaymentDeclinedException {
        orderRepository.save(order);
        throw new PaymentDeclinedException("카드 승인 거절");
    }

    @Transactional(rollbackFor = PaymentDeclinedException.class)
    public void placeB(Order order) throws PaymentDeclinedException {
        orderRepository.save(order);
        throw new PaymentDeclinedException("카드 승인 거절");
    }

    @Transactional
    public void placeC(Order order) {
        orderRepository.save(order);
        throw new IllegalStateException("재고 부족");
    }

    @Transactional(noRollbackFor = IllegalStateException.class)
    public void placeD(Order order) {
        orderRepository.save(order);
        throw new IllegalStateException("재고 부족");
    }
}
```

호출 전 orders 테이블은 비어 있다. 네 호출에는 서로 다른 주문 객체를 넘기며, 컨트롤러는 호출마다 던져진 예외를 catch해 로그만 남기고 다음 호출로 넘어간다.', 'OBJECTIVE'),
       (4380, 700, '아래 코드의 트랜잭션 동작에 대한 설명으로 옳은 것은?', '```java
@Component
@RequiredArgsConstructor
public class OrderFacade {

    private final TransactionTemplate txTemplate;
    private final OrderService orderService;
    private final PaymentClient paymentClient;

    public void placeOrder(OrderRequest req) {
        Long orderId = txTemplate.execute(status -> orderService.create(req));
        PaymentResult result = paymentClient.pay(orderId, req.amount());
        txTemplate.executeWithoutResult(status -> orderService.confirm(orderId, result));
    }
}
```

OrderFacade와 OrderService의 메서드에는 @Transactional이 붙어 있지 않다. paymentClient.pay()는 외부 결제 서버를 HTTP로 호출하며, 응답이 늦으면 런타임 예외를 던진다.', 'OBJECTIVE'),
       (4381, 700, '아래 환경에서 세 메서드에 적용되는 트랜잭션에 대한 설명으로 옳은 것은?', '```java
@Service
@Transactional(readOnly = true)
public class MemberService {

    private final MemberRepository memberRepository;

    public MemberService(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }

    public Member find(Long id) {
        return memberRepository.findById(id).orElseThrow();
    }

    @Transactional
    public void rename(Long id, String name) {
        memberRepository.findById(id).orElseThrow().changeName(name);
    }

    @Transactional
    void resetPoint(Long id) {
        memberRepository.findById(id).orElseThrow().resetPoint();
    }
}
```

Spring Framework 6.1 기반의 JPA 애플리케이션이며, MemberService는 인터페이스 없이 CGLIB 프록시로 감싸진다. 같은 패키지에 있는 다른 빈이 세 메서드를 호출한다.', 'OBJECTIVE'),
       (4382, 700, '아래 상황에서 이어지는 결과로 옳은 것은?', '```java
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final AuditService auditService;

    @Transactional
    public void place(Order order) {
        orderRepository.save(order);
        auditService.log(order.getId());
    }
}

@Service
@RequiredArgsConstructor
public class AuditService {

    private final AuditLogRepository auditLogRepository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void log(Long orderId) {
        auditLogRepository.save(new AuditLog(orderId));
    }
}
```

커넥션 풀의 최대 크기는 10개이고, 풀에서 커넥션을 기다리는 제한 시간은 30초다. 요청 10개가 동시에 들어와 각각 place()의 트랜잭션을 시작하며 커넥션을 하나씩 잡았고, 그 상태에서 10개 요청 모두 auditService.log()를 호출했다. 그 사이 다른 요청은 들어오지 않았다.', 'OBJECTIVE'),
       (4383, 700, '아래 로그에서 PointRepository.add만 다른 connection 값을 받은 원인이 되는, 스프링이 내부에서 쓰는 자바 표준 클래스의 이름은?', '```
[http-nio-8080-exec-3] OrderService.place       - 트랜잭션 시작, connection=HikariProxyConnection@1a2b3c
[http-nio-8080-exec-3] OrderRepository.save     - connection=HikariProxyConnection@1a2b3c
[http-nio-8080-exec-3] StockRepository.decrease - connection=HikariProxyConnection@1a2b3c
[pool-2-thread-1]      PointRepository.add      - connection=HikariProxyConnection@7d4e5f
[http-nio-8080-exec-3] OrderService.place       - 롤백 완료
```

place()는 @Transactional 메서드이고, 세 리포지토리는 모두 커넥션을 파라미터로 받지 않는다. place() 안에서 PointRepository.add()만 ExecutorService에 넘겨 실행했는데, place()가 롤백된 뒤 주문·재고 변경은 취소되고 포인트 적립만 DB에 남았다.', 'SUBJECTIVE'),
       (4384, 700, '아래 변화를 가져오도록 @Transactional에 추가한 속성의 이름은?', '주문 내역 화면의 조회 메서드 findHistory()에는 `@Transactional`만 붙어 있었고, 이 메서드는 주문 엔티티 3만 건을 불러와 DTO로 바꿔 반환한다. 애플리케이션은 JPA(하이버네이트)를 쓰며, 쓰기 DB와 읽기 복제본을 나눠 쓰는 라우팅 데이터소스가 설정돼 있다. 애노테이션에 속성 하나만 추가해 배포했더니 아래 변화가 나타났다.

| 지표 | 추가 전 | 추가 후 |
|---|---|---|
| 호출 1회당 힙 사용 증가량 | 약 48MB | 약 27MB |
| 커밋 직전 엔티티 변경 여부 비교 시간 | 약 310ms | 0ms |
| 쿼리가 나간 DB | primary-db | replica-db |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4379
(11851, 4379, '0개', '예외가 나면 종류와 설정에 상관없이 롤백된다고 본 오해. 체크 예외는 기본 규칙상 커밋되고, noRollbackFor로 지정한 런타임 예외도 커밋되므로 placeA와 placeD의 주문은 남는다.', false),
(11852, 4379, '1개', '체크 예외도 기본으로 롤백된다고 봤거나 noRollbackFor를 놓친 계산. 체크 예외만 던진 placeA는 기본 규칙상 커밋되고, placeD는 noRollbackFor로 롤백 대상에서 빠져 커밋되므로 두 건이 남는다.', false),
(11853, 4379, '2개', 'placeA는 체크 예외라 기본 규칙대로 커밋, placeB는 rollbackFor로 롤백, placeC는 런타임 예외라 롤백, placeD는 noRollbackFor로 커밋된다. 예외는 모두 컨트롤러까지 전파되지만 커밋 여부는 롤백 규칙이 정한다.', true),
(11854, 4379, '4개', '컨트롤러의 catch를 메서드 안에서 예외를 삼킨 것과 같다고 본 오해. 예외가 프록시를 지나는 순간 롤백 여부가 이미 결정되므로, 프록시 바깥에서 잡아도 롤백된 트랜잭션이 다시 커밋되지 않는다.', false),

-- 문제 4380
(11855, 4380, 'pay()가 예외를 던지면 create()로 저장한 주문은 커밋된 채 남고 confirm()은 실행되지 않는다.', 'execute()는 람다가 정상 반환되면 그 자리에서 커밋하고 끝난다. 결제 호출은 이미 끝난 트랜잭션 밖이라 예외가 나도 되돌릴 대상이 없다. 트랜잭션을 짧게 나눈 대가로, 남은 주문을 취소하는 보상 처리가 따로 필요하다.', true),
(11856, 4380, '두 execute 블록이 하나의 물리 트랜잭션으로 묶여, pay()가 실패하면 주문 저장도 롤백된다.', '한 메서드 안의 트랜잭션 블록이 모두 이어진다고 본 오해. 바깥에 진행 중인 트랜잭션이 없으므로 execute()마다 새 트랜잭션을 열고, 블록이 끝날 때 각각 커밋한다.', false),
(11857, 4380, 'OrderFacade에 @Transactional이 없으므로 두 execute 블록도 트랜잭션 없이 실행된다.', '트랜잭션은 애노테이션으로만 열린다고 본 오해. TransactionTemplate은 트랜잭션 매니저로 직접 시작·커밋·롤백하는 프로그래밍 방식이라 애노테이션 없이도 블록 단위로 트랜잭션이 걸린다.', false),
(11858, 4380, 'execute에 넘긴 람다는 별도 스레드에서 실행되어 호출자 스레드의 트랜잭션과 분리된다.', '람다를 비동기 실행으로 오해. execute()는 호출한 스레드에서 람다를 곧바로 실행하고, 트랜잭션 자원도 그 스레드에 묶인 채 쓰인다. 트랜잭션이 스레드를 넘지 못한다는 제약이 끼어들 여지가 없는 코드다.', false),

-- 문제 4381
(11859, 4381, 'find()는 메서드에 @Transactional이 없어 트랜잭션 없이 실행된다.', '애노테이션이 붙은 메서드에만 트랜잭션이 걸린다고 본 오해. 클래스에 붙인 @Transactional은 그 클래스의 모든 public 메서드에 적용되므로 find()는 읽기 전용 트랜잭션 안에서 실행된다.', false),
(11860, 4381, 'resetPoint()는 패키지 접근 메서드여도 쓰기 가능한 트랜잭션으로 실행된다.', 'Spring Framework 6.0부터 CGLIB 프록시는 protected·패키지 접근 메서드에도 트랜잭션을 적용한다. 메서드에 붙인 @Transactional이 클래스의 readOnly 설정을 덮어써 쓰기 가능한 트랜잭션이 되고, 변경 감지로 UPDATE가 나간다.', true),
(11861, 4381, 'rename()에는 클래스의 readOnly = true가 함께 적용되어 이름 변경이 반영되지 않는다.', '클래스와 메서드의 설정이 합쳐진다고 본 오해. 메서드에 붙인 @Transactional이 클래스 설정을 통째로 덮어쓰므로 rename()은 readOnly가 기본값 false인 트랜잭션으로 실행된다.', false),
(11862, 4381, 'rename()을 호출하면 클래스용과 메서드용 트랜잭션이 따로 열려 커넥션을 두 개 쓴다.', '애노테이션 개수만큼 트랜잭션이 생긴다고 본 오해. 프록시는 메서드에 적용할 트랜잭션 설정을 하나만 골라 쓰며, 메서드에 설정이 있으면 그것으로 트랜잭션 하나만 연다.', false),

-- 문제 4382
(11863, 4382, 'log()가 place()의 커넥션을 이어받아 10개 요청이 모두 곧바로 처리된다.', 'REQUIRED의 참여 동작을 REQUIRES_NEW에 옮겨 붙인 오해. REQUIRES_NEW는 기존 트랜잭션에 참여하지 않고 새 물리 트랜잭션을 열기 때문에 커넥션이 하나 더 필요하다.', false),
(11864, 4382, 'place()의 트랜잭션이 보류되며 커넥션이 풀로 반납되고, log()가 그 커넥션을 쓴다.', '보류를 커넥션 반납으로 오해. 보류는 바깥 트랜잭션 자원을 잠시 떼어 두는 것일 뿐 커넥션은 여전히 place()가 쥐고 있고, log()가 끝나면 그대로 이어서 쓴다.', false),
(11865, 4382, '먼저 요청한 5개는 커넥션을 두 개씩 확보해 처리되고, 나머지 5개만 기다린다.', '풀 크기를 요청당 필요한 커넥션 수로 나눠 본 오해. 본문에서는 10개 요청이 이미 커넥션을 하나씩 잡아 풀이 비어 있으므로 두 번째 커넥션을 먼저 얻을 수 있는 요청이 없다.', false),
(11866, 4382, 'log()가 새 커넥션을 기다리지만 반납되는 커넥션이 없어 제한 시간이 지나면 예외가 난다.', 'REQUIRES_NEW는 바깥 커넥션을 쥔 채 커넥션을 하나 더 요청한다. 10개 요청이 모두 첫 커넥션을 쥐고 두 번째를 기다리니 서로 반납을 기다리는 교착이 되고, 제한 시간이 지나야 커넥션 획득 실패 예외로 풀린다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1416, 4383, 'ThreadLocal,java.lang.ThreadLocal,thread local,thread-local,스레드 로컬,스레드로컬,스레드 로컬 변수,스레드 지역 변수', 'ThreadLocal은 같은 변수라도 스레드마다 값을 따로 들고 있게 해 주는 자바 표준 클래스다. 스프링의 트랜잭션 동기화(TransactionSynchronizationManager)는 트랜잭션을 시작할 때 얻은 커넥션을 ThreadLocal에 묶어 두고, 같은 스레드의 리포지토리가 커넥션을 요청하면 묶여 있는 것을 꺼내 준다. 그래서 exec-3 스레드의 세 호출은 같은 커넥션(@1a2b3c)을 써서 함께 롤백됐지만, pool-2-thread-1에서는 묶인 커넥션이 보이지 않아 다른 커넥션(@7d4e5f)으로 따로 처리돼 적립이 남았다. TransactionSynchronizationManager는 이 저장소를 관리하는 스프링 클래스이고 ThreadLocal은 값을 실제로 스레드별로 나눠 담는 자바 표준 클래스라는 점에서 구분된다. 또한 커넥션을 스레드에 묶는 것은 트랜잭션 동기화의 동작이며, 한 번 만든 커넥션을 여러 요청이 돌려 쓰게 하는 커넥션 풀의 역할과는 다르다.'),
       (1417, 4384, 'readOnly,readOnly = true,readOnly=true,read only,read-only,읽기 전용,읽기전용,읽기 전용 트랜잭션,리드온리,리드 온리', 'readOnly = true는 이 트랜잭션이 읽기만 한다는 사실을 여러 계층에 알리는 최적화 힌트다. 하이버네이트는 플러시 모드를 MANUAL로 두고 엔티티를 읽기 전용으로 불러와 변경 감지용 스냅샷을 만들지 않으므로, 힙 사용이 줄고 커밋 직전의 변경 비교(더티 체킹)도 사라진다. JDBC 커넥션에도 읽기 전용 힌트가 전달되고, 라우팅 데이터소스는 이 표시를 보고 쿼리를 읽기 복제본으로 보낸다. 같은 @Transactional 속성이라도 isolation은 동시에 실행되는 트랜잭션끼리 서로의 변경을 어디까지 보게 할지 정하는 격리 수준 설정이라 이런 효과가 없고, timeout은 제한 시간을 넘긴 트랜잭션을 롤백시킬 뿐 조회 비용을 줄이지 않는다. 또한 readOnly는 쓰기를 막는 검증 장치가 아니어서, 엔티티를 고쳐도 예외 없이 DB에 반영만 되지 않는다는 점을 함께 기억해야 한다.');

-- =====================================================
-- Lesson 858: 트랜잭션 매니저 선택과 NESTED 전파
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5327, 858, '아래 코드에서 트랜잭션이 없는 컨트롤러가 place()를 호출했을 때의 결과로 옳은 것은?', '```java
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final PointService pointService;

    @Transactional
    public void place(Order order) {
        orderRepository.save(order);
        try {
            pointService.earn(order.getMemberId(), 100);
        } catch (RuntimeException e) {
            log.warn("포인트 적립 실패", e);
        }
    }
}

@Service
@RequiredArgsConstructor
public class PointService {

    private final PointHistoryRepository pointHistoryRepository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void earn(Long memberId, int amount) {
        pointHistoryRepository.save(new PointHistory(memberId, amount));
        throw new IllegalStateException("일일 적립 한도 초과");
    }
}
```

호출 전 주문 테이블과 포인트 이력 테이블은 모두 비어 있다.', 'OBJECTIVE'),
       (5328, 858, '아래 환경에서 settle()을 호출했을 때의 동작으로 옳은 것은?', '스프링 부트 프로젝트로, 클래스패스에 Spring Data JPA와 MyBatis가 함께 있고 둘은 같은 DataSource를 쓴다. 트랜잭션 매니저 빈은 직접 등록하지 않았으며, settle()은 트랜잭션이 없는 컨트롤러에서 호출된다.

```java
@Service
@RequiredArgsConstructor
public class SettlementService {

    private final OrderRepository orderRepository;     // Spring Data JPA
    private final SettlementMapper settlementMapper;   // MyBatis 매퍼

    @Transactional
    public void settle(Long orderId) {
        Order order = orderRepository.findById(orderId).orElseThrow();
        order.markSettled();
        settlementMapper.insert(orderId, order.getAmount());   // 호출 즉시 INSERT 실행
        throw new IllegalStateException("정산 금액 검증 실패");
    }
}
```', 'OBJECTIVE'),
       (5329, 858, '아래 코드에서 다른 빈이 stamp()를 호출했을 때의 결과로 옳은 것은?', '```java
@Service
public class StampService {

    private final StampRepository stampRepository;

    public StampService(StampRepository stampRepository) {
        this.stampRepository = stampRepository;
    }

    @Transactional
    public final void stamp(Long memberId) {
        stampRepository.save(new Stamp(memberId));
    }
}
```

StampService는 인터페이스를 구현하지 않은 스프링 빈이다. 다른 빈은 생성자로 주입받은 stampService를 통해 stamp()를 호출한다.', 'OBJECTIVE'),
       (5330, 858, '이미 이 쿠폰을 받은 회원으로 issue()를 호출했을 때의 결과로 옳은 것은?', '```java
@Service
@RequiredArgsConstructor
public class CouponService {

    private final CouponRepository couponRepository;
    private final MemberCouponRepository memberCouponRepository;

    @Transactional
    public IssueResult issue(Long memberId, Long couponId) {
        couponRepository.decreaseStock(couponId);
        try {
            memberCouponRepository.insert(memberId, couponId);
        } catch (DuplicateCouponException e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return IssueResult.duplicated();
        }
        return IssueResult.issued();
    }
}
```

호출 전 쿠폰 재고는 100개다. 두 리포지토리는 JdbcTemplate으로 SQL을 바로 실행하며 @Transactional이 붙어 있지 않다. 이미 발급받은 회원이면 insert()가 DuplicateCouponException(RuntimeException 하위)을 던진다. issue()는 트랜잭션이 없는 컨트롤러에서 호출된다.', 'OBJECTIVE'),
       (5331, 858, '아래 결과가 나온 원인으로, record() 실행 중 감사 DB 커넥션이 놓여 있던 모드를 가리키는 용어는?', '```java
@Configuration
public class TxConfig {

    @Bean
    @Primary
    public PlatformTransactionManager orderTxManager(
            @Qualifier("orderDataSource") DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }

    @Bean
    public PlatformTransactionManager auditTxManager(
            @Qualifier("auditDataSource") DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }
}

@Service
public class AuditService {

    private final JdbcTemplate auditJdbcTemplate;   // auditDataSource로 만든 JdbcTemplate

    public AuditService(@Qualifier("auditJdbcTemplate") JdbcTemplate auditJdbcTemplate) {
        this.auditJdbcTemplate = auditJdbcTemplate;
    }

    @Transactional
    public void record(Long orderId) {
        auditJdbcTemplate.update("INSERT INTO audit_log(order_id) VALUES (?)", orderId);
        throw new IllegalStateException("감사 항목 검증 실패");
    }
}
```

orderDataSource는 주문 DB를, auditDataSource는 감사 DB를 가리키며 두 커넥션 풀 모두 기본 설정을 그대로 쓴다. 트랜잭션이 없는 컨트롤러에서 record()를 호출하자 IllegalStateException이 컨트롤러까지 전달됐지만, 감사 DB의 audit_log에는 방금 넣은 행이 그대로 남아 있었다.', 'SUBJECTIVE'),
       (5332, 858, '아래 로그가 남도록 importRow()의 @Transactional에 지정한 설정 값은?', '애플리케이션은 MyBatis와 DataSourceTransactionManager를 쓴다. importRow()는 다른 빈인 RowImporter의 메서드이고, @Transactional에 설정 하나가 지정돼 있다. 두 번째 행은 INSERT 직후 검증에서 InvalidRowException(RuntimeException 하위)이 났고, 실행이 끝난 뒤 product 테이블에는 A-100과 A-102만 남았다.

```java
@Slf4j
@Service
@RequiredArgsConstructor
public class ImportService {

    private final RowImporter rowImporter;

    @Transactional
    public void importAll(List<ProductRow> rows) {
        for (ProductRow row : rows) {
            try {
                rowImporter.importRow(row);
            } catch (InvalidRowException e) {
                log.warn("잘못된 행 건너뜀: {}", row.sku());
            }
        }
    }
}
```

DB 쪽 SQL 로그 (대괄호 안은 커넥션 번호)

```
[conn-17] BEGIN
[conn-17] SAVEPOINT SAVEPOINT_1
[conn-17] INSERT INTO product(sku, name) VALUES (''A-100'', ''무선 마우스'')
[conn-17] RELEASE SAVEPOINT SAVEPOINT_1
[conn-17] SAVEPOINT SAVEPOINT_2
[conn-17] INSERT INTO product(sku, name) VALUES (''A-101'', ''기계식 키보드'')
[conn-17] ROLLBACK TO SAVEPOINT SAVEPOINT_2
[conn-17] RELEASE SAVEPOINT SAVEPOINT_2
[conn-17] SAVEPOINT SAVEPOINT_3
[conn-17] INSERT INTO product(sku, name) VALUES (''A-102'', ''USB 허브'')
[conn-17] RELEASE SAVEPOINT SAVEPOINT_3
[conn-17] COMMIT
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5327
(14379, 5327, '주문과 포인트 이력이 모두 롤백되고, 호출자에게 UnexpectedRollbackException이 던져진다.', 'REQUIRED로 참여했을 때의 동작을 옮겨 붙인 오해. REQUIRES_NEW인 earn()은 별도 물리 트랜잭션이라 실패해도 바깥 트랜잭션에 롤백 표시를 남기지 않고, 바깥은 예외를 catch해 정상 종료했으므로 커밋된다.', false),
(14380, 5327, '주문은 커밋되고 포인트 이력은 롤백되며, 호출자는 예외 없이 정상 반환받는다.', 'earn()은 바깥 트랜잭션을 보류하고 새 커넥션으로 독립된 물리 트랜잭션을 열며, 예외가 자기 프록시를 지날 때 그 트랜잭션만 롤백된다. 예외는 place()의 catch에서 멈추므로 바깥 프록시는 정상 종료로 보고 주문을 커밋한다.', true),
(14381, 5327, '주문과 포인트 이력이 모두 커밋되고, 호출자는 예외 없이 정상 반환받는다.', 'place()에서 예외를 삼켰으니 전부 커밋된다고 본 오해. 롤백 여부는 트랜잭션마다 자기 프록시가 판단하며, earn()의 프록시는 런타임 예외가 지나가는 것을 보고 자기 트랜잭션을 이미 롤백했다.', false),
(14382, 5327, '포인트 이력은 커밋되고 주문은 롤백되며, 호출자에게 IllegalStateException이 전달된다.', '안쪽 트랜잭션은 먼저 끝나 확정되고 예외는 바깥만 되돌린다고 본 오해. earn()은 예외로 끝났으므로 자기 트랜잭션을 롤백하고, 그 예외는 place()가 catch해 호출자까지 전달되지 않는다.', false),

-- 문제 5328
(14383, 5328, 'MyBatis는 JPA 트랜잭션에 참여하지 못해, 정산 INSERT는 그대로 남고 주문 변경만 롤백된다.', 'JPA와 JDBC 기반 기술은 트랜잭션이 따로 논다고 본 오해. JpaTransactionManager는 JPA가 쓰는 JDBC 커넥션도 스레드에 함께 묶어 두므로, 같은 DataSource를 쓰는 MyBatis도 그 커넥션으로 같은 트랜잭션에 들어간다.', false),
(14384, 5328, '트랜잭션 매니저 빈이 없어 @Transactional이 적용되지 않고, 정산 INSERT는 실행 즉시 커밋된다.', '스프링 부트의 자동 설정을 놓친 오해. 클래스패스에 JPA가 있으면 스프링 부트가 JpaTransactionManager를 자동 등록하므로, 직접 등록하지 않아도 settle()에는 트랜잭션이 걸린다.', false),
(14385, 5328, '주문 변경은 변경 감지로 예외와 상관없이 UPDATE가 반영되고, 정산 INSERT만 롤백된다.', '변경 감지 결과는 무조건 반영된다고 본 오해. 변경 감지는 커밋 직전 플러시에서 UPDATE로 바뀌는데, 런타임 예외로 롤백이 정해지면 커밋과 플러시가 일어나지 않아 주문 변경도 반영되지 않는다.', false),
(14386, 5328, 'MyBatis도 JPA가 잡은 커넥션을 그대로 쓰므로, 주문 변경과 정산 INSERT가 함께 롤백된다.', '스프링 부트가 자동 등록한 JpaTransactionManager는 트랜잭션을 시작하며 얻은 JDBC 커넥션을 트랜잭션 동기화로 스레드에 묶어 둔다. MyBatis 매퍼도 그 커넥션을 꺼내 쓰므로 런타임 예외로 롤백되면 INSERT까지 함께 취소된다.', true),

-- 문제 5329
(14387, 5329, '프록시 객체에서 그대로 실행되어, 필드가 null이라 NullPointerException이 난다.', 'CGLIB 프록시는 대상 클래스를 상속해 메서드를 재정의하는 방식이라 final 메서드는 가로채지 못한다. 호출은 생성자를 거치지 않고 만든 프록시 객체에서 원래 코드로 실행되고, 그 객체의 필드는 주입되지 않아 null이다.', true),
(14388, 5329, '트랜잭션만 걸리지 않은 채 대상 객체에서 실행되어, 저장은 곧바로 DB에 반영된다.', 'final이면 트랜잭션만 빠질 뿐 대상 객체가 실행된다고 본 오해. 대상 객체로 호출을 넘기는 일도 재정의된 프록시 메서드가 하므로, 재정의가 막힌 final 메서드는 넘겨지지 않고 프록시 객체에서 실행된다.', false),
(14389, 5329, 'final 메서드는 프록시로 감쌀 수 없어 애플리케이션 시작 단계에서 빈 생성이 실패한다.', '프록시 생성 자체가 막힌다고 본 오해. 클래스 전체가 final이면 상속이 안 돼 시작 단계에서 실패하지만, 메서드만 final이면 스프링은 디버그 로그만 남기고 프록시를 만들어 문제가 호출 시점에 드러난다.', false),
(14390, 5329, '프록시가 대상 객체로 호출을 넘겨, 트랜잭션 안에서 저장이 정상적으로 커밋된다.', 'final이 프록시 동작에 영향을 주지 않는다고 본 오해. CGLIB 프록시는 하위 클래스에서 메서드를 재정의해 트랜잭션을 끼워 넣는데, final 메서드는 재정의할 수 없어 트랜잭션 처리도 대상 위임도 일어나지 않는다.', false),

-- 문제 5330
(14391, 5330, '재고는 99개로 커밋되고, 호출자는 예외 없이 duplicated 결과를 받는다.', 'catch로 예외를 삼키면 무조건 커밋된다고 본 오해. 예외는 프록시에 닿지 않았지만 setRollbackOnly()로 현재 트랜잭션에 롤백 표시를 남겼으므로, 프록시는 커밋 대신 롤백한다.', false),
(14392, 5330, '재고는 100개로 돌아가고, 호출자에게 UnexpectedRollbackException이 던져진다.', '참여한 안쪽 트랜잭션이 롤백 표시를 남긴 경우와 혼동한 오해. 그 예외는 커밋을 요청한 쪽이 모르는 롤백일 때 난다. 가장 바깥 트랜잭션의 코드가 직접 롤백을 요청하면 예외 없이 조용히 롤백된다.', false),
(14393, 5330, '재고는 100개로 돌아가고, 호출자는 예외 없이 duplicated 결과를 받는다.', 'setRollbackOnly()는 예외를 던지지 않고 현재 트랜잭션에 롤백 표시만 남긴다. 메서드가 정상 반환되면 프록시가 커밋하려다 표시를 보고 롤백하므로, 재고 차감은 취소되고 반환값은 그대로 호출자에게 간다.', true),
(14394, 5330, '재고는 100개로 돌아가고, 호출자에게 DuplicateCouponException이 다시 전파된다.', 'setRollbackOnly()가 잡은 예외를 다시 던진다고 본 오해. 이 메서드는 롤백 표시만 남길 뿐 예외를 만들지 않으며, catch 블록이 결과 객체를 반환하므로 호출자는 예외를 받지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1732, 5331, '자동 커밋,자동커밋,자동 커밋 모드,오토 커밋,오토커밋,auto commit,autocommit,auto-commit,autocommit 모드,autoCommit=true,autoCommit = true', '한정자 없는 @Transactional은 @Primary가 붙은 orderTxManager를 쓴다. 그래서 트랜잭션은 주문 DB 커넥션을 얻어 autoCommit=false로 바꾼 뒤 그 커넥션에만 걸린다. JdbcTemplate이 감사 DB에서 받은 커넥션은 풀 기본값인 자동 커밋 모드 그대로여서 INSERT가 실행되는 즉시 확정됐고, 예외 뒤의 롤백은 아무것도 바꾸지 않은 주문 DB 커넥션에만 적용됐다. IllegalStateException은 런타임 예외라 롤백 규칙상 롤백 대상이 맞으므로, 행이 남은 원인은 롤백 규칙이 아니라 트랜잭션이 엉뚱한 DB에 걸린 데 있다. 감사 로그를 함께 되돌리려면 @Transactional(transactionManager = "auditTxManager")처럼 매니저를 지정해야 한다. 다만 주문 DB와 감사 DB의 변경을 한 트랜잭션으로 묶는 일은 매니저 지정만으로는 안 되고 JtaTransactionManager 같은 분산 트랜잭션 구성이 따로 필요하다는 점과 구분해야 한다.'),
       (1733, 5332, 'NESTED,Propagation.NESTED,propagation = Propagation.NESTED,propagation=Propagation.NESTED,PROPAGATION_NESTED,네스티드,중첩,중첩 트랜잭션', 'NESTED는 이미 진행 중인 트랜잭션 안에서 JDBC 세이브포인트를 잡고 실행한다. 로그에서 모든 SQL이 같은 conn-17로 나가고 importRow() 호출마다 SAVEPOINT가 잡힌 것, 예외가 난 두 번째 행만 ROLLBACK TO SAVEPOINT로 되돌린 뒤 마지막 COMMIT 한 번으로 나머지가 확정된 것이 그 흔적이다. 세이브포인트는 바깥 트랜잭션의 일부라, 바깥이 롤백되면 이미 RELEASE된 행까지 함께 취소된다. REQUIRES_NEW였다면 호출마다 다른 커넥션에서 독립된 트랜잭션이 열려 행마다 따로 COMMIT됐을 것이고, REQUIRED였다면 두 번째 행의 예외로 전체에 롤백 표시가 남아 커밋 시점에 모두 롤백되고 UnexpectedRollbackException이 났을 것이다. 또한 NESTED는 JDBC 세이브포인트에 기대므로 이 문제처럼 DataSourceTransactionManager 환경에서 쓸 수 있고, JPA의 JpaTransactionManager는 기본 설정에서 NESTED를 허용하지 않는다.');
