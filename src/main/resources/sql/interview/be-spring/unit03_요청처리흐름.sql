-- Unit: 요청 처리 흐름 (Unit ID: 114)
-- Chapter: Spring (Chapter ID: 10)
-- Topic: SPRING_BOOT
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-spring-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(566, 'SPRING_BOOT', 114, 'HARD', true,
 '@RequestBody로 JSON을 받고 @ResponseBody로 응답하는 API에서, 모든 응답 본문을 공통 형식으로 감싸려고 HandlerInterceptor의 postHandle에서 본문을 수정했는데 반영되지 않았습니다. 요청이 DispatcherServlet에 들어와 응답이 쓰이기까지의 흐름을 바탕으로 원인과 대안을 설명해 주시겠어요?',
 '요청은 톰캣을 거쳐 DispatcherServlet으로 들어오고, HandlerMapping이 처리할 핸들러와 인터셉터 목록을 HandlerExecutionChain으로 반환합니다. 이후 preHandle을 거쳐 HandlerAdapter가 핸들러를 호출하는데, 이 핸들러 호출 단계 안에서 컨트롤러가 실행된 뒤 @ResponseBody 반환값은 ReturnValueHandler가 즉시 응답 본문에 기록합니다. 이때 JSON 직렬화는 HttpMessageConverter가 담당합니다. 즉 응답 본문은 핸들러 호출 단계에서 이미 쓰이고, postHandle은 핸들러 호출 이후에 실행되기 때문에 이미 쓰인 응답 본문을 수정할 수 없습니다. 그래서 postHandle에서의 수정이 반영되지 않은 것입니다. 참고로 뷰 이름을 반환하는 방식이라면 postHandle 시점이 렌더링 전이라 모델을 수정할 수 있습니다. 대안으로, 요청/응답 본문을 감싸는 작업은 스프링 MVC 확장 지점 중 Filter가 담당하는 영역이므로 FilterRegistrationBean 등으로 Filter를 등록해 처리하는 것이 적절합니다.',
 'interview-question/566.mp3'),
(567, 'SPRING_BOOT', 114, 'NORMAL', true,
 '스프링 MVC에서 HandlerMapping과 HandlerAdapter는 각각 어떤 역할을 하며, DispatcherServlet이 핸들러를 직접 호출하지 않고 HandlerAdapter를 거치는 이유는 무엇인가요?',
 'HandlerMapping은 요청의 URL·HTTP 메서드·헤더 등을 보고 이 요청을 처리할 핸들러를 찾아 반환하는, 즉 ''누가 처리할지''를 정하는 역할입니다. 반환값은 핸들러와 인터셉터 목록을 담은 HandlerExecutionChain입니다. HandlerAdapter는 찾은 핸들러를 ''어떻게 호출할지''를 담당합니다. 핸들러의 형태가 애노테이션 메서드(HandlerMethod), 레거시 Controller 인터페이스, HttpRequestHandler처럼 제각각이기 때문에 DispatcherServlet이 직접 호출하지 않고 어댑터 패턴으로 호출 방법을 추상화합니다. DispatcherServlet은 등록된 어댑터를 순회하며 supports(handler)가 true인 어댑터를 골라 handle()을 호출합니다. 예를 들어 애노테이션 컨트롤러는 RequestMappingHandlerMapping이 찾고 RequestMappingHandlerAdapter가 호출합니다.',
 'interview-question/567.mp3'),
(568, 'SPRING_BOOT', 114, 'NORMAL', true,
 '@RestController에서 객체를 반환하는 경우와 @Controller에서 뷰 이름을 반환하는 경우, 스프링 MVC의 응답 처리 방식은 어떻게 다른가요?',
 '@RestController에서 객체를 반환하면 @ResponseBody가 적용되어, ReturnValueHandler가 HttpMessageConverter를 사용해 반환값을 JSON·XML·문자열 등으로 변환한 뒤 즉시 응답 본문에 기록합니다. 이때 Content-Type은 요청의 Accept 헤더와 컨버터 협상(Content Negotiation)으로 결정됩니다. 반면 @Controller에서 뷰 이름(String)을 반환하면 ModelAndView로 감싸 DispatcherServlet에 전달되고, ViewResolver가 View를 찾아 View.render()로 Thymeleaf 같은 템플릿을 렌더링하며, 이 경우 Content-Type은 템플릿 엔진이 결정합니다. 참고로 @RestController는 @Controller와 @ResponseBody의 조합일 뿐 별도의 처리 경로가 아니어서, 두 방식 모두 같은 HandlerMapping·HandlerAdapter를 거치고 반환값을 다루는 ReturnValueHandler만 달라집니다.',
 'interview-question/568.mp3'),
(569, 'SPRING_BOOT', 114, 'EASY', true,
 'DispatcherServlet이란 무엇이며, 스프링 MVC가 프런트 컨트롤러 패턴으로 동작한다는 것은 어떤 의미인가요?',
 'DispatcherServlet은 HttpServlet을 상속한 하나의 서블릿으로, 모든 HTTP 요청을 받는 스프링 MVC의 시작점입니다. 스프링 이전에는 URL마다 서블릿을 하나씩 만들어 web.xml에 매핑했는데, 인코딩·예외·뷰 렌더링 같은 공통 처리가 서블릿마다 중복되는 문제가 있었습니다. 프런트 컨트롤러 패턴은 하나의 서블릿이 모든 요청을 받아 공통 처리는 한 곳에서 하고, 실제 비즈니스 처리는 컨트롤러 빈에 위임하는 구조를 말합니다. 톰캣이 요청을 받아 DispatcherServlet에 넘기면, DispatcherServlet은 ApplicationContext에서 컨트롤러 빈을 찾아 호출합니다. 스프링 부트에서는 DispatcherServletAutoConfiguration이 DispatcherServlet을 빈으로 만들어 / 경로에 자동 등록합니다.',
 'interview-question/569.mp3'),
(570, 'SPRING_BOOT', 114, 'EASY', true,
 '스프링 MVC 요청 처리 흐름에서 HandlerInterceptor의 preHandle, postHandle, afterCompletion은 각각 어느 시점에 호출되나요?',
 'DispatcherServlet은 HandlerMapping으로 핸들러와 인터셉터 목록을 조회하고 HandlerAdapter를 고른 뒤, 먼저 preHandle을 호출합니다. 즉 preHandle은 HandlerAdapter가 핸들러를 호출하기 전에 실행되는 전처리이며, false를 반환하면 그 시점에서 처리가 종료됩니다. 이후 HandlerAdapter.handle()로 컨트롤러가 실행되고 나면 postHandle이 호출되는데, 이는 핸들러 호출 이후 응답 생성 단계(뷰 렌더링 등) 전에 실행되는 후처리로 ModelAndView에 접근할 수 있습니다. 마지막으로 응답 생성이 끝나면 afterCompletion이 호출되며, 이는 예외 발생 여부와 무관하게 실행되는 마무리 단계입니다.',
 'interview-question/570.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 566
(3041, 566, '@ResponseBody 반환값은 핸들러 호출 단계에서 ReturnValueHandler가 즉시 응답 본문에 기록함을 설명', 'ESSENTIAL', 1),
(3042, 566, 'postHandle은 핸들러 호출 이후 실행되어 이미 쓰인 응답 본문을 수정할 수 없음을 설명', 'ESSENTIAL', 2),
(3043, 566, '응답 본문을 감싸는 작업의 확장 지점으로 Filter를 대안으로 제시', 'ESSENTIAL', 3),
(3044, 566, '응답 본문의 JSON 직렬화를 HttpMessageConverter가 담당함을 언급', 'SUPPLEMENTARY', 4),
(3045, 566, 'HandlerMapping이 핸들러와 인터셉터 목록을 HandlerExecutionChain으로 반환함을 언급', 'SUPPLEMENTARY', 5),
(3046, 566, '뷰 이름 반환 방식이면 postHandle 시점이 렌더링 전이라 모델 수정이 가능함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 567
(3047, 567, 'HandlerMapping은 요청을 보고 처리할 핸들러를 찾아 반환하는 역할임을 설명', 'ESSENTIAL', 1),
(3048, 567, 'HandlerAdapter는 찾은 핸들러를 어떻게 호출할지 담당하는 역할임을 설명', 'ESSENTIAL', 2),
(3049, 567, '핸들러 형태가 제각각이라 어댑터 패턴으로 호출 방법을 추상화함을 설명', 'ESSENTIAL', 3),
(3050, 567, 'DispatcherServlet이 supports(handler)가 true인 어댑터를 골라 handle()을 호출함을 언급', 'SUPPLEMENTARY', 4),
(3051, 567, '애노테이션 컨트롤러는 RequestMappingHandlerAdapter가 호출함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 568
(3052, 568, '@ResponseBody 반환값은 HttpMessageConverter가 JSON 등으로 변환해 응답 본문에 기록함을 설명', 'ESSENTIAL', 1),
(3053, 568, '뷰 이름 반환 시 ViewResolver가 View를 찾아 View.render()로 렌더링함을 설명', 'ESSENTIAL', 2),
(3054, 568, '두 방식 모두 같은 HandlerMapping·HandlerAdapter를 거치고 ReturnValueHandler만 달라짐을 설명', 'SUPPLEMENTARY', 3),
(3055, 568, '@ResponseBody 응답의 Content-Type은 Accept 헤더와 컨버터 협상으로 결정됨을 언급', 'SUPPLEMENTARY', 4),
(3056, 568, '뷰 이름 반환값은 ModelAndView로 감싸 DispatcherServlet에 전달됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 569
(3057, 569, 'DispatcherServlet이 모든 HTTP 요청을 받는 하나의 서블릿임을 설명', 'ESSENTIAL', 1),
(3058, 569, '공통 처리는 한 곳에서 하고 실제 처리는 컨트롤러에 위임하는 구조임을 설명', 'ESSENTIAL', 2),
(3059, 569, 'URL마다 서블릿을 두면 공통 처리가 서블릿마다 중복되는 문제를 언급', 'SUPPLEMENTARY', 3),
(3060, 569, '스프링 부트가 DispatcherServletAutoConfiguration으로 / 경로에 자동 등록함을 언급', 'SUPPLEMENTARY', 4),
(3061, 569, '톰캣이 넘긴 요청을 DispatcherServlet이 ApplicationContext의 컨트롤러 빈에 넘김을 언급', 'SUPPLEMENTARY', 5),

-- 질문 570
(3062, 570, 'preHandle이 HandlerAdapter의 핸들러 호출 전에 실행됨을 설명', 'ESSENTIAL', 1),
(3063, 570, 'postHandle이 핸들러 호출 이후 응답 생성 단계 전에 실행됨을 설명', 'ESSENTIAL', 2),
(3064, 570, 'afterCompletion이 예외 발생 여부와 무관하게 마지막에 실행됨을 설명', 'ESSENTIAL', 3),
(3065, 570, 'preHandle이 false를 반환하면 그 시점에서 요청 처리가 종료됨을 언급', 'SUPPLEMENTARY', 4),
(3066, 570, 'postHandle에서 ModelAndView에 접근할 수 있음을 언급', 'SUPPLEMENTARY', 5);
