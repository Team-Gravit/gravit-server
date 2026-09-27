-- Unit: 예외 처리와 응답 규약 (Unit ID: 120)
-- Chapter: Spring (Chapter ID: 10)
-- Topic: SPRING_BOOT
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-spring-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(596, 'SPRING_BOOT', 120, 'HARD', true,
 '컨트롤러마다 try-catch로 예외를 잡아 각자 응답을 만들던 API 서버를 개선하려고 합니다. 예외 처리 구조를 어떻게 바꾸시겠으며, 그 구조에서도 따로 주의해야 할 지점은 무엇인가요?',
 '컨트롤러마다 try-catch를 두면 처리 코드가 중복되고, 일부 예외는 누락되며, 컨트롤러마다 응답 형식이 달라지는 문제가 생깁니다. 그래서 @RestControllerAdvice에 전역 예외 핸들러를 두고 @ExceptionHandler로 예외 타입별 처리를 한 곳에 모은 뒤, 컨트롤러는 정상 흐름만 작성하도록 바꾸겠습니다. 이때 에러 응답은 code·message·timestamp·errors 같은 일관된 구조의 ErrorResponse로 표준화해서 클라이언트가 하나의 파싱 로직으로 처리할 수 있게 합니다. 주의할 점은 두 가지입니다. 첫째, JWT 검증 같은 필터에서 던진 예외는 DispatcherServlet 밖에서 발생하므로 HandlerExceptionResolver 체인을 타지 않아 @ControllerAdvice가 잡지 못합니다. 따라서 필터 예외는 HandlerExceptionResolver에 직접 위임하거나 필터 안에서 응답을 직접 써야 합니다. 둘째, Exception.class를 잡는 최후 방어선 핸들러는 반드시 두되, 원인은 로그로만 남기고 응답에는 일반화된 메시지만 담아야 합니다. e.getMessage()나 스택 트레이스를 그대로 응답에 담으면 내부 테이블명이나 경로가 노출되어 보안 취약점이 되기 때문입니다.'),
(597, 'SPRING_BOOT', 120, 'NORMAL', true,
 '에러 응답을 팀이 정의한 자체 ErrorResponse 형식으로 만드는 방식과 RFC 7807 ProblemDetail을 사용하는 방식은 어떻게 다르고, 각각 어떤 상황에서 선택하나요?',
 '자체 ErrorResponse는 팀이 정의한 JSON 구조로, 예를 들어 code·message·timestamp·errors 필드를 두고 application/json으로 응답합니다. 스프링이 형식을 정해 주지 않으므로 직접 구현해야 하지만, 기존 클라이언트와 호환되고 필드를 자유롭게 정할 수 있다는 장점이 있습니다. 반면 RFC 7807 Problem Details는 업계 표준 형식으로 type, title, status, detail, instance라는 표준 필드를 가지며, Content-Type이 application/problem+json입니다. Spring 6부터는 ProblemDetail 클래스와 ErrorResponseException을 지원하고, spring.mvc.problemdetails.enabled=true 설정도 제공합니다. 또 properties를 통해 애플리케이션 에러 코드 같은 확장 필드를 추가할 수 있습니다. 선택 기준은, 사내 응답 규약이 이미 있다면 자체 표준을 유지하고, 신규 API나 외부 공개 API라면 표준인 ProblemDetail을 검토하는 것입니다.'),
(598, 'SPRING_BOOT', 120, 'NORMAL', true,
 '커스텀 비즈니스 예외를 체크 예외가 아닌 RuntimeException 기반으로 설계하는 이유는 무엇이며, HTTP 상태 코드와 별도로 애플리케이션 에러 코드를 두는 이유는 무엇인가요?',
 '커스텀 예외를 RuntimeException 기반으로 만들면 서비스 메서드 시그니처가 throws 선언으로 오염되지 않습니다. 또 @Transactional의 기본 롤백 규칙은 런타임 예외에서 롤백하는 것이라 비즈니스 예외가 발생했을 때 자연스럽게 롤백되는데, 체크 예외를 던지면 기본적으로 커밋되어 롤백을 기대했다가 문제가 생길 수 있습니다. 실무에서는 RuntimeException을 상속한 BusinessException 하나에 ErrorCode enum을 보유하게 해서, 예외 클래스를 무한히 늘리지 않고 상태 코드와 메시지를 한 곳에서 관리하는 구조를 많이 씁니다. 애플리케이션 에러 코드를 따로 두는 이유는 HTTP 상태 코드가 너무 거칠기 때문입니다. 예를 들어 404 하나로는 주문이 없는 것인지 회원이 없는 것인지 알 수 없으므로 O001 같은 애플리케이션 코드를 별도로 둡니다. 덧붙여 리포지토리의 DataAccessException 같은 인프라 예외는 서비스 경계에서 비즈니스 예외로 감싸 상위 계층이 인프라 기술을 몰라도 되게 합니다.'),
(599, 'SPRING_BOOT', 120, 'EASY', true,
 '스프링 MVC에서 컨트롤러가 던진 예외는 어떤 흐름을 거쳐 응답으로 변환되는지 설명해 주시겠어요?',
 '컨트롤러에서 던져진 예외는 DispatcherServlet의 doDispatch()가 잡아서 HandlerExceptionResolver 체인에 넘깁니다. 체인은 리졸버를 순서대로 시도하고, 먼저 처리에 성공한 리졸버의 결과를 응답으로 사용합니다. 첫 번째는 ExceptionHandlerExceptionResolver로, 컨트롤러 내부와 @ControllerAdvice의 @ExceptionHandler 메서드를 탐색합니다. 여기서 처리되지 않으면 ResponseStatusExceptionResolver가 @ResponseStatus 애노테이션이나 ResponseStatusException을 처리하고, 그다음 DefaultHandlerExceptionResolver가 스프링 내부 예외를 400, 405, 415 같은 표준 상태 코드로 바꿉니다. 이 체인에서도 처리되지 않으면 예외가 서블릿 컨테이너로 전파되고, /error로 재요청되어 스프링 부트 기본 에러 응답인 BasicErrorController가 응답합니다.'),
(600, 'SPRING_BOOT', 120, 'EASY', true,
 '@RestControllerAdvice는 무엇이며, 여러 Advice가 있을 때 각 Advice의 적용 범위와 우선순위는 어떻게 정하나요?',
 '@RestControllerAdvice는 @ControllerAdvice에 @ResponseBody를 합친 애노테이션으로, 전역 예외 핸들러를 모아 두는 클래스에 붙입니다. @ResponseBody가 포함되어 있어 핸들러의 반환값이 HttpMessageConverter로 직렬화되어 응답 본문이 됩니다. Advice는 basePackages 같은 속성으로 적용 범위를 제한할 수 있습니다. 예를 들어 basePackages = "com.app.api"로 지정하면 해당 패키지에만 적용됩니다. 여러 Advice가 있으면 @Order로 우선순위를 정하며, 범위가 좁은 Advice를 앞에 둡니다. 덧붙여 ResponseEntityExceptionHandler를 상속하면 HttpRequestMethodNotSupportedException, MethodArgumentNotValidException 같은 스프링 MVC 내부 예외의 처리 메서드가 이미 정의되어 있어 필요한 것만 오버라이드할 수 있습니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 596
(3208, 596, '@RestControllerAdvice 전역 핸들러에 예외 처리를 모으고 컨트롤러는 정상 흐름만 두는 구조를 제시', 'ESSENTIAL', 1),
(3209, 596, '에러 응답을 code·message·timestamp·errors 같은 일관된 구조로 표준화함을 제시', 'ESSENTIAL', 2),
(3210, 596, '필터에서 던진 예외는 DispatcherServlet 밖이라 @ControllerAdvice가 잡지 못함을 언급', 'ESSENTIAL', 3),
(3211, 596, 'Exception.class 최후 핸들러는 원인을 로그로만 남기고 응답에는 일반화된 메시지만 담는다고 설명', 'ESSENTIAL', 4),
(3212, 596, '컨트롤러별 try-catch가 중복·누락·형식 불일치를 낳는다는 문제를 언급', 'SUPPLEMENTARY', 5),
(3213, 596, '필터 예외는 HandlerExceptionResolver에 직접 위임하거나 필터 안에서 응답을 써야 한다고 제시', 'SUPPLEMENTARY', 6),
(3214, 596, 'e.getMessage()나 스택 트레이스를 응답에 담으면 내부 테이블명·경로가 노출됨을 언급', 'SUPPLEMENTARY', 7),

-- 질문 597
(3215, 597, 'ProblemDetail 표준 필드(type·title·status·detail·instance) 중 최소 2개를 제시', 'ESSENTIAL', 1),
(3216, 597, '자체 표준은 사내 규약이 있을 때, ProblemDetail은 신규·외부 공개 API에 선택한다고 제시', 'ESSENTIAL', 2),
(3217, 597, 'ProblemDetail 응답의 Content-Type이 application/problem+json임을 언급', 'SUPPLEMENTARY', 3),
(3218, 597, '자체 표준은 기존 클라이언트와 호환되고 필드를 자유롭게 정할 수 있음을 언급', 'SUPPLEMENTARY', 4),
(3219, 597, 'ProblemDetail은 properties로 확장 필드를 추가할 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 598
(3220, 598, 'RuntimeException 기반이면 서비스 시그니처가 throws로 오염되지 않음을 언급', 'ESSENTIAL', 1),
(3221, 598, 'RuntimeException 기반이어야 @Transactional 기본 롤백 규칙에 따라 롤백됨을 설명', 'ESSENTIAL', 2),
(3222, 598, 'HTTP 상태 코드만으로는 오류 원인을 세밀하게 나눌 수 없어 애플리케이션 에러 코드를 별도로 둔다고 설명', 'ESSENTIAL', 3),
(3223, 598, 'BusinessException에 ErrorCode enum을 두어 상태 코드·메시지를 한 곳에서 관리함을 언급', 'SUPPLEMENTARY', 4),
(3224, 598, 'DataAccessException 같은 인프라 예외를 서비스 경계에서 비즈니스 예외로 감싼다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 599
(3225, 599, 'DispatcherServlet이 예외를 잡아 HandlerExceptionResolver 체인에 넘긴다고 설명', 'ESSENTIAL', 1),
(3226, 599, 'ExceptionHandlerExceptionResolver가 체인의 첫 번째로 @ExceptionHandler를 탐색함을 언급', 'ESSENTIAL', 2),
(3227, 599, '어떤 리졸버도 처리하지 못하면 /error 재요청으로 BasicErrorController가 응답함을 언급', 'ESSENTIAL', 3),
(3228, 599, 'ResponseStatusExceptionResolver와 DefaultHandlerExceptionResolver가 뒤이어 시도됨을 언급', 'SUPPLEMENTARY', 4),
(3229, 599, '체인은 먼저 처리에 성공한 리졸버의 결과를 응답으로 사용함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 600
(3230, 600, '@RestControllerAdvice가 @ControllerAdvice와 @ResponseBody의 조합임을 언급', 'ESSENTIAL', 1),
(3231, 600, 'basePackages 같은 속성으로 Advice의 적용 범위를 제한할 수 있음을 언급', 'ESSENTIAL', 2),
(3232, 600, '여러 Advice가 있으면 @Order로 우선순위를 정한다고 언급', 'ESSENTIAL', 3),
(3233, 600, '@RestControllerAdvice 핸들러의 반환값이 HttpMessageConverter로 직렬화됨을 언급', 'SUPPLEMENTARY', 4),
(3234, 600, '범위가 좁은 Advice를 우선순위상 앞에 둔다고 언급', 'SUPPLEMENTARY', 5),
(3235, 600, 'ResponseEntityExceptionHandler를 상속하면 내부 예외 처리 메서드 중 필요한 것만 오버라이드함을 언급', 'SUPPLEMENTARY', 6);
