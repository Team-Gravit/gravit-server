-- Unit: AOP와 프록시 동작 (Unit ID: 113)
-- Chapter: Spring (Chapter ID: 10)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (539, 113, 'Aspect 실행 순서와 포인트컷'),
       (697, 113, 'JDK 동적 프록시와 자기 호출 한계'),
       (855, 113, '위빙 시점과 횡단 관심사, 캐시 프록시');

-- =====================================================
-- Lesson 539: Aspect 실행 순서와 포인트컷
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3413, 539, '아래 두 AOP 적용 방식을 비교한 표에 대한 설명으로 옳은 것은?', '| 항목 | 방식 A | 방식 B |
| --- | --- | --- |
| 부가 기능 결합 시점 | 애플리케이션 기동 중 빈 초기화 마지막 단계 | 컴파일 또는 클래스 로드 시점 |
| 결합 방법 | 대상과 같은 타입의 대리 객체를 만들어 빈으로 등록 | 클래스 파일의 바이트코드를 직접 수정 |
| 포인트컷 표현식 | 방식 B의 execution(..) 문법을 그대로 빌려 씀 | 자체 문법 |
| 추가 빌드 설정 | 필요 없음 | 컴파일러 플러그인 또는 자바 에이전트 필요 |', 'OBJECTIVE'),
       (3414, 539, '아래 코드에서 외부 호출로 generateAll이 실행되던 중 두 번째 건에서 예외가 발생했다. 그 결과로 옳은 것은?', '```java
@Service
@RequiredArgsConstructor
public class ReportService {

    private final ReportRepository reportRepository;

    @Transactional
    public void generateAll(List<Long> ids) {
        for (Long id : ids) {
            generateOne(id);
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void generateOne(Long id) {
        reportRepository.save(Report.of(id));
    }
}
```

```java
// 호출부 (다른 빈에서 주입받아 호출)
reportService.generateAll(List.of(1L, 2L, 3L));   // id=2 처리 중 RuntimeException 발생
```', 'OBJECTIVE'),
       (3415, 539, '아래 실행 로그에 대한 설명으로 옳지 않은 것은?', '같은 메서드에 두 Aspect가 적용돼 있다.

- LoggingAspect: @Order(1)
- MetricAspect: @Order(2)

주문 API를 한 번 호출한 뒤 남은 로그는 아래와 같다.

```
[LoggingAspect] enter createOrder
[MetricAspect]  enter createOrder
[OrderService]  createOrder 본문 실행
[MetricAspect]  exit  createOrder (12 ms)
[LoggingAspect] exit  createOrder (15 ms)
```', 'OBJECTIVE'),
       (3416, 539, '아래 상황에서 스프링이 만든 프록시에 대한 설명으로 옳은 것은?', 'OrderService는 인터페이스를 구현하지 않은 구체 클래스이고, 클래스 안 메서드에 @Transactional이 붙어 있다. 스프링 부트 애플리케이션을 기본 설정으로 띄우자 트랜잭션이 정상 동작했고, 다른 빈에는 OrderService 타입 그대로 주입됐다. 이후 클래스 선언만 public final class OrderService로 바꾸자, 기동 중 프록시를 만들지 못해 애플리케이션이 뜨지 않았다.', 'OBJECTIVE'),
       (3417, 539, '아래에서 두 실행 결과의 차이를 만든 AOP 구성 요소의 이름은?', '감사 로그를 남기는 Aspect를 하나 두고, @Around에 적은 표현식만 바꿔 같은 요청을 두 번 처리했다. Advice 메서드 본문은 한 줄도 고치지 않았다.

```
execution(* com.app..*Service.*(..))  ->  감사 로그 8줄,   응답 시간 40 ms
execution(* com.app..*(..))           ->  감사 로그 341줄, 응답 시간 260 ms
```', 'SUBJECTIVE'),
       (3418, 539, '아래 Aspect가 의도대로 동작하려면 빈칸에 들어가야 하는 애노테이션은?', '```java
@Aspect
@Component
public class PriceFallbackAspect {

    // 외부 시세 API가 죽어도 화면이 깨지지 않도록
    // 예외를 잡아 기본 시세를 대신 돌려준다.
    @____("execution(* com.app.pricing..*(..))")
    public Object withFallback(ProceedingJoinPoint pjp) throws Throwable {
        try {
            return pjp.proceed();
        } catch (PricingApiException e) {
            return Price.defaultPrice();
        }
    }
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3413
(9275, 3413, '방식 A는 대리 객체를 거치므로 원본 클래스의 private 메서드에도 부가 기능을 적용할 수 있다.', '대리 객체는 대상을 상속하거나 인터페이스를 구현해 만들므로, 오버라이드할 수 없는 private 메서드는 애초에 가로챌 지점이 되지 못한다. 대리 객체를 거치면 무엇이든 잡힌다고 본 오해다.', false),
(9276, 3413, '방식 B는 대리 객체를 두지 않으므로 필드 접근이나 생성자 호출 시점에도 부가 기능을 끼워 넣을 수 있다.', '바이트코드를 직접 고치면 개입 지점이 메서드 실행으로 묶이지 않는다. 반대로 대리 객체 방식은 대상 메서드가 호출돼야만 끼어들 수 있어 필드 접근과 생성자에는 손댈 수 없다.', true),
(9277, 3413, '방식 A는 자체 포인트컷 문법을 쓰므로 방식 B에서 쓰던 표현식을 그대로 옮길 수 없다.', '표에 적힌 대로 방식 A는 방식 B의 execution(..) 문법을 빌려 쓴다. 적용 방법이 다르니 표현식 문법도 다를 것이라고 넘겨짚은 오해다.', false),
(9278, 3413, '방식 B는 실행 중에 결합되므로 다시 빌드하지 않고도 적용 대상을 바꿀 수 있다.', '방식 B는 컴파일 또는 클래스 로드 시점에 결합돼, 대상을 바꾸려면 다시 빌드하거나 에이전트 설정을 손봐야 한다. 실행 중에 결합되는 쪽은 방식 A다.', false),

-- 문제 3414
(9279, 3414, 'generateOne마다 새 트랜잭션이 시작돼 첫 번째 보고서는 커밋된 채로 남는다.', 'REQUIRES_NEW는 선언만 해두면 늘 적용된다고 본 오해다. 전파 속성은 프록시가 호출을 가로챌 때 읽히므로, 프록시를 지나지 않은 호출에는 반영될 기회 자체가 없다.', false),
(9280, 3414, '예외가 난 두 번째 보고서만 롤백되고 첫 번째 보고서는 그대로 저장된다.', '실패한 호출만 따로 되돌려진다고 본 오해다. 세 번의 저장이 같은 트랜잭션에 속해 있어 일부만 되돌릴 수 없고, 예외는 generateAll 밖으로 그대로 빠져나간다.', false),
(9281, 3414, '전파 속성이 서로 달라 애플리케이션 기동 시점에 프록시 생성이 실패한다.', '한 클래스 안에 전파 속성이 다른 메서드가 섞여 있어도 프록시는 문제없이 만들어진다. 동작하지 않는 원인을 설정 오류로 돌린 오해로, 기동은 정상이고 실행 시점에 무시될 뿐이다.', false),
(9282, 3414, 'REQUIRES_NEW가 적용되지 않아 첫 번째 보고서까지 함께 롤백된다.', 'this로 부르는 내부 호출은 프록시가 아니라 원본 객체에 바로 닿아 전파 속성이 읽히지 않는다. 저장이 모두 generateAll이 연 트랜잭션 하나에 묶여 예외 한 번에 전부 되돌아간다.', true),

-- 문제 3415
(9283, 3415, '@Order 값이 큰 MetricAspect가 더 바깥쪽에 놓여 LoggingAspect보다 먼저 시작한다.', '로그에서 LoggingAspect가 먼저 들어가고 가장 나중에 나온다. @Order는 값이 작을수록 우선순위가 높아 바깥쪽에 놓이므로, 값이 클수록 바깥이라는 이 진술이 거짓이다.', true),
(9284, 3415, 'MetricAspect가 측정한 12 ms에는 LoggingAspect의 후처리 시간이 들어 있지 않다.', 'MetricAspect의 exit이 LoggingAspect의 exit보다 먼저 찍혔다. 안쪽 Advice의 측정 구간은 바깥쪽 Advice가 뒤에 하는 일을 포함할 수 없어 12 ms와 15 ms의 차이가 생긴다.', false),
(9285, 3415, 'LoggingAspect는 MetricAspect 안에서 발생한 예외까지 가로챌 수 있는 자리에 있다.', '바깥쪽 Advice는 안쪽 Advice와 원본 메서드를 통째로 감싼다. 안쪽에서 던진 예외는 바깥쪽을 지나 밖으로 나가므로 잡아서 처리할 수 있고, 로그의 중첩 구조가 그 포함 관계를 보여준다.', false),
(9286, 3415, '두 Aspect 모두 대상 메서드 실행 전과 후에 로그를 남기므로 @Around로 작성됐다고 볼 수 있다.', '@Before나 @AfterReturning은 한쪽 시점만 잡는다. 한 Advice가 실행 전후를 모두 감싸고 걸린 시간까지 재려면 원본 호출을 직접 진행시키는 @Around여야 한다.', false),

-- 문제 3416
(9287, 3416, '대상이 구현한 인터페이스 타입으로만 주입받을 수 있어 구체 클래스 타입으로는 주입되지 않는다.', 'java.lang.reflect.Proxy로 만드는 인터페이스 기반 프록시의 제약을 갖다 붙인 오개념이다. 본문의 프록시는 대상 클래스를 상속해 만들어지므로 구체 클래스 타입으로 주입된다.', false),
(9288, 3416, 'InvocationHandler의 invoke에서 호출을 넘겨받아 리플렉션으로 원본 메서드를 부른다.', '인터페이스 기반 프록시의 가로채기 지점이다. 서브클래스를 만들어 쓰는 프록시는 MethodInterceptor의 intercept에서 호출을 받아 부모 메서드 호출로 원본에 위임한다.', false),
(9289, 3416, '원본 클래스의 생성자를 거치지 않고 인스턴스를 만들기 때문에 프록시 객체의 필드는 비어 있다.', '서브클래스 프록시는 Objenesis로 인스턴스를 찍어내 부모 생성자를 부르지 않는다. 그래서 주입받은 빈의 필드를 직접 읽으면 null이고, 원본 값은 메서드를 통해서만 얻을 수 있다.', true),
(9290, 3416, 'private 메서드도 서브클래스에서 재정의되므로 트랜잭션 Advice가 함께 적용된다.', 'private 메서드는 오버라이드 대상이 아니라 프록시가 감쌀 수 없다. 상속으로 만든 프록시라면 모든 메서드를 감쌀 것이라는 오해로, 같은 이유에서 final 메서드도 제외된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1094, 3417, '포인트컷,포인트 컷,pointcut,point cut,포인트컷 표현식,pointcut expression', 'Advice 본문은 그대로인데 감사 로그가 8줄에서 341줄로 늘고 응답 시간이 40 ms에서 260 ms로 뛰었다. 바뀐 것은 부가 기능을 어디에 걸지 골라내는 조건뿐이므로, 차이를 만든 구성 요소는 포인트컷이다. 부가 기능 코드 자체인 Advice, Advice와 포인트컷을 한 덩어리로 묶은 Aspect, 부가 기능이 적용되는 원본 객체인 Target과 헷갈리지 않아야 한다. 스프링 AOP는 메서드 실행만 Join Point로 지원하므로, execution 표현식의 범위를 넓히면 프록시로 감싸는 빈과 가로채는 호출이 함께 늘어 성능까지 영향을 받는다.'),
       (1095, 3418, '@Around,Around,어라운드,어라운드 어드바이스,@Around 어드바이스,around advice', 'pjp.proceed()로 원본 호출 시점을 직접 잡고, 예외를 삼킨 뒤 반환값을 기본 시세로 바꿔치기하고 있다. 실행 여부와 반환값을 모두 제어할 수 있는 Advice는 @Around뿐이고, ProceedingJoinPoint를 매개변수로 받을 수 있다는 점도 결정적인 단서다. @Before는 실행 전 시점만 잡아 반환값에 손댈 수 없고, @AfterReturning은 반환값을 읽을 수만 있으며 바꾸지는 못한다. @AfterThrowing은 예외를 기록하거나 다른 예외로 바꿀 수 있을 뿐 정상 반환으로 되돌리지 못하고, @After는 finally에 해당해 결과에 관여하지 않는다.');

-- =====================================================
-- Lesson 697: JDK 동적 프록시와 자기 호출 한계
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4361, 697, '아래 설정과 기동 오류에 대한 설명으로 옳은 것은?', 'application.yml에 아래 설정을 넣고 애플리케이션을 띄웠다.

```yaml
spring:
  aop:
    proxy-target-class: false
```

```java
public interface PaymentGateway {
    void pay(Long orderId);
}

@Service
public class PaymentService implements PaymentGateway {

    @Override
    @Transactional
    public void pay(Long orderId) { /* 결제 처리 */ }
}

@Component
@RequiredArgsConstructor
public class CheckoutFacade {
    private final PaymentService paymentService;
}
```

기동 중 아래 오류가 나며 애플리케이션이 뜨지 않았다.

```
BeanNotOfRequiredTypeException: Bean named ''paymentService'' is expected to be of type ''com.app.PaymentService'' but was actually of type ''jdk.proxy2.$Proxy87''
```', 'OBJECTIVE'),
       (4362, 697, '아래 코드를 실행한 뒤 CallCountAspect.COUNT의 값은?', '```java
@Aspect
@Component
public class CallCountAspect {

    public static final AtomicInteger COUNT = new AtomicInteger();   // 초기값 0

    @Around("execution(* com.app.coupon.CouponService.*(..))")
    public Object count(ProceedingJoinPoint pjp) throws Throwable {
        COUNT.incrementAndGet();
        return pjp.proceed();
    }
}

@Service
public class CouponService {

    public Coupon issue(Long userId) {
        return new Coupon(userId);
    }

    public static String normalize(String code) {
        return code.trim().toUpperCase();
    }
}
```

```java
// 기동이 끝난 뒤 다른 빈에서 실행 (couponService는 스프링이 주입한 빈)
couponService.issue(1L);
couponService.issue(2L);
CouponService.normalize(" spring10 ");

CouponService manual = new CouponService();
manual.issue(3L);
manual.issue(4L);
```', 'OBJECTIVE'),
       (4363, 697, '아래 구성에서 재시도가 일어난 과정에 대한 설명으로 옳은 것은?', '재고 차감 메서드에 재시도 Aspect와 트랜잭션이 함께 걸려 있다. @Retry는 직접 만든 표시용 애노테이션이고, 트랜잭션 설정은 기본값 그대로다.

```java
@Aspect
@Component
@Order(1)
public class RetryAspect {

    @Around("@annotation(com.app.support.Retry)")
    public Object retry(ProceedingJoinPoint pjp) throws Throwable {
        for (int attempt = 1; ; attempt++) {
            try {
                return pjp.proceed();
            } catch (OptimisticLockingFailureException e) {
                if (attempt == 3) throw e;
            }
        }
    }
}

@Service
@RequiredArgsConstructor
public class StockService {

    private final StockRepository stockRepository;

    @Retry
    @Transactional
    public void decrease(Long itemId) {
        Stock stock = stockRepository.findById(itemId).orElseThrow();
        stock.decrease(1);   // version 컬럼으로 동시 수정 충돌을 감지
    }
}
```

다른 빈에서 stockService.decrease(1L)을 호출했더니, 첫 번째 시도에서 버전 충돌 예외가 났고 두 번째 시도에서 성공했다.', 'OBJECTIVE'),
       (4364, 697, '아래 빈 후처리 과정에 대한 설명으로 옳은 것은?', '스프링 컨테이너는 빈 객체를 생성하고 의존성 주입과 초기화 콜백(@PostConstruct 등)까지 모두 마친 뒤, 마지막 후처리 단계에서 포인트컷에 맞는 메서드를 가진 빈을 같은 타입으로 보이는 프록시로 감싼다. 그리고 원본 객체 대신 이 프록시를 빈으로 등록해 다른 빈에 주입한다.', 'OBJECTIVE'),
       (4365, 697, '아래 (가)~(다) 각각을 AOP에서 부르는 용어는?', '주문 도메인에 감사 기록 Advice를 붙이려고 아래 세 시점을 검토했다.

- (가) OrderService.cancel() 메서드가 실행되는 시점
- (나) Order 객체의 status 필드에 값이 대입되는 시점
- (다) new Order(...)로 생성자가 호출되는 시점

스프링 AOP에서는 포인트컷 표현식을 어떻게 고쳐 써도 (가)에서만 Advice가 실행됐다. 빌드에 AspectJ 컴파일 타임 위빙을 도입하자 (나)와 (다)에서도 같은 Advice가 실행됐다.', 'SUBJECTIVE'),
       (4366, 697, '아래 두 구성의 실행 결과가 갈린 원인을 가리키는 용어는?', '두 구성 모두 @EnableAsync가 켜져 있고, 컨트롤러는 주입받은 notificationService.sendAll(List.of(1L, 2L, 3L))을 호출한다.

**구성 1**

```java
@Service
public class NotificationService {

    public void sendAll(List<Long> userIds) {
        for (Long id : userIds) {
            send(id);
        }
    }

    @Async
    public void send(Long userId) { /* 메일 발송, 약 1초 */ }
}
```

```
[http-nio-8080-exec-1] send user=1
[http-nio-8080-exec-1] send user=2
[http-nio-8080-exec-1] send user=3
API 응답 시간: 3,012 ms
```

**구성 2** — send()를 MailSender 빈으로 옮기고, sendAll()에서는 주입받은 mailSender.send(id)를 호출

```
[task-1] send user=1
[task-2] send user=2
[task-3] send user=3
API 응답 시간: 18 ms
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4361
(11803, 4361, 'PaymentService를 상속해 만든 프록시가 원본 생성자를 거치지 않아 타입 검사에서 거부됐다.', '로그의 jdk.proxy2.$Proxy87은 인터페이스를 구현해 만든 프록시다. 상속과 생성자 생략은 CGLIB 방식의 특징이며, CGLIB 프록시였다면 PaymentService의 서브클래스라 이 타입으로 문제없이 주입됐을 것이다.', false),
(11804, 4361, '주입받는 필드 타입을 PaymentGateway로 바꾸면 설정을 그대로 두어도 기동에 성공한다.', 'proxy-target-class가 false라 인터페이스를 구현한 JDK Dynamic Proxy가 빈으로 등록됐다. 이 프록시는 PaymentGateway 타입이지만 PaymentService의 하위 타입은 아니므로, 인터페이스 타입으로 주입받으면 오류가 사라진다.', true),
(11805, 4361, '인터페이스를 구현한 빈이므로 스프링 부트는 설정과 상관없이 인터페이스 기반 프록시를 만든다.', '인터페이스가 있으면 늘 JDK Dynamic Proxy가 쓰인다고 본 오해다. 스프링 부트 2.0부터 기본값이 proxy-target-class=true라 인터페이스가 있어도 CGLIB로 만들고, 본문은 이 값을 false로 바꿨기 때문에 JDK 방식이 쓰였다.', false),
(11806, 4361, '@Transactional을 PaymentGateway의 메서드 선언으로 옮기면 PaymentService 타입으로도 주입된다.', '애노테이션 위치가 프록시 방식을 정한다고 본 오해다. 어느 쪽에 붙여도 설정이 false인 한 인터페이스 구현체 프록시가 만들어지고, 이 객체는 여전히 PaymentService 타입으로 주입될 수 없다.', false),

-- 문제 4362
(11807, 4362, '2', '주입받은 couponService는 프록시라 issue(1L)·issue(2L) 두 번만 Advice를 거친다. static 메서드는 오버라이드할 수 없어 프록시가 가로챌 수 없고, new로 만든 manual은 빈이 아니라 프록시로 감싸지지 않는다.', true),
(11808, 4362, '3', '포인트컷 표현식에 static 메서드도 맞으니 normalize 호출까지 센다고 본 오해다. static 호출은 클래스에 바로 연결돼 프록시 객체를 거치지 않으므로, 표현식에 맞아도 Advice가 실행되지 않는다.', false),
(11809, 4362, '4', '같은 클래스의 인스턴스라면 new로 만들어도 Advice가 붙는다고 본 오해다. 프록시는 컨테이너가 빈을 등록할 때만 만들어지므로, 직접 생성한 manual의 issue(3L)·issue(4L)은 원본 메서드만 실행된다.', false),
(11810, 4362, '5', '포인트컷에 맞는 메서드가 실행되기만 하면 모두 가로챈다고 본 오해다. 스프링 AOP는 프록시를 통과한 호출에만 Advice를 적용하므로 static 호출과 new로 만든 객체의 호출은 모두 빠진다.', false),

-- 문제 4363
(11811, 4363, 'RetryAspect가 트랜잭션 Advice보다 안쪽에서 실행돼 두 시도가 한 트랜잭션을 함께 쓴다.', '@Order 값이 작을수록 안쪽이라고 거꾸로 본 오해다. 값이 작을수록 바깥쪽이고, 트랜잭션 Advice는 기본 순서가 Ordered.LOWEST_PRECEDENCE라 가장 안쪽에 놓인다. 그래서 RetryAspect가 트랜잭션 전체를 감싼다.', false),
(11812, 4363, '첫 번째 시도의 변경은 롤백되지 않고 남아 두 번째 시도의 변경과 함께 커밋된다.', '시도가 바뀌어도 변경이 쌓인다고 본 오해다. 첫 시도는 예외로 끝나 트랜잭션 Advice가 먼저 롤백한 뒤 예외를 바깥으로 던지고, RetryAspect는 롤백이 끝난 다음에야 그 예외를 잡는다.', false),
(11813, 4363, '두 번째 시도는 새 트랜잭션에서 재고를 다시 조회하므로 다른 요청이 커밋한 최신 version을 읽는다.', 'RetryAspect(@Order(1))가 바깥, 트랜잭션 Advice가 안쪽이라 pjp.proceed()를 부를 때마다 트랜잭션이 새로 열린다. 새 트랜잭션의 findById가 최신 행을 읽어 오므로 두 번째 시도에서는 버전이 맞아 커밋에 성공한다.', true),
(11814, 4363, '버전 충돌 예외가 커밋 시점에 나면 트랜잭션 Advice 밖으로 전달되지 않아 RetryAspect가 잡지 못한다.', '커밋 중 난 예외는 삼켜진다고 본 오해다. 트랜잭션 Advice는 커밋 실패도 호출한 쪽으로 다시 던지고, 그 바깥에서 proceed()를 감싼 RetryAspect의 catch 블록에 걸린다. 순서가 반대였다면 잡지 못했을 것이다.', false),

-- 문제 4364
(11815, 4364, '프록시는 원본 클래스의 메서드 본문을 복사해 가지므로 원본 객체 없이 혼자 호출을 처리한다.', '프록시가 원본을 통째로 대신한다고 본 오해다. 프록시는 부가 기능을 수행한 뒤 원본 객체에 호출을 위임할 뿐 핵심 로직을 갖고 있지 않다. 그래서 등록 후에도 원본 객체는 프록시가 참조하는 대상으로 남는다.', false),
(11816, 4364, '프록시를 만드는 과정에서 원본 클래스의 생성자와 @PostConstruct 메서드가 한 번 더 실행된다.', '감쌀 때 초기화가 다시 돈다고 본 오해다. 초기화가 끝난 원본을 한 번 감쌀 뿐 초기화 콜백을 다시 부르지 않는다. CGLIB 프록시도 Objenesis로 인스턴스를 만들어 원본 생성자를 호출하지 않는다.', false),
(11817, 4364, '다른 빈이 자기 @PostConstruct에서 주입받은 이 빈의 @Transactional 메서드를 부르면 트랜잭션 없이 실행된다.', '@PostConstruct 안에서는 언제나 프록시가 없다고 넓혀 본 오해다. 주입되는 빈은 후처리까지 끝나 이미 프록시로 감싸진 상태라, 다른 빈의 초기화 콜백에서 부른 호출도 프록시를 거쳐 트랜잭션이 적용된다.', false),
(11818, 4364, '빈이 자기 @PostConstruct 메서드에서 같은 클래스의 @Transactional 메서드를 부르면 트랜잭션 없이 실행된다.', '초기화 콜백은 프록시로 감싸기 전에 실행되므로 그 시점의 this는 원본 객체다. 호출이 프록시를 거치지 않아 트랜잭션 Advice가 끼어들 수 없다. 초기화 시점에 트랜잭션이 필요하면 다른 빈에서 호출하거나 기동 완료 이벤트를 쓴다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1410, 4365, '조인 포인트,조인포인트,join point,joinpoint,join-point,결합점,접합점', '(가)는 메서드 실행, (나)는 필드 대입, (다)는 생성자 호출로, 모두 프로그램이 실행되는 도중 Advice를 끼워 넣을 수 있는 후보 지점이므로 조인 포인트(Join Point)다. 스프링 AOP는 프록시가 메서드 호출을 가로채는 방식이라 조인 포인트 가운데 메서드 실행만 지원하고, 그래서 포인트컷을 어떻게 고쳐도 (나)와 (다)는 잡히지 않았다. 바이트코드를 직접 고치는 AspectJ 위빙은 필드 접근과 생성자 호출 조인 포인트까지 다룬다. 조인 포인트 가운데 실제로 적용할 대상을 골라내는 표현식인 포인트컷, 그 지점에서 실행되는 부가 기능 코드인 Advice, Aspect를 대상 코드에 결합하는 과정인 위빙과 헷갈리지 않아야 한다.'),
       (1411, 4366, 'self-invocation,self invocation,selfinvocation,자기 호출,자기호출,자가 호출,자가호출,내부 호출,내부호출,셀프 인보케이션,셀프인보케이션', '구성 1의 sendAll()은 같은 객체 안에서 this를 통해 send()를 부른다. 컨트롤러의 호출은 프록시를 거쳐 sendAll()까지 들어가지만, 그 안의 send() 호출은 원본 객체에서 바로 실행돼 @Async Advice가 끼어들지 못한다. 그래서 세 번의 발송이 요청 스레드(http-nio-8080-exec-1)에서 차례로 돌아 약 3초가 걸렸다. 구성 2는 다른 빈의 프록시를 거치므로 발송이 task 스레드로 넘어가 응답이 18 ms로 줄었다. 이 자기 호출 문제는 @Transactional·@Cacheable 같은 프록시 기반 애노테이션 전부에 해당한다. 빈끼리 서로 주입을 요구해 생성 단계에서 막히는 순환 참조, 빈이 아니라서 애초에 프록시가 없는 new 생성 객체의 경우와는 원인이 다르다.');

-- =====================================================
-- Lesson 855: 위빙 시점과 횡단 관심사, 캐시 프록시
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5309, 855, '아래 코드를 스프링 부트 3.x 기본 설정으로 실행했을 때, 출력되는 세 줄을 차례대로 나타낸 것으로 옳은 것은?', '애플리케이션에 직접 만든 Aspect는 없고, 그 밖의 설정도 모두 기본값이다.

```java
public interface PaymentGateway {
    void pay(Long orderId);
}

@Service
public class PaymentService implements PaymentGateway {
    @Override
    @Transactional
    public void pay(Long orderId) { /* 결제 처리 */ }
}

@Service
public class MemberService {
    public void updateNickname(Long memberId, String nickname) { /* 닉네임 변경 */ }
}

@Service
public class OrderService {
    @Transactional
    public void place(Order order) { /* 주문 저장 */ }
}
```

```java
// 기동이 끝난 뒤 다른 빈에서 실행 (세 필드 모두 스프링이 주입)
System.out.println(paymentGateway.getClass().getSimpleName());
System.out.println(memberService.getClass().getSimpleName());
System.out.println(orderService.getClass().getSimpleName());
```', 'OBJECTIVE'),
       (5310, 855, '아래 코드에서 다른 빈이 주입받은 pointService로 두 메서드를 차례로 호출했을 때의 결과로 옳은 것은?', '스프링 부트 3.x 기본 설정이다.

```java
@Service
@RequiredArgsConstructor
public class PointService {

    private final PointRepository pointRepository;

    @Transactional
    public void earn(Long userId, int amount) {
        pointRepository.save(Point.earn(userId, amount));
    }

    @Transactional
    public final void use(Long userId, int amount) {
        pointRepository.save(Point.use(userId, amount));
    }
}
```

```java
// 호출부 (다른 빈)
pointService.earn(1L, 500);
pointService.use(1L, 300);
```', 'OBJECTIVE'),
       (5311, 855, '아래 수정안을 각각 적용했을 때의 결과에 대한 설명으로 옳지 않은 것은?', '스프링 부트 3.x 기본 설정에 @EnableCaching만 켰다. 다른 빈에서 같은 id 목록으로 priceService.getPrices()를 두 번 호출했는데, 두 번 모두 외부 시세 API가 id 개수만큼 호출됐다.

```java
@Service
@RequiredArgsConstructor
public class PriceService {

    private final PriceApiClient priceApi;

    public List<Price> getPrices(List<Long> itemIds) {
        List<Price> result = new ArrayList<>();
        for (Long id : itemIds) {
            result.add(getPrice(id));
        }
        return result;
    }

    @Cacheable("price")
    public Price getPrice(Long itemId) {
        return priceApi.fetch(itemId);   // 외부 API 호출, 약 200 ms
    }
}
```

| 수정안 | 변경 내용 |
| --- | --- |
| A | getPrice를 새 빈 PriceReader로 옮기고, getPrices에서는 주입받은 priceReader.getPrice(id)를 호출 |
| B | 직접 작성한 생성자에서 @Lazy를 붙여 PriceService 자신을 self로 주입받고, self.getPrice(id)를 호출 |
| C | getPrices에서 ((PriceService) AopContext.currentProxy()).getPrice(id)를 호출. 그 밖의 설정은 그대로 둠 |
| D | @EnableCaching(mode = AdviceMode.ASPECTJ)로 바꾸고, JVM 실행 옵션에 AspectJ 에이전트(-javaagent)를 추가 |', 'OBJECTIVE'),
       (5312, 855, '아래 코드를 실행했을 때 TraceAspect가 남기는 로그는 모두 몇 줄인가?', '```java
@Slf4j
@Aspect
@Component
public class TraceAspect {

    @Pointcut("execution(* com.app.stock.StockService.decrease(..))")
    void stockDecrease() {}

    @Before("stockDecrease()")
    public void before() { log.info("before"); }

    @AfterReturning("stockDecrease()")
    public void afterReturning() { log.info("afterReturning"); }

    @AfterThrowing("stockDecrease()")
    public void afterThrowing() { log.info("afterThrowing"); }

    @After("stockDecrease()")
    public void after() { log.info("after"); }
}
```

```java
// 다른 빈에서 주입받은 stockService로 실행 (현재 재고 10개)
stockService.decrease(1L, 3);         // 정상 반환, 남은 재고 7개
try {
    stockService.decrease(1L, 50);    // 재고 부족으로 IllegalStateException 발생
} catch (IllegalStateException e) {
    // 예외를 잡고 넘어감
}
```', 'OBJECTIVE'),
       (5313, 855, '아래 두 구성에서 시점과 방식은 달랐지만 공통으로 일어난 일을 AOP에서 부르는 용어는?', '메서드 실행 전에 로그를 남기는 같은 LoggingAspect를 두 가지 구성으로 OrderService.cancel()에 적용했다. 두 구성 모두 OrderService.java 소스에는 로그 코드를 한 줄도 쓰지 않았다.

**구성 1** — 빌드에 AspectJ 컴파일러(ajc)를 붙였다. 빌드된 OrderService.class를 디컴파일하면 아래와 같다.

```java
public void cancel(Long orderId) {
    JoinPoint jp = Factory.makeJP(ajc$tjp_0, this, this, orderId);
    LoggingAspect.aspectOf().ajc$before$com_app_LoggingAspect$1$9f1c(jp);
    orderRepository.cancel(orderId);
}
```

**구성 2** — 스프링 AOP로 적용했다. 빌드된 OrderService.class는 소스와 똑같았다. 대신 애플리케이션이 기동하면서 OrderService를 상속한 클래스가 메모리에서 새로 만들어졌고, 컨트롤러에는 그 클래스의 객체가 주입됐다.

두 구성 모두 cancel()을 호출하면 LoggingAspect의 로그가 먼저 찍혔다.', 'SUBJECTIVE'),
       (5314, 855, '아래에서 (가) 줄들이 담당하는 관심사를 AOP에서 부르는 용어는?', '서비스 클래스 38개의 public 메서드는 모두 아래와 같은 모양이었다.

```java
public Order placeOrder(OrderRequest req) {
    long start = System.nanoTime();                                          // (가)
    Order order = orderFactory.create(req);                                  // (나)
    order.applyCoupon(req.couponId());                                       // (나)
    orderRepository.save(order);                                             // (나)
    log.info("placeOrder {} ms", (System.nanoTime() - start) / 1_000_000);   // (가)
    return order;                                                            // (나)
}
```

(나) 줄들은 결제 승인, 배송 등록, 회원 가입처럼 클래스마다 내용이 모두 달랐다. 반면 (가) 줄들은 로그 문자열 속 메서드 이름만 빼고 214개 메서드에 똑같이 들어 있어, 측정 단위를 ms에서 μs로 바꾸라는 요청 하나에 파일 38개를 고쳐야 했다. 이후 (가)를 @Around Advice 하나로 옮기자 같은 요청을 파일 1개 수정으로 처리했고, 서비스 메서드에는 (나)만 남았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5309
(14331, 5309, 'PaymentService$$SpringCGLIB$$0 / MemberService$$SpringCGLIB$$0 / OrderService$$SpringCGLIB$$0', '모든 빈이 프록시로 감싸진다고 본 오해다. 컨테이너는 빈 초기화 마지막 단계에서 적용할 Advice가 있는 빈만 프록시로 바꾼다. MemberService에는 @Transactional도, 맞는 포인트컷도 없어 원본 객체가 그대로 빈이 된다.', false),
(14332, 5309, '$Proxy87 / MemberService / OrderService$$SpringCGLIB$$0', '인터페이스를 구현한 빈에는 JDK Dynamic Proxy가 쓰인다고 본 오해다. 스프링 부트는 2.0부터 proxy-target-class=true가 기본값이라, 인터페이스가 있어도 CGLIB로 PaymentService의 서브클래스를 만든다.', false),
(14333, 5309, 'PaymentService / MemberService / OrderService', '프록시가 getClass()까지 원본에 넘겨 원래 클래스 이름이 나온다고 본 오해다. getClass()는 Object의 final 메서드라 가로챌 수 없고, 실제로 주입된 객체인 프록시의 클래스를 그대로 돌려준다.', false),
(14334, 5309, 'PaymentService$$SpringCGLIB$$0 / MemberService / OrderService$$SpringCGLIB$$0', '@Transactional이 붙은 PaymentService와 OrderService만 프록시로 감싸지고, Advice가 없는 MemberService는 원본이 빈이 된다. 부트 기본값에서는 인터페이스가 있어도 CGLIB를 쓰므로 두 프록시 모두 서브클래스 이름이 찍힌다.', true),

-- 문제 5310
(14335, 5310, 'earn은 정상 저장되고, use는 pointRepository가 null이라 NullPointerException이 난다.', 'CGLIB 프록시는 final 메서드를 재정의하지 못해 use 호출이 프록시 객체 자신에서 실행된다. 프록시는 원본 생성자를 거치지 않고 만들어져 필드가 비어 있으므로 pointRepository가 null이다. 기동은 정상이라 호출 시점에야 드러난다.', true),
(14336, 5310, '두 메서드 모두 프록시를 거쳐 각자의 트랜잭션 안에서 정상 저장된다.', 'final이 프록시와 무관하다고 본 오해다. CGLIB 프록시는 대상 클래스를 상속해 메서드를 재정의하는 방식이라, 재정의가 막힌 final 메서드는 가로챌 수 없다. Advice를 거치는 것은 earn뿐이다.', false),
(14337, 5310, 'use가 final이라 프록시를 만들 수 없어 애플리케이션 기동이 실패한다.', 'final 클래스와 final 메서드를 같게 본 오해다. 클래스가 final이면 상속 자체가 막혀 프록시 생성이 실패하지만, 메서드만 final이면 프록시는 만들어지고 그 메서드만 가로채지 못한 채 기동이 끝난다.', false),
(14338, 5310, 'use는 Advice 없이 원본 객체로 바로 위임돼 트랜잭션 없이 저장된다.', '가로채지 못한 호출도 원본으로 넘어간다고 본 오해다. 원본에 위임하는 코드는 프록시가 재정의한 메서드 안에만 있다. final 메서드는 재정의되지 않아 위임 없이 프록시 인스턴스에서 그대로 실행된다.', false),

-- 문제 5311
(14339, 5311, 'A는 getPrice 호출이 PriceReader의 프록시를 거쳐, 두 번째 getPrices 호출부터 캐시가 쓰인다.', '참이다. 다른 빈의 메서드를 부르면 호출이 그 빈의 프록시로 들어가 캐시 Advice가 끼어든다. 첫 getPrices에서 저장된 값을 두 번째 호출에서 꺼내 쓰므로 외부 API 호출이 사라진다. 책임도 나뉘어 가장 권장되는 방법이다.', false),
(14340, 5311, 'B에서 self로 부른 getPrice는 컨테이너의 프록시 빈을 거치므로 캐시 Advice가 적용된다.', '참이다. @Lazy로 주입된 self는 호출되는 순간 컨테이너에서 PriceService 빈, 즉 캐시 프록시를 찾아 호출을 넘긴다. this가 아니라 프록시를 거치므로 캐시가 동작한다. 다만 자기 자신을 주입하는 구조라 설계가 어색하다.', false),
(14341, 5311, 'C는 지금 호출을 처리 중인 프록시를 꺼내 쓰므로 다른 설정 없이도 캐시가 적용된다.', '거짓이다. AopContext는 exposeProxy가 true일 때만 현재 프록시를 스레드에 보관하는데, 기본값은 false다. 설정을 그대로 두면 currentProxy()에서 IllegalStateException이 난다. @EnableAspectJAutoProxy(exposeProxy = true)를 함께 써야 한다.', true),
(14342, 5311, 'D는 캐시 로직이 PriceService 클래스에 직접 결합돼 this를 통한 내부 호출에도 캐시가 적용된다.', '참이다. ASPECTJ 모드는 프록시를 두지 않고, 클래스가 로드될 때 에이전트가 PriceService 바이트코드에 캐시 로직을 직접 끼워 넣는다. 호출 경로가 아니라 메서드 자체가 바뀌므로 this로 부른 getPrice에도 캐시가 적용된다.', false),

-- 문제 5312
(14343, 5312, '5', '@After가 정상 반환 때만 실행된다고 본 오해다. @After는 finally처럼 정상 종료든 예외든 메서드가 끝나면 항상 실행되므로, 예외로 끝난 두 번째 호출에서도 after가 찍힌다.', false),
(14344, 5312, '6', '첫 호출은 정상 반환이라 before·afterReturning·after 3줄, 두 번째 호출은 예외라 before·afterThrowing·after 3줄이다. 반환 시점 Advice는 결과에 따라 둘 중 하나만 실행되고, @After는 매번 실행된다.', true),
(14345, 5312, '7', '@AfterReturning이 메서드가 끝나기만 하면 실행된다고 본 오해다. @AfterReturning은 정상 반환일 때만 실행되므로, 예외로 끝난 두 번째 호출에서는 afterReturning이 찍히지 않는다.', false),
(14346, 5312, '8', '선언한 Advice가 호출마다 모두 실행된다고 본 오해다. @AfterReturning과 @AfterThrowing은 결과에 따라 갈려, 정상 반환이면 afterThrowing이, 예외면 afterReturning이 건너뛰어진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1726, 5313, '위빙,weaving,애스펙트 위빙,에스펙트 위빙,aspect weaving,엮기', '구성 1은 컴파일 시점에 바이트코드를 직접 고쳐 Advice 호출을 cancel() 안에 끼워 넣었고, 구성 2는 실행 시점에 대상을 상속한 프록시를 만들어 호출을 가로채게 했다. 시점(컴파일·로드·런타임)과 방법은 달라도 Aspect를 대상 코드에 결합했다는 점은 같으므로 이 과정이 위빙(Weaving)이다. 결합된 뒤 실제로 실행되는 부가 기능 코드인 Advice, 결합할 대상을 고르는 표현식인 포인트컷, 결합이 일어날 수 있는 후보 지점인 조인 포인트와 구분해야 한다. 스프링 AOP는 런타임 프록시 방식이라 메서드 실행에만 개입하지만, AspectJ의 컴파일·로드 타임 위빙은 바이트코드 자체를 바꾸므로 필드 접근이나 생성자 호출에도 결합할 수 있다.'),
       (1727, 5314, '횡단 관심사,횡단관심사,공통 관심사,공통관심사,크로스커팅 관심사,크로스 커팅 관심사,크로스커팅 컨선,cross-cutting concern,crosscutting concern,cross cutting concern,횡단 관심 사항,공통 관심 사항', '(가)는 실행 시간 측정처럼 비즈니스 로직과 상관없이 여러 클래스에 똑같이 흩어져 들어가는 코드이므로 횡단 관심사(cross-cutting concern, 공통 관심사)에 해당한다. 클래스마다 내용이 다른 (나)는 그 클래스가 존재하는 이유인 핵심 관심사(core concern)다. 횡단 관심사가 핵심 로직에 섞여 있으면 본문처럼 변경 요청 하나에 파일 수십 개를 고쳐야 하므로, AOP는 이를 Aspect로 모아 한 곳에서 관리하고 핵심 로직에는 (나)만 남긴다. 관심사 자체를 부르는 말이므로, 그 관심사를 모듈로 묶은 단위인 Aspect나 실제로 실행되는 부가 기능 코드인 Advice와는 구분해야 한다.');
