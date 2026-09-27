-- Unit: AOP와 프록시 동작 (Unit ID: 113)
-- Chapter: Spring (Chapter ID: 10)
-- Topic: SPRING_BOOT
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-spring-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(561, 'SPRING_BOOT', 113, 'HARD', true,
 'OrderService의 placeOrder 메서드 안에서 같은 클래스의 @Transactional(propagation = REQUIRES_NEW) 메서드를 호출했더니 새 트랜잭션이 적용되지 않았습니다. 원인이 무엇이고, 어떤 해결 방법을 선택하며 각 방법의 대가는 무엇인지 설명해 주세요.',
 '원인은 self-invocation입니다. 스프링 AOP는 프록시로 구현되고, 컨테이너는 포인트컷에 매칭되는 빈을 프록시로 감싸 프록시를 빈으로 등록하기 때문에 다른 빈에 주입되는 것은 항상 원본이 아니라 프록시입니다. 프록시는 외부에서 들어오는 호출만 가로챕니다. placeOrder 안에서 saveHistory를 부르면 this.saveHistory() 호출이 되는데, 이때 this는 프록시가 아니라 원본 객체이므로 트랜잭션 Advice가 적용되지 않고 REQUIRES_NEW가 무시됩니다. 가장 권장하는 해결책은 saveHistory를 OrderHistoryService 같은 별도 빈으로 옮겨 외부 호출이 되게 해서 프록시를 거치게 하는 것이고, 책임 분리로 설계도 개선됩니다. 다른 대안도 있지만 대가가 있습니다. ObjectProvider나 @Lazy로 자기 자신(프록시)을 주입받아 호출하는 방법은 동작하지만 순환 구조가 어색하고, @EnableAspectJAutoProxy(exposeProxy = true) 후 AopContext.currentProxy()로 현재 프록시를 조회하는 방법은 코드가 AOP 인프라에 의존하게 됩니다. AspectJ 위빙은 컴파일·로드 시점에 바이트코드를 직접 수정해 프록시 한계는 없지만 빌드·설정 복잡도가 증가합니다. 참고로 이 문제는 @Transactional뿐 아니라 @Cacheable, @Async, @Retryable, @PreAuthorize 등 프록시 기반 애노테이션 전부에 해당합니다.'),
(562, 'SPRING_BOOT', 113, 'NORMAL', true,
 'JDK Dynamic Proxy와 CGLIB 프록시는 어떻게 다르고, 스프링 부트는 기본으로 어떤 방식을 사용하나요?',
 'JDK Dynamic Proxy는 java.lang.reflect.Proxy로 인터페이스 구현체를 만들어내는 방식이라 대상이 반드시 인터페이스를 구현해야 하고, 인터페이스 타입으로만 주입할 수 있습니다. 호출은 InvocationHandler.invoke()에서 가로챕니다. 반면 CGLIB는 바이트코드 조작으로 대상 클래스의 서브클래스를 생성하므로 구체 클래스 타입으로도 주입할 수 있고, MethodInterceptor.intercept()로 호출을 가로챕니다. 대신 서브클래스를 만들어 오버라이드하는 구조라 클래스·메서드가 final이 아니어야 하고, private 메서드에는 적용할 수 없습니다. 또 CGLIB 프록시는 Objenesis로 인스턴스를 만들어 원본 생성자를 호출하지 않으므로 프록시 객체의 필드는 초기화되지 않은 null 상태이고, 주입받은 빈의 public 필드를 직접 읽으면 null이 나옵니다. 스프링 부트는 2.0부터 spring.aop.proxy-target-class=true가 기본이라 인터페이스가 있어도 CGLIB를 사용합니다. 인터페이스 타입·구체 클래스 타입 어느 쪽으로 주입하든 동작해야 하고, 두 방식의 동작을 통일하기 위해서입니다.'),
(563, 'SPRING_BOOT', 113, 'NORMAL', true,
 '스프링 AOP와 AspectJ는 Aspect를 적용하는 방식에서 어떻게 다르며, 그 차이 때문에 스프링 AOP에는 어떤 제약이 생기나요?',
 '스프링 AOP는 런타임 프록시 방식입니다. 컨테이너가 빈 초기화 마지막 단계에서 포인트컷에 매칭되는 빈을 프록시로 감싸고, 그 프록시가 호출을 가로채 Advice를 수행한 뒤 원본에 위임합니다. AspectJ의 포인트컷 표현식 문법만 빌려 쓰고 실제 적용은 프록시로 합니다. 반면 AspectJ는 컴파일·로드 시점에 바이트코드를 직접 수정해 위빙하므로 필드 접근이나 생성자 호출까지 가로챌 수 있습니다. 이 차이 때문에 스프링 AOP는 메서드 실행 Join Point만 지원하고 필드 접근·생성자·정적 메서드는 가로챌 수 없습니다. 또 프록시를 거쳐야 하므로 같은 객체 내부 호출은 Advice가 적용되지 않고, 빈에만 적용되어 new로 직접 만든 객체에는 Aspect가 적용되지 않습니다. AspectJ 위빙을 쓰면 이런 프록시 한계는 없지만 빌드·설정 복잡도가 증가합니다.'),
(564, 'SPRING_BOOT', 113, 'EASY', true,
 'AOP란 무엇이며, AOP의 핵심 용어인 Aspect, Pointcut, Advice는 각각 무엇을 의미하나요?',
 'AOP(관점 지향 프로그래밍)는 트랜잭션·로깅·보안처럼 여러 클래스에 흩어지는 공통 관심사를 핵심 로직에서 분리해 한 곳에서 관리하는 기법입니다. Aspect는 이런 공통 관심사를 모듈화한 단위로, Advice와 Pointcut으로 구성되며 스프링에서는 @Aspect 클래스로 만듭니다. Join Point는 Advice를 적용할 수 있는 지점이고, Pointcut은 그 Join Point 중 실제로 적용할 대상을 고르는 표현식으로 execution(* com.app..*Service.*(..)) 같은 형태입니다. Advice는 실제로 수행되는 부가 기능 코드로 @Before, @Around, @AfterReturning 등이 있습니다. Advice가 적용되는 원본 객체를 Target이라 하고, Aspect를 대상 코드에 결합하는 과정을 Weaving이라 하는데 스프링 AOP는 런타임 프록시 방식으로 Weaving합니다.'),
(565, 'SPRING_BOOT', 113, 'EASY', true,
 '스프링 AOP의 Advice 종류에는 무엇이 있고, 여러 Aspect가 한 메서드에 적용될 때 실행 순서는 어떻게 결정되나요?',
 'Advice는 실행 시점에 따라 다섯 가지가 있습니다. @Before는 대상 메서드 실행 전에 동작하고 인자를 조회할 수 있지만 실행 자체는 예외로만 막을 수 있습니다. @AfterReturning은 정상 반환 후 실행되어 반환값을 조회할 수 있지만 수정은 불가합니다. @AfterThrowing은 예외 발생 후 실행되어 예외 로깅·변환에 쓰입니다. @After는 정상·예외와 무관하게 종료 후 실행되어 finally에 해당합니다. @Around는 실행 전후 전체를 감싸 실행 여부·인자·반환값을 모두 제어할 수 있는 가장 강력한 Advice입니다. 여러 Aspect가 한 메서드에 적용되면 @Order 값으로 순서를 제어하는데, 값이 낮을수록 바깥쪽에서 실행되어 먼저 시작하고 나중에 끝납니다. 트랜잭션 Advice는 기본 순서가 Ordered.LOWEST_PRECEDENCE라서 커스텀 Aspect는 대개 트랜잭션 바깥에서 실행되고, 트랜잭션 안쪽에서 실행돼야 하면 @EnableTransactionManagement(order = ...)로 조정합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 561
(3011, 561, '다른 빈에 주입되는 것은 원본이 아니라 프록시 객체임을 언급', 'ESSENTIAL', 1),
(3012, 561, '내부 호출의 this는 프록시가 아닌 원본 객체라서 Advice가 적용되지 않음을 설명', 'ESSENTIAL', 2),
(3013, 561, '해당 메서드를 별도 빈으로 분리해 호출이 프록시를 거치게 하는 해결책을 제시', 'ESSENTIAL', 3),
(3014, 561, '자기 자신 주입·AopContext.currentProxy()·AspectJ 위빙 중 최소 1개 대안의 단점을 제시', 'ESSENTIAL', 4),
(3015, 561, '@Cacheable·@Async 등 프록시 기반 애노테이션 전부에 같은 문제가 생김을 언급', 'SUPPLEMENTARY', 5),
(3016, 561, '별도 빈 분리가 책임 분리로 설계까지 개선되어 가장 권장되는 방법임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 562
(3017, 562, 'JDK Dynamic Proxy는 인터페이스 구현체를, CGLIB는 대상 클래스의 서브클래스를 생성함을 설명', 'ESSENTIAL', 1),
(3018, 562, 'JDK Dynamic Proxy는 대상이 인터페이스를 구현해야 한다는 전제 조건을 언급', 'ESSENTIAL', 2),
(3019, 562, '스프링 부트 2.0 이상은 인터페이스가 있어도 CGLIB를 기본으로 사용함을 언급', 'ESSENTIAL', 3),
(3020, 562, '인터페이스·구체 클래스 타입 어느 쪽으로 주입해도 동작하게 하려는 것을 CGLIB 기본 채택 이유로 제시', 'SUPPLEMENTARY', 4),
(3021, 562, 'CGLIB 프록시는 final 클래스·final 메서드에 적용할 수 없다는 제약을 언급', 'SUPPLEMENTARY', 5),
(3022, 562, 'CGLIB 프록시 객체의 필드는 초기화되지 않아 public 필드를 직접 읽으면 null임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 563
(3023, 563, '스프링 AOP는 런타임 프록시 방식으로 Aspect를 적용함을 언급', 'ESSENTIAL', 1),
(3024, 563, 'AspectJ는 컴파일·로드 시점에 바이트코드를 직접 수정해 위빙함을 언급', 'ESSENTIAL', 2),
(3025, 563, '스프링 AOP는 메서드 실행 Join Point만 지원해 필드 접근·생성자를 가로챌 수 없음을 설명', 'ESSENTIAL', 3),
(3026, 563, '스프링 AOP는 AspectJ의 포인트컷 표현식 문법만 빌려 쓴다는 점을 언급', 'SUPPLEMENTARY', 4),
(3027, 563, 'new로 직접 만든 객체처럼 빈이 아닌 객체에는 Aspect가 적용되지 않음을 언급', 'SUPPLEMENTARY', 5),
(3028, 563, 'AspectJ 위빙은 프록시 한계가 없는 대신 빌드·설정 복잡도가 증가함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 564
(3029, 564, 'AOP가 트랜잭션·로깅 같은 공통 관심사를 핵심 로직에서 분리하는 기법임을 설명', 'ESSENTIAL', 1),
(3030, 564, 'Aspect가 공통 관심사를 모듈화한 단위임을 언급', 'ESSENTIAL', 2),
(3031, 564, 'Pointcut이 Join Point 중 실제 적용 대상을 고르는 표현식임을 언급', 'ESSENTIAL', 3),
(3032, 564, 'Advice가 실제로 수행되는 부가 기능 코드임을 언급', 'ESSENTIAL', 4),
(3033, 564, 'Aspect가 Advice와 Pointcut으로 구성됨을 언급', 'SUPPLEMENTARY', 5),
(3034, 564, 'Join Point가 Advice를 적용할 수 있는 지점임을 언급', 'SUPPLEMENTARY', 6),
(3035, 564, 'Weaving이 Aspect를 대상 코드에 결합하는 과정임을 언급', 'SUPPLEMENTARY', 7),

-- 질문 565
(3036, 565, '@Before·@AfterReturning·@AfterThrowing·@After·@Around 중 최소 3개를 실행 시점과 함께 제시', 'ESSENTIAL', 1),
(3037, 565, '@Order 값이 낮을수록 바깥쪽에서 실행됨을 설명', 'ESSENTIAL', 2),
(3038, 565, '@Around가 실행 여부·인자·반환값을 모두 제어할 수 있음을 언급', 'SUPPLEMENTARY', 3),
(3039, 565, '트랜잭션 Advice가 LOWEST_PRECEDENCE 기본값이라 커스텀 Aspect가 대개 트랜잭션 바깥에서 실행됨을 언급', 'SUPPLEMENTARY', 4),
(3040, 565, '@After는 정상·예외와 무관하게 실행되어 finally에 해당함을 언급', 'SUPPLEMENTARY', 5);
