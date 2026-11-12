-- Unit: 요청 전후 처리 계층 (Unit ID: 115)
-- Chapter: Spring (Chapter ID: 10)
-- Topic: SPRING_BOOT
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-spring-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(571, 'SPRING_BOOT', 115, 'HARD', true,
 '스프링 시큐리티 없이 로그인 인증을 직접 구현하면서 인증 검사를 필터에 두었더니, 인증 실패 예외가 @ControllerAdvice의 JSON 에러 응답으로 처리되지 않습니다. 원인과 해결 방법, 그리고 인증 로직을 어느 계층에 두는 것이 적절한지 설명해 주세요.',
 '필터는 서블릿 스펙으로 DispatcherServlet 바깥에서 동작하기 때문에, 필터에서 던진 예외는 DispatcherServlet에 도달하기 전에 발생하고 @ControllerAdvice가 잡지 못합니다. 이 경우 흐름은 톰캣의 오류 처리를 거쳐 /error, 즉 BasicErrorController로 넘어가서 우리가 정의한 JSON 에러 응답이 나오지 않습니다. 해결하려면 필터 안에서 직접 response에 에러 응답을 쓰거나, 예외를 잡아 HandlerExceptionResolver의 resolveException에 위임해서 기존 @ExceptionHandler를 재사용하는 방법이 있습니다. 반면 인터셉터의 preHandle은 DispatcherServlet의 doDispatch() 안에서 실행되므로 여기서 던진 예외는 @ControllerAdvice가 정상적으로 처리합니다. 또 인터셉터는 HandlerMethod를 받아 @PublicApi 같은 애노테이션을 보고 인증 여부를 분기할 수 있습니다. 그래서 스프링 시큐리티를 쓰면 인증은 필터 체인에 두고, 직접 구현한다면 인터셉터의 preHandle에서 인증을 확인해 차단하고, ArgumentResolver로 @LoginMember 같은 파라미터에 로그인 사용자를 주입하는 조합이 적절합니다. 두 계층의 역할이 차단과 주입으로 나뉘는 구조입니다.',
 'interview-question/571.mp3'),
(572, 'SPRING_BOOT', 115, 'NORMAL', true,
 '스프링에서 필터와 인터셉터는 어떤 차이가 있는지 설명해 주세요.',
 '필터와 인터셉터는 실행 위치, 핸들러 정보 접근, 예외 처리 범위에서 차이가 납니다. 먼저 실행 위치를 보면, 필터는 서블릿 스펙인 jakarta.servlet.Filter라서 DispatcherServlet 바깥에서 동작하고, 인터셉터는 스프링 MVC 스펙인 HandlerInterceptor라서 DispatcherServlet 안에서 동작합니다. 요청은 필터를 거쳐 DispatcherServlet에 들어간 뒤 인터셉터의 preHandle을 지나 컨트롤러로 가고, 응답은 역순으로 필터를 되돌아 나갑니다. 두 번째로 핸들러 정보 접근입니다. 인터셉터는 핸들러 객체, 즉 HandlerMethod를 받기 때문에 어떤 컨트롤러 메서드가 실행될지 알 수 있고, 메서드의 애노테이션을 보고 분기할 수 있습니다. 필터는 핸들러 정보에 접근할 수 없습니다. 세 번째로 예외 처리 범위입니다. 필터에서 던진 예외는 DispatcherServlet에 도달하기 전이라 @ControllerAdvice가 적용되지 않고, 톰캣의 오류 처리를 거쳐 /error의 BasicErrorController로 넘어갑니다. 반면 인터셉터 preHandle에서 던진 예외는 DispatcherServlet의 doDispatch() 안이므로 @ControllerAdvice가 정상적으로 처리합니다. 그 밖에 필터는 HttpServletRequest/Response를 래퍼로 교체할 수 있는 유일한 계층이라 본문 재사용이나 응답 압축, 인코딩 처리에 적합합니다. 그래서 인코딩·로깅·본문 캐싱 같은 스프링과 무관한 전역 처리는 필터에, 애노테이션 기반 권한 체크처럼 컨트롤러 메서드 정보를 보고 판단해야 하는 처리는 인터셉터에 둡니다.',
 'interview-question/572.mp3'),
(573, 'SPRING_BOOT', 115, 'NORMAL', true,
 '인터셉터의 postHandle과 afterCompletion은 어떻게 다르고, MDC나 ThreadLocal 같은 자원 정리는 어디에 두어야 하는지 설명해 주세요.',
 'postHandle은 컨트롤러 실행 후, 뷰 렌더링 전에 호출되어 뷰 기반에서 모델에 공통 데이터를 추가하는 데 쓰입니다. 하지만 컨트롤러에서 예외가 발생하면 postHandle은 호출되지 않습니다. 또 @RestController는 postHandle 시점에 이미 응답 본문이 쓰여 있어서 본문을 수정할 수도 없습니다. 반면 afterCompletion은 응답이 완료된 후 호출되며, 예외 여부와 무관하게 항상 호출되고 예외가 있었다면 그 예외 객체도 전달받습니다. 그래서 MDC나 ThreadLocal 해제 같은 자원 정리는 postHandle이 아니라 반드시 afterCompletion에 두어야, 컨트롤러에서 예외가 나도 정리가 누락되지 않습니다.',
 'interview-question/573.mp3'),
(574, 'SPRING_BOOT', 115, 'EASY', true,
 '스프링 MVC의 HandlerMethodArgumentResolver는 무엇이며 어떻게 동작하는지 설명해 주세요.',
 'HandlerMethodArgumentResolver는 컨트롤러 메서드의 파라미터 하나를 만들어 주는 역할을 합니다. 요청 흐름을 막거나 통과시키는 계층이 아니라 파라미터 조립을 담당합니다. 동작은 두 메서드로 이루어지는데, supportsParameter()에서 파라미터에 @LoginMember 같은 애노테이션이 붙어 있는지, 타입이 맞는지 보고 이 리졸버가 처리할 파라미터인지 판단하고, true인 첫 리졸버가 사용됩니다. 그러면 resolveArgument()에서 요청의 세션 등에서 값을 꺼내 파라미터 값을 만들어 반환합니다. 이를 통해 컨트롤러마다 세션이나 헤더에서 사용자를 꺼내는 반복 코드를 공통화하고, 컨트롤러는 비즈니스에만 집중할 수 있습니다. 등록은 WebMvcConfigurer의 addArgumentResolvers()로 하며, 스프링 시큐리티의 @AuthenticationPrincipal도 같은 원리로 동작하는 리졸버입니다.',
 'interview-question/574.mp3'),
(575, 'SPRING_BOOT', 115, 'EASY', true,
 '서블릿 필터에서 chain.doFilter()는 어떤 역할을 하며, 필터를 구현할 때 OncePerRequestFilter를 상속하는 이유는 무엇인지 설명해 주세요.',
 'chain.doFilter()는 현재 필터의 처리를 마친 뒤 요청을 다음 필터로, 마지막 필터라면 DispatcherServlet으로 넘기는 역할을 합니다. 응답은 역순으로 필터를 되돌아 나오므로 chain.doFilter() 호출 전후에 처리 시간 로깅 같은 작업을 둘 수 있습니다. chain.doFilter()를 호출하지 않으면 요청이 그 필터에서 끝나므로, 인증 실패 시 직접 응답을 써서 요청을 차단할 수 있습니다. OncePerRequestFilter를 상속하는 이유는 forward나 error 디스패치로 같은 요청이 다시 들어와도 필터가 한 번만 실행되도록 보장하기 위해서입니다. 참고로 필터 클래스에 @Component를 붙인 상태에서 FilterRegistrationBean으로 한 번 더 등록하면 필터가 두 번 실행되므로, 경로와 순서를 제어하려면 FilterRegistrationBean으로만 등록하고 setOrder 값은 낮을수록 먼저 실행됩니다.',
 'interview-question/575.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 571
(3067, 571, '필터에서 던진 예외는 DispatcherServlet 도달 전이라 @ControllerAdvice가 잡지 못함을 설명', 'ESSENTIAL', 1),
(3068, 571, '필터 안에서 response에 직접 쓰거나 HandlerExceptionResolver에 위임하는 방법 중 최소 1개를 제시', 'ESSENTIAL', 2),
(3069, 571, '인터셉터 preHandle에서 던진 예외는 @ControllerAdvice가 정상 처리함을 언급', 'ESSENTIAL', 3),
(3070, 571, '직접 구현 시 인터셉터로 인증을 차단하고 ArgumentResolver로 사용자를 주입하는 조합을 제시', 'ESSENTIAL', 4),
(3071, 571, '필터 예외는 톰캣 오류 처리를 거쳐 /error의 BasicErrorController로 넘어감을 언급', 'SUPPLEMENTARY', 5),
(3072, 571, '스프링 시큐리티를 쓰는 경우에는 인증을 필터에 둔다는 점을 언급', 'SUPPLEMENTARY', 6),

-- 질문 572
(3073, 572, '필터는 DispatcherServlet 바깥, 인터셉터는 DispatcherServlet 안에서 실행됨을 설명', 'ESSENTIAL', 1),
(3074, 572, '인터셉터만 실행될 컨트롤러 메서드(HandlerMethod) 정보에 접근할 수 있음을 언급', 'ESSENTIAL', 2),
(3075, 572, '필터 예외에는 @ControllerAdvice가 적용되지 않고 인터셉터 예외에는 적용됨을 설명', 'ESSENTIAL', 3),
(3076, 572, '필터는 서블릿 스펙이고 인터셉터는 스프링 MVC 스펙임을 언급', 'SUPPLEMENTARY', 4),
(3077, 572, 'Request/Response를 래퍼로 교체할 수 있는 것은 필터뿐임을 언급', 'SUPPLEMENTARY', 5),
(3078, 572, '인코딩·로깅·본문 캐싱은 필터, 애노테이션 기반 권한 분기는 인터셉터가 적합하다는 선택 기준을 제시', 'SUPPLEMENTARY', 6),

-- 질문 573
(3079, 573, 'postHandle은 컨트롤러 실행 후 뷰 렌더링 전에 호출됨을 언급', 'ESSENTIAL', 1),
(3080, 573, '컨트롤러에서 예외가 발생하면 postHandle이 호출되지 않음을 언급', 'ESSENTIAL', 2),
(3081, 573, 'afterCompletion은 예외 여부와 무관하게 항상 호출됨을 언급', 'ESSENTIAL', 3),
(3082, 573, 'MDC·ThreadLocal 같은 자원 해제는 afterCompletion에 두어야 함을 제시', 'ESSENTIAL', 4),
(3083, 573, '@RestController는 postHandle 시점에 응답 본문이 이미 쓰여 수정할 수 없음을 언급', 'SUPPLEMENTARY', 5),
(3084, 573, 'afterCompletion에는 발생한 예외 객체가 전달됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 574
(3085, 574, 'ArgumentResolver는 컨트롤러 메서드의 파라미터를 만들어 주는 역할임을 설명', 'ESSENTIAL', 1),
(3086, 574, 'supportsParameter()가 true인 리졸버가 해당 파라미터 처리에 사용됨을 언급', 'ESSENTIAL', 2),
(3087, 574, 'resolveArgument()에서 요청 정보로 파라미터 값을 만들어 반환함을 언급', 'ESSENTIAL', 3),
(3088, 574, '컨트롤러마다 반복되는 세션·헤더 기반 사용자 조회 코드를 공통화하는 목적을 언급', 'SUPPLEMENTARY', 4),
(3089, 574, 'WebMvcConfigurer의 addArgumentResolvers()로 등록함을 언급', 'SUPPLEMENTARY', 5),
(3090, 574, '@AuthenticationPrincipal이 같은 원리로 동작하는 리졸버임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 575
(3091, 575, 'chain.doFilter()가 요청을 다음 필터나 DispatcherServlet으로 넘김을 설명', 'ESSENTIAL', 1),
(3092, 575, 'chain.doFilter()를 호출하지 않으면 요청이 필터에서 끝나 차단됨을 언급', 'ESSENTIAL', 2),
(3093, 575, 'OncePerRequestFilter는 forward·error 디스패치로 요청이 다시 들어와도 한 번만 실행됨을 언급', 'ESSENTIAL', 3),
(3094, 575, '@Component와 FilterRegistrationBean으로 중복 등록하면 필터가 두 번 실행됨을 언급', 'SUPPLEMENTARY', 4),
(3095, 575, 'FilterRegistrationBean의 setOrder 값이 낮을수록 먼저 실행됨을 언급', 'SUPPLEMENTARY', 5);
