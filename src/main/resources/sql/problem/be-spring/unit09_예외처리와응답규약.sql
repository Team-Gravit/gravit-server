-- Unit: 예외 처리와 응답 규약 (Unit ID: 120)
-- Chapter: Spring (Chapter ID: 10)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (546, 120, '에러 코드 열거형과 RFC 7807'),
       (704, 120, 'Advice 선택 규칙과 예외 전환'),
       (862, 120, '체크 예외 롤백과 상태 코드 선택');

-- =====================================================
-- Lesson 546: 에러 코드 열거형과 RFC 7807
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3455, 546, '아래 코드가 배포된 서버에 GET /orders/1을 요청했을 때 클라이언트가 받는 HTTP 상태 코드는?', '```java
@RestController
@RequestMapping("/orders")
public class OrderController {

    @GetMapping("/{id}")
    public OrderResponse find(@PathVariable Long id) {
        throw new OrderNotFoundException(id);   // OrderNotFoundException extends BusinessException
    }

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handle(BusinessException e) {
        return ResponseEntity.status(409).body(ErrorResponse.of(e));
    }
}

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(OrderNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(OrderNotFoundException e) {
        return ResponseEntity.status(404).body(ErrorResponse.of(e));
    }

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusiness(BusinessException e) {
        return ResponseEntity.status(400).body(ErrorResponse.of(e));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleUnknown(Exception e) {
        return ResponseEntity.status(500).body(ErrorResponse.of(e));
    }
}
```', 'OBJECTIVE'),
       (3456, 546, '아래 세 요청에 대해 스프링 부트 기본 예외 처리가 내보내는 HTTP 상태 코드를 위에서부터 순서대로 나열한 것은?', '| 요청 | 상황 |
|---|---|
| GET /orders | 컨트롤러가 필수 @RequestParam memberId를 요구하는데 파라미터 없이 호출됨 |
| GET /admin/orders | 로그인은 마친 사용자지만 @PreAuthorize에 적힌 권한 조건을 만족하지 못함 |
| DELETE /orders/1 | /orders/{id} 경로에는 GET·POST 매핑만 선언되어 있음 |

세 요청 모두 컨트롤러 메서드 본문에는 진입하지 못했고, 애플리케이션에 별도 @ExceptionHandler는 없다.', 'OBJECTIVE'),
       (3457, 546, '아래 예외 설계 방식에 대한 설명으로 옳은 것은?', '커스텀 예외 클래스를 실패 종류마다 늘리는 대신, 서비스 계층이 던지는 예외를 RuntimeException을 상속한 공통 부모 예외 하나로 두었다. HTTP 상태 코드·사용자 메시지·애플리케이션 에러 코드는 열거형 상수에 모아 두고, 예외를 만들 때 그 상수를 생성자로 넘긴다.', 'OBJECTIVE'),
       (3458, 546, '아래 응답을 내보내는 API의 문제점을 지적한 설명으로 옳지 않은 것은?', '주문 API에서 재고가 모자라 주문이 실패했을 때 실제로 나가는 응답이다.

```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "success": false,
  "message": "java.lang.IllegalStateException: stock 0 < 2 at com.app.order.OrderService.decrease(OrderService.java:88)"
}
```', 'OBJECTIVE'),
       (3459, 546, '아래 에러 응답 본문이 따르고 있는 표준 규격의 이름은?', '외부에 공개한 주문 API가 재고 부족으로 실패했을 때 내보내는 응답 본문이다.

```json
{
  "type": "https://api.shop.com/errors/insufficient-stock",
  "title": "Insufficient Stock",
  "status": 409,
  "detail": "주문 수량 2개, 남은 재고 0개",
  "instance": "/orders/1024",
  "code": "O002"
}
```

여기서 code는 팀이 확장 필드로 덧붙인 값이고, 나머지 다섯 필드는 규격이 정해 둔 이름을 그대로 쓴 것이다.', 'SUBJECTIVE'),
       (3460, 546, '아래 상황에서 토큰 검사 코드가 놓여 있던 서블릿 구성 요소는?', '만료된 JWT로 GET /orders를 호출하자, 전역 예외 핸들러가 만드는 표준 JSON 대신 아래 응답이 나갔다. 핸들러 안에 넣어 둔 log.error도 찍히지 않았다.

```json
{"timestamp":"2026-09-08T10:12:03.512+00:00","status":500,"error":"Internal Server Error","path":"/orders"}
```

같은 검사 코드를 한 줄도 고치지 않고 인터셉터의 preHandle로 옮기자, 이번에는 전역 핸들러가 예외를 받아 표준 JSON과 로그가 정상으로 나왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3455
(9387, 3455, '404', '예외 클래스 계층에서 가까운 타입이 언제나 이긴다고 본 오해. 타입 비교는 후보를 모은 다음 이야기이고, 후보는 예외가 난 컨트롤러 안에서 먼저 찾는다. 컨트롤러 안에 매칭되는 핸들러가 있으면 Advice의 더 구체적인 핸들러는 후보에 오르지도 않는다.', false),
(9388, 3455, '400', '같은 예외 타입이면 전역 Advice가 최종 결정권을 갖는다고 본 오해. 우선순위는 반대로, 컨트롤러 내부 @ExceptionHandler가 먼저다. Advice의 BusinessException 핸들러는 다른 컨트롤러에서 같은 예외가 났을 때 쓰인다.', false),
(9389, 3455, '409', 'ExceptionHandlerExceptionResolver는 예외가 발생한 컨트롤러의 @ExceptionHandler를 먼저 뒤지고, 없을 때만 @ControllerAdvice로 넘어간다. OrderNotFoundException은 BusinessException의 하위 타입이라 컨트롤러의 handle이 매칭돼 409가 나간다.', true),
(9390, 3455, '500', 'Exception.class 핸들러를 최후 방어선이 아니라 기본 경로로 오해한 것. 이 핸들러는 더 가까운 타입의 핸들러가 하나도 없을 때만 선택된다. 여기서는 BusinessException 핸들러가 매칭되므로 차례가 오지 않는다.', false),

-- 문제 3456
(9391, 3456, '400 → 403 → 405', '필수 파라미터 누락은 MissingServletRequestParameterException으로 400, 인증을 마친 사용자의 권한 부족은 AccessDeniedException으로 403, 매핑되지 않은 메서드는 HttpRequestMethodNotSupportedException으로 405가 된다.', true),
(9392, 3456, '400 → 401 → 405', '인증(누구인지 모름)과 인가(누구인지는 알지만 권한 없음)를 혼동한 것. 401은 신원 확인 자체가 안 됐을 때다. 로그인을 마친 사용자가 권한 조건에 걸린 상황이므로 403이 맞다.', false),
(9393, 3456, '400 → 403 → 404', '요청을 처리할 핸들러가 없으니 경로가 없는 것과 같다고 본 오해. /orders/1 경로 자체는 매핑돼 있고 DELETE 메서드만 지원되지 않으므로 405다. 404는 매핑된 경로가 아예 없을 때 쓴다.', false),
(9394, 3456, '500 → 403 → 405', '컨트롤러 진입 전에 터진 예외를 서버 잘못으로 본 오해. 요청 형식이 규약과 맞지 않아 생긴 실패이므로 DefaultHandlerExceptionResolver가 4xx로 변환한다. 500은 서버 내부 결함일 때다.', false),

-- 문제 3457
(9395, 3457, '서비스 메서드마다 throws 선언이 필요해 호출 계층의 시그니처가 예외 타입에 묶인다.', 'RuntimeException 계열은 언체크 예외라 throws 선언이 강제되지 않는다. 시그니처가 throws로 오염되는 것은 Exception을 직접 상속한 체크 예외 쪽 이야기이고, 이를 피하려고 런타임 기반으로 설계한 것이다.', false),
(9396, 3457, '상태 코드가 같은 두 실패를 클라이언트가 구분하려면 예외 클래스를 따로 만들어야 한다.', '열거형에 상태 코드와 별개로 애플리케이션 에러 코드를 두었으므로, 주문 없음과 회원 없음이 똑같이 404여도 코드 값으로 갈린다. 클래스를 늘리지 않고 구분하려고 이 조합을 쓴다.', false),
(9397, 3457, '예외 클래스에 @ResponseStatus를 붙여야 상태 코드가 정해지므로 열거형의 상태 코드 값은 응답에 반영되지 않는다.', '핸들러가 열거형에서 상태 코드를 꺼내 ResponseEntity.status에 넘기면 그대로 응답에 실린다. 오히려 @ResponseStatus는 응답 본문 형식을 제어할 수 없어 표준 에러 응답 구조와 어울리지 않는다.', false),
(9398, 3457, '@Transactional이 걸린 서비스에서 이 예외가 빠져나가면 rollbackFor를 지정하지 않아도 롤백된다.', '스프링의 기본 롤백 규칙 대상은 언체크 예외(RuntimeException·Error)다. 공통 부모를 RuntimeException 기반으로 두면 별도 설정 없이 롤백이 걸린다. 체크 예외였다면 기본 동작은 커밋이라 rollbackFor가 필요했을 것이다.', true),

-- 문제 3458
(9399, 3458, 'message에 예외 클래스명과 소스 파일·줄 번호가 실려 내부 구현이 그대로 드러난다.', '옳은 지적이다. 예외 원인은 서버 로그로만 남기고 응답에는 일반화된 메시지를 담아야 한다. 내부 클래스 경로와 줄 번호는 공격자에게 프레임워크·구조 정보를 알려 주는 단서가 된다.', false),
(9400, 3458, '예외 메시지를 응답에 그대로 담으면 클라이언트가 원인을 정확히 알 수 있어 별도 에러 코드가 필요 없다.', '거짓이다. 예외 메시지는 리팩터링 한 번에 바뀌는 문자열이라 클라이언트가 파싱할 계약이 못 되고, 내부 정보까지 노출한다. 분기가 필요하면 사람이 읽는 message와 별개로 고정된 에러 코드를 둬야 한다.', true),
(9401, 3458, '재고 부족은 현재 리소스 상태와 요청이 충돌한 경우이므로 200이 아니라 409 같은 4xx로 알리는 편이 의미에 맞다.', '옳은 지적이다. 상태 코드는 결과의 의미를 담는 자리다. 요청 자체가 처리되지 못했는데 200을 주면 프로토콜 수준에서 성공과 실패가 구분되지 않는다.', false),
(9402, 3458, '상태 코드가 200이라 4xx·5xx 비율을 보는 모니터링과 프록시 캐시가 이 실패를 정상 응답으로 취급한다.', '옳은 지적이다. 상태 코드는 클라이언트뿐 아니라 캐시·게이트웨이·알림 규칙이 함께 읽는 값이라, 200으로 내보낸 실패는 지표에도 잡히지 않고 캐시될 수도 있다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1108, 3459, 'RFC 7807,RFC7807,rfc 7807,RFC 9457,RFC9457,Problem Details,Problem Details for HTTP APIs,프로블럼 디테일스,프로블럼 디테일,ProblemDetail,problem+json,application/problem+json', 'type·title·status·detail·instance 다섯 필드는 RFC 7807(Problem Details for HTTP APIs)이 정해 둔 표준 필드다. 이 규격을 따르는 응답은 application/json이 아니라 application/problem+json 타입으로 나가고, 스프링 6부터는 ProblemDetail 클래스로 만들면서 setProperty로 code 같은 확장 필드를 덧붙일 수 있다. 팀이 직접 정의한 ErrorResponse(code·message·timestamp·errors)와 갈리는 지점은 필드 이름을 팀이 정하느냐 규격이 정하느냐다. 사내 규약과 기존 클라이언트가 이미 있으면 자체 표준이 유리하고, 외부에 공개하는 신규 API라면 파싱 규칙을 따로 문서화하지 않아도 되는 이 규격이 낫다. 2023년 RFC 9457이 7807을 대체했지만 스프링 문서와 실무에서는 아직 7807로 부르는 경우가 많다.'),
       (1109, 3460, '필터,Filter,filter,서블릿 필터,Servlet Filter,servlet filter,필터 체인,Filter Chain', '응답에 찍힌 timestamp·status·error·path 네 필드는 스프링 부트가 /error 재요청을 받아 BasicErrorController로 만들어 낸 기본 형식이다. 즉 예외가 DispatcherServlet 안에서 처리되지 못하고 서블릿 컨테이너까지 올라갔다는 뜻이다. 필터는 DispatcherServlet 앞단에서 도는 서블릿 스펙 구성 요소라, 거기서 던진 예외는 HandlerExceptionResolver 체인을 아예 타지 않고 따라서 @ControllerAdvice의 @ExceptionHandler도 호출되지 않는다. 반면 인터셉터는 DispatcherServlet 안쪽에서 동작하므로 preHandle에서 던진 예외는 리졸버 체인이 받아 전역 핸들러까지 도달한다. 코드를 옮겼을 뿐인데 응답이 달라진 이유가 이 경계다. 검사 로직을 필터에 그대로 두어야 한다면 HandlerExceptionResolver에 직접 위임하거나 필터 안에서 표준 형식의 응답 본문을 직접 써 주어야 한다.');

-- =====================================================
-- Lesson 704: Advice 선택 규칙과 예외 전환
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4403, 704, '아래 세 Advice가 등록된 애플리케이션에 GET /orders/7을 요청했을 때 응답 상태 코드는?', '```java
// com.app.api.order 패키지
@RestController
public class OrderController {
    @GetMapping("/orders/{id}")
    public OrderResponse find(@PathVariable Long id) {
        throw new OrderNotFoundException(id);   // OrderNotFoundException extends BusinessException extends RuntimeException
    }
}

@Order(1)
@RestControllerAdvice(basePackages = "com.app.admin")
public class AdminExceptionHandler {
    @ExceptionHandler(OrderNotFoundException.class)
    public ResponseEntity<ErrorResponse> handle(OrderNotFoundException e) {
        return ResponseEntity.status(403).body(ErrorResponse.of(e.getErrorCode()));
    }
}

@Order(2)
@RestControllerAdvice
public class CommonExceptionHandler {
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleUnknown(Exception e) {
        return ResponseEntity.status(500).body(ErrorResponse.of(ErrorCode.INTERNAL_ERROR));
    }

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusiness(BusinessException e) {
        return ResponseEntity.status(409).body(ErrorResponse.of(e.getErrorCode()));
    }
}

@Order(3)
@RestControllerAdvice
public class OrderExceptionHandler {
    @ExceptionHandler(OrderNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(OrderNotFoundException e) {
        return ResponseEntity.status(404).body(ErrorResponse.of(e.getErrorCode()));
    }
}
```', 'OBJECTIVE'),
       (4404, 704, '아래 상황에서 404가 나가지 않은 이유로 옳은 것은?', '주문이 없을 때 404가 나가도록 OrderNotFoundException 클래스 위에 `@ResponseStatus(HttpStatus.NOT_FOUND)`를 붙였다. 이 예외는 RuntimeException을 바로 상속하며, 애플리케이션의 Advice에는 아래 핸들러 하나만 있다.

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleUnknown(Exception e) {
        log.error("Unhandled exception", e);
        return ResponseEntity.internalServerError()
                .body(ErrorResponse.of(ErrorCode.INTERNAL_ERROR));
    }
}
```

없는 주문을 조회하자 실제로 나간 응답은 아래와 같다.

```
HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{"code":"S001","message":"일시적인 오류가 발생했습니다","timestamp":"2026-09-13T09:12:44","errors":[]}
```', 'OBJECTIVE'),
       (4405, 704, '아래 예외 처리 방식에 대한 설명으로 옳은 것은?', '주문 서비스는 리포지토리에서 올라오는 DataAccessException과, 결제사 API를 RestTemplate으로 호출하다 올라오는 HttpClientErrorException을 서비스 메서드 경계에서 잡는다. 잡은 예외는 원래 예외를 cause로 넘기면서 ErrorCode를 담은 BusinessException으로 감싸 다시 던진다.', 'OBJECTIVE'),
       (4406, 704, '아래 코드에서 존재하지 않는 주문 id로 조회했을 때 벌어지는 일로 옳은 것은?', '```java
@Service
public class OrderService {
    public Order find(Long id) {
        try {
            return orderRepository.findById(id)
                    .orElseThrow(() -> new OrderNotFoundException(id));   // ErrorCode.ORDER_NOT_FOUND (404, O001)
        } catch (OrderNotFoundException e) {
            return null;
        }
    }
}

@RestController
public class OrderController {
    @GetMapping("/orders/{id}")
    public OrderResponse find(@PathVariable Long id) {
        Order order = orderService.find(id);
        return new OrderResponse(order.getId(), order.getStatus());
    }
}

@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(BusinessException.class)   // ErrorCode에 담긴 상태 코드·코드로 응답
    public ResponseEntity<ErrorResponse> handleBusiness(BusinessException e) { ... }

    @ExceptionHandler(Exception.class)           // 500, S001로 응답
    public ResponseEntity<ErrorResponse> handleUnknown(Exception e) { ... }
}
```', 'OBJECTIVE'),
       (4407, 704, '아래 상황에서 GlobalExceptionHandler가 새로 상속한 스프링 제공 클래스의 이름은?', '팀원이 전역 Advice 선언부에 상속 한 줄(`extends ???`)만 추가하자 서버 기동이 아래 오류로 실패했다.

```java
@RestControllerAdvice
public class GlobalExceptionHandler extends ??? {

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ErrorResponse> handleMethodNotAllowed(HttpRequestMethodNotSupportedException e) { ... }

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusiness(BusinessException e) { ... }
}
```

```
Caused by: java.lang.IllegalStateException: Ambiguous @ExceptionHandler method mapped for
  [class org.springframework.web.HttpRequestMethodNotSupportedException]:
  {public final ResponseEntity ???.handleException(Exception, WebRequest),
   public ResponseEntity GlobalExceptionHandler.handleMethodNotAllowed(HttpRequestMethodNotSupportedException)}
```

상속은 그대로 두고 handleMethodNotAllowed 메서드만 지우자 기동에 성공했다. 이후 DELETE를 지원하지 않는 경로에 DELETE를 보내자, 직접 작성한 핸들러가 하나도 없는데도 405 응답이 type·title·status·detail·instance 필드를 갖춘 본문으로 나갔다.', 'SUBJECTIVE'),
       (4408, 704, '아래 상황에서 요청 처리 중 실제로 던져진 예외 클래스의 이름은?', '회원가입 API에서 입력이 잘못되면 필드별 오류 목록을 내려주려고 전역 Advice에 핸들러를 추가했다. Advice에는 이 핸들러 하나만 있고, 스프링 부트 에러 설정은 기본값이다.

```java
@PostMapping("/members")
public MemberResponse signUp(@Valid @RequestBody SignUpRequest request) { ... }   // SignUpRequest.email에 @Email

@ExceptionHandler(ConstraintViolationException.class)
public ResponseEntity<ErrorResponse> handleValidation(ConstraintViolationException e) {
    log.warn("validation failed");
    ...
}
```

email에 "abc"를 넣어 요청하자 상태 코드는 400이었지만 본문은 아래와 같았고, log.warn도 찍히지 않았다.

```json
{"timestamp":"2026-09-13T09:41:27.108+00:00","status":400,"error":"Bad Request","path":"/members"}
```

@ExceptionHandler 괄호 속 클래스와 파라미터 타입을 실제로 던져진 예외로 바꾸자 핸들러가 호출되어 errors 배열에 email 필드 오류가 담겼다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4403
(11915, 4403, '403', '@Order 값이 가장 작은 Advice가 무조건 먼저 처리한다고 본 오해. AdminExceptionHandler는 basePackages가 com.app.admin이라 com.app.api.order 패키지의 컨트롤러에는 적용 대상이 아니므로 후보에서 빠진다.', false),
(11916, 4403, '404', 'Advice 전체를 통틀어 가장 구체적인 타입이 이긴다고 본 오해. 타입 비교는 한 Advice 안의 메서드끼리 하고, Advice끼리는 @Order 순서가 먼저다. 앞 순서인 CommonExceptionHandler에서 이미 매칭되므로 3번째 Advice까지 가지 않는다.', false),
(11917, 4403, '409', '적용 범위 밖인 AdminExceptionHandler를 건너뛰면 다음 순서는 CommonExceptionHandler다. 이 안에서는 Exception과 BusinessException 핸들러가 모두 매칭되지만, 예외 클래스 계층에서 더 가까운 BusinessException 핸들러가 선택된다.', true),
(11918, 4403, '500', '한 클래스 안에서 먼저 선언된 메서드가 선택된다고 본 오해. 선언 순서는 영향이 없고, 예외 클래스 계층에서 거리가 가까운 타입의 핸들러가 선택된다. Exception 핸들러는 더 가까운 핸들러가 없을 때만 쓰인다.', false),

-- 문제 4404
(11919, 4404, '@ExceptionHandler 메서드를 찾는 리졸버가 @ResponseStatus를 읽는 리졸버보다 먼저 시도되어 Exception 핸들러가 예외를 가져갔다.', 'HandlerExceptionResolver 체인은 ExceptionHandlerExceptionResolver가 첫 번째다. Exception 핸들러가 매칭되어 처리를 끝냈으므로, 클래스의 @ResponseStatus를 읽는 두 번째 리졸버까지 차례가 오지 않았다.', true),
(11920, 4404, 'Advice가 하나라도 등록되어 있으면 예외 클래스에 붙인 @ResponseStatus는 어떤 경우에도 무시된다.', '지나친 일반화. Advice가 있어도 그 예외와 매칭되는 @ExceptionHandler가 없으면 첫 리졸버가 처리에 실패하고, 다음 리졸버가 @ResponseStatus를 읽어 404를 낸다. 여기서는 Exception 핸들러가 매칭된 것이 원인이다.', false),
(11921, 4404, '@ResponseStatus는 체크 예외에만 적용되므로 RuntimeException을 상속한 예외에서는 무시된다.', '롤백 규칙(체크 예외는 기본 커밋)과 섞어 생긴 오해. @ResponseStatus는 체크·언체크를 가리지 않고 예외 클래스에 붙이면 읽힌다. 404가 안 나간 것은 앞선 리졸버가 먼저 처리했기 때문이다.', false),
(11922, 4404, '서블릿 컨테이너의 기본 에러 페이지 설정이 @ResponseStatus 값보다 우선해 500으로 덮어썼다.', '응답 본문이 팀의 ErrorResponse(code S001) 형식이라는 점이 반증이다. 컨테이너까지 올라가 /error로 처리됐다면 스프링 부트 기본 형식이 나갔을 것이다. 예외는 DispatcherServlet 안의 Advice에서 처리됐다.', false),

-- 문제 4405
(11923, 4405, '원래 예외를 cause로 넘기면 전역 Advice가 만드는 응답 본문에도 SQL·결제사 오류 메시지가 함께 실린다.', 'cause는 예외 객체끼리의 연결일 뿐 응답 본문과는 무관하다. 응답은 ErrorCode의 코드·메시지로 만들고, cause는 log.error로 스택 트레이스를 남길 때 실제 원인을 추적하는 용도로 쓰인다.', false),
(11924, 4405, '결제사가 돌려준 400 상태 코드를 우리 API 응답에도 그대로 전달하는 것이 이 방식의 목적이다.', '외부 API의 400은 우리 클라이언트 입장에서 의미가 다르다. 클라이언트 요청은 정상인데 결제사가 거절했을 수 있다. 감싸는 목적은 인프라 세부를 숨기고 우리 ErrorCode로 실패의 의미를 다시 정하는 것이다.', false),
(11925, 4405, '전역 Advice가 404와 409를 구분하려면 DataAccessException 전용 @ExceptionHandler를 따로 두어야 한다.', '서비스 경계에서 이미 ErrorCode를 담은 BusinessException으로 바뀌어 올라오므로, Advice는 ErrorCode의 상태 값만 읽으면 된다. 인프라 예외마다 핸들러를 늘리는 구조가 바로 이 방식이 피하려는 것이다.', false),
(11926, 4405, '결제 연동을 다른 HTTP 클라이언트로 바꿔 던지는 예외 타입이 달라져도 컨트롤러와 전역 Advice는 고칠 필요가 없다.', '상위 계층이 받는 것은 항상 BusinessException이라 아래에서 어떤 기술의 예외가 났는지 몰라도 된다. 클라이언트 교체로 예외 타입이 바뀌면 서비스 경계의 변환 코드만 손보면 된다.', true),

-- 문제 4406
(11927, 4406, '서비스가 예외를 잡아 처리했으므로 전역 Advice는 호출되지 않고 200 상태 코드와 빈 본문이 나간다.', '서비스는 예외를 삼켰을 뿐 문제를 해결하지 않았다. null을 받은 컨트롤러가 order.getId()에서 NullPointerException을 던지므로 예외는 다시 발생해 Advice까지 올라간다.', false),
(11928, 4406, '클라이언트는 O001·404가 아니라 S001·500을 받고, 로그에는 주문 없음 대신 NullPointerException이 남는다.', 'null을 받은 컨트롤러에서 NullPointerException이 난다. 이 예외는 BusinessException 계열이 아니라 Exception 핸들러가 받아 500을 낸다. 주문이 없다는 진짜 원인은 catch에서 사라져 로그로도 추적하기 어렵다.', true),
(11929, 4406, '전역 Advice가 catch에서 삼킨 OrderNotFoundException까지 추적해 원래 의도대로 404로 응답한다.', 'Advice는 컨트롤러 메서드 밖으로 던져진 예외만 넘겨받는다. catch 블록 안에서 끝난 예외는 HandlerExceptionResolver 체인에 전달되지 않으므로 Advice가 그 존재를 알 방법이 없다.', false),
(11930, 4406, 'NullPointerException도 RuntimeException이므로 BusinessException 핸들러가 받아 ErrorCode에 맞춰 응답한다.', '상속 방향을 거꾸로 본 오해. BusinessException이 RuntimeException의 하위 타입이지, NullPointerException이 BusinessException의 하위 타입은 아니다. 이 예외와 매칭되는 핸들러는 Exception 핸들러뿐이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1424, 4407, 'ResponseEntityExceptionHandler,org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler,Response Entity Exception Handler,리스폰스엔티티익셉션핸들러,리스폰스 엔티티 익셉션 핸들러', 'ResponseEntityExceptionHandler를 상속하면 부모의 handleException 메서드도 함께 등록되는데, 이 메서드의 @ExceptionHandler에는 HttpRequestMethodNotSupportedException을 비롯한 스프링 MVC 내부 예외들이 이미 매핑되어 있다. 자식 클래스가 같은 예외를 @ExceptionHandler로 다시 선언하면 한 Advice 안에 같은 타입의 핸들러가 둘이 되어 기동 시 Ambiguous 오류가 난다. 그래서 이 클래스를 상속했다면 새 핸들러를 추가하지 말고 handleHttpRequestMethodNotSupported 같은 protected 메서드를 오버라이드해 응답만 바꾼다. 핸들러를 지운 뒤 405가 ProblemDetail 형식(type·title·status·detail·instance)으로 나간 것도 부모의 기본 구현이 동작한 결과다. 체인의 세 번째 리졸버인 DefaultHandlerExceptionResolver도 같은 내부 예외를 405 같은 상태 코드로 바꿔 주지만, 상태 코드만 정할 뿐 응답 본문을 만들지 않고 Advice 안에서 동작하는 것도 아니라는 점에서 구분된다.'),
       (1425, 4408, 'MethodArgumentNotValidException,org.springframework.web.bind.MethodArgumentNotValidException,메서드 아규먼트 낫 밸리드 익셉션,메서드아규먼트낫밸리드익셉션', '@RequestBody에 @Valid를 붙인 파라미터의 검증이 실패하면 스프링 MVC는 MethodArgumentNotValidException을 던진다. Advice에는 이 타입과 매칭되는 핸들러가 없었으므로 체인의 세 번째인 DefaultHandlerExceptionResolver가 400으로 바꾸었고, 본문은 /error를 거친 스프링 부트 기본 형식(timestamp·status·error·path)이 되어 어느 필드가 틀렸는지 알 수 없었다. 핸들러를 이 타입으로 지정하면 e.getBindingResult()에서 필드별 거절 값과 메시지를 꺼내 errors 배열에 담을 수 있다. 괄호에 넣었던 ConstraintViolationException은 서비스 등 클래스에 @Validated를 붙여 AOP로 메서드 검증을 할 때 나는 Bean Validation 예외라 이 경로에서는 던져지지 않는다. @RequestParam·@PathVariable 제약 검증이 실패할 때(스프링 6.1+) 나는 HandlerMethodValidationException과도 구분해야 한다. 참고로 이 예외는 BindException을 상속하므로 BindException 핸들러로도 잡히지만, 실제로 던져지는 타입은 MethodArgumentNotValidException이다.');

-- =====================================================
-- Lesson 862: 체크 예외 롤백과 상태 코드 선택
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5351, 862, '아래 코드가 배포된 서버에 없는 주문 id로 GET /orders/99를 요청했을 때 클라이언트가 받는 응답으로 옳은 것은?', '스프링 부트 3 애플리케이션이며 에러 관련 설정은 모두 기본값이다. 클라이언트는 Accept: application/json으로 요청한다.

```java
@RestController
@RequestMapping("/orders")
public class OrderController {

    @GetMapping("/{id}")
    public OrderResponse find(@PathVariable Long id) {
        return orderService.findById(id)                  // 없는 주문이면 Optional.empty()
                .map(OrderResponse::from)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "주문이 없습니다"));
    }
}

// 전역 Advice(GlobalExceptionHandler)에 등록된 핸들러는 아래 둘뿐이다.
@ExceptionHandler(BusinessException.class)
public ResponseEntity<ErrorResponse> handleBusiness(BusinessException e) {
    ErrorCode code = e.getErrorCode();
    return ResponseEntity.status(code.getStatus()).body(ErrorResponse.of(code));
}

@ExceptionHandler(MethodArgumentNotValidException.class)
public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException e) {
    return ResponseEntity.badRequest()
            .body(ErrorResponse.of(ErrorCode.INVALID_INPUT, e.getBindingResult()));
}
```

ErrorResponse는 code·message·timestamp·errors 네 필드로 직렬화된다.', 'OBJECTIVE'),
       (5352, 862, '아래 상황에서 재고 부족으로 실패한 주문의 행이 DB에 남은 원인으로 옳은 것은?', '```java
public class InsufficientStockException extends Exception {
    public InsufficientStockException(Long productId) {
        super("재고 부족: productId=" + productId);
    }
}

@Service
@RequiredArgsConstructor
public class OrderService {

    @Transactional
    public Long place(Long productId, int quantity) throws InsufficientStockException {
        Order order = orderRepository.save(new Order(productId, quantity));
        Product product = productRepository.findById(productId).orElseThrow();
        if (product.getStock() < quantity) {
            throw new InsufficientStockException(productId);
        }
        product.decrease(quantity);
        return order.getId();
    }
}
```

전역 Advice에는 InsufficientStockException을 받아 409와 코드 O002로 응답하는 핸들러가 있고, 트랜잭션 관련 설정은 모두 기본값이다. 재고가 0개인 상품을 2개 주문하자 클라이언트는 409와 O002를 받았다. 그런데 주문 테이블을 조회하니 방금 실패한 주문의 행이 그대로 남아 있었다.', 'OBJECTIVE'),
       (5353, 862, '아래 조회 메서드 설계에 대한 설명으로 옳은 것은?', '회원 서비스의 조회 메서드를 용도에 따라 둘로 나눴다. 주문 생성처럼 주문자 회원이 반드시 있어야 하는 곳에서는, 없으면 MemberNotFoundException(BusinessException 하위, 404·M001)을 던지는 getByEmail을 쓴다. 가입 화면의 이메일 중복 확인처럼 회원이 없는 것도 정상 결과인 곳에서는 Optional<Member>를 돌려주는 findByEmail이나 boolean을 돌려주는 existsByEmail을 쓴다. 이전에는 중복 확인에서도 getByEmail을 try-catch로 감싸, 예외가 잡히면 "사용 가능한 이메일"로 판단했다.', 'OBJECTIVE'),
       (5354, 862, '아래 에러 코드 정의 중 HTTP 상태 코드를 상황의 의미에 맞지 않게 고른 상수는?', '주문 API의 ErrorCode 열거형에 새로 추가한 상수들이다.

| 상수 | HTTP 상태 | 코드 | 쓰이는 상황 |
|---|---|---|---|
| TOKEN_EXPIRED | 401 | C003 | 만료된 액세스 토큰으로 주문 API를 호출했다 |
| ORDER_NOT_CANCELABLE | 409 | O004 | 이미 배송이 시작된 주문에 취소를 요청했다 |
| PAYMENT_TIMEOUT | 400 | P001 | 결제사 승인 API가 5초 안에 응답하지 않아 승인에 실패했다 |
| TOO_MANY_ORDERS | 429 | O005 | 같은 회원이 1초에 30번 주문 API를 호출했다 |', 'OBJECTIVE'),
       (5355, 862, '아래 상황에서 업그레이드 뒤 새로 던져지기 시작해 Exception 핸들러에 잡힌 예외의 클래스 이름은?', '스프링 부트를 3.1에서 3.2로 올렸다. 전역 Advice와 정적 리소스 설정은 바꾸지 않았고 그 밖의 설정도 모두 기본값이다. Advice의 핸들러는 아래 둘뿐이다.

```java
@ExceptionHandler(BusinessException.class)
public ResponseEntity<ErrorResponse> handleBusiness(BusinessException e) { ... }

@ExceptionHandler(Exception.class)
public ResponseEntity<ErrorResponse> handleUnknown(Exception e) {
    log.error("Unhandled exception", e);
    return ResponseEntity.internalServerError()
            .body(ErrorResponse.of(ErrorCode.INTERNAL_ERROR));
}
```

클라이언트가 주소를 잘못 입력해 매핑된 컨트롤러가 없는 GET /ordres/1을 호출했을 때 결과가 아래처럼 달라졌다.

| 버전 | 응답 | 서버 로그 |
|---|---|---|
| 3.1 | 404, `{"timestamp":…,"status":404,"error":"Not Found","path":"/ordres/1"}` | 없음 |
| 3.2 | 500, `{"code":"S001","message":"일시적인 오류가 발생했습니다",…}` | Unhandled exception 스택 트레이스 (예외가 생성된 곳: ResourceHttpRequestHandler.handleRequest) |

팀은 이 예외 전용 @ExceptionHandler를 Advice에 추가해 다시 404로 응답하도록 고쳤다.', 'SUBJECTIVE'),
       (5356, 862, '아래 상황에서 배포 전 GlobalExceptionHandler 선언부에 붙어 있던 애노테이션은?', '리팩터링 커밋에 섞여 전역 예외 처리 클래스 선언부의 애노테이션 하나가 @ControllerAdvice로 바뀐 채 배포됐다. 메서드는 한 줄도 바뀌지 않았다.

```java
@ControllerAdvice                  // 배포 전에는 다른 애노테이션 하나가 이 자리에 있었다
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleValidation(MethodArgumentNotValidException e) {
        log.warn("validation failed");
        return ErrorResponse.of(ErrorCode.INVALID_INPUT, e.getBindingResult());
    }
}
```

배포 뒤 형식이 틀린 이메일로 회원가입을 요청하자 log.warn은 그대로 찍혔지만, 클라이언트는 errors 배열이 담긴 ErrorResponse JSON을 받지 못했다. 원인을 좁히려고 이 메서드의 반환 타입만 ResponseEntity<ErrorResponse>로 바꿔 보니 같은 요청에서 JSON이 정상으로 나왔다. 팀은 메서드를 고치는 대신 선언부 애노테이션을 원래대로 되돌렸고, 그 뒤 원래 메서드 그대로 JSON이 다시 나왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5351
(14443, 5351, '404, 본문은 code·message·timestamp·errors 필드의 ErrorResponse', '전역 Advice가 모든 예외 응답을 팀 형식으로 바꿔 준다고 본 오해. Advice는 등록된 @ExceptionHandler와 예외 타입이 맞을 때만 응답을 만든다. ResponseStatusException은 BusinessException 계열도 검증 예외도 아니어서 두 핸들러 모두 매칭되지 않는다.', false),
(14444, 5351, '404, 본문은 timestamp·status·error·path 필드의 스프링 부트 기본 형식', '첫 번째 리졸버가 매칭되는 @ExceptionHandler를 찾지 못하자, 두 번째 ResponseStatusExceptionResolver가 예외에 담긴 404로 sendError를 호출한다. 이어진 /error 재요청을 BasicErrorController가 받아 부트 기본 형식 본문을 만든다. 상태 코드는 맞아도 팀 표준 형식은 깨진다.', true),
(14445, 5351, '500, 본문은 code·message·timestamp·errors 필드의 ErrorResponse', 'Advice가 처리하지 못한 예외를 알아서 INTERNAL_ERROR로 감싼다고 본 오해. 그런 응답은 Exception.class를 받는 최후 방어선 핸들러를 직접 둘 때만 나오는데, 이 Advice에는 그 핸들러가 없다.', false),
(14446, 5351, '500, 본문은 timestamp·status·error·path 필드의 스프링 부트 기본 형식', 'Advice가 못 잡은 예외는 곧장 서블릿 컨테이너로 올라가 500이 된다고 본 오해. 리졸버 체인에는 @ExceptionHandler 탐색 다음 순서가 남아 있고, ResponseStatusException은 두 번째 리졸버가 예외에 담긴 상태 코드 404로 처리한다.', false),

-- 문제 5352
(14447, 5352, '전역 Advice가 예외를 409 응답으로 바꿔 처리했으므로, 트랜잭션은 정상 종료로 보고 커밋했다.', '처리 순서를 거꾸로 본 오해. 커밋·롤백은 예외가 place()를 빠져나가는 순간 @Transactional 프록시가 먼저 결정하고, Advice는 그 뒤 컨트롤러 밖에서 응답만 만든다. 같은 예외가 RuntimeException 계열이었다면 Advice가 있어도 롤백됐다.', false),
(14448, 5352, 'save()를 호출하는 순간 INSERT가 바로 커밋되므로, 뒤에서 예외가 나도 이미 저장된 행은 되돌릴 수 없다.', '자동 커밋 모드로 착각한 오해. @Transactional 메서드 안의 SQL은 하나의 트랜잭션으로 묶여 메서드가 끝날 때 함께 커밋되거나 롤백된다. save() 시점에 INSERT가 실행되더라도 커밋 전이므로 롤백하면 사라진다.', false),
(14449, 5352, '롤백은 예외가 던져진 줄 이후의 변경만 취소하므로, 그보다 먼저 실행된 save()는 롤백 범위에 들지 않는다.', '세이브포인트까지만 되돌리는 동작과 혼동한 오해. 트랜잭션 롤백은 시작 이후의 모든 변경을 취소한다. 실제로 롤백이 일어났다면 예외보다 앞선 save()의 주문 행도 함께 사라졌을 것이다.', false),
(14450, 5352, 'InsufficientStockException이 Exception을 직접 상속한 체크 예외라서, 기본 설정의 @Transactional은 이 예외에 대해 커밋한다.', '스프링의 기본 롤백 대상은 언체크 예외(RuntimeException·Error)이고, 체크 예외는 던져져도 커밋한다. 커스텀 예외를 RuntimeException 기반으로 바꾸거나 rollbackFor를 지정해야 롤백되며, RuntimeException 기반이면 throws 선언이 호출 계층으로 번지는 문제도 함께 사라진다.', true),

-- 문제 5353
(14451, 5353, '이메일 중복 확인처럼 회원이 없는 결과가 흔한 호출에서, 매번 예외 객체를 만들고 스택 트레이스를 기록하던 비용이 사라진다.', '예외 객체는 생성될 때 호출 스택을 기록하므로 일반 반환값보다 비용이 크다. 이전 방식은 정상 결과인 사용 가능 판정마다 이 비용을 치렀다. 없음이 정상인 곳은 Optional·boolean으로, 없으면 안 되는 곳만 예외로 알리는 것이 흐름 제어에 예외를 쓰지 않는 설계다.', true),
(14452, 5353, 'findByEmail이 Optional을 돌려주므로, 호출자가 값이 없는 경우를 처리하지 않고 get()을 부르면 컴파일 오류가 난다.', 'Optional이 처리를 컴파일 단계에서 강제한다고 본 오해. Optional은 값이 없을 수 있음을 타입으로 드러낼 뿐이라, 비어 있는 채로 get()을 부르면 컴파일은 되고 실행 중에 NoSuchElementException이 난다. 컴파일러가 처리를 강제하는 것은 체크 예외다.', false),
(14453, 5353, '이 원칙을 끝까지 따르면 getByEmail도 없애고, 주문 생성처럼 회원이 꼭 있어야 하는 곳까지 Optional을 받아 직접 분기해야 한다.', '원칙을 지나치게 넓힌 오해. 흐름 제어에 예외를 쓰지 말라는 것은 없음이 정상 결과인 경우의 이야기다. 있어야 할 회원이 없는 것은 진짜 실패이므로 예외로 알리고 전역 Advice가 404·M001로 바꾸게 두는 편이, 호출부마다 같은 분기를 반복하지 않는다.', false),
(14454, 5353, 'MemberNotFoundException을 체크 예외로 바꾸면 컴파일러가 catch를 강제하므로, 이전의 try-catch 방식도 문제없이 쓸 수 있다.', 'catch가 강제되는지와 흐름 제어에 예외를 쓰는 문제는 별개다. 체크 예외여도 정상 결과마다 예외를 만드는 비용은 그대로이고, 오히려 호출 계층마다 throws 선언이 번지며 @Transactional의 기본 롤백 대상에서도 빠진다.', false),

-- 문제 5354
(14455, 5354, 'TOKEN_EXPIRED', '만료된 토큰도 결국 요청자의 신원을 확인하지 못한 경우라 401이 맞다. 403과 헷갈리기 쉽지만 403은 누구인지는 확인됐는데 그 작업이 허용되지 않을 때 쓴다. 401을 받은 클라이언트는 토큰을 갱신해 다시 시도하면 된다.', false),
(14456, 5354, 'ORDER_NOT_CANCELABLE', '요청 형식은 멀쩡하지만 주문의 현재 상태(배송 시작)와 충돌해 처리할 수 없는 경우라 409가 맞다. 400으로 착각하기 쉽지만 400은 요청 자체가 잘못됐을 때 쓴다. 같은 요청도 배송 전이었다면 성공했을 것이다.', false),
(14457, 5354, 'PAYMENT_TIMEOUT', '4xx는 클라이언트가 요청을 고쳐야 해결되는 실패에 쓴다. 결제사 무응답은 요청 내용과 무관한 서버 쪽 연동 실패라 502·503·504 같은 5xx가 맞다. 400으로 내보내면 클라이언트는 고칠 것 없는 요청을 고치려 하고, 5xx 비율을 보는 모니터링에도 장애가 잡히지 않는다.', true),
(14458, 5354, 'TOO_MANY_ORDERS', '짧은 시간에 요청을 지나치게 많이 보낸 경우를 위한 전용 코드가 429(Too Many Requests)다. 자주 보지 못해 틀려 보이기 쉽지만 호출량 제한에 걸린 상황에 정확히 맞고, Retry-After 헤더로 다시 시도할 시점을 알려 줄 수도 있다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1740, 5355, 'NoResourceFoundException,org.springframework.web.servlet.resource.NoResourceFoundException,노리소스파운드익셉션,노 리소스 파운드 익셉션,No Resource Found Exception', '스프링 6.1(부트 3.2)부터 정적 리소스 처리기 ResourceHttpRequestHandler는 요청 경로에 맞는 리소스를 찾지 못하면 NoResourceFoundException을 던진다. 기본 설정에서는 /** 정적 리소스 매핑이 컨트롤러에 매핑되지 않은 경로까지 받아 주므로 오타 난 주소도 이 처리기로 간다. 3.1까지는 같은 상황에서 예외 없이 response.sendError(404)만 호출했기 때문에, /error 재요청을 BasicErrorController가 받아 부트 기본 형식의 404가 나갔고 Advice는 호출되지도 않았다. 3.2에서는 이것이 예외가 되어 HandlerExceptionResolver 체인을 타고, 첫 리졸버가 Advice에서 핸들러를 찾는데 BusinessException 계열이 아니므로 최후 방어선인 Exception 핸들러가 받아 500과 에러 로그를 남긴 것이다. 그래서 @ExceptionHandler(NoResourceFoundException.class)로 404를 돌려주거나, 이 예외 처리가 이미 들어 있는 ResponseEntityExceptionHandler를 상속해 해결한다. 이름이 비슷한 NoHandlerFoundException은 요청을 받을 핸들러가 아예 없을 때 나는 예외인데, 정적 리소스 매핑이 모든 경로를 받아 주는 기본 설정에서는 핸들러가 있는 것으로 처리되므로 이 상황에서는 던져지지 않는다. 최후 방어선 핸들러는 꼭 필요하지만, 범위가 넓은 만큼 프레임워크가 던지는 4xx 성격의 예외까지 500으로 바꿔 버릴 수 있다는 점도 함께 기억해 둔다.'),
       (1741, 5356, '@RestControllerAdvice,RestControllerAdvice,org.springframework.web.bind.annotation.RestControllerAdvice,레스트컨트롤러어드바이스,레스트 컨트롤러 어드바이스,Rest Controller Advice', '@RestControllerAdvice는 @ControllerAdvice에 @ResponseBody를 더한 애노테이션이다. 그래서 여기에 속한 @ExceptionHandler 메서드가 돌려준 객체는 HttpMessageConverter를 거쳐 JSON 본문으로 직렬화된다. @ControllerAdvice만 남으면 핸들러 자체는 똑같이 호출되지만(log.warn이 찍힌 이유), ErrorResponse 같은 일반 객체 반환값은 응답 본문이 아니라 모델 속성으로 취급되어 스프링이 뷰를 찾아 렌더링하려 하므로 기대한 JSON이 나가지 않는다. 반면 ResponseEntity는 그 자체가 상태 코드·헤더·본문을 담은 응답 객체라 @ResponseBody 없이도 본문으로 쓰이며, 반환 타입만 바꿨을 때 JSON이 나온 이유가 이것이다. @ResponseBody를 떠올리기 쉽지만 이 상황은 선언부의 애노테이션 하나를 다른 하나로 바꾼 것이므로, 두 역할을 합친 @RestControllerAdvice가 원래 자리에 있던 애노테이션이다. @RestController와 @Controller의 관계와 같은 짝으로 기억하면 된다.');
