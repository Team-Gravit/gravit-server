-- Unit: 요청 전후 처리 계층 (Unit ID: 115)
-- Chapter: Spring (Chapter ID: 10)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (541, 115, '세 계층 비교와 인터셉터 콜백 순서'),
       (699, 115, '요구사항별 배치와 필터 예외 위임'),
       (857, 115, '경로 패턴 적용 범위와 비동기 디스패치');

-- =====================================================
-- Lesson 541: 세 계층 비교와 인터셉터 콜백 순서
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3425, 541, '아래 요청 전후 처리 계층에 대한 설명으로 옳은 것은?', '이 계층은 jakarta.servlet 스펙에 정의되어 있어 DispatcherServlet 바깥에서 동작하고, 스프링 MVC를 전혀 몰라도 등록해 쓸 수 있다. 체인의 다음 대상으로 요청을 넘기는 호출을 하지 않으면 요청은 그 지점에서 끝난다.', 'OBJECTIVE'),
       (3426, 541, '아래 요청을 한 번 보냈을 때 콘솔에 남는 로그를 순서대로 나열한 것은?', '```java
public class TraceInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler) {
        log.info("A");
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest req, HttpServletResponse res,
                           Object handler, ModelAndView mv) {
        log.info("B");
    }

    @Override
    public void afterCompletion(HttpServletRequest req, HttpServletResponse res,
                                Object handler, Exception ex) {
        log.info("C");
    }
}

// TraceInterceptor는 /api/** 에 등록되어 있다.
@GetMapping("/api/orders/{id}")
public OrderResponse find(@PathVariable Long id) {
    throw new OrderNotFoundException();   // @RestControllerAdvice가 404 응답으로 변환한다
}
```

보낸 요청: `GET /api/orders/7`', 'OBJECTIVE'),
       (3427, 541, '아래 설정에서 로그가 이렇게 남는 원인으로 옳은 것은?', '```java
@Component
public class RequestLoggingFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
            throws ServletException, IOException {
        chain.doFilter(req, res);
        log.info("{} {}", req.getMethod(), req.getRequestURI());
    }
}

@Configuration
public class FilterConfig {

    @Bean
    public FilterRegistrationBean<RequestLoggingFilter> loggingFilter() {
        FilterRegistrationBean<RequestLoggingFilter> bean =
                new FilterRegistrationBean<>(new RequestLoggingFilter());
        bean.addUrlPatterns("/api/*");
        return bean;
    }
}
```

관찰된 로그 — `GET /api/orders` 요청 1회, `GET /health` 요청 1회를 보낸 결과다.

```
GET /api/orders
GET /api/orders
GET /health
```', 'OBJECTIVE'),
       (3428, 541, '아래 비교표를 바탕으로 판단할 때 옳지 않은 것은?', '| 항목 | 필터 | 인터셉터 | ArgumentResolver |
|---|---|---|---|
| 스펙 | 서블릿(jakarta.servlet) | 스프링 MVC | 스프링 MVC |
| 실행 위치 | DispatcherServlet 바깥 | DispatcherServlet 안 | HandlerAdapter 안 |
| 핸들러 정보 접근 | 불가 | 가능(HandlerMethod) | 가능(MethodParameter) |
| 요청·응답 객체 교체 | 가능(래퍼) | 불가(참조만) | 불가 |
| @ControllerAdvice 적용 | 안 됨 | 됨 | 됨 |', 'OBJECTIVE'),
       (3429, 541, '아래 상황을 해결하려고 코드를 옮겨 간 인터셉터 콜백 메서드의 이름은?', '요청마다 인터셉터에서 MDC에 추적 ID를 심고, 컨트롤러 실행이 끝난 직후 도는 콜백에서 MDC를 지우도록 했다. 평소에는 잘 지워졌지만, 컨트롤러가 예외를 던져 @RestControllerAdvice가 500 응답을 만든 요청에서는 지워지지 않았다. 그 뒤 같은 스레드를 재사용한 다음 요청의 로그에 앞 요청의 추적 ID가 그대로 따라붙었다. 지우는 코드를 다른 콜백으로 옮기자 예외가 난 요청에서도 값이 남지 않았다.', 'SUBJECTIVE'),
       (3430, 541, '아래 상황에서 새로 만들어 등록한 스프링 MVC 구성 요소의 이름은?', '컨트롤러 메서드 40여 곳에 세션에서 memberId를 꺼내고 null이면 예외를 던지는 다섯 줄이 똑같이 반복됐다. @LoginMember라는 애노테이션을 만들고 그에 대응하는 구현체를 WebMvcConfigurer에 등록하자, 반복되던 다섯 줄이 모두 사라지고 메서드 시그니처가 `me(@LoginMember Long memberId)`로 바뀌었다. 이 구성 요소는 요청을 막거나 통과시키는 판단은 하지 않으며, 스프링 시큐리티의 @AuthenticationPrincipal도 같은 원리로 동작한다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3425
(9307, 3425, '실행될 컨트롤러 메서드에 붙은 애노테이션을 확인해 요청을 통과시킬지 결정할 수 있다.', '핸들러 정보(HandlerMethod)를 받는 계층은 인터셉터다. 서블릿 스펙 계층은 어느 컨트롤러가 실행될지 알 수 없어 URL 패턴으로만 대상을 가른다.', false),
(9308, 3425, '여기서 던진 예외는 @ControllerAdvice가 잡지 못하고 톰캣의 오류 처리를 거쳐 /error로 넘어간다.', '예외를 @ExceptionHandler로 모으는 일은 DispatcherServlet 안에서 일어난다. 그 바깥에서 터진 예외는 서블릿 컨테이너가 처리해 BasicErrorController로 흐른다.', true),
(9309, 3425, '요청·응답 객체를 래퍼로 바꿔 끼울 수 없어 본문을 두 번 읽는 처리는 맡길 수 없다.', '반대다. 요청·응답 객체를 감싼 래퍼로 교체할 수 있는 유일한 계층이라 본문 캐싱이나 응답 압축을 바로 이 자리에서 처리한다.', false),
(9310, 3425, '컨트롤러 메서드의 파라미터 값을 만들어 넣어 주는 것이 이 계층의 주된 역할이다.', '파라미터 조립은 ArgumentResolver의 몫이다. 이 계층은 값을 만들지 않고 요청 흐름 자체를 다음으로 넘기거나 끊는 일을 한다.', false),

-- 문제 3426
(9311, 3426, 'A', '예외가 나면 preHandle 뒤의 콜백이 전부 끊긴다고 본 오해. preHandle이 true를 돌려준 요청이라면 afterCompletion은 예외가 나든 안 나든, 예외가 이미 처리된 뒤라도 반드시 호출되므로 C가 빠질 수 없다.', false),
(9312, 3426, 'A → B', 'postHandle을 컨트롤러 실행 직후 무조건 도는 지점으로, afterCompletion을 정상 흐름 전용 마무리로 본 오해. 두 메서드의 성격이 정반대다.', false),
(9313, 3426, 'A → C', 'preHandle에서 A가 찍히고, 컨트롤러가 예외를 던져 postHandle은 건너뛴다. 예외를 @RestControllerAdvice가 이미 404 응답으로 바꿨어도 응답 완료 후 afterCompletion은 호출되므로 C가 남는다.', true),
(9314, 3426, 'A → B → C', '세 콜백이 언제나 순서대로 다 돈다고 본 오해. postHandle은 컨트롤러가 값을 정상 반환했을 때만 호출된다.', false),

-- 문제 3427
(9315, 3427, '@Component로 자동 등록된 필터가 전체 경로에, 수동 등록된 필터가 /api/* 에 각각 걸려 두 벌이 동작한다.', '스프링 부트는 필터 타입 빈을 발견하면 모든 URL에 등록한다. 여기에 FilterRegistrationBean 등록이 겹쳐 /api 아래에서만 두 번, 그 밖에서는 한 번 찍힌다.', true),
(9316, 3427, 'OncePerRequestFilter를 상속하지 않아 forward·error 디스패치마다 필터가 다시 실행된다.', '중복 실행을 디스패치 재진입으로 돌린 오해. 코드는 이미 OncePerRequestFilter를 상속했고, 재진입이 원인이라면 /health가 찍히는 이유를 설명하지 못한다.', false),
(9317, 3427, 'addUrlPatterns의 /api/* 패턴이 상위 경로까지 확장돼 /health 요청에도 함께 매칭된다.', '서블릿 URL 패턴 /api/* 는 /api 로 시작하는 경로에만 맞는다. /health까지 찍히는 이유는 패턴이 아니라 경로 제한 없이 등록된 쪽이 따로 있어서다.', false),
(9318, 3427, 'setOrder를 지정하지 않아 순서가 정해지지 않은 필터가 체인을 한 번 더 순회한다.', 'setOrder는 필터들 사이의 실행 순서만 정할 뿐 실행 횟수와는 무관하다. 값을 지정해도 등록이 두 벌이면 그대로 두 번 실행된다.', false),

-- 문제 3428
(9319, 3428, '컨트롤러 메서드에 붙은 애노테이션으로 인가를 나누는 처리는 필터가 아니라 인터셉터에 두어야 한다.', '참이다. 핸들러 정보 접근 행에서 필터는 불가, 인터셉터는 HandlerMethod를 받으므로 어떤 메서드가 실행될지 보고 분기할 수 있다.', false),
(9320, 3428, '필터에서 인증에 실패해 예외를 던지면 @ControllerAdvice가 만드는 공통 오류 응답으로 내려가지 않는다.', '참이다. @ControllerAdvice 적용 행에서 필터만 안 됨이다. DispatcherServlet 바깥이라 스프링의 예외 처리 흐름에 아예 닿지 못한다.', false),
(9321, 3428, '요청 인코딩 통일처럼 스프링 MVC와 무관한 전역 처리는 세 계층 중 필터에 두는 것이 알맞다.', '참이다. 표에서 필터만 서블릿 스펙이고 DispatcherServlet 바깥에서 도므로, 스프링을 모르는 처리를 가장 앞단에서 한 번에 걸 수 있다.', false),
(9322, 3428, '인터셉터는 요청 객체를 래퍼로 갈아 끼울 수 있어 본문을 여러 번 읽는 처리를 맡기기 좋다.', '요청·응답 객체 교체 행에서 인터셉터는 불가라 거짓이다. 인터셉터는 객체 참조만 받으므로 본문 캐싱 래핑은 교체가 되는 필터에서 해야 한다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1098, 3429, 'afterCompletion,afterCompletion(),after completion,애프터컴플리션,애프터 컴플리션', '컨트롤러가 예외를 던지면 postHandle은 건너뛰지만, preHandle이 true를 돌려준 요청이라면 afterCompletion은 예외 발생 여부와 무관하게(예외가 @RestControllerAdvice로 이미 처리됐더라도) 항상 호출된다. 실행이 보장되는 유일한 콜백이라 MDC·ThreadLocal 해제처럼 빠뜨리면 다음 요청까지 오염되는 정리를 여기에 둔다. 다만 예외 리졸버가 이미 처리한 예외는 afterCompletion의 ex 인자로 넘어오지 않아 null이 들어오므로, 예외 로깅을 이 인자에만 기대면 안 된다. preHandle은 컨트롤러 실행 전 검증, postHandle은 뷰 렌더링 전 모델 보강이 제자리라 자원 정리 용도로는 맞지 않는다.'),
       (1099, 3430, 'ArgumentResolver,HandlerMethodArgumentResolver,argument resolver,handler method argument resolver,아규먼트 리졸버,아규먼트리졸버,아규먼트 리솔버', '컨트롤러 메서드의 파라미터 하나를 대신 조립해 넣어 주는 구성 요소가 HandlerMethodArgumentResolver다. supportsParameter()가 true를 돌려주는 첫 구현체가 선택되며 WebMvcConfigurer.addArgumentResolvers()로 등록한다. 요청을 끊을 수 있는 인터셉터와 달리 차단 권한이 없어, 인증은 인터셉터가 맡고 값 주입만 여기서 하는 조합이 흔하다.');

-- =====================================================
-- Lesson 699: 요구사항별 배치와 필터 예외 위임
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4373, 699, '아래 요청을 한 번 보냈을 때 콘솔에 찍히는 로그의 순서로 옳은 것은?', '```java
public class TraceFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res,
                                    FilterChain chain) throws ServletException, IOException {
        log.info("F1");
        chain.doFilter(req, res);
        log.info("F2");
    }
}

public class TraceInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler) {
        log.info("I1");
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest req, HttpServletResponse res,
                           Object handler, ModelAndView mv) {
        log.info("I2");
    }

    @Override
    public void afterCompletion(HttpServletRequest req, HttpServletResponse res,
                                Object handler, Exception ex) {
        log.info("I3");
    }
}

public class LoginMemberArgumentResolver implements HandlerMethodArgumentResolver {

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(LoginMember.class);
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mav,
                                  NativeWebRequest webRequest, WebDataBinderFactory binderFactory) {
        log.info("R");
        return 1L;
    }
}

@RestController
public class MemberController {

    @GetMapping("/api/me")
    public MemberResponse me(@LoginMember Long memberId) {
        log.info("C");
        return memberService.find(memberId);
    }
}
```

TraceFilter는 `/api/*`, TraceInterceptor는 `/api/**`에 등록되어 있고, LoginMemberArgumentResolver도 등록되어 있다. 컨트롤러는 예외 없이 정상 반환한다.

보낸 요청: `GET /api/me`', 'OBJECTIVE'),
       (4374, 699, '아래 요구사항 표를 보고 요구사항과 구현 위치를 옳게 짝지은 것은?', '| 구분 | 요구사항 |
|---|---|
| (가) | 모든 요청의 문자 인코딩을 UTF-8로 맞추고, 요청 본문을 로그로 남기려고 요청 객체를 래퍼로 감싸 다음 단계에 넘긴다. |
| (나) | `@AdminOnly`가 붙은 컨트롤러 메서드만 관리자 권한을 검사하고, 권한이 없으면 `@RestControllerAdvice`에 정의한 공통 오류 JSON(403)으로 응답한다. |
| (다) | 컨트롤러 메서드에서 `@CurrentTenant`가 붙은 파라미터에, X-Tenant-Id 헤더로 조회한 Tenant 객체를 넣어 준다. |
| (라) | HTTP 요청 없이 `@Scheduled` 배치에서도 호출되는 `SettlementService.settle()`의 실행 시간을 호출마다 기록한다. |', 'OBJECTIVE'),
       (4375, 699, '아래 코드와 실행 결과에서 응답에 X-Trace-Id 헤더가 빠진 원인으로 옳은 것은?', '```java
public class TraceIdInterceptor implements HandlerInterceptor {

    @Override
    public void postHandle(HttpServletRequest req, HttpServletResponse res,
                           Object handler, ModelAndView mv) {
        res.setHeader("X-Trace-Id", UUID.randomUUID().toString());
        log.info("postHandle 실행");
    }
}

@RestController
public class OrderController {

    @GetMapping("/api/orders/{id}")
    public OrderResponse find(@PathVariable Long id) {
        return orderService.find(id);
    }
}
```

TraceIdInterceptor는 `/api/**`에 등록되어 있다. `GET /api/orders/7`을 보낸 결과는 다음과 같다.

```
[서버 로그] postHandle 실행

[응답] 200 OK
Content-Type: application/json
{"id":7,"status":"PAID"}
(X-Trace-Id 헤더 없음)
```', 'OBJECTIVE'),
       (4376, 699, '아래 스프링 MVC 구성 요소에 대한 설명으로 옳은 것은?', '이 구성 요소는 스프링 MVC가 컨트롤러 메서드를 호출하기 직전에 동작한다. 메서드의 파라미터를 하나씩 살펴 자신이 맡을 수 있는 파라미터인지 판단하고, 맡기로 한 파라미터에 넣을 값을 세션·헤더 등에서 꺼내 만들어 돌려준다.', 'OBJECTIVE'),
       (4377, 699, '아래 상황에서 catch 블록이 잡은 예외를 넘긴 빈의 인터페이스 이름은?', 'JWT를 검사하는 서블릿 필터에서 토큰이 만료되면 `ExpiredJwtException`을 던지도록 했다. `@RestControllerAdvice`에는 이 예외를 받아 401과 `{"code":"TOKEN_EXPIRED"}`를 돌려주는 `@ExceptionHandler`도 만들어 두었다. 그런데 만료된 토큰으로 `GET /api/orders`를 보내자 아래 응답이 내려왔다.

```
HTTP/1.1 500
{"timestamp":"2026-09-13T01:12:31.402+00:00","status":500,"error":"Internal Server Error","path":"/api/orders"}
```

필터 본문을 try-catch로 감싸고, catch 블록에서 `@Qualifier`를 붙여 생성자로 주입받은 빈의 메서드를 `(request, response, null, e)` 인자로 호출하게 고쳤다. 필터가 예외를 다시 던지지 않는데도, 같은 요청에 401 `{"code":"TOKEN_EXPIRED"}` 응답이 내려왔다.', 'SUBJECTIVE'),
       (4378, 699, '아래 상황에서 허용 분기에 추가한 호출의 메서드 이름은?', '사내 IP에서만 `/admin/*`에 접근할 수 있도록 서블릿 필터를 추가했다. 필터는 요청 IP가 허용 목록에 없으면 `response.sendError(403)`을 호출하고 `return`하며, 허용 목록에 있으면 로그 한 줄만 남기고 메서드를 끝낸다.

배포 후 허용된 사내 IP로 `GET /admin/dashboard`를 보내자 403은 나오지 않았다. 필터 로그는 매번 찍혔지만 인터셉터·컨트롤러 로그는 한 줄도 없었고, 본문이 빈 200 응답만 돌아왔다. 허용 분기의 로그 다음 줄에 호출 하나를 추가하자 대시보드 응답이 정상으로 내려왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4373
(11835, 4373, 'F1 → R → I1 → C → I2 → I3 → F2', '파라미터 조립이 인터셉터보다 먼저라고 본 오해. ArgumentResolver는 HandlerAdapter가 컨트롤러를 호출하기 직전에 동작하므로, DispatcherServlet이 그보다 앞서 부르는 preHandle(I1)을 앞지를 수 없다.', false),
(11836, 4373, 'I1 → F1 → R → C → I2 → I3 → F2', '인터셉터가 필터보다 먼저라고 본 오해. 필터는 DispatcherServlet 바깥에서 요청을 먼저 받고, 인터셉터는 chain.doFilter()로 요청이 DispatcherServlet에 들어간 뒤에야 호출된다.', false),
(11837, 4373, 'F1 → I1 → R → C → I2 → I3 → F2', '필터(F1)를 지난 요청은 DispatcherServlet 안에서 preHandle(I1) → 파라미터 조립(R) → 컨트롤러(C) → postHandle(I2) → afterCompletion(I3) 순으로 처리된다. DispatcherServlet이 끝나야 chain.doFilter()가 반환되므로 F2가 마지막이다.', true),
(11838, 4373, 'F1 → I1 → R → C → I2 → F2 → I3', 'afterCompletion을 응답이 필터까지 다 빠져나간 뒤의 콜백으로 본 오해. afterCompletion도 DispatcherServlet 안에서 호출되므로, chain.doFilter() 다음 줄의 F2보다 먼저 찍힌다.', false),

-- 문제 4374
(11839, 4374, '(가) — 인터셉터', '요청 객체를 래퍼로 바꿔 넘기는 일은 인터셉터가 할 수 없다. 인터셉터는 이미 만들어진 요청 객체의 참조만 받으므로, 인코딩 설정과 요청 래핑은 DispatcherServlet 앞에서 요청을 받는 필터에 둬야 한다.', false),
(11840, 4374, '(나) — 인터셉터', '인터셉터는 preHandle에서 HandlerMethod를 통해 실행될 메서드의 @AdminOnly를 확인할 수 있다. DispatcherServlet 안에서 동작하므로 여기서 던진 예외를 @RestControllerAdvice가 받아 공통 오류 JSON으로 바꿔 준다.', true),
(11841, 4374, '(다) — 필터', '필터는 어떤 컨트롤러 메서드가 실행될지 모르고, 그 파라미터에 값을 넣을 수단도 없다. @CurrentTenant가 붙은 파라미터를 골라 값을 만들어 넣는 일은 ArgumentResolver가 맡는다.', false),
(11842, 4374, '(라) — 인터셉터', '성능 측정을 인터셉터 몫으로만 외운 오해. @Scheduled 배치 호출에는 HTTP 요청이 없어 필터·인터셉터가 아예 실행되지 않는다. 서비스 메서드 단위의 공통 처리는 AOP로 건다.', false),

-- 문제 4375
(11843, 4375, '컨트롤러에서 예외가 발생해, 예외 시 호출되지 않는 postHandle이 통째로 건너뛰어졌다.', 'postHandle이 컨트롤러 예외 시 건너뛰어지는 것은 맞지만 이 요청과는 무관하다. 로그에 postHandle 실행이 찍혔고 200 정상 응답이 나왔으니, 헤더 코드는 실행됐는데 응답에 반영되지 않은 것이다.', false),
(11844, 4375, '인터셉터는 응답 객체를 래퍼로 바꿀 수 없어, 헤더를 추가하는 호출 자체가 효과를 내지 못한다.', '객체 교체 불가를 수정 불가로 넓힌 오해. 인터셉터도 받은 응답 객체에 setHeader를 호출할 수 있어, 같은 코드를 preHandle에 두면 헤더가 정상으로 붙는다. 인터셉터가 못 하는 것은 래퍼로 갈아 끼우는 일이다.', false),
(11845, 4375, '@RestController라 postHandle에 ModelAndView가 null로 들어와, 거기서 설정한 헤더도 함께 버려졌다.', 'ModelAndView는 뷰 이름과 모델을 담는 객체라 응답 헤더와 무관하다. null이 들어온 것은 맞지만, setHeader는 응답 객체에 직접 거는 호출이라 mv 값 때문에 버려지지 않는다.', false),
(11846, 4375, '컨트롤러 반환값이 postHandle 호출 전에 이미 JSON 본문으로 쓰여, 그 뒤에 넣은 헤더가 반영되지 않았다.', '@RestController의 반환값은 HandlerAdapter 안에서 메시지 컨버터가 곧바로 본문에 쓰고 응답을 커밋한다. postHandle은 그 뒤에 호출되므로 헤더를 넣어도 늦다. 이런 헤더는 preHandle이나 ResponseBodyAdvice에서 넣어야 한다.', true),

-- 문제 4376
(11847, 4376, '같은 파라미터를 처리할 수 있는 구현체가 여럿 등록돼 있으면, 먼저 확인된 하나만 쓰이고 나머지는 호출되지 않는다.', 'ArgumentResolver는 등록된 구현체를 순서대로 확인해 supportsParameter()가 true인 첫 구현체만 쓴다. 기본 구현체가 먼저 확인되므로, 기본 구현체가 이미 맡는 파라미터에 건 커스텀 구현체는 무시될 수 있다.', true),
(11848, 4376, '맡을 수 없다고 판단한 파라미터가 하나라도 있으면, 컨트롤러를 호출하지 않고 요청 처리를 끝낸다.', 'false로 요청을 멈추는 것은 인터셉터 preHandle의 성질이다. 여기서 맡을 수 없다는 판단은 다음 구현체에 차례를 넘길 뿐이며, 이 구성 요소는 요청을 막거나 통과시키는 판단을 하지 않는다.', false),
(11849, 4376, '컨트롤러 메서드가 반환한 객체를 받아, JSON 같은 응답 본문으로 바꿔 쓰는 일도 함께 맡는다.', '입력 조립과 반환값 처리를 혼동한 오해. 반환값을 응답 본문으로 쓰는 일은 HandlerMethodReturnValueHandler와 메시지 컨버터가 맡는다. 이 구성 요소는 호출 직전의 입력값만 만든다.', false),
(11850, 4376, '여기서 던진 예외는 DispatcherServlet 바깥에서 발생해, @RestControllerAdvice가 잡지 못한다.', '필터의 예외 경계를 옮겨 붙인 오해. 파라미터 조립은 DispatcherServlet이 부른 HandlerAdapter 안에서 일어나므로, 여기서 던진 예외도 @RestControllerAdvice가 정상적으로 처리한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1414, 4377, 'HandlerExceptionResolver,handler exception resolver,핸들러 익셉션 리졸버,핸들러익셉션리졸버,핸들러 예외 리졸버,핸들러예외리졸버,핸들러 익셉션 리솔버', '필터는 DispatcherServlet 바깥에서 동작하므로, 여기서 던진 예외는 @RestControllerAdvice에 닿지 못하고 서블릿 컨테이너의 오류 처리를 거쳐 /error(BasicErrorController)의 기본 500 응답이 된다. HandlerExceptionResolver는 DispatcherServlet이 컨트롤러 쪽 예외를 @ExceptionHandler로 연결할 때 쓰는 인터페이스라, 필터에서 잡은 예외를 resolveException(request, response, null, e)로 직접 넘기면 같은 @ExceptionHandler를 재사용할 수 있다. handler 자리가 null인 것은 필터 단계에서는 아직 실행될 컨트롤러 메서드가 정해지지 않았기 때문이다. 스프링 부트에는 이 인터페이스를 구현한 빈이 여럿(DefaultErrorAttributes 등)이라 @Qualifier("handlerExceptionResolver")로 골라 주입한다. @ExceptionHandler는 예외를 처리할 메서드에 붙이는 애노테이션, @RestControllerAdvice는 그런 메서드를 모아 두는 클래스로, 예외를 넘겨받는 인터페이스인 HandlerExceptionResolver와는 구분된다.'),
       (1415, 4378, 'doFilter,doFilter(),chain.doFilter,chain.doFilter(),filterChain.doFilter,filterChain.doFilter()', '필터가 요청을 다음 필터나 DispatcherServlet으로 넘기려면 FilterChain의 doFilter()를 직접 호출해야 한다. 이를 부르지 않으면 요청은 그 필터에서 끝나 뒤의 필터·DispatcherServlet·인터셉터·컨트롤러가 전혀 실행되지 않고, 응답에 아무것도 쓰지 않았으니 서블릿 컨테이너가 빈 200 응답으로 마무리한다. 차단 분기에서 일부러 호출하지 않고 응답을 직접 쓰는 것은 인증 실패 같은 요청을 필터에서 끊는 정상적인 방법이다. OncePerRequestFilter를 상속했다면 개발자가 재정의하는 메서드는 doFilterInternal()이지만, 다음 단계로 넘길 때 호출하는 것은 여전히 chain.doFilter()다. 인터셉터에는 이런 호출이 없고 preHandle()이 true를 돌려주는 것으로 통과를, false를 돌려주는 것으로 중단을 표시한다는 점과 구분한다.');

-- =====================================================
-- Lesson 857: 경로 패턴 적용 범위와 비동기 디스패치
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5321, 857, '아래 설정에서 AuthInterceptor가 UnauthorizedException을 던지는 요청은?', '```java
public class AuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if (!(handler instanceof HandlerMethod handlerMethod)) {
            return true;
        }
        if (handlerMethod.hasMethodAnnotation(PublicApi.class)) {
            return true;
        }
        if (request.getSession(false) == null) {
            throw new UnauthorizedException();
        }
        return true;
    }
}

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new AuthInterceptor())
                .addPathPatterns("/api/**")
                .excludePathPatterns("/api/auth/**");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/api/images/**")
                .addResourceLocations("classpath:/static/images/");
    }
}

@RestController
public class ProductController {

    @PublicApi
    @GetMapping("/api/products")
    public List<ProductResponse> list() { ... }

    @GetMapping("/api/products/{id}")
    public ProductResponse detail(@PathVariable Long id) { ... }
}

@RestController
public class AuthController {

    @GetMapping("/api/auth/me")
    public MemberResponse me() { ... }
}
```

`@PublicApi`는 메서드에 붙이는 커스텀 애노테이션이다. 요청은 모두 세션 쿠키 없이 보내며, `/api/images/banner.png` 파일은 실제로 존재한다.', 'OBJECTIVE'),
       (5322, 857, '아래 코드와 실행 결과에서 로그인하지 않은 요청에 /api/admin/stats가 200을 돌려준 원인으로 옳은 것은?', '로그인 검사 인터셉터를 없애고, 아래 ArgumentResolver 하나로 로그인 검사까지 대신하도록 바꿨다.

```java
public class LoginMemberArgumentResolver implements HandlerMethodArgumentResolver {

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(LoginMember.class);
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mav,
                                  NativeWebRequest webRequest, WebDataBinderFactory binderFactory) {
        HttpServletRequest request = webRequest.getNativeRequest(HttpServletRequest.class);
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("memberId") == null) {
            throw new UnauthorizedException();   // @RestControllerAdvice가 401 응답으로 변환
        }
        return session.getAttribute("memberId");
    }
}

@RestController
public class AdminController {

    @GetMapping("/api/admin/members/{id}")
    public MemberResponse member(@LoginMember Long adminId, @PathVariable Long id) { ... }

    @GetMapping("/api/admin/stats")
    public StatsResponse stats() { ... }
}
```

세션 쿠키 없이 보낸 두 요청의 결과는 다음과 같다.

```
GET /api/admin/members/3  → 401 {"code":"UNAUTHORIZED"}
GET /api/admin/stats      → 200 {"todayOrders":152,"newMembers":37}
```', 'OBJECTIVE'),
       (5323, 857, '아래 필터 설정과 실행 결과에서 요청 B가 접근 로그에 남지 않은 원인으로 옳은 것은?', '두 필터는 모두 FilterRegistrationBean으로 등록했다.

| 필터 | setOrder | URL 패턴 | 동작 |
|---|---|---|---|
| AccessLogFilter | 2 | /* | chain.doFilter()가 반환된 뒤 메서드·URI·상태 코드를 로그로 남긴다. |
| TokenAuthFilter | 1 | /api/* | Authorization 헤더가 없으면 response.setStatus(401)로 상태를 정하고 오류 JSON을 직접 쓴 뒤 메서드를 끝낸다. 헤더가 있으면 chain.doFilter()를 호출한다. |

실행 결과

```
요청 A: GET /api/orders (Authorization 있음) → 200, 접근 로그 "GET /api/orders 200"
요청 B: GET /api/orders (Authorization 없음) → 401, 접근 로그 없음
요청 C: GET /health     (Authorization 없음) → 200, 접근 로그 "GET /health 200"
```', 'OBJECTIVE'),
       (5324, 857, '아래 비동기 요청 처리 흐름에 대한 설명으로 옳은 것은?', '주문 내역 엑셀 내보내기 API의 컨트롤러는 DeferredResult를 곧바로 반환하고, 파일 생성은 별도 스레드 풀에 맡긴다. 요청을 받은 톰캣 스레드는 컨트롤러가 반환하자마자 반납되고, 파일 생성이 끝나 DeferredResult에 결과가 채워지면 같은 요청이 같은 경로로 다시 디스패치되어 응답이 쓰인다.

이 API 경로에는 preHandle이 호출될 때마다 API 호출 수 카운터를 1씩 올리는 인터셉터가 등록되어 있고, 이 인터셉터는 디스패치 종류를 따로 구분하지 않는다.', 'OBJECTIVE'),
       (5325, 857, '아래 상황에서 로깅 필터가 새로 상속한 클래스의 이름은?', '요청마다 메서드·URI·처리 시간을 남기는 로깅 필터를 jakarta.servlet.Filter 인터페이스를 직접 구현해 만들었다. 오류로 끝난 요청도 기록하려고 FilterRegistrationBean에 REQUEST와 ERROR 디스패치 타입을 모두 지정해 등록했다.

그런데 컨트롤러에서 처리되지 않은 예외가 나 500으로 끝난 요청은, 클라이언트가 한 번 보냈을 뿐인데 로그가 두 줄씩 남아 일별 요청 수 통계가 실제보다 부풀었다.

```
GET /api/orders/7 35ms
GET /error 4ms
```

등록 설정은 그대로 두고 필터 클래스의 부모 타입만 스프링이 제공하는 추상 클래스로 바꾸자, 같은 상황에서도 첫 줄만 남았다.', 'SUBJECTIVE'),
       (5326, 857, '아래 상황에서 실행 시간 측정 코드를 옮겨 간 공통 처리 기법의 이름은?', '주문 확정 메서드 OrderService.confirm()이 느리다는 제보를 받고, 주문 확정 API 경로(`/api/orders/*/confirm`)에 인터셉터를 걸어 preHandle에서 시작 시각을 기록하고 afterCompletion에서 걸린 시간을 남기게 했다.

한 달 뒤 집계해 보니 confirm() 실행 기록은 3,120건뿐이었다. 같은 메서드는 결제 대행사 콜백을 받는 `POST /api/payments/callback` 처리 중에도(2,410건), 주문 이벤트를 받는 Kafka 컨슈머에서도(820건) 호출되는데, 이 두 경로의 호출은 한 건도 남지 않았다. 게다가 남은 기록에는 confirm() 실행 시간뿐 아니라 요청 파라미터 변환과 응답 JSON 직렬화 시간까지 섞여 있었다.

측정 코드를 인터셉터에서 빼내 스프링이 지원하는 다른 공통 처리 기법으로 옮기자, OrderService 코드는 한 줄도 고치지 않았는데 세 경로의 호출 6,350건이 모두 기록되었고 기록된 시간도 confirm() 실행 구간만 담게 되었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5321
(14363, 5321, 'GET /api/auth/me', '로그인 사용자 조회라 막힐 것처럼 보이지만, /api/auth/** 가 excludePathPatterns에 들어 있어 AuthInterceptor가 아예 호출되지 않는다. 인터셉터 적용 여부는 경로 이름의 뜻이 아니라 등록한 패턴이 정한다.', false),
(14364, 5321, 'GET /api/images/banner.png', '/api/** 에 걸려 preHandle은 호출되지만, 정적 리소스 요청이라 handler로 HandlerMethod가 아닌 ResourceHttpRequestHandler가 들어온다. 첫 번째 if에서 true를 돌려주므로 세션 검사까지 가지 않는다.', false),
(14365, 5321, 'GET /api/products/7', '제외 경로가 아니고 handler도 HandlerMethod다. @PublicApi는 목록 조회 list()에만 붙어 있고 상세 조회 detail()에는 없으므로, 세션이 없는 이 요청은 마지막 if에서 UnauthorizedException으로 막힌다.', true),
(14366, 5321, 'GET /api/products', '상세 조회와 같은 경로 아래라도 list()에는 @PublicApi가 붙어 있어 hasMethodAnnotation 검사에서 통과한다. 애노테이션은 경로나 클래스 단위가 아니라 실제로 실행될 메서드 단위로 확인된다.', false),

-- 문제 5322
(14367, 5322, 'resolveArgument는 @LoginMember가 붙은 파라미터를 채울 때만 호출되어, 그런 파라미터가 없는 stats()에서는 세션 검사가 실행되지 않았다.', 'supportsParameter가 true인 파라미터가 없으면 resolveArgument는 호출될 일이 없다. 파라미터를 만드는 계층이라 요청 차단을 맡길 수 없으니, 로그인 차단은 인터셉터에 두고 값 주입만 ArgumentResolver에 맡겨야 한다.', true),
(14368, 5322, 'ArgumentResolver를 등록할 때 addPathPatterns로 /api/admin/** 를 지정하지 않아, stats 경로가 적용 대상에서 빠졌다.', '인터셉터의 경로 지정 방식을 ArgumentResolver에 옮겨 붙인 오해. addArgumentResolvers에는 경로 패턴 개념이 없고, 같은 /api/admin 아래의 members/3이 401을 받은 것도 경로 문제가 아님을 보여 준다.', false),
(14369, 5322, 'ArgumentResolver에서 던진 예외는 DispatcherServlet 바깥에서 발생해, @RestControllerAdvice가 잡지 못하고 200으로 바뀌었다.', '필터의 예외 경계를 옮겨 붙인 오해. 파라미터 조립은 DispatcherServlet 안의 HandlerAdapter에서 일어나 예외가 @RestControllerAdvice로 정상 처리되며, 실제로 members/3은 401을 받았다.', false),
(14370, 5322, 'ArgumentResolver는 컨트롤러 메서드가 반환된 뒤에 실행되어, stats()가 응답을 먼저 쓴 다음 던진 예외가 반영되지 않았다.', '실행 시점을 거꾸로 본 오해. ArgumentResolver는 컨트롤러 메서드를 호출하기 직전에 인자를 만들며, 인자를 만들다 예외가 나면 컨트롤러 메서드 자체가 호출되지 않는다.', false),

-- 문제 5323
(14371, 5323, 'AccessLogFilter의 /* 패턴은 한 단계 경로에만 맞아, /api/orders 같은 하위 경로 요청은 처음부터 걸러진다.', '인터셉터 경로 패턴의 규칙을 서블릿 URL 패턴에 옮겨 붙인 오해. 필터의 /* 는 모든 경로에 맞으며, 실제로 요청 A의 GET /api/orders는 접근 로그에 남았다.', false),
(14372, 5323, '401 응답은 필터가 던진 예외로 만들어져 /error로 넘어가므로, 상태 코드가 정해지기 전에 로그 기록이 취소된다.', 'TokenAuthFilter는 예외를 던지지 않고 401 응답을 직접 쓴 뒤 끝난다. /error로 넘어가는 흐름은 예외가 필터 밖으로 빠져나갈 때의 일이라 이 요청과 무관하다.', false),
(14373, 5323, 'AccessLogFilter가 바깥에서 먼저 실행되지만, 안쪽 필터가 응답을 직접 쓰고 끝나면 chain.doFilter() 다음 줄은 실행되지 않는다.', '두 가지를 오해했다. setOrder 값이 작을수록 먼저라 AccessLogFilter(2)는 안쪽이다. 또 바깥 필터였다면 안쪽이 응답을 쓰고 끝나도 chain.doFilter()가 반환되어 다음 줄의 로그는 남는다.', false),
(14374, 5323, 'TokenAuthFilter가 AccessLogFilter보다 바깥에서 먼저 실행되어, 헤더 없는 요청은 AccessLogFilter를 거치지 않고 응답이 끝난다.', 'setOrder 값이 작은 TokenAuthFilter(1)가 먼저 요청을 받고, 헤더가 없으면 chain.doFilter()를 부르지 않아 안쪽의 AccessLogFilter까지 요청이 가지 않는다. 거부된 요청도 남기려면 로그 필터의 order를 더 작게 둔다.', true),

-- 문제 5324
(14375, 5324, '톰캣 스레드가 반납되는 시점에 postHandle과 afterCompletion이 호출되고, 결과 디스패치 때는 인터셉터를 다시 거치지 않는다.', '동기 요청의 흐름을 그대로 적용한 오해. 비동기 처리가 시작된 첫 디스패치에서는 postHandle·afterCompletion이 호출되지 않고(AsyncHandlerInterceptor라면 afterConcurrentHandlingStarted만 호출), 두 메서드는 결과 디스패치에서 호출된다.', false),
(14376, 5324, 'API를 한 번 호출해도 결과 디스패치 때 같은 인터셉터의 preHandle이 다시 호출되어, 카운터는 1이 아니라 2가 오른다.', '결과 디스패치도 DispatcherServlet을 거치므로 경로가 맞는 인터셉터의 preHandle이 한 번 더 불린다. 한 번만 세려면 request.getDispatcherType()이 ASYNC인 호출을 건너뛰어야 한다.', true),
(14377, 5324, '결과 디스패치 중 던진 예외는 DispatcherServlet 바깥에서 발생하므로, @RestControllerAdvice가 처리하지 못한다.', '필터의 예외 경계를 옮겨 붙인 오해. 결과 디스패치도 DispatcherServlet 안에서 처리되므로, 여기서 나온 예외는 동기 요청과 마찬가지로 @RestControllerAdvice의 @ExceptionHandler가 처리한다.', false),
(14378, 5324, '결과를 채운 스레드 풀의 스레드가 응답까지 직접 쓰므로, 인터셉터의 afterCompletion도 그 스레드에서 호출된다.', '결과를 채우는 일과 응답을 쓰는 일을 한 스레드의 일로 본 오해. 스레드 풀의 스레드는 DeferredResult에 값을 넣을 뿐이고, 응답은 다시 디스패치된 요청 처리 흐름에서 쓰이며 afterCompletion도 그때 호출된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1730, 5325, 'OncePerRequestFilter,Once Per Request Filter,OncePerRequest Filter,org.springframework.web.filter.OncePerRequestFilter,원스퍼리퀘스트필터,원스 퍼 리퀘스트 필터,원스퍼리퀘스트 필터', 'OncePerRequestFilter는 한 요청 안에서 필터 본문(doFilterInternal)이 한 번만 실행되도록 보장하는 스프링의 추상 필터 클래스다. forward처럼 같은 요청이 필터 체인을 다시 지날 때는 요청 속성에 남겨 둔 실행 표시를 보고 본문을 건너뛰고, 오류 페이지로 가는 ERROR 디스패치도 기본 설정에서는 본문을 실행하지 않고 통과시킨다. 그래서 등록 설정을 REQUEST·ERROR로 그대로 둬도 /error 줄이 사라졌다. 반면 Filter 인터페이스를 직접 구현하면 등록한 디스패치 타입마다 doFilter()가 그대로 다시 호출된다. 같은 스프링 추상 클래스인 GenericFilterBean은 필터 설정값을 편하게 읽게 해 줄 뿐 중복 실행을 막지 않고, FilterRegistrationBean은 필터의 URL 패턴·순서·디스패치 타입을 정하는 등록 도구이지 필터가 상속하는 부모 클래스가 아니라는 점과 구분한다.'),
       (1731, 5326, 'AOP,스프링 AOP,Spring AOP,관점 지향 프로그래밍,관점지향프로그래밍,관점 지향,관점지향,Aspect Oriented Programming,Aspect-Oriented Programming,AspectOrientedProgramming,애스펙트 지향 프로그래밍', 'AOP(관점 지향 프로그래밍)는 여러 곳에 흩어지는 공통 처리를 핵심 로직에서 떼어 내 메서드 실행 지점에 끼워 넣는 기법이다. 스프링 AOP는 OrderService 빈을 프록시로 감싸므로, @Around 어드바이스로 confirm()을 감싸면 호출한 쪽이 주문 확정 API든 결제 콜백 처리든 Kafka 컨슈머든 메서드 실행 구간만 정확히 잰다. 반면 필터·인터셉터·ArgumentResolver는 HTTP 요청이 DispatcherServlet 앞뒤를 지날 때만 동작하고 경로 패턴으로 대상을 고르므로, 다른 경로나 HTTP가 아닌 호출은 잡지 못하고 인터셉터가 잰 시간에는 파라미터 조립·응답 직렬화까지 섞인다. 요청 단위 공통 처리는 세 계층에, 트랜잭션·캐시·실행 시간 측정처럼 서비스 메서드 단위 공통 처리는 AOP에 둔다. 다만 같은 클래스 안에서 this로 부르는 내부 호출은 프록시를 거치지 않아 AOP가 적용되지 않는다는 점도 기억한다.');
