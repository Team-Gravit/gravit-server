-- Unit: IoC/DI와 빈 생명주기 (Unit ID: 112)
-- Chapter: Spring (Chapter ID: 10)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (538, 112, '제어의 역전과 주입 방식, 컨테이너 기능'),
       (696, 112, '빈 초기화 순서와 싱글톤 상태 공유'),
       (854, 112, '스코프별 소멸 콜백과 순환 참조 해소');

-- =====================================================
-- Lesson 538: 제어의 역전과 주입 방식, 컨테이너 기능
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3407, 538, '아래 코드에서 addAndGet()을 세 번 연속 호출했을 때, 세 번째 호출이 돌려주는 값은?', '두 클래스 모두 컴포넌트 스캔으로 등록되며, CartService는 기본 스코프를 그대로 쓴다.

```java
@Component
@Scope("prototype")
public class Cart {
    private int count;
    public void add() { count++; }
    public int count() { return count; }
}

@Service
public class CartService {
    private final Cart cart;

    public CartService(Cart cart) {
        this.cart = cart;
    }

    public int addAndGet() {
        cart.add();
        return cart.count();
    }
}
```', 'OBJECTIVE'),
       (3408, 538, '아래 비교표를 바탕으로 한 설명으로 옳지 않은 것은?', '| 항목 | 생성자 주입 | 세터 주입 | 필드 주입 |
| --- | --- | --- | --- |
| 의존 필드에 final 선언 | 가능 | 불가 | 불가 |
| 주입이 이뤄지는 시점 | 인스턴스화와 동시 | 인스턴스화 뒤 세터 호출 | 인스턴스화 뒤 필드에 직접 대입 |
| 의존 객체 없이 인스턴스만 만들기 | 불가 | 가능 | 가능 |
| 컨테이너 없이 new로 조립 | 생성자 인자로 넘기면 됨 | 세터를 직접 불러야 함 | 리플렉션이 필요함 |', 'OBJECTIVE'),
       (3409, 538, '아래 기동 로그가 가리키는 문제를 근본적으로 바로잡는 방법으로 옳은 것은?', '스프링 부트 3.2 환경이고, CouponService와 OrderService는 둘 다 생성자 주입을 쓴다.

```
***************************
APPLICATION FAILED TO START
***************************

Description:

The dependencies of some of the beans in the application context form a cycle:

┌─────┐
|  couponService
↑     ↓
|  orderService
└─────┘
```', 'OBJECTIVE'),
       (3410, 538, '아래에서 설명한 스프링 컨테이너에 대해 옳은 것은?', '스프링 부트의 SpringApplication.run()이 돌려주는 이 컨테이너는, 빈을 등록하고 꺼내 주는 최소 기능만 갖춘 컨테이너를 상속하면서 메시지 국제화, 이벤트 발행, 환경 변수 조회, 리소스 로딩, AOP 통합까지 함께 제공한다. 또한 싱글톤 빈을 기동 시점에 미리 다 만들어 둔다.', 'OBJECTIVE'),
       (3411, 538, '아래 두 사례가 공통으로 따르고 있는 설계 원칙의 이름은?', '서블릿 컨테이너는 개발자가 만든 클래스에 정의한 doGet()을 개발자 코드 어디서도 부르지 않는데, 요청이 들어올 때마다 실행한다. 스프링 컨테이너 역시 개발자가 new를 쓴 적 없는 @Service 클래스의 인스턴스를 만들어 두고, 그 안에 필요한 다른 객체를 끼워 넣은 뒤 초기화 메서드까지 대신 불러 준다.', 'SUBJECTIVE'),
       (3412, 538, '아래 상황에서 loadRates() 위에 붙인 애너테이션의 이름은?', '환율 표를 미리 읽어 캐시에 담는 loadRates()를 만들었다. 이 호출을 생성자 안에 두자 주입받기로 한 RateClient가 아직 null이어서 기동이 실패했고, 컨트롤러가 매 요청마다 직접 부르게 하자 같은 표를 1분에 400번 다시 받아 왔다. 결국 loadRates() 위에 애너테이션 한 줄만 붙였더니, 코드 어디서도 이 메서드를 부르지 않는데 기동 로그에 "환율 3,120건 적재"가 정확히 한 번 찍혔고 첫 요청은 12ms 만에 응답했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3407
(9259, 3407, '0', 'count()가 증가 전 값을 돌려준다고 본 계산이다. addAndGet()은 add()를 먼저 실행한 뒤 count()를 부르므로 첫 호출부터 이미 1 이상이 나온다.', false),
(9260, 3407, '1', '조회할 때마다 새 인스턴스가 온다는 프로토타입의 성질을 주입에까지 적용한 오해다. 주입은 CartService를 만들 때 단 한 번 일어나고, 그 뒤로는 같은 Cart 참조가 계속 쓰인다.', false),
(9261, 3407, '2', '주입 과정에서 add()가 한 번 먼저 불렸다고 보고 첫 호출을 세지 않은 계산이다. 주입은 참조를 넘길 뿐 메서드를 부르지 않으므로 세 번 호출이면 정확히 세 번 증가한다.', false),
(9262, 3407, '3', 'CartService는 기본 스코프라 인스턴스가 하나뿐이고, 생성 시점에 받은 Cart를 계속 붙들고 있다. 프로토타입은 컨테이너에서 꺼낼 때마다 새로 만들어질 뿐 이미 주입된 참조를 바꾸지 않아 count가 1, 2, 3으로 누적된다.', true),

-- 문제 3408
(9263, 3408, '필드 주입은 @Autowired가 붙은 의존 객체를 다 채운 뒤에야 인스턴스를 만들어 주므로, 컨테이너 밖 테스트에서도 널 참조로 실패할 일이 없다.', '표에서 필드 주입은 인스턴스화가 끝난 뒤에 필드로 값이 들어가고, 의존 객체 없이 인스턴스만 만드는 것도 가능하다. 컨테이너 밖에서 new로 만들면 필드가 빈 채로 남아 첫 호출에서 널 참조가 난다. 생성 시점에 누락을 막아 주는 쪽은 인자를 강제하는 생성자 주입이다.', true),
(9264, 3408, '세터 주입은 인스턴스를 먼저 만들고 값을 나중에 넣으므로, 세터를 부르기 전까지는 의존 객체가 비어 있는 객체가 존재한다.', '표의 주입 시점 행대로 세터 주입은 인스턴스화와 주입이 나뉘어 있다. 컨테이너가 조립할 때는 세터를 대신 불러 주지만, 직접 조립하는 코드에서 호출을 빠뜨려도 컴파일러가 잡아 주지 않아 문제가 실제 사용 시점까지 미뤄진다.', false),
(9265, 3408, '생성자 주입으로 짠 서비스는 컨테이너를 띄우지 않고도 가짜 구현을 인자로 넘겨 곧바로 검증할 수 있다.', '표에서 new에 인자를 넘기는 것만으로 조립이 끝나는 쪽은 생성자 주입뿐이다. 세터 주입은 세터를 빠짐없이 불러야 하고 필드 주입은 리플렉션을 써야 해, 테스트 코드가 프레임워크와 내부 필드 이름에 묶인다.', false),
(9266, 3408, '생성자 주입에서 의존 필드를 final로 선언하면, 주입이 끝난 뒤 다른 객체로 바꿔 끼우는 코드가 컴파일 단계에서 막힌다.', '표에서 final 선언이 가능한 쪽은 생성자 주입뿐이다. final 필드는 생성자에서 한 번만 대입되므로 이후 재대입은 컴파일 오류가 되고, 그 덕에 의존 관계가 실행 중에 뒤바뀌지 않는다.', false),

-- 문제 3409
(9267, 3409, '두 서비스에 @Primary를 붙여 주입 후보의 우선순위를 정해 준다.', '@Primary는 같은 타입의 빈이 여럿일 때 어느 것을 고를지 정하는 장치다. 여기서 막힌 이유는 후보가 많아서가 아니라 두 빈이 서로를 필요로 해 생성 순서를 정할 수 없어서이므로, 우선순위를 정해도 고리는 그대로 남는다.', false),
(9268, 3409, '두 서비스가 함께 쓰는 로직을 제3의 클래스로 뽑아, 의존이 한쪽 방향으로만 흐르게 고친다.', '고리를 없애려면 공통 책임을 별도 빈으로 분리하거나 이벤트 발행으로 역방향 의존을 끊어야 한다. 의존 그래프에서 사이클이 사라지면 생성 순서가 하나로 정해져 기동이 통과한다.', true),
(9269, 3409, '생성자 주입을 필드 주입으로 바꾸면 컨테이너가 미완성 참조를 먼저 넘겨 고리를 풀어 준다.', '미완성 참조를 임시로 넘겨 순환을 푸는 것은 세터·필드 주입의 옛 동작이다. 스프링 부트 2.6부터 순환 참조는 주입 방식과 관계없이 기본 금지라, 필드 주입으로 바꿔도 같은 자리에서 기동이 막힌다.', false),
(9270, 3409, '두 빈의 스코프를 prototype으로 바꿔 조회할 때마다 새 인스턴스를 만들게 한다.', '스코프를 바꿔도 A를 만들려면 B가, B를 만들려면 A가 있어야 한다는 관계는 그대로다. 오히려 조회할 때마다 같은 고리를 새로 타게 되어 생성이 끝나지 않는다.', false),

-- 문제 3410
(9271, 3410, '싱글톤 빈은 처음 꺼내 쓸 때 만들어지므로, 의존 관계를 잘못 적어도 오류는 그 빈을 처음 쓰는 요청에서야 드러난다.', '최소 기능 컨테이너의 지연 생성 동작을 그대로 옮겨 붙인 오해다. 이 컨테이너는 싱글톤을 기동 때 모두 만들어 두므로, 잘못된 의존 관계는 첫 요청을 받기도 전에 기동 단계에서 예외로 드러난다.', false),
(9272, 3410, '미리 만드는 대상은 컨테이너 안의 모든 빈이므로, HTTP 요청 단위 빈도 첫 요청 전에 하나 준비돼 있다.', '미리 만드는 대상은 싱글톤에 한정된다. 요청 스코프 빈은 살아 있는 요청이 있어야 만들 수 있어, 요청 밖에서 꺼내려 하면 해당 스코프를 찾지 못했다는 예외가 난다.', false),
(9273, 3410, '@Lazy를 붙인 싱글톤 빈은 미리 만드는 대상에서 빠져 최초 조회 때 만들어지고, 그 설정 오류도 그 시점에 드러난다.', '@Lazy는 생성 시점을 뒤로 미뤄 기동을 가볍게 하지만, 미리 생성이 주던 이점인 조기 오류 발견도 함께 미룬다. 기동 시간과 오류 발견 시점을 맞바꾸는 선택이라 남용하면 장애가 운영 중에 드러난다.', true),
(9274, 3410, '컨텍스트를 닫아도 컨테이너는 빈의 소멸 콜백을 부르지 않으므로 자원 정리는 개발자가 직접 해야 한다.', '컨텍스트가 종료되면 싱글톤 빈의 @PreDestroy와 소멸 메서드가 호출된다. 소멸 콜백을 받지 못하는 쪽은 컨테이너가 생성과 주입까지만 관리하는 프로토타입 빈이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1092, 3411, '제어의 역전,제어 역전,IoC,Inversion of Control,인버전 오브 컨트롤,아이오씨', '두 사례의 공통점은 객체를 언제 만들고 언제 부를지 정하는 주도권이 개발자 코드가 아니라 프레임워크에 있다는 것이다. 이렇게 제어 흐름이 뒤집힌 구조를 제어의 역전(IoC)이라 부른다. 의존성 주입(DI)과 헷갈리기 쉬운데, IoC는 제어를 프레임워크로 넘긴다는 원칙이고 DI는 그 원칙을 구현하는 여러 기법 가운데 하나다. 서블릿 컨테이너가 doGet()을 부르는 것은 DI가 아니지만 IoC에는 해당하므로, 두 사례를 함께 묶는 이름은 DI가 아니라 IoC다. 프레임워크가 알고리즘 골격을 쥐고 내 코드를 불러 쓰는 템플릿 메서드 패턴도 같은 원칙에 속한다.'),
       (1093, 3412, '@PostConstruct,PostConstruct,포스트 컨스트럭트,포스트컨스트럭트', '컨테이너는 인스턴스를 만들고 의존성 주입을 끝낸 직후에 @PostConstruct가 붙은 메서드를 딱 한 번 부른다. 생성자 시점에는 주입이 아직 끝나지 않아 RateClient가 null이었고, 요청마다 직접 부르는 방식은 같은 작업을 되풀이해 낭비가 됐다. 초기화 지점을 이 콜백으로 옮기면 두 문제가 함께 풀린다. 같은 자리에서 InitializingBean.afterPropertiesSet()이나 @Bean(initMethod)도 쓸 수 있으나, 표준 애너테이션이라 특정 프레임워크에 덜 묶인다. 종료 시 한 번 불리는 @PreDestroy와 짝을 이루며, 스프링 6·부트 3부터는 javax.annotation이 아니라 jakarta.annotation 패키지에서 가져온다.');

-- =====================================================
-- Lesson 696: 빈 초기화 순서와 싱글톤 상태 공유
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4355, 696, '아래 빈이 등록된 애플리케이션을 기동했을 때, 콘솔에 숫자가 찍히는 순서는?', '스프링 부트 3.2 애플리케이션이다. PriceCache는 기본 스코프로 컴포넌트 스캔되고, PriceClient는 이미 빈으로 등록돼 있다. @PostConstruct는 jakarta.annotation 패키지의 것을 쓴다.

```java
@Component
public class PriceCache implements BeanNameAware, InitializingBean {

    private PriceClient client;

    public PriceCache() {
        System.out.println("1");
    }

    @Override
    public void afterPropertiesSet() {
        System.out.println("2");
    }

    @Override
    public void setBeanName(String name) {
        System.out.println("3");
    }

    @PostConstruct
    public void warmUp() {
        System.out.println("4");
    }

    @Autowired
    public void setClient(PriceClient client) {
        this.client = client;
        System.out.println("5");
    }
}
```', 'OBJECTIVE'),
       (4356, 696, '아래 조건에서 요청 A·B·C가 각각 받는 응답을 바르게 나열한 것은?', 'GreetingService는 스코프를 따로 지정하지 않은 빈이고, 동기화 처리는 없다. 세 요청은 서로 다른 스레드에서 처리되며 도착하자마자 greet()를 호출한다. 한 스레드가 쓴 필드 값은 다른 스레드에서 곧바로 읽힌다고 보고, Thread.sleep() 외의 실행 시간은 0으로 둔다.

```java
@Service
public class GreetingService {

    private String userName;

    public String greet(String name) throws InterruptedException {
        this.userName = name;
        Thread.sleep(100);
        return "Hello, " + userName;
    }
}
```

| 요청 | 도착 시각 | 호출 |
| --- | --- | --- |
| A | 0ms | greet("kim") |
| B | 30ms | greet("lee") |
| C | 120ms | greet("park") |', 'OBJECTIVE'),
       (4357, 696, '아래 설정과 코드로 애플리케이션을 기동했을 때의 결과로 옳은 것은?', '스프링 부트 3.2 애플리케이션이다. 네 클래스는 모두 컴포넌트 스캔으로 등록되는 기본 스코프 빈이다. 아래에서 MemberService·PointService를 Member·Point 쌍, OrderService·StockService를 Order·Stock 쌍이라 부른다.

```properties
# application.properties
spring.main.allow-circular-references=true
```

```java
@Service
public class MemberService {
    @Autowired
    private PointService pointService;
}

@Service
public class PointService {
    @Autowired
    private MemberService memberService;
}

@Service
public class OrderService {
    private final StockService stockService;

    public OrderService(StockService stockService) {
        this.stockService = stockService;
    }
}

@Service
public class StockService {
    private final OrderService orderService;

    public StockService(OrderService orderService) {
        this.orderService = orderService;
    }
}
```', 'OBJECTIVE'),
       (4358, 696, '아래 (가)~(라) 사례를 제어의 역전(IoC)과 의존성 주입(DI)으로 분류한 설명으로 옳은 것은?', '(가) JUnit 5가 테스트 클래스에서 @Test가 붙은 인자 없는 메서드를 찾아 실행한다. 개발자 코드에는 이 메서드를 부르는 곳이 없다.

(나) 스프링 컨테이너가 OrderService의 생성자 인자 자리에 OrderRepository 타입의 빈을 찾아 넣어 준다.

(다) @Service가 붙은 OrderService가 자기 생성자 안에서 new JdbcOrderRepository()를 호출해 필드에 담는다.

(라) 스프링 스케줄러가 @Scheduled가 붙은 인자 없는 cleanUp() 메서드를 5분마다 호출한다. 개발자 코드에는 이 메서드를 부르는 곳이 없다.', 'OBJECTIVE'),
       (4359, 696, '아래 로그를 남긴 SchemaGuard가 구현한 스프링 인터페이스의 이름은?', '스프링 부트 3.2 애플리케이션에 직접 만든 SchemaGuard 클래스를 빈으로 등록했다. SchemaGuard는 스프링이 제공하는 인터페이스 하나를 구현하고, 그 콜백 메서드 안에서 아래 로그를 남긴다. 로그는 기동 중 찍힌 순서 그대로다.

```
[main] SchemaGuard 콜백 시작 (기동 중 이 한 번만 호출됨)
[main]   orderService  class=OrderService  scope=singleton  lazyInit=false
[main]   couponPolicy  class=CouponPolicy  scope=singleton  lazyInit=false
[main]   ... 등록 항목 57개 확인
[main]   couponPolicy의 scope를 prototype으로 변경
[main] SchemaGuard 콜백 끝
[main] OrderService 생성자 호출
[main] OrderService @PostConstruct 실행
[main] Started ShopApplication in 2.1 seconds
```

SchemaGuard 콜백이 끝날 때까지 OrderService를 비롯한 애플리케이션 빈의 생성자는 한 번도 호출되지 않았다. 기동이 끝난 뒤 getBean("couponPolicy")를 부를 때마다 서로 다른 CouponPolicy 인스턴스가 돌아왔다.', 'SUBJECTIVE'),
       (4360, 696, '아래 로그로 볼 때, ReportWriter 선언부에만 추가한 빈 설정의 값은?', '웹 서버 없이 AnnotationConfigApplicationContext로 띄운 콘솔 프로그램이다. ReportWriter와 AuditLog는 둘 다 인스턴스가 만들어질 때 임시 파일을 하나 열고, 각 클래스의 @PreDestroy 메서드에서 그 파일을 닫으며 로그를 남긴다. 처음에는 두 클래스가 똑같이 동작했는데, ReportWriter 선언부에만 애너테이션 한 줄을 추가하자 실행 결과가 아래처럼 바뀌었다.

```
getBean(ReportWriter.class) → ReportWriter@1b6d3586
getBean(ReportWriter.class) → ReportWriter@4554617c
getBean(ReportWriter.class) → ReportWriter@74a14482
getBean(AuditLog.class)     → AuditLog@1540e19d
getBean(AuditLog.class)     → AuditLog@1540e19d
context.close() 호출
AuditLog: audit.tmp 닫음
프로세스 종료 시점에 열린 채 남은 파일: report-1.tmp, report-2.tmp, report-3.tmp
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4355
(11787, 4355, '1 → 3 → 5 → 4 → 2', 'Aware 콜백이 인스턴스화 바로 다음에 온다고 본 오해다. 컨테이너는 생성자를 부른 뒤 @Autowired 세터 주입(5)부터 끝내고, 그다음 초기화 단계에 들어가면서 setBeanName(3) 같은 Aware 콜백을 부른다. 그래서 5가 3보다 먼저 찍힌다.', false),
(11788, 4355, '1 → 4 → 5 → 3 → 2', '이름만 보고 @PostConstruct가 생성자 직후에 불린다고 본 오해다. 이 콜백은 주입과 Aware 콜백이 모두 끝난 뒤에 실행되므로, warmUp() 안에서 client를 쓰면 이미 채워져 있다. 생성자 바로 다음이었다면 client는 아직 null이다.', false),
(11789, 4355, '1 → 5 → 3 → 4 → 2', '생성자(1) → 세터 주입(5) → BeanNameAware(3) → 초기화 전 후처리 단계의 @PostConstruct(4) → InitializingBean.afterPropertiesSet()(2) 순서다. 소스에 적힌 메서드 순서가 아니라 컨테이너가 정한 생명주기 단계가 호출 순서를 정한다.', true),
(11790, 4355, '1 → 5 → 3 → 2 → 4', '스프링 인터페이스 콜백이 표준 애너테이션보다 먼저 불린다고 본 오해다. @PostConstruct는 초기화 전 후처리 단계에서 처리되고, afterPropertiesSet()은 그 뒤 초기화 메서드 호출 단계에서 불린다. @Bean(initMethod)가 있었다면 그보다도 뒤다.', false),

-- 문제 4356
(11791, 4356, 'A: Hello, lee / B: Hello, park / C: Hello, park', '스코프를 지정하지 않은 빈은 싱글톤이라 세 스레드가 같은 userName 필드를 공유한다. A는 100ms에 읽는데 그 전 30ms에 B가 lee를 썼고, B는 130ms에 읽는데 120ms에 C가 park을 썼다. C가 읽는 220ms까지는 더 쓰는 요청이 없어 park이다.', true),
(11792, 4356, 'A: Hello, kim / B: Hello, lee / C: Hello, park', '요청마다 빈 인스턴스나 필드가 따로 생긴다고 본 오해다. 기본 스코프 빈은 컨테이너에 하나뿐이고 모든 요청 스레드가 같은 객체를 쓰므로, sleep 사이에 다른 요청이 필드를 덮어쓴다. 요청별 데이터는 지역 변수나 파라미터로 다뤄야 한다.', false),
(11793, 4356, 'A: Hello, lee / B: Hello, lee / C: Hello, park', 'B도 A처럼 100ms 시점에 값을 읽는다고 본 계산이다. B는 30ms에 대입하고 100ms를 쉰 뒤 130ms에 읽으므로, 그 사이인 120ms에 C가 쓴 park을 읽는다. 공유 필드에서 읽히는 값은 읽는 순간 마지막으로 쓰인 값이다.', false),
(11794, 4356, 'A: Hello, park / B: Hello, park / C: Hello, park', '모든 요청이 가장 마지막에 쓰인 값을 본다고 본 오해다. A는 100ms에 이미 필드를 읽어 응답을 만들었고 park은 그보다 뒤인 120ms에 쓰였다. 필드를 공유하더라도 각 요청이 받는 값은 자신이 읽는 순간의 값이다.', false),

-- 문제 4357
(11795, 4357, '순환 참조를 허용하는 설정이 켜져 있으므로, Member·Point 쌍과 Order·Stock 쌍 모두 고리가 풀려 정상 기동한다.', '설정이 모든 순환을 풀어 준다고 본 오해다. 이 설정은 주입 전 객체의 참조를 미리 넘기는 방식을 허용할 뿐인데, 생성자 주입은 인스턴스를 만드는 순간 상대 빈이 있어야 해 미리 넘길 참조 자체가 없다. 그래서 Order·Stock 쌍은 풀리지 않는다.', false),
(11796, 4357, 'Member·Point 쌍은 주입 전 참조를 먼저 넘겨 풀 수 있지만, Order·Stock 쌍은 생성 중인 빈을 다시 요청하게 되어 기동이 실패한다.', '필드 주입은 인스턴스화와 주입이 나뉘어 있어, 허용 설정이 켜지면 주입 전 객체의 참조를 상대에게 먼저 넘겨 고리를 푼다. 생성자 주입은 생성 자체에 상대 빈이 필요해 생성 중인 빈을 다시 찾게 되고, BeanCurrentlyInCreationException으로 기동이 멈춘다.', true),
(11797, 4357, '스프링 부트 2.6 이후로는 이 설정이 무시되므로, 필드 주입인 Member·Point 쌍도 순환으로 막혀 기동이 실패한다.', '기본값이 바뀐 것을 설정으로도 되돌릴 수 없다고 본 오해다. 스프링 부트 2.6부터 이 속성의 기본값이 false가 됐을 뿐, true로 켜면 필드·세터 주입 순환은 예전처럼 주입 전 참조로 풀린다. 기동을 막는 쪽은 생성자 주입 쌍이다.', false),
(11798, 4357, 'Order·Stock 쌍은 생성자 실행 뒤 참조를 채워 풀 수 있지만, Member·Point 쌍은 필드가 null로 남아 기동이 실패한다.', '두 주입 방식의 성질을 뒤바꾼 오해다. 생성자 주입은 생성자를 부르는 순간 인자로 상대 빈이 있어야 해 나중에 채워 넣을 틈이 없다. 반대로 필드 주입은 인스턴스를 먼저 만든 뒤 필드에 넣으므로 주입 전 참조로 고리를 풀 수 있다.', false),

-- 문제 4358
(11799, 4358, '(가)는 넣어 주는 의존 객체가 없으므로 IoC에도 해당하지 않는다.', 'IoC와 DI를 같은 것으로 본 오해다. IoC는 누가 흐름을 쥐고 내 코드를 부르는지에 관한 원칙이라, JUnit이 테스트 메서드를 찾아 실행하는 것만으로 IoC에 해당한다. 의존 객체를 밖에서 넣어 주는지는 DI인지를 가르는 기준이다.', false),
(11800, 4358, '(나)는 DI에 해당하지만 IoC에는 해당하지 않는다.', 'DI를 IoC와 별개의 기법으로 본 오해다. 의존 객체를 누가 만들고 언제 넣을지를 컨테이너가 정하므로 제어가 넘어간 것이고, DI는 IoC 원칙을 구현하는 대표 기법이다. DI이면서 IoC가 아닌 경우는 없다.', false),
(11801, 4358, '(다)는 OrderService가 빈으로 등록돼 있으므로 DI에 해당한다.', '빈으로 등록된 클래스라면 그 안의 의존 객체도 주입받는다고 본 오해다. 컨테이너가 관리하는 것은 OrderService 자체일 뿐, 어떤 저장소 구현을 쓸지는 여전히 코드 안의 new가 정한다. 테스트에서 가짜 저장소로 바꾸려면 OrderService를 고쳐야 한다.', false),
(11802, 4358, '(라)는 IoC에 해당하지만 DI에는 해당하지 않는다.', 'cleanUp()을 언제 부를지 개발자 코드가 아니라 스케줄러가 정하므로 제어의 역전이다. 다만 메서드에 넘겨주는 인자도, 밖에서 넣어 주는 의존 객체도 없어 DI는 일어나지 않는다. 프레임워크가 내 코드를 부르는 구조는 DI 없이도 IoC에 속한다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1408, 4359, 'BeanFactoryPostProcessor,빈 팩토리 후처리기,빈팩토리 후처리기,빈 팩토리 포스트 프로세서,빈 팩토리 포스트프로세서,빈팩토리포스트프로세서,BFPP', '로그의 단서는 세 가지다. 기동 중 딱 한 번 불렸고, 애플리케이션 빈의 생성자가 하나도 불리기 전이었으며, 객체가 아니라 빈마다 등록된 클래스·스코프·지연 생성 여부 같은 정보를 읽고 고쳤다. 컨테이너는 설정을 읽어 빈 정의(BeanDefinition)를 모두 등록한 뒤, 인스턴스를 만들기 전에 BeanFactoryPostProcessor를 불러 그 정의를 손볼 기회를 준다. 그래서 여기서 scope를 prototype으로 바꾸자 이후 couponPolicy를 꺼낼 때마다 새 인스턴스가 만들어졌다. ${...} 플레이스홀더를 실제 값으로 바꾸는 PropertySourcesPlaceholderConfigurer가 대표적인 구현이다. 이름이 비슷한 BeanPostProcessor와 헷갈리기 쉬운데, BeanPostProcessor는 인스턴스가 만들어지고 주입까지 끝난 뒤 빈마다 초기화 전후로 불려 객체 자체를 다룬다. AOP 프록시로 원본을 바꿔 끼우는 것도 그 단계다. SchemaGuard가 BeanPostProcessor였다면 생성자 로그보다 뒤에, 빈 개수만큼 반복해서 찍혔을 것이다.'),
       (1409, 4360, 'prototype,프로토타입,prototype scope,프로토타입 스코프,@Scope("prototype"),@Scope(prototype),SCOPE_PROTOTYPE,프로토타입 빈,prototype bean', '로그의 단서는 두 가지다. getBean을 부를 때마다 해시값이 다른 새 ReportWriter가 나왔고, context.close() 때 AuditLog와 달리 ReportWriter의 @PreDestroy는 한 번도 불리지 않았다. 둘 다 @Scope("prototype")을 붙인 프로토타입 빈의 특징이다. 컨테이너는 프로토타입 빈을 조회할 때마다 새로 만들어 주입과 초기화 콜백까지만 해 주고 손을 떼므로, 만들어 준 인스턴스를 추적하지 않고 종료 때 소멸 콜백도 부르지 않는다. 그래서 파일·커넥션 같은 자원은 꺼내 쓴 쪽이 직접 닫아야 한다. 기본값인 싱글톤은 AuditLog처럼 같은 인스턴스를 돌려주고 종료 때 소멸 콜백을 받는다. 요청마다 새 인스턴스를 만드는 request 스코프도 있지만 웹 환경에서만 쓸 수 있고 요청이 끝나면 소멸 콜백이 불리므로 이 콘솔 프로그램과 맞지 않는다. 생성 시점을 최초 조회로 미루는 @Lazy는 인스턴스가 여전히 하나뿐이라 역시 다르다.');

-- =====================================================
-- Lesson 854: 스코프별 소멸 콜백과 순환 참조 해소
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5303, 854, '아래 코드로 만든 애플리케이션에 GET /orders를 세 번 차례로 요청했을 때, 세 응답 본문을 순서대로 나열한 것은?', '스프링 부트 3.2 웹 애플리케이션이다. 세 클래스는 모두 컴포넌트 스캔으로 등록되며, OrderService와 OrderController는 스코프를 따로 지정하지 않았다. 세 요청은 앞 요청의 응답을 받은 뒤에 보내는 서로 다른 HTTP 요청이다.

```java
@Component
@Scope(value = "request", proxyMode = ScopedProxyMode.TARGET_CLASS)
public class RequestLogger {
    private int count;
    public int next() { return ++count; }
}

@Service
public class OrderService {
    private final RequestLogger logger;

    public OrderService(RequestLogger logger) {
        this.logger = logger;
    }

    public int place() {
        logger.next();
        return logger.next();
    }
}

@RestController
public class OrderController {
    private final RequestLogger logger;
    private final OrderService orderService;

    public OrderController(RequestLogger logger, OrderService orderService) {
        this.logger = logger;
        this.orderService = orderService;
    }

    @GetMapping("/orders")
    public String orders() {
        logger.next();
        return String.valueOf(orderService.place());
    }
}
```', 'OBJECTIVE'),
       (5304, 854, '아래 애플리케이션을 기동했을 때 콘솔에 찍히는 두 줄을 순서대로 나열한 것은?', 'spring-boot-starter-data-jpa와 H2 데이터베이스가 설정된 스프링 부트 3.2 애플리케이션이다. 두 클래스는 모두 컴포넌트 스캔으로 등록되는 기본 스코프 빈이고, @PostConstruct는 jakarta.annotation 패키지의 것을 쓴다. isActualTransactionActive()는 현재 스레드에서 실제 트랜잭션이 진행 중이면 true를 돌려준다.

```java
@Service
public class PointService {

    @PostConstruct
    public void init() {
        grantWelcomePoints("init");
    }

    @Transactional
    public void grantWelcomePoints(String caller) {
        boolean active = TransactionSynchronizationManager.isActualTransactionActive();
        System.out.println(caller + " → " + active);
    }
}

@Component
public class WelcomeRunner {

    public WelcomeRunner(PointService pointService) {
        pointService.grantWelcomePoints("runner");
    }
}
```', 'OBJECTIVE'),
       (5305, 854, '아래 (가)~(라) 중 애플리케이션이 종료되며 컨텍스트가 닫힐 때 정리 메서드가 호출되는 것만 모두 고른 것은?', '스프링 부트 3.2 애플리케이션이다. 네 클래스는 모두 DisposableBean·AutoCloseable 같은 인터페이스를 구현하지 않으며, 각 정리 메서드는 호출되면 자기 클래스 이름을 로그로 남긴다. 네 객체는 모두 기동 뒤 한 번 이상 만들어졌고, 애플리케이션은 정상 종료된다.

(가) @Configuration 클래스의 @Bean 메서드로 등록한 ReportClient. 인자 없는 public void close()가 있고, destroyMethod는 지정하지 않았다.

(나) @Configuration 클래스의 @Bean 메서드로 등록한 ArchivePool. 인자 없는 public void shutdown()이 있고, destroyMethod는 지정하지 않았다.

(다) @Configuration 클래스의 @Bean 메서드로 등록한 CsvExporter. 인자 없는 public void destroy()가 있고, destroyMethod는 지정하지 않았다.

(라) @Component와 @Scope("prototype")을 붙인 TempFile. 인자 없는 메서드에 @PreDestroy를 붙였고, getBean()으로 한 번 꺼내 썼다.', 'OBJECTIVE'),
       (5306, 854, '아래 (가)·(나) 두 버전의 OrderService를 비교한 설명으로 옳은 것은?', 'OrderRepository는 인터페이스이고, 지금은 구현 클래스 JdbcOrderRepository 하나만 @Repository로 등록돼 있다. 팀은 저장 방식을 JPA 기반의 JpaOrderRepository로 옮기려 한다.

```java
// (가)
@Service
public class OrderService {
    private final OrderRepository repository = new JdbcOrderRepository();

    public void place(Order order) { repository.save(order); }
}

// (나)
@Service
public class OrderService {
    private final OrderRepository repository;

    public OrderService(OrderRepository repository) {
        this.repository = repository;
    }

    public void place(Order order) { repository.save(order); }
}
```', 'OBJECTIVE'),
       (5307, 854, '아래 상황에서 두 서비스에 새로 적용한 방식의 이름은?', '스프링 부트 3.2 프로젝트이고, application.properties에 spring.main.allow-circular-references=true가 켜져 있다. PaymentService와 RefundService는 서로를 포함해 각자 의존 객체 3개를 @Autowired 필드로 받고 있었는데, 코드 리뷰에서 의존 객체를 받는 방식을 바꾸자는 의견이 나왔다. 설정은 그대로 둔 채 두 서비스를 같은 방식으로 고치자 아래 변화가 생겼다.

- 의존 필드에 모두 final을 붙일 수 있게 되어, 실행 중 다른 객체로 바꿔 끼우는 코드가 컴파일 오류로 막혔다.
- 단위 테스트에서 ReflectionTestUtils.setField()로 private 필드를 채우던 코드 9줄이 사라졌고, 이제는 스프링 컨텍스트도 리플렉션도 없이 가짜 객체만으로 PaymentService를 조립한다.
- 그동안 아무 문제 없이 기동되던 두 서비스의 서로 참조가, 로컬 기동 단계에서 BeanCurrentlyInCreationException으로 곧바로 드러났다.', 'SUBJECTIVE'),
       (5308, 854, '아래 상황에서 OrderService 생성자의 매개변수 앞에 붙인 애너테이션의 이름은?', '스프링 부트 3.2 애플리케이션이다. OrderService와 CouponService는 서로를 생성자로 주입받고 있어, 기동할 때마다 두 빈이 순환 참조를 이룬다는 오류로 실패했다. 다른 코드는 그대로 두고 OrderService 생성자의 CouponService 매개변수 앞에 애너테이션 한 줄만 붙이자 기동에 성공했고, 로그는 아래와 같았다.

```
[main] OrderService 생성자 호출 - 받은 couponService: com.shop.CouponService$$SpringCGLIB$$0
[main] CouponService 생성자 호출 - 받은 orderService: com.shop.OrderService
[main] Started ShopApplication in 2.3 seconds
[http-nio-8080-exec-1] OrderService.checkout() → couponService.apply() 호출
[http-nio-8080-exec-1] CouponService.apply() 실행 - this: com.shop.CouponService
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5303
(14315, 5303, '1, 1, 1', '프록시가 메서드를 부를 때마다 새 인스턴스를 만든다고 본 오해다. 요청 스코프 프록시는 호출마다 현재 HTTP 요청에 묶인 RequestLogger를 찾아 위임하므로, 한 요청 안에서 부른 세 번의 next()는 모두 같은 인스턴스의 count를 올린다.', false),
(14316, 5303, '2, 2, 2', '주입받은 자리마다 인스턴스가 따로 생긴다고 본 오해다. OrderController와 OrderService가 받은 것은 같은 프록시이고, 같은 요청 안에서는 둘 다 같은 RequestLogger에 위임한다. 그래서 컨트롤러의 한 번과 서비스의 두 번이 한 count에 쌓인다.', false),
(14317, 5303, '3, 3, 3', '한 요청 안에서 컨트롤러가 한 번, 서비스가 두 번 next()를 불러 같은 RequestLogger의 count가 3이 된다. 다음 요청에서는 프록시가 그 요청용으로 새로 만든 인스턴스에 위임하므로 count가 다시 0에서 시작해 매번 3이 나온다.', true),
(14318, 5303, '3, 6, 9', '싱글톤이 주입 시점에 받은 인스턴스를 계속 쓴다는 규칙을 그대로 적용한 오해다. proxyMode를 지정하면 주입되는 것은 실제 빈이 아니라 프록시라서, 싱글톤이 이를 계속 붙들고 있어도 호출마다 현재 요청의 빈을 새로 찾아 위임한다.', false),

-- 문제 5304
(14319, 5304, 'init → false / runner → true', '트랜잭션을 거는 프록시는 초기화 뒤 후처리 단계에서 만들어지는데, @PostConstruct는 그보다 먼저 실행되고 this도 원본 객체라 init 쪽엔 트랜잭션이 없다. WelcomeRunner는 후처리까지 끝난 프록시를 주입받으므로 runner 쪽 호출은 트랜잭션 안에서 실행된다.', true),
(14320, 5304, 'init → true / runner → true', '@Transactional이 붙은 메서드는 어디서 부르든 트랜잭션이 걸린다고 본 오해다. 트랜잭션은 애너테이션 자체가 아니라 원본을 감싼 프록시가 시작하므로, 프록시가 생기기 전에 원본의 this로 부른 init 쪽 호출은 트랜잭션 없이 실행된다.', false),
(14321, 5304, 'init → false / runner → false', '다른 빈의 생성자 안은 아직 기동 중이라 트랜잭션이 걸리지 않는다고 본 오해다. 트랜잭션 적용 여부는 기동 중인지가 아니라 프록시를 거치는지로 갈린다. WelcomeRunner가 받은 PointService는 후처리까지 끝나 프록시로 바뀐 객체다.', false),
(14322, 5304, 'init → true / runner → false', '초기화 콜백은 준비가 다 끝난 뒤라 안전하고 다른 빈의 생성자는 이르다고 뒤집어 본 오해다. 실제로는 @PostConstruct가 프록시 생성보다 앞 단계라 트랜잭션이 없고, WelcomeRunner에 주입될 때는 프록시가 이미 만들어져 있다.', false),

-- 문제 5305
(14323, 5305, '(가)', 'AutoCloseable 규약의 close()만 정리 메서드로 알아본다고 본 오해다. @Bean으로 등록한 객체는 destroyMethod를 지정하지 않으면 인자 없는 public close()를 먼저 찾고, 없으면 shutdown()을 찾아 종료 때 부른다. 그래서 (나)의 shutdown()도 호출된다.', false),
(14324, 5305, '(가), (나)', '@Bean의 destroyMethod 기본값은 추론이라 인자 없는 public close()나 shutdown()을 소멸 메서드로 삼는다. (다)의 destroy()는 추론 대상 이름이 아니고, (라)는 프로토타입이라 컨테이너가 만들어 넘긴 뒤 추적하지 않아 소멸 콜백을 부르지 않는다.', true),
(14325, 5305, '(가), (나), (다)', 'DisposableBean 인터페이스의 destroy()와 이름이 같으면 불린다고 본 오해다. CsvExporter는 그 인터페이스를 구현하지 않았고 추론은 close()·shutdown()만 찾으므로, destroy()를 쓰려면 @Bean(destroyMethod = "destroy")처럼 직접 지정해야 한다.', false),
(14326, 5305, '(가), (나), (라)', '@PreDestroy를 붙이면 스코프와 관계없이 종료 때 불린다고 본 오해다. 프로토타입 빈은 컨테이너가 생성·주입·초기화까지만 맡고 그 뒤로는 추적하지 않아 소멸 콜백을 부르지 않는다. TempFile이 쥔 자원은 꺼내 쓴 쪽이 직접 정리해야 한다.', false),

-- 문제 5306
(14327, 5306, '(가)도 @Service가 붙은 빈이므로, JpaOrderRepository를 빈으로 등록하면 repository 필드가 새 구현으로 바뀐다.', 'OrderService가 빈이라는 것과 그 안의 의존 객체를 컨테이너가 넣어 주는 것은 별개다. (가)의 필드는 클래스 안의 new가 채우므로 컨테이너가 끼어들 자리가 없고, 구현을 바꾸려면 OrderService 코드를 직접 고쳐야 한다.', false),
(14328, 5306, '(나)는 생성자에 @Autowired가 없어, 컨테이너가 이 생성자로 주입하지 않고 repository를 null로 남겨 둔다.', '생성자가 하나뿐이면 스프링 4.3부터 @Autowired를 생략해도 컨테이너가 그 생성자로 인스턴스를 만든다. 이때 인자 자리에 맞는 OrderRepository 빈을 찾아 넘기므로 repository는 등록된 구현으로 채워진다.', false),
(14329, 5306, '(나)는 조립을 컨테이너가 맡으므로, 단위 테스트에서도 스프링 컨텍스트를 띄워야만 OrderService를 만들 수 있다.', '컨테이너가 조립을 맡는다고 조립 방법이 컨테이너에만 있는 것은 아니다. (나)는 평범한 생성자라 테스트에서 가짜 저장소를 인자로 넘겨 new로 곧바로 만들 수 있다. 오히려 (가)가 실제 JDBC 구현에 묶여 가짜로 바꾸기 어렵다.', false),
(14330, 5306, '(나)는 JpaOrderRepository를 빈으로 등록하고 기존 구현의 등록을 빼면, OrderService 코드는 그대로 둔 채 저장 방식이 바뀐다.', '(나)는 인터페이스에만 의존하고 어떤 구현을 넣을지는 컨테이너가 정한다. 그래서 구현 교체가 빈 등록을 바꾸는 것으로 끝나고 OrderService는 그대로다. (가)는 사용하는 쪽이 구현 클래스를 직접 new해 둘이 강하게 묶여 있다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1724, 5307, '생성자 주입,생성자주입,생성자 기반 주입,생성자 의존성 주입,생성자 방식 주입,생성자를 통한 주입,생성자 인젝션,constructor injection,constructor-based injection,constructor based injection,constructor DI', '세 가지 변화는 모두 의존 객체를 생성자 인자로 받게 바꾼 결과다. 인자는 생성자에서 단 한 번 대입되므로 필드를 final로 둘 수 있고, 평범한 생성자라 테스트에서 new에 가짜 객체를 넘기기만 하면 조립이 끝나 리플렉션도 컨테이너도 필요 없다. 또 인스턴스를 만드는 순간 상대 빈이 이미 완성돼 있어야 하므로, 주입 전 참조를 먼저 넘겨 순환을 풀어 주는 allow-circular-references 설정이 켜져 있어도 서로 참조는 기동 단계에서 예외로 드러난다. 세터 주입과 헷갈리기 쉬운데, 세터 주입은 인스턴스를 먼저 만든 뒤 세터로 값을 넣으므로 final을 쓸 수 없고, 허용 설정이 켜져 있으면 순환도 주입 전 참조로 풀려 문제가 잠복한다. 필드 주입은 여기에 더해 테스트에서 리플렉션까지 필요하다. 이런 이유로 스프링 공식 문서도 필수 의존성에는 생성자 주입을 권장한다.'),
       (1725, 5308, '@Lazy,Lazy,레이지,@레이지', '@Lazy를 주입 지점(생성자 매개변수)에 붙이면 컨테이너는 진짜 CouponService를 넘기는 대신, 메서드가 불리는 시점에 실제 빈을 찾아 위임하는 프록시를 만들어 넘긴다. 그래서 OrderService는 CouponService의 완성을 기다리지 않고 생성을 마칠 수 있어 고리가 끊긴다. 로그에서 OrderService가 받은 객체에는 $$SpringCGLIB$$가 붙어 있고, 실제 apply()는 원본 CouponService에서 실행된 것이 그 흔적이다. 다만 이는 기동만 되게 하는 임시방편이다. 두 클래스가 서로의 책임을 나눠 갖고 있다는 설계 신호는 그대로 남으므로, 공통 로직을 제3의 클래스로 빼거나 이벤트 발행으로 한 방향 의존을 만드는 것이 정석이다. 순환 참조 허용 설정(spring.main.allow-circular-references=true)과 헷갈리기 쉬운데, 그 설정은 세터·필드 주입에서 주입 전 참조를 넘기는 것만 허용할 뿐 생성자 주입끼리의 순환은 풀지 못하고 프록시도 만들지 않는다. @Primary·@Qualifier는 같은 타입 후보 가운데 무엇을 고를지 정할 뿐 생성 순서의 고리와는 관계가 없다.');
