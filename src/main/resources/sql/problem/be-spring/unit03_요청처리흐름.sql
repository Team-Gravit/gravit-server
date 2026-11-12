-- Unit: 요청 처리 흐름 (Unit ID: 114)
-- Chapter: Spring (Chapter ID: 10)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (540, 114, '위임 구조와 메시지 컨버터, 인자 해석'),
       (698, 114, '핸들러 매핑 순서와 인터셉터 호출 흐름'),
       (856, 114, '필터 예외 경계와 경로 패턴 매칭');

-- =====================================================
-- Lesson 540: 위임 구조와 메시지 컨버터, 인자 해석
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3419, 540, '아래 웹 요청 처리 구조에 대한 설명으로 옳은 것은?', '톰캣이 소켓 연결을 받아 스레드를 하나 할당하고 HttpServletRequest·HttpServletResponse 객체를 만든 뒤, HttpServlet을 상속한 단 하나의 서블릿에 모든 URL의 요청을 넘긴다. 이 서블릿은 요청을 직접 처리하지 않고, 자신을 띄운 것과는 다른 컨테이너에 등록된 빈 가운데 이 요청을 맡을 대상을 골라 호출한다.', 'OBJECTIVE'),
       (3420, 540, '아래는 JSON을 반환하는 GET 요청 하나를 처리하며 남은 로그다. 해석으로 옳은 것은?', '```
10:21:03.114  LoggingInterceptor#preHandle          uri=/api/orders/7
10:21:03.117  OrderController#find                  id=7
10:21:03.120  MappingJackson2HttpMessageConverter   write OrderResponse -> application/json
10:21:03.121  LoggingInterceptor#postHandle         modelAndView=null
10:21:03.122  LoggingInterceptor#afterCompletion    ex=null
```', 'OBJECTIVE'),
       (3421, 540, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 순서 | 인터페이스 | 하는 일 | 애노테이션 컨트롤러용 구현체 |
| --- | --- | --- | --- |
| 2단계 | HandlerMapping | 요청 URL·HTTP 메서드를 보고 이 요청을 처리할 핸들러를 찾는다 | RequestMappingHandlerMapping |
| 3단계 | HandlerAdapter | 찾아낸 핸들러를 어떤 방식으로 호출할지 고른다 | RequestMappingHandlerAdapter |', 'OBJECTIVE'),
       (3422, 540, '아래 요청이 들어왔을 때의 처리 과정에 대한 설명으로 옳은 것은?', '```java
public record OrderCreateRequest(Long itemId, @Positive int quantity) {}

@PostMapping("/api/customers/{customerId}/orders")
public ResponseEntity<OrderResponse> create(
        @PathVariable Long customerId,
        @RequestParam(defaultValue = "false") boolean urgent,
        @Valid @RequestBody OrderCreateRequest request) {
    log.info("start");
    return ResponseEntity.created(URI.create("/api/orders/1")).body(service.create(request));
}
```

요청: `POST /api/customers/9/orders` / `Content-Type: application/json` / 본문 `{"itemId": 10, "quantity": 0}`', 'OBJECTIVE'),
       (3423, 540, '아래 상황에서 설정을 바꾸자 출력이 달라진 구성 요소의 이름은?', '@RestController의 find()가 OrderResponse 객체를 그대로 반환하자 응답 본문에 {"id":7,"total":980,"createdAt":[2026,9,8,10,21,3]}이 실려 나갔다. createdAt이 배열로 나가는 것을 고치려고 WebMvcConfigurer에서 Jackson 관련 설정을 갈아 끼웠더니, 같은 요청의 응답이 {"id":7,"total":980,"createdAt":"2026-09-08T10:21:03"}으로 바뀌었다. 반면 같은 애플리케이션에서 문자열 orders/list를 반환하는 @Controller의 목록 화면은 설정을 바꾸기 전과 뒤가 완전히 같은 HTML이었다.', 'SUBJECTIVE'),
       (3424, 540, '아래 리팩터링에서 새로 등록한 스프링 MVC 확장 지점의 이름은?', '리팩터링 전 — 컨트롤러 40개가 저마다 이렇게 시작했다.

```java
@GetMapping("/orders")
public String list(HttpSession session, Model model) {
    Long id = (Long) session.getAttribute("LOGIN_MEMBER_ID");
    if (id == null) throw new UnauthorizedException();
    Member member = memberRepository.findById(id).orElseThrow();
    ...
}
```

리팩터링 후 — 앞의 세 줄이 40곳 모두에서 사라졌다.

```java
@GetMapping("/orders")
public String list(@LoginMember Member member, Model model) { ... }
```

바뀐 설정은 WebMvcConfigurer에 구현체 하나를 등록한 것뿐이고, HandlerMapping·HandlerAdapter 쪽은 그대로다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3419
(9291, 3419, '서블릿마다 담당 URL이 고정되어 있어 인코딩·예외 처리 같은 공통 코드가 서블릿 수만큼 중복된다.', 'URL마다 서블릿을 만들어 web.xml에 매핑하던 이전 방식의 특징이다. 본문은 모든 URL을 서블릿 하나가 받으므로 공통 코드가 중복될 자리 자체가 없다.', false),
(9292, 3419, '요청 객체를 만드는 컨테이너와 빈을 관리하는 컨테이너가 같아서 두 설정이 한 곳에서 관리된다.', '톰캣(서블릿 컨테이너)과 스프링 컨테이너를 하나로 보는 오개념이다. 계층이 달라 톰캣은 서블릿에 요청을 넘기는 데까지, 빈 탐색과 생명주기는 스프링 컨테이너가 맡는다.', false),
(9293, 3419, '요청을 맡을 빈을 못 찾으면 톰캣이 연결을 끊어 클라이언트는 응답을 아예 받지 못한다.', '핸들러를 못 찾는 것과 연결이 끊기는 것을 같은 일로 본 오개념이다. 스프링 부트에서는 BasicErrorController가 404 응답 본문을 만들어 정상적으로 돌려준다.', false),
(9294, 3419, '요청을 받은 스레드가 위임한 빈의 처리가 끝날 때까지 붙잡혀 있어, 처리가 느려지면 스레드부터 고갈된다.', '위임은 호출일 뿐 스레드 교대가 아니다. 본문에서 톰캣이 할당한 스레드 하나가 빈 호출과 응답 작성까지 동기적으로 이어가므로, 느린 처리는 곧 스레드 점유 시간 증가로 나타난다.', true),

-- 문제 3420
(9295, 3420, 'modelAndView가 null인 것은 뷰 이름에 맞는 템플릿을 찾지 못했다는 뜻이다.', '뷰 조회 실패로 오해한 것이다. 반환값이 이미 응답 본문으로 쓰여 넘길 ModelAndView가 만들어지지 않은 것이며, 템플릿을 찾지 못했다면 렌더링 단계에서 예외가 났을 것이다.', false),
(9296, 3420, 'postHandle에서 응답 본문을 고쳐도 클라이언트가 받는 JSON은 달라지지 않는다.', '로그에서 컨버터의 write가 postHandle보다 먼저 찍혔다. 본문이 이미 응답에 기록된 뒤라 이 시점의 수정은 전달되지 않는다. 렌더링 전이라 모델을 고칠 수 있는 뷰 반환 경로와 갈리는 지점이다.', true),
(9297, 3420, 'afterCompletion 줄이 남았다는 것은 처리 중 예외가 없었음을 뜻하며, 예외가 났다면 이 줄은 찍히지 않는다.', 'afterCompletion을 정상 종료 신호로 오해한 것이다. 이 메서드는 예외 발생 여부와 무관하게 항상 실행되고 예외는 인자로 전달된다. 예외 유무를 알려 주는 것은 ex=null 쪽이다.', false),
(9298, 3420, 'preHandle이 false를 반환했더라도 컨트롤러는 실행되고 응답 기록만 중단된다.', 'preHandle을 로그만 남기는 훅으로 본 오개념이다. false를 반환하면 그 자리에서 처리가 끝나므로 컨트롤러 호출도, 두 번째 줄 같은 로그도 남지 않는다.', false),

-- 문제 3421
(9299, 3421, '핸들러 형태가 새로 늘어나면 DispatcherServlet의 doDispatch() 안에 형태별 분기를 추가해야 한다.', '거짓이라 정답이다. 호출 방법 선택을 HandlerAdapter에 맡긴 이유가 바로 이 분기를 없애기 위해서다. 새 형태가 생기면 어댑터 구현체를 하나 더 등록하면 되고 DispatcherServlet 코드는 그대로 둔다.', true),
(9300, 3421, '정적 리소스 요청은 애노테이션 컨트롤러가 아니어서 표에 적힌 것과는 다른 구현체 짝이 처리한다.', '참이다. 정적 리소스는 SimpleUrlHandlerMapping이 찾고 HttpRequestHandlerAdapter가 호출한다. 표의 두 단계를 똑같이 밟되 각 인터페이스의 구현체만 달라진다.', false),
(9301, 3421, '2단계가 돌려주는 결과에는 핸들러뿐 아니라 이 요청에 걸린 인터셉터 목록도 함께 들어 있다.', '참이다. 반환 타입이 HandlerExecutionChain이라 핸들러와 인터셉터가 한 묶음으로 넘어온다. 덕분에 3단계 호출 앞뒤로 preHandle·postHandle을 끼워 넣을 수 있다.', false),
(9302, 3421, 'URL이 같아도 HTTP 메서드가 다르면 2단계에서 다른 핸들러가 선택될 수 있다.', '참이다. 표대로 URL과 HTTP 메서드를 함께 보고 찾으므로 GET /orders와 POST /orders는 서로 다른 메서드에 매핑된다. 헤더·produces 조건도 같은 방식으로 매칭에 쓰인다.', false),

-- 문제 3422
(9303, 3422, '세 파라미터는 하나의 리졸버가 선언 순서대로 값을 채운다.', '리졸버를 공용 부품 하나로 본 오개념이다. @PathVariable·@RequestParam·@RequestBody는 저마다 지원 여부를 스스로 판정하는 별개의 리졸버가 맡고, 목록을 순회하며 담당자를 고른다.', false),
(9304, 3422, 'JSON 본문을 객체로 바꾸는 일은 HandlerAdapter가 직접 하고, HttpMessageConverter는 응답을 쓸 때만 관여한다.', '컨버터를 응답 전용으로 오해한 것이다. 요청의 Content-Type과 파라미터 타입을 보고 역직렬화할 컨버터를 고르는 것도 같은 HttpMessageConverter이며, 어댑터는 그 호출을 엮을 뿐이다.', false),
(9305, 3422, 'quantity가 0이므로 컨트롤러 메서드의 첫 줄인 log.info까지 가지 못하고 처리가 끊긴다.', '@Valid 검증은 @RequestBody 인자를 만드는 리졸버 안에서 이뤄진다. 인자 조립 단계에서 MethodArgumentNotValidException이 던져지므로 메서드 본문은 시작조차 하지 않는다.', true),
(9306, 3422, 'urgent 값이 요청에 없으므로 핸들러를 찾는 단계에서 매칭이 어긋나 404가 된다.', '쿼리 파라미터를 매핑 조건으로 오해한 것이다. 매핑은 경로와 HTTP 메서드로 정해지고, 값이 없는 urgent는 리졸버가 defaultValue인 false로 채운다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1096, 3423, 'HttpMessageConverter,HTTP 메시지 컨버터,메시지 컨버터,메시지컨버터,MessageConverter,message converter,HttpMessageConverters', '@ResponseBody 경로에서 반환 객체를 응답 본문 바이트로 바꾸는 담당이 HttpMessageConverter다. JSON이면 MappingJackson2HttpMessageConverter가 선택되므로 Jackson 설정을 갈아 끼우면 직렬화 결과가 곧바로 달라진다. 뷰 이름을 반환하는 경로는 ViewResolver가 View를 찾아 render()로 HTML을 만들기 때문에 같은 설정을 바꿔도 출력이 그대로인 것이다. 응답 Content-Type도 이 컨버터가 Accept 헤더와 협상해 정한다는 점에서, 템플릿 엔진이 text/html로 결정하는 ViewResolver 경로와 구분해 두자.'),
       (1097, 3424, 'HandlerMethodArgumentResolver,ArgumentResolver,아규먼트 리졸버,아규먼트리졸버,argument resolver,핸들러메서드아규먼트리졸버,인자 리졸버', '컨트롤러 메서드의 인자를 조립하는 단계에 끼어드는 확장 지점이 HandlerMethodArgumentResolver다. supportsParameter()로 @LoginMember가 붙은 파라미터를 잡고 resolveArgument()에서 세션의 식별자로 Member를 만들어 넘기므로, 40곳에 흩어져 있던 조회 코드가 구현체 한 곳으로 모인다. 필터와 HandlerInterceptor도 컨트롤러 앞에서 공통 처리를 하지만, 이들은 요청을 통과시킬지 말지를 정할 뿐 메서드 인자를 만들어 넣을 수는 없다는 것이 경계다.');

-- =====================================================
-- Lesson 698: 핸들러 매핑 순서와 인터셉터 호출 흐름
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4367, 698, '아래 스프링 MVC 구성 요소에 대한 설명으로 옳은 것은?', '이 구성 요소는 애플리케이션이 기동될 때 @Controller·@RestController 빈에서 @RequestMapping 계열 애노테이션이 붙은 메서드를 모두 훑는다. 그리고 HTTP 메서드·URL 패턴·헤더·produces 같은 조건 묶음을 키로, 실행할 메서드를 값으로 하는 맵을 만들어 둔다. 요청이 들어오면 이 맵에서 조건이 모두 맞는 항목을 찾아 DispatcherServlet에 돌려준다.', 'OBJECTIVE'),
       (4368, 698, '아래 설정에서 각 요청이 처리되는 과정에 대한 설명으로 옳은 것은?', '스프링 부트 3.3 애플리케이션의 DispatcherServlet에는 HandlerMapping이 아래 순서로 등록돼 있고, 요청이 오면 위에서부터 차례로 조회해 처음 매칭된 핸들러를 쓴다.

```
1) RequestMappingHandlerMapping   GET /index.html  → HomeController#index()
2) BeanNameUrlHandlerMapping      /hello           → 빈 이름이 "/hello"인 HelloController
3) SimpleUrlHandlerMapping        /**              → ResourceHttpRequestHandler (classpath:/static/)
```

- HelloController는 애노테이션 없이 org.springframework.web.servlet.mvc.Controller 인터페이스를 구현한 클래스다.
- classpath:/static/ 폴더에는 index.html, logo.png 두 파일만 있다.
- HandlerAdapter는 스프링 부트 기본 구성 그대로다.', 'OBJECTIVE'),
       (4369, 698, '아래 두 요청의 처리 과정에 대한 설명으로 옳은 것은?', '```java
@Controller
public class OrderPageController {
    @GetMapping("/orders")
    public String list(Model model) {
        model.addAttribute("count", 3);
        return "orders/list";
    }
}

@RestController
public class OrderApiController {
    @GetMapping("/api/orders")
    public String list() {
        return "orders/list";
    }
}
```

- 뷰 템플릿으로 Thymeleaf를 쓰며, templates/orders/list.html은 모델의 count 값을 화면에 출력한다.
- 요청 두 건: GET /orders, GET /api/orders', 'OBJECTIVE'),
       (4370, 698, '아래 로그에 대한 해석으로 옳은 것은?', 'AuthInterceptor는 preHandle·postHandle·afterCompletion이 호출될 때마다 한 줄씩 로그를 남기도록 구현돼 있다. GlobalExceptionHandler는 @RestControllerAdvice 클래스이고, @ExceptionHandler(OrderNotFoundException.class)가 붙은 notFound() 메서드를 갖고 있다. 아래는 GET /api/orders/99 요청 한 건을 처리하며 남은 로그 전체다.

```
[exec-4] AuthInterceptor#preHandle          uri=/api/orders/99 → true
[exec-4] OrderController#find               id=99
[exec-4] OrderService#find                  throw OrderNotFoundException
[exec-4] GlobalExceptionHandler#notFound    → 404 {"code":"ORDER_NOT_FOUND"}
[exec-4] AuthInterceptor#afterCompletion    status=404
```', 'OBJECTIVE'),
       (4371, 698, '아래 개편으로 도입한 설계 패턴의 이름은?', '레거시 쇼핑몰의 web.xml에는 아래 같은 매핑이 URL마다 하나씩 모두 32개 있었고, 서블릿 32개의 doGet()은 한결같이 문자 인코딩 설정과 똑같은 try-catch 오류 처리로 시작했다.

```xml
<servlet-mapping>
    <servlet-name>orderListServlet</servlet-name>
    <url-pattern>/orders</url-pattern>
</servlet-mapping>
<!-- /orders/detail, /cart, /members/join ... 같은 형태로 31개 더 -->
```

개편 후 web.xml에 남은 매핑은 아래 하나뿐이다.

```xml
<servlet-mapping>
    <servlet-name>shopServlet</servlet-name>
    <url-pattern>/</url-pattern>
</servlet-mapping>
```

인코딩 설정·오류 처리 코드는 이제 shopServlet에만 있고, 주문 목록 같은 기능 32개는 HttpServlet을 상속하지 않는 일반 클래스로 바뀌었다. 이후 URL을 3개 더 추가했지만 web.xml은 한 줄도 바뀌지 않았다.', 'SUBJECTIVE'),
       (4372, 698, '아래 로그의 2차 시도에서 AdminGuard가 구현한 스프링 MVC 인터페이스의 이름은?', E'일반 회원(USER) 계정으로 GET /admin/reports/2026-09 요청을 보내면서, 접근 제어 코드 AdminGuard를 두 가지 방식으로 구현해 로그를 비교했다. ReportController#monthly()에는 @AdminOnly 애노테이션이 붙어 있다.\n\n```\n-- 1차: jakarta.servlet.Filter를 구현해 등록\n[AdminGuard]  uri=/admin/reports/2026-09  target=알 수 없음  role=USER → 판단 근거 없음, 통과\n[ReportController#monthly]  month=2026-09\n응답 200\n\n-- 2차: 같은 판단 로직을 옮겨 WebMvcConfigurer에 등록\n[AdminGuard]  uri=/admin/reports/2026-09  target=ReportController#monthly(YearMonth)  @AdminOnly=있음  role=USER → false 반환\n응답 403  (ReportController#monthly 로그 없음)\n```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4367
(11819, 4367, '조건이 맞는 항목을 찾지 못하면 이 구성 요소가 직접 404 응답을 작성하고 처리를 끝낸다.', '매핑 단계가 404를 쓴다고 본 오개념이다. 못 찾으면 null을 돌려줄 뿐 응답에는 손대지 않고, DispatcherServlet이 다음 HandlerMapping을 이어서 조회한다. 404 응답은 그 뒤 단계에서 만들어지며, 스프링 부트 기본값이면 BasicErrorController가 본문을 만든다.', false),
(11820, 4367, '경로의 {id} 문자열을 메서드 파라미터 타입인 Long으로 바꾸는 일도 이 조회 단계에서 끝낸다.', '핸들러 조회와 인자 조립을 한 단계로 본 오개념이다. 이 단계는 경로에서 {id} 자리의 문자열을 뽑아 둘 뿐이고, Long으로 바꾸는 일은 HandlerAdapter가 인자를 조립할 때 PathVariableMethodArgumentResolver가 맡는다.', false),
(11821, 4367, '두 컨트롤러가 똑같이 GET /api/orders/{id}를 선언하면 첫 요청이 오기 전 기동 과정에서 오류가 난다.', '맵은 기동 시 한 번 만들어지므로, 같은 조건 묶음을 두 메서드가 선언하면 어느 쪽을 값으로 둘지 정할 수 없다. 그래서 등록 단계에서 Ambiguous mapping 오류가 나 애플리케이션이 뜨지 않고, 문제가 요청 시점까지 미뤄지지 않는다.', true),
(11822, 4367, 'Accept 헤더가 produces와 달라도 URL과 HTTP 메서드만 맞으면 선택되고, 형식은 응답을 쓸 때 맞춘다.', 'produces를 응답 변환 옵션으로만 본 오개념이다. produces는 매칭 키의 일부라서 Accept: application/xml 요청은 produces=application/json인 메서드와 맞지 않아 선택되지 않고, 406 Not Acceptable 응답으로 끝난다.', false),

-- 문제 4368
(11823, 4368, 'GET /index.html은 static 폴더에 같은 이름의 파일이 있으므로 정적 리소스 핸들러가 그 파일을 내려준다.', '실제 파일이 있으면 정적 리소스가 우선한다고 본 오개념이다. 조회는 위에서부터 이뤄지므로 1)의 RequestMappingHandlerMapping이 GET /index.html에 먼저 매칭되어 HomeController#index()가 처리하고, 3)까지는 내려가지 않는다.', false),
(11824, 4368, 'GET /hello는 애노테이션 컨트롤러가 아니므로 SimpleControllerHandlerAdapter가 핸들러를 호출한다.', '2)가 찾은 핸들러는 HandlerMethod가 아니라 Controller 인터페이스 구현체다. DispatcherServlet이 등록된 어댑터마다 supports()를 물으면 이 형태를 지원하는 SimpleControllerHandlerAdapter만 true를 돌려주므로, 그 어댑터의 handle()로 호출된다.', true),
(11825, 4368, 'GET /logo.png는 매칭되는 컨트롤러 메서드가 없으므로 DispatcherServlet을 거치지 않고 톰캣이 파일을 직접 내려준다.', '정적 파일은 스프링 MVC 밖에서 처리된다고 본 오개념이다. 3)의 SimpleUrlHandlerMapping이 DispatcherServlet 안에서 /**로 매칭하고, ResourceHttpRequestHandler를 HttpRequestHandlerAdapter가 호출해 logo.png를 내려준다.', false),
(11826, 4368, 'GET /report.pdf는 어느 HandlerMapping과도 매칭되지 않아 HandlerAdapter를 고르는 단계까지 가지 않는다.', '파일이 없으면 매칭도 실패한다고 본 오개념이다. 3)의 /**는 모든 경로에 매칭되므로 핸들러 조회와 어댑터 선택은 정상 진행되고, 파일을 찾지 못한 ResourceHttpRequestHandler가 NoResourceFoundException을 던져 404가 된다.', false),

-- 문제 4369
(11827, 4369, 'GET /api/orders도 반환값이 같은 문자열이므로 ViewResolver가 orders/list 템플릿을 찾아 HTML로 응답한다.', '반환 타입만 보고 처리 경로를 판단한 오개념이다. @RestController는 @Controller에 @ResponseBody를 더한 것이라 반환값이 뷰 이름으로 해석되지 않고, HttpMessageConverter가 응답 본문에 곧바로 기록한다.', false),
(11828, 4369, '두 요청은 컨트롤러에 붙은 애노테이션이 달라 서로 다른 HandlerAdapter가 메서드를 호출한다.', '@RestController를 별도 처리 경로로 본 오개념이다. 두 메서드 모두 HandlerMethod라 RequestMappingHandlerMapping이 찾고 RequestMappingHandlerAdapter가 호출한다. 두 요청이 갈리는 곳은 반환값을 다루는 ReturnValueHandler뿐이다.', false),
(11829, 4369, 'GET /orders에 인터셉터를 걸어 postHandle에서 모델의 count를 5로 바꿔도 화면에는 3이 그대로 나온다.', '@ResponseBody 경로의 postHandle 제약을 뷰 경로에 옮겨 붙인 오개념이다. 뷰 이름을 반환하면 postHandle이 끝난 뒤에 ViewResolver가 찾은 View가 render()하므로, 이때 바꾼 count=5가 화면에 반영된다.', false),
(11830, 4369, 'GET /api/orders의 응답 본문에는 템플릿 HTML 대신 orders/list라는 글자가 그대로 담긴다.', '@RestController 메서드의 반환값은 ReturnValueHandler가 @ResponseBody 방식으로 처리해 StringHttpMessageConverter가 문자열을 본문에 그대로 쓴다. 같은 문자열이 @Controller에서는 뷰 이름으로 해석되어 템플릿이 렌더링되는 것과 대비된다.', true),

-- 문제 4370
(11831, 4370, 'postHandle 로그가 없는 것은 컨트롤러 호출이 예외로 끝나 후처리 단계를 건너뛰었기 때문이다.', 'postHandle은 HandlerAdapter를 통한 핸들러 호출이 정상적으로 끝났을 때만 실행된다. 예외가 나면 곧바로 HandlerExceptionResolver 체인으로 넘어가고, 인터셉터 쪽은 예외 발생 여부와 무관하게 실행되는 afterCompletion만 남는다.', true),
(11832, 4370, '응답 코드가 404이므로 HandlerMapping이 /api/orders/99를 처리할 핸들러를 찾지 못한 경우다.', '404를 곧 매핑 실패로 본 오개념이다. 로그에서 OrderController#find가 실행됐으니 핸들러는 찾았다. 이 404는 서비스가 던진 OrderNotFoundException을 GlobalExceptionHandler가 응답으로 바꾼 결과다.', false),
(11833, 4370, '컨트롤러 밖으로 나온 예외가 톰캣까지 올라가 BasicErrorController가 응답 본문을 만들었다.', '컨트롤러 예외는 곧장 서블릿 컨테이너로 간다고 본 오개념이다. DispatcherServlet 안의 HandlerExceptionResolver 체인이 @ExceptionHandler 메서드인 GlobalExceptionHandler#notFound를 찾아 응답을 만들었으므로, 예외는 톰캣까지 전파되지 않았다.', false),
(11834, 4370, '예외가 난 스레드는 곧바로 풀에 반납되고, 예외 처리는 다른 스레드가 이어받아 응답을 만들었다.', '예외 처리를 별도 스레드의 일로 본 오개념이다. 모든 줄이 같은 exec-4 스레드에서 찍혔듯이, 핸들러 조회부터 예외 처리와 afterCompletion까지 요청을 받은 톰캣 스레드 하나에서 동기적으로 이어진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1412, 4371, '프런트 컨트롤러 패턴,프런트 컨트롤러,프론트 컨트롤러 패턴,프론트 컨트롤러,프런트컨트롤러 패턴,프론트컨트롤러 패턴,프런트컨트롤러,프론트컨트롤러,front controller pattern,front controller,frontcontroller pattern,frontcontroller,front controller 패턴,front-controller', '모든 요청을 하나의 서블릿이 진입점으로 받아 인코딩·오류 처리 같은 공통 처리를 한곳에서 하고, 실제 기능은 요청을 보고 골라 부르는 구조가 프런트 컨트롤러 패턴이다. 32개였던 매핑이 url-pattern / 하나로 줄고, 공통 코드 중복이 사라지고, URL을 늘려도 web.xml을 고치지 않게 된 것이 이 패턴의 효과다. 스프링 MVC에서는 DispatcherServlet이 바로 이 진입점 서블릿 역할을 한다. 여러 하위 객체 앞에 단순한 호출 창구를 두는 퍼사드 패턴과 헷갈리기 쉬운데, 프런트 컨트롤러는 웹 요청의 진입점을 하나로 모은 뒤 요청마다 처리 대상을 골라 위임한다는 점이 핵심이다. 모델·뷰·컨트롤러의 역할 분리를 말하는 MVC 패턴 자체와도 구분해 두자.'),
       (1413, 4372, 'HandlerInterceptor,핸들러 인터셉터,핸들러인터셉터,인터셉터,interceptor,handler interceptor,스프링 인터셉터,스프링 MVC 인터셉터,AsyncHandlerInterceptor', 'DispatcherServlet이 HandlerMapping으로 핸들러를 찾은 뒤 그 호출 앞뒤와 완료 시점에 끼어드는 확장 지점이 HandlerInterceptor다. preHandle(request, response, handler)의 handler로 호출될 컨트롤러 메서드(HandlerMethod)와 거기 붙은 @AdminOnly를 읽을 수 있고, false를 반환하면 그 자리에서 처리가 끝나 컨트롤러가 실행되지 않는다. 등록은 WebMvcConfigurer.addInterceptors()로 한다. 1차의 Filter는 DispatcherServlet보다 앞선 서블릿 스펙 단계에서 실행되므로, 아직 어느 컨트롤러로 갈지 정해지지 않아 target을 알 수 없었다. 같은 WebMvcConfigurer에 등록하는 HandlerMethodArgumentResolver와도 구분하자. 리졸버는 컨트롤러 파라미터에 넣을 값을 만들어 돌려줄 뿐, 요청을 통과시킬지 막을지는 정하지 않는다.');

-- =====================================================
-- Lesson 856: 필터 예외 경계와 경로 패턴 매칭
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5315, 856, '아래 코드에서 기대한 401 대신 500 응답이 돌아온 원인으로 옳은 것은?', '만료된 토큰을 걸러 내려고 아래 필터와 예외 처리기를 만들었다. ExpiredTokenException은 RuntimeException을 상속한 클래스다.

```java
@Component
public class JwtAuthFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res,
                                    FilterChain chain) throws ServletException, IOException {
        if (tokenService.isExpired(req.getHeader("Authorization"))) {
            throw new ExpiredTokenException();
        }
        chain.doFilter(req, res);
    }
}

@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ExpiredTokenException.class)
    public ResponseEntity<ErrorBody> expired() {
        return ResponseEntity.status(401).body(new ErrorBody("TOKEN_EXPIRED"));
    }
}
```

만료된 토큰으로 GET /api/orders를 보내자 아래 응답이 돌아왔고, expired()에 걸어 둔 중단점에서는 한 번도 멈추지 않았다.

```
HTTP/1.1 500
{"timestamp":"2026-09-21T10:15:03.114+00:00","status":500,"error":"Internal Server Error","path":"/api/orders"}
```', 'OBJECTIVE'),
       (5316, 856, '아래 컨트롤러를 새 버전에서 실행했을 때의 결과로 옳은 것은?', '스프링 부트 2.5로 만든 파일 서비스를 스프링 부트 3.3으로 올렸다. 경로 매칭과 관련된 설정은 따로 넣지 않았다. 2.5에서는 GET /files/2026/09/report/download 같은 요청이 아래 메서드로 정상 처리됐다.

```java
@RestController
public class FileController {

    @GetMapping("/files/**/download")
    public ResponseEntity<Resource> download(HttpServletRequest request) {
        String path = extractPath(request);   // /files/ 와 /download 사이의 경로
        return ResponseEntity.ok(storage.load(path));
    }
}
```', 'OBJECTIVE'),
       (5317, 856, '아래 요청을 처리한 결과로 옳은 것은?', '```java
@PostMapping("/api/orders")
public ResponseEntity<OrderResponse> create(@RequestBody OrderCreateRequest request) {
    OrderResponse created = orderService.create(request);   // 주문 저장 후 커밋
    return ResponseEntity
            .created(URI.create("/api/orders/" + created.id()))
            .body(created);
}
```

```
POST /api/orders
Content-Type: application/json
Accept: application/xml

{"itemId": 10, "quantity": 2}
```

- 등록된 HttpMessageConverter 가운데 OrderCreateRequest와 OrderResponse를 다룰 수 있는 것은 JSON용(Jackson) 하나뿐이다.
- 예외 처리 설정은 스프링 부트 기본값 그대로다.', 'OBJECTIVE'),
       (5318, 856, '아래 코드에서 GET /api/me 요청 한 건을 처리하는 동안 콘솔에 찍히는 순서는?', 'TraceInterceptor와 LoginMemberResolver는 WebMvcConfigurer에 등록했고, LoginMemberResolver의 supportsParameter()는 @LoginMember가 붙은 파라미터에 true를 돌려준다.

```java
@Component
public class TraceFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        System.out.print("A ");
        chain.doFilter(req, res);
        System.out.print("F ");
    }
}

public class TraceInterceptor implements HandlerInterceptor {
    public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler) {
        System.out.print("B ");
        return true;
    }
    public void postHandle(HttpServletRequest req, HttpServletResponse res,
                           Object handler, ModelAndView mv) {
        System.out.print("E ");
    }
    public void afterCompletion(HttpServletRequest req, HttpServletResponse res,
                                Object handler, Exception ex) {
        System.out.print("G ");
    }
}

public class LoginMemberResolver implements HandlerMethodArgumentResolver {
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer,
                                  NativeWebRequest webRequest, WebDataBinderFactory binderFactory) {
        System.out.print("C ");
        return new Member(1L, "kim");
    }
    // supportsParameter() 생략
}

@RestController
public class MeController {
    @GetMapping("/api/me")
    public MemberResponse me(@LoginMember Member member) {
        System.out.print("D ");
        return MemberResponse.from(member);
    }
}
```', 'OBJECTIVE'),
       (5319, 856, '아래 상황에서 두 설정값이 전달되는 스프링 MVC 구성 요소의 이름은?', '사내 관리자 화면은 JSP로 만들어져 있다. 화면을 돌려주는 컨트롤러 30개는 모두 `return "orders/list";`처럼 폴더와 확장자가 빠진 짧은 문자열만 반환한다. JSP 파일을 새 폴더로 옮기면서 컨트롤러는 한 줄도 고치지 않고 application.properties만 아래처럼 바꿨다.

| 설정 | 변경 전 | 변경 후 |
| --- | --- | --- |
| spring.mvc.view.prefix | /WEB-INF/views/ | /WEB-INF/jsp/admin/ |
| spring.mvc.view.suffix | .jsp | .jsp |

- 변경 후 `orders/list`를 반환한 요청은 /WEB-INF/jsp/admin/orders/list.jsp로 화면이 그려졌다.
- 오타로 `orders/lsit`를 반환한 메서드는 컨트롤러 실행까지 정상으로 끝났고, 그 뒤 단계에서 화면 파일을 찾지 못했다는 오류가 났다.
- 같은 애플리케이션의 @RestController가 돌려주는 JSON 응답은 설정 변경 전후가 똑같았다.', 'SUBJECTIVE'),
       (5320, 856, '아래 코드의 ????에 들어갈 스프링 MVC 인터페이스의 이름은?', '레거시 프레임워크에서 옮겨 온 주문 처리 클래스 12개는 모두 자체 인터페이스 Command를 구현하고, 메서드는 `String execute(Map<String, String> params)` 하나뿐이다. 이 클래스들을 빈으로 등록하고 SimpleUrlHandlerMapping에 `/legacy/orders → orderCommand` 같은 URL 매핑을 추가한 뒤 요청을 보냈다.

```
DEBUG SimpleUrlHandlerMapping : Mapped to com.shop.legacy.OrderCommand@5d1a
ERROR [dispatcherServlet]     : Servlet.service() threw jakarta.servlet.ServletException
→ 응답 500, OrderCommand#execute는 호출되지 않음
```

Command 클래스 12개와 URL 매핑 설정은 그대로 둔 채 아래 클래스 하나를 빈으로 추가하자, 같은 요청이 200으로 처리됐다.

```java
@Component
public class LegacyCommandBridge implements ???? {

    @Override
    public boolean supports(Object handler) {
        return handler instanceof Command;
    }

    @Override
    public ModelAndView handle(HttpServletRequest request, HttpServletResponse response,
                               Object handler) throws Exception {
        Map<String, String> params = toSingleValueMap(request.getParameterMap());
        String viewName = ((Command) handler).execute(params);
        return new ModelAndView(viewName);
    }

    // 나머지 메서드 생략
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5315
(14347, 5315, '@RestControllerAdvice는 반환값을 응답 본문에 쓰는 용도라서, 예외를 받으려면 @ControllerAdvice로 바꿔야 한다.', '두 애노테이션의 쓰임을 나눠 본 오개념이다. @RestControllerAdvice는 @ControllerAdvice에 @ResponseBody를 더한 것일 뿐 예외를 받는 범위는 같다. 같은 예외가 컨트롤러에서 났다면 지금 코드로도 401이 나갔을 것이다.', false),
(14348, 5315, '필터는 톰캣이 요청 스레드와 다른 스레드에서 실행하므로, 거기서 난 예외는 예외 처리기로 전달되지 않는다.', '필터를 별도 스레드의 일로 본 오개념이다. 필터 체인부터 DispatcherServlet, 컨트롤러까지 요청을 받은 톰캣 스레드 하나에서 이어진다. 예외가 전달되지 않은 까닭은 스레드가 아니라 예외가 난 위치에 있다.', false),
(14349, 5315, '예외가 DispatcherServlet에 닿기 전 필터 체인에서 던져져, 스프링 MVC가 예외를 응답으로 바꾸는 단계를 거치지 않았다.', '@ExceptionHandler는 DispatcherServlet 안의 HandlerExceptionResolver 체인이 찾아 호출한다. 필터는 그보다 앞선 서블릿 스펙 단계라 예외가 곧장 톰캣으로 올라갔고, 스프링 부트의 /error 처리(BasicErrorController)가 500 본문을 만들었다.', true),
(14350, 5315, 'expired()가 예외 객체를 파라미터로 받지 않아서, 어떤 예외를 처리하는 메서드인지 매칭되지 않았다.', '파라미터가 있어야 매칭된다고 본 오개념이다. 처리할 예외 타입은 @ExceptionHandler에 적은 값으로 정해지므로 파라미터가 없어도 유효하다. 같은 예외가 컨트롤러에서 났다면 이 메서드가 호출됐을 것이다.', false),

-- 문제 5316
(14351, 5316, '기동 중 이 매핑을 등록하다가 패턴 해석 오류가 나서, 첫 요청을 받기 전에 애플리케이션이 멈춘다.', '스프링 부트 2.6부터 기본 경로 매칭 방식이 AntPathMatcher에서 PathPatternParser로 바뀌었고, 새 방식은 **를 패턴 끝에만 허용한다. 매핑 정보는 기동 시 한 번에 만들어지므로 중간에 **가 있는 패턴은 그때 해석 오류를 내 기동이 실패한다.', true),
(14352, 5316, '기동은 되지만 같은 요청이 이 메서드와 매칭되지 않아서, 요청 시점에 404 응답이 돌아간다.', '문제가 요청 시점에 드러난다고 본 오개념이다. 패턴은 요청이 올 때가 아니라 기동 때 매핑 정보를 만들며 해석되므로, 허용되지 않는 패턴은 404가 나기 전 기동 단계에서 오류가 된다.', false),
(14353, 5316, '기동은 되고 **가 경로 한 단계만 매칭하도록 뜻이 바뀌어, /files/a/download 같은 요청만 처리된다.', '**가 *처럼 좁아진다고 본 오개념이다. 새 방식은 **의 뜻을 바꾸지 않고 쓸 수 있는 위치를 패턴 끝으로 제한할 뿐이라, 중간에 둔 **를 다르게 해석해 주지 않고 오류로 거부한다.', false),
(14354, 5316, '경로 변수가 없는 패턴이라 매칭 방식이 바뀌어도 영향이 없어, 이전과 똑같이 처리된다.', '매칭 방식 변경이 {id} 같은 경로 변수에만 영향을 준다고 본 오개념이다. 와일드카드 **의 허용 위치도 달라졌으므로, 이전 동작을 유지하려면 spring.mvc.pathmatch.matching-strategy=ant-path-matcher를 따로 설정해야 한다.', false),

-- 문제 5317
(14355, 5317, 'Accept와 맞는 형식이 없으므로 핸들러를 찾는 단계에서 406으로 거절되고, 컨트롤러는 실행되지 않는다.', 'Accept가 늘 매핑 조건이 된다고 본 오개념이다. 매핑에 produces를 적지 않았으므로 Accept와 상관없이 이 메서드가 선택된다. produces=application/json을 적었다면 그때는 핸들러를 찾는 단계에서 406이 났을 것이다.', false),
(14356, 5317, 'XML로 쓸 수 있는 HttpMessageConverter가 없으면 JSON으로 대신 써서, 201과 JSON 본문이 돌아간다.', '형식이 안 맞으면 알아서 대체된다고 본 오개념이다. 응답 형식은 Accept와 HttpMessageConverter가 쓸 수 있는 형식이 겹치는 것 가운데서 고르는데, 여기서는 겹치는 것이 없어 406 예외가 난다. Accept에 */*가 있었다면 JSON이 골라졌을 것이다.', false),
(14357, 5317, '요청 본문을 읽을 HttpMessageConverter도 Accept를 보고 고르므로, 본문을 객체로 바꾸는 단계에서 415로 끝난다.', 'Accept와 Content-Type의 역할을 뒤바꾼 오개념이다. 요청 본문을 읽을 HttpMessageConverter는 Content-Type(application/json)으로 고르므로 역직렬화는 성공한다. 415는 Content-Type에 맞는 HttpMessageConverter가 없을 때 난다.', false),
(14358, 5317, '컨트롤러 메서드는 끝까지 실행되고, 반환값을 응답 본문으로 쓰는 단계에서 형식이 맞지 않아 406이 된다.', 'Content-Type이 JSON이라 본문은 정상으로 읽혀 컨트롤러가 끝까지 실행된다. 그 뒤 ReturnValueHandler가 Accept(application/xml)에 맞춰 OrderResponse를 쓸 HttpMessageConverter를 찾지 못해 406이 된다. 이미 커밋된 주문은 그대로 남는다.', true),

-- 문제 5318
(14359, 5318, 'B A C D E G F', '인터셉터가 필터보다 먼저 실행된다고 본 오개념이다. 필터는 서블릿 스펙 단계라 DispatcherServlet보다 앞에서 실행되고, 인터셉터는 DispatcherServlet이 핸들러를 찾은 뒤에야 호출되므로 A가 B보다 먼저 찍힌다.', false),
(14360, 5318, 'A B C D E G F', '필터가 A를 찍고 chain.doFilter()로 넘기면 DispatcherServlet이 preHandle(B)을 부르고, HandlerAdapter가 LoginMemberResolver로 인자를 만든 뒤(C) 메서드를 실행한다(D). postHandle(E)과 afterCompletion(G)까지 끝나야 chain.doFilter()가 반환돼 F가 찍힌다.', true),
(14361, 5318, 'A C B D E G F', '인자 조립을 핸들러 조회 직후의 일로 본 오개념이다. LoginMemberResolver는 preHandle이 true를 돌려준 뒤 HandlerAdapter가 메서드를 호출하려 할 때 실행되므로 C는 B 다음이다. preHandle이 false였다면 C는 아예 찍히지 않는다.', false),
(14362, 5318, 'A B C D E F G', 'afterCompletion을 필터까지 끝난 뒤의 마지막 단계로 본 오개념이다. afterCompletion은 DispatcherServlet이 요청 처리를 마무리하며 호출하므로, chain.doFilter()가 반환된 다음에 찍히는 F보다 먼저다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1728, 5319, 'ViewResolver,뷰 리졸버,뷰리졸버,view resolver,뷰 해석기,InternalResourceViewResolver,인터널 리소스 뷰 리졸버', '컨트롤러가 반환한 뷰 이름(orders/list)을 실제로 그릴 View로 바꿔 주는 구성 요소가 ViewResolver다. 스프링 부트는 spring.mvc.view.prefix·suffix 값을 기본 구현체인 InternalResourceViewResolver에 넘기고, 이 구현체가 prefix + 뷰 이름 + suffix로 JSP 경로를 만든다. 그래서 파일 위치가 바뀌어도 컨트롤러 30개는 그대로 두고 설정만 고치면 된다. 오타 난 뷰 이름이 컨트롤러 실행 뒤에야 드러난 것도, 뷰 이름을 해석하고 화면을 그리는 일이 컨트롤러가 끝난 다음 단계이기 때문이다. @RestController 경로는 반환값을 HttpMessageConverter가 곧바로 응답 본문에 쓰므로 ViewResolver를 거치지 않고, 그래서 JSON 응답은 설정과 무관했다. 뷰 이름을 받아 화면을 찾는 ViewResolver와 객체를 JSON 같은 본문으로 바꾸는 HttpMessageConverter를 구분해 두자.'),
       (1729, 5320, 'HandlerAdapter,핸들러 어댑터,핸들러어댑터,handler adapter,핸들러 아답터', 'DispatcherServlet은 HandlerMapping이 찾아 준 핸들러를 직접 호출하지 않는다. 등록된 HandlerAdapter마다 supports(handler)를 물어 true를 돌려준 어댑터의 handle()에 호출을 맡긴다. 기본 어댑터인 RequestMappingHandlerAdapter·HttpRequestHandlerAdapter·SimpleControllerHandlerAdapter는 모두 Command를 지원하지 않으므로, 로그처럼 핸들러를 찾고도(Mapped to) 호출할 어댑터가 없어 ServletException이 났다. LegacyCommandBridge는 Command 타입에만 true를 돌려주고, handle()에서 요청 파라미터를 Map으로 모아 execute()를 부른 뒤 결과를 ModelAndView로 감싸 돌려주는 HandlerAdapter 구현체다. 덕분에 Command 클래스나 DispatcherServlet 코드를 고치지 않고 새 핸들러 형태를 붙일 수 있다(어댑터 패턴). 누가 처리할지 찾는 HandlerMapping과 헷갈리기 쉬운데, 이번 경우는 찾기는 이미 끝났고 어떻게 호출할지가 비어 있던 것이다. 이름이 비슷한 HandlerMethodArgumentResolver의 supportsParameter()도 구분하자. 이것은 애노테이션 컨트롤러 메서드의 파라미터 하나를 맡을지만 판단할 뿐, 핸들러 자체를 호출하지는 않는다.');
