-- Unit: 인증·인가 필터 체인 (Unit ID: 121)
-- Chapter: Spring (Chapter ID: 10)
-- Topic: SPRING_BOOT
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-spring-unit10 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(601, 'SPRING_BOOT', 121, 'HARD', true,
 '직접 만든 JWT 인증 필터를 UsernamePasswordAuthenticationFilter 앞에 배치했을 때, 토큰이 없는 요청과 만료·위조된 토큰 요청을 각각 어떻게 처리해야 하는지 필터 순서 관점의 이유와 함께 설명해 주세요.',
 '토큰이 없는 요청은 JWT 필터에서 예외를 던지지 말고 chain.doFilter로 그냥 통과시켜야 합니다. permitAll로 열어 둔 공개 경로도 이 필터를 지나가기 때문에, 토큰이 없다고 여기서 401을 내면 공개 API까지 막히게 됩니다. 인증 여부 판단은 뒤에 있는 AuthorizationFilter에 맡기면 되고, 인증되지 않은 요청을 최종적으로 막는 것도 AuthorizationFilter입니다. 반면 토큰이 만료되거나 위조된 경우에는 401을 명확히 알려야 하므로 예외로 처리해야 합니다. 그런데 ExceptionTranslationFilter는 자기보다 뒤에서 던져진 AuthenticationException·AccessDeniedException만 잡기 때문에, 그보다 앞에 있는 JWT 필터에서 던진 예외는 AuthenticationEntryPoint로 가지 않고 서블릿 컨테이너로 전파됩니다. 그래서 JWT 필터 안에서 예외를 잡아 HandlerExceptionResolver로 위임해 @ControllerAdvice에서 처리하게 하거나, 직접 응답을 써서 401을 내려 줍니다. 덧붙여 이 필터를 @Component로 만들면 스프링 부트가 서블릿 컨테이너 필터로도 자동 등록해 시큐리티 체인 안과 밖에서 두 번 실행되므로, FilterRegistrationBean으로 setEnabled(false)를 지정하거나 설정 클래스에서 new로 생성해 addFilterBefore에만 넘깁니다.'),
(602, 'SPRING_BOOT', 121, 'NORMAL', true,
 '스프링 시큐리티에서 세션 기반 폼 로그인 방식과 JWT 무상태 방식은 인증 정보(SecurityContext) 저장과 CSRF 처리 측면에서 어떻게 다른가요?',
 '세션 기반 폼 로그인은 UsernamePasswordAuthenticationFilter가 인증을 처리하고, HttpSessionSecurityContextRepository를 통해 SecurityContext를 HTTP 세션에 저장해 요청 사이에 인증을 유지하는 Stateful 방식입니다. 반면 JWT 방식은 SessionCreationPolicy.STATELESS로 세션 저장소를 쓰지 않으므로 컨텍스트를 저장하지 않고, 커스텀 JwtAuthenticationFilter가 매 요청마다 토큰을 검증해 SecurityContextHolder를 다시 채웁니다. CSRF 측면에서는 세션 방식은 쿠키가 자동 전송되기 때문에 CSRF 보호가 필요하고, JWT 방식은 헤더에 담긴 토큰이 자동 전송되지 않으므로 보통 CSRF를 비활성화합니다. 추가로 로그아웃·강제 만료는 세션 방식이 세션 무효화로 즉시 가능한 반면 JWT는 토큰 자체가 만료 전까지 유효해 블랙리스트나 짧은 만료와 리프레시 토큰으로 보완해야 하고, 수평 확장 시 세션 방식은 Redis 같은 세션 공유 저장소가 필요하지만 JWT는 서버 간 상태 공유가 필요 없습니다.'),
(603, 'SPRING_BOOT', 121, 'NORMAL', true,
 '스프링 시큐리티의 URL 기반 인가(authorizeHttpRequests)와 메서드 기반 인가(@PreAuthorize)는 어떻게 다르고, 각각 어떤 경우에 적합한가요?',
 'URL 기반 인가는 authorizeHttpRequests에서 requestMatchers(...).hasRole(...) 같은 경로 규칙을 정의하고, 필터 체인의 AuthorizationFilter가 요청 경로에 대해 이 규칙을 검사합니다. 메서드 기반 인가는 @EnableMethodSecurity로 활성화한 뒤 서비스나 컨트롤러 메서드에 @PreAuthorize를 붙이는 방식으로, AOP로 메서드 호출 시점에 적용됩니다. 그래서 URL 기반은 경로 단위의 굵은 정책에 적합하고, 메서드 기반은 예를 들어 hasRole(''ADMIN'') or #memberId == authentication.principal.id처럼 도메인 객체 소유권 같은 세밀한 규칙에 적합합니다. 주의할 점으로 requestMatchers 규칙은 위에서 아래로 첫 매칭이 적용되므로 구체적인 경로를 먼저 써야 하고, 메서드 보안은 AOP 프록시 기반이라 같은 클래스 안에서의 self-invocation에서는 무시됩니다.'),
(604, 'SPRING_BOOT', 121, 'EASY', true,
 '스프링 시큐리티에서 요청이 DelegatingFilterProxy, FilterChainProxy, SecurityFilterChain을 거치는 구조와 각 구성 요소의 역할을 설명해 주세요.',
 '스프링 시큐리티는 컨트롤러가 아니라 서블릿 필터 체인에서 인증과 인가를 처리합니다. 먼저 DelegatingFilterProxy는 서블릿 컨테이너에 등록된 표준 필터로, springSecurityFilterChain 빈에 처리를 위임해 스프링 빈을 서블릿 필터 세계로 이어 주는 다리 역할을 합니다. 위임받은 FilterChainProxy는 스프링 시큐리티의 진입점으로, 여러 SecurityFilterChain 중 securityMatcher로 요청 URL과 매칭되는 첫 번째 체인 하나만 선택해 적용합니다. SecurityFilterChain은 CsrfFilter, 인증 필터, AuthorizationFilter 같은 실제 보안 필터 목록이며, 이를 통과한 요청이 DispatcherServlet을 거쳐 컨트롤러로 갑니다. 참고로 WebSecurityConfigurerAdapter는 5.7에서 deprecated되고 6.0에서 제거되어, 지금은 SecurityFilterChain 빈을 등록하는 방식만 사용합니다.'),
(605, 'SPRING_BOOT', 121, 'EASY', true,
 '스프링 시큐리티에서 인증된 사용자 정보는 어떤 구조로 어디에 보관되며, 그 보관 방식 때문에 비동기 코드에서 주의할 점은 무엇인가요?',
 '인증 정보는 Authentication 객체에 담기는데, 여기에는 principal(사용자), credentials(비밀번호 등), authorities(권한)와 authenticated 플래그가 있습니다. 이 Authentication을 SecurityContext가 담고, SecurityContextHolder가 그 SecurityContext를 보관하는 정적 접근점 역할을 합니다. SecurityContextHolder는 기본 전략으로 ThreadLocal에 컨텍스트를 보관하며, 요청 시작 시 SecurityContextRepository에서 컨텍스트를 로드해 세팅하고 요청 종료 시 ThreadLocal 누수 방지를 위해 Holder를 비웁니다. ThreadLocal 기반이기 때문에 @Async, CompletableFuture, 별도 스레드 풀에서 실행되는 코드는 인증 정보를 볼 수 없습니다. 자식 스레드로 전파하려면 DelegatingSecurityContextExecutor나 DelegatingSecurityContextAsyncTaskExecutor로 실행기를 감싸야 합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 601
(3236, 601, '토큰이 없으면 예외를 던지지 않고 다음 필터로 통과시켜야 함을 언급', 'ESSENTIAL', 1),
(3237, 601, 'permitAll 공개 경로도 JWT 필터를 지나가므로 토큰 없음에 401을 내면 공개 API가 막힘을 설명', 'ESSENTIAL', 2),
(3238, 601, 'JWT 필터가 ExceptionTranslationFilter보다 앞이라 던진 예외가 EntryPoint로 가지 않음을 설명', 'ESSENTIAL', 3),
(3239, 601, '잘못된 토큰의 401 응답을 HandlerExceptionResolver 위임 또는 직접 응답 작성으로 처리하는 방법을 제시', 'ESSENTIAL', 4),
(3240, 601, '인증되지 않은 요청을 최종적으로 막는 것이 AuthorizationFilter임을 언급', 'SUPPLEMENTARY', 5),
(3241, 601, 'JWT 필터를 @Component로 만들면 서블릿 컨테이너에도 자동 등록돼 두 번 실행됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 602
(3242, 602, '세션 방식은 SecurityContext를 HTTP 세션에 저장해 요청 사이에 인증을 유지함을 언급', 'ESSENTIAL', 1),
(3243, 602, 'JWT 방식은 컨텍스트를 저장하지 않고 요청마다 토큰을 검증해 재구성함을 언급', 'ESSENTIAL', 2),
(3244, 602, '세션 방식에 CSRF 보호가 필요한 이유로 쿠키 자동 전송을 제시', 'ESSENTIAL', 3),
(3245, 602, 'JWT 방식에서 CSRF를 보통 비활성화하는 이유로 헤더 토큰이 자동 전송되지 않음을 제시', 'ESSENTIAL', 4),
(3246, 602, '세션은 무효화로 즉시 로그아웃되지만 JWT는 만료 전까지 유효하다는 차이를 서술', 'SUPPLEMENTARY', 5),
(3247, 602, '세션 방식은 수평 확장 시 Redis 같은 세션 공유 저장소가 필요함을 언급', 'SUPPLEMENTARY', 6),
(3248, 602, 'HttpSessionSecurityContextRepository를 세션 방식의 저장소 구현으로 제시', 'SUPPLEMENTARY', 7),

-- 질문 603
(3249, 603, 'URL 기반 인가는 필터 체인의 AuthorizationFilter에서 검사됨을 언급', 'ESSENTIAL', 1),
(3250, 603, '메서드 기반 인가는 메서드 호출에 AOP로 적용됨을 언급', 'ESSENTIAL', 2),
(3251, 603, 'URL 기반은 경로 단위의 굵은 정책에, 메서드 기반은 도메인 객체 소유권 등 세밀한 규칙에 적합함을 설명', 'ESSENTIAL', 3),
(3252, 603, 'requestMatchers 규칙은 위에서 아래로 첫 매칭이 적용되어 구체적인 경로를 먼저 써야 함을 언급', 'SUPPLEMENTARY', 4),
(3253, 603, '메서드 보안은 AOP 프록시라 self-invocation에서 무시됨을 언급', 'SUPPLEMENTARY', 5),
(3254, 603, '메서드 보안을 켜는 권장 방식으로 @EnableMethodSecurity를 제시', 'SUPPLEMENTARY', 6),

-- 질문 604
(3255, 604, 'DelegatingFilterProxy가 스프링 빈을 서블릿 필터 세계로 이어 주는 다리 역할임을 설명', 'ESSENTIAL', 1),
(3256, 604, 'FilterChainProxy가 요청과 매칭되는 첫 번째 SecurityFilterChain 하나만 적용함을 설명', 'ESSENTIAL', 2),
(3257, 604, 'SecurityFilterChain이 실제 보안 필터 목록을 담고 있음을 언급', 'ESSENTIAL', 3),
(3258, 604, 'WebSecurityConfigurerAdapter가 6.0에서 제거되어 SecurityFilterChain 빈 등록 방식을 쓴다고 언급', 'SUPPLEMENTARY', 4),
(3259, 604, '스프링 시큐리티가 컨트롤러가 아닌 서블릿 필터 체인에서 인증·인가를 처리함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 605
(3260, 605, 'Authentication이 SecurityContext에 담기고 SecurityContextHolder가 이를 보관하는 구조를 설명', 'ESSENTIAL', 1),
(3261, 605, 'SecurityContextHolder가 기본 전략으로 ThreadLocal에 컨텍스트를 보관함을 언급', 'ESSENTIAL', 2),
(3262, 605, '@Async 등 별도 스레드에서 실행되는 코드는 인증 정보를 볼 수 없음을 언급', 'ESSENTIAL', 3),
(3263, 605, 'DelegatingSecurityContextExecutor로 실행기를 감싸 자식 스레드로 전파하는 방법을 제시', 'SUPPLEMENTARY', 4),
(3264, 605, '요청 종료 시 Holder를 비워 ThreadLocal 누수를 방지함을 언급', 'SUPPLEMENTARY', 5),
(3265, 605, 'Authentication이 principal·credentials·authorities를 담는다고 언급', 'SUPPLEMENTARY', 6);
