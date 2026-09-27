-- Unit: 인증·인가 필터 체인 (Unit ID: 121)
-- Chapter: Spring (Chapter ID: 10)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (547, 121, '다중 체인 매칭과 ROLE 접두사'),
       (705, 121, '인가 규칙 순서와 컨텍스트 명시 저장'),
       (863, 121, '401·403 판정과 인증 제공자 역할');

-- =====================================================
-- Lesson 547: 다중 체인 매칭과 ROLE 접두사
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3461, 547, '아래 보안 설정에서 익명 사용자가 보낸 GET /api/admin/stats 요청의 처리 결과로 옳은 것은?', '두 빈은 같은 @Configuration 클래스에 등록되어 있다.

```java
@Bean
@Order(1)
public SecurityFilterChain chainA(HttpSecurity http) throws Exception {
    http.securityMatcher("/api/**")
        .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
    return http.build();
}

@Bean
@Order(2)
public SecurityFilterChain chainB(HttpSecurity http) throws Exception {
    http.securityMatcher("/api/admin/**")
        .authorizeHttpRequests(auth -> auth.anyRequest().hasRole("ADMIN"));
    return http.build();
}
```', 'OBJECTIVE'),
       (3462, 547, '아래 증상이 나타난 원인으로 옳은 것은?', '설정과 필터 구현

```java
http.addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)
    .exceptionHandling(e -> e.authenticationEntryPoint(new JsonAuthenticationEntryPoint()));

// jwtFilter는 만료된 토큰을 만나면 JwtException을 그대로 던진다.
```

만료된 토큰을 담아 GET /api/orders 를 호출한 결과

| 구분 | 응답 |
|---|---|
| 기대 | JsonAuthenticationEntryPoint가 만든 {"code":"TOKEN_EXPIRED"} JSON, 상태 코드 401 |
| 실제 | 톰캣 기본 오류 페이지(HTML), 상태 코드 500, 서버 로그에 JwtException 스택 트레이스 |', 'OBJECTIVE'),
       (3463, 547, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 항목 | 세션 기반 폼 로그인 | JWT 무상태 방식 |
|---|---|---|
| 인증 필터 | UsernamePasswordAuthenticationFilter | 직접 만든 JwtAuthenticationFilter |
| 컨텍스트 저장 | HttpSessionSecurityContextRepository(세션) | 저장하지 않고 요청마다 다시 채움 |
| CSRF | 활성화 | 보통 비활성화 |
| 강제 로그아웃 | 세션 무효화로 즉시 반영 | 만료 시각 전까지 토큰이 유효 |
| 수평 확장 | 세션 공유 저장소 필요 | 서버 간 상태 공유 불필요 |', 'OBJECTIVE'),
       (3464, 547, '아래 코드에서 두 로그의 사용자 이름이 다르게 찍힌 이유로 옳은 것은?', 'supplyAsync에 넘긴 작업은 ForkJoinPool의 다른 스레드에서 실행된다.

```java
@GetMapping("/api/orders/report")
public String report() {
    log.info("controller={}", SecurityContextHolder.getContext()
            .getAuthentication().getName());                 // controller=kim
    return CompletableFuture.supplyAsync(() -> {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        log.info("async={}", auth == null ? "null" : auth.getName());   // async=null
        return "ok";
    }).join();
}
```', 'OBJECTIVE'),
       (3465, 547, '아래 상황에서 자동 등록을 끄기 위해 별도 빈으로 선언해야 하는 스프링 부트 클래스의 이름은?', '직접 만든 인증 필터에 @Component를 붙이고, 보안 설정에서도 addFilterBefore로 체인에 넣었다. 그러자 요청 한 건마다 필터의 진입 로그가 두 줄씩 찍혔다. 확인해 보니 이 필터가 시큐리티 체인 안에서 한 번, 서블릿 컨테이너에 등록된 필터로 또 한 번, 모두 두 번 실행되고 있었다. 필터는 빈으로 그대로 두면서 컨테이너 쪽 등록만 없애야 한다.', 'SUBJECTIVE'),
       (3466, 547, '아래 코드에서 403이 사라지려면 authorities 목록에 담아야 하는 권한 문자열 값은?', '관리자 계정으로 로그인한 뒤 GET /api/admin/members 를 호출하면 인증은 통과하는데 403이 돌아온다.

```java
// UserDetailsService 구현체
return User.withUsername(member.getEmail())
        .password(member.getPassword())
        .authorities(new SimpleGrantedAuthority("ADMIN"))
        .build();

// SecurityConfig
.authorizeHttpRequests(auth -> auth
        .requestMatchers("/api/admin/**").hasRole("ADMIN")
        .anyRequest().authenticated())
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3461
(9403, 3461, '매칭되는 두 체인의 규칙이 차례로 모두 적용되어, chainB의 권한 검사에서 걸려 403이 반환된다.', '매칭되는 체인이 누적 적용된다고 본 오개념. FilterChainProxy는 여러 체인을 겹쳐 적용하지 않고 하나만 골라 그 체인의 필터만 실행한다.', false),
(9404, 3461, '경로가 더 구체적인 chainB가 선택되어, ADMIN 권한이 없는 요청이 403으로 거부된다.', '경로 길이가 긴 쪽이 우선한다고 본 오개념. 선택 기준은 경로의 구체성이 아니라 등록 순서이며, 여기서는 @Order(1)이 먼저 검사된다.', false),
(9405, 3461, 'chainA가 먼저 매칭되어 그 체인만 적용되므로, 권한 검사 없이 요청이 컨트롤러까지 전달된다.', 'FilterChainProxy는 체인을 등록 순서대로 훑어 처음 매칭된 하나만 적용한다. /api/** 를 맡은 @Order(1) 체인이 먼저 걸리므로 뒤 체인의 규칙은 검사되지 않는다.', true),
(9406, 3461, '두 securityMatcher의 경로가 겹치므로 애플리케이션 기동 시점에 설정 충돌 예외가 발생한다.', '경로 중복을 프레임워크가 막아 준다고 본 오개념. 겹쳐도 기동은 정상이며, 뒤 체인이 조용히 무시되는 탓에 발견이 늦어지는 것이 오히려 함정이다.', false),

-- 문제 3462
(9407, 3462, 'jwtFilter가 ExceptionTranslationFilter보다 앞에 있어, 거기서 던진 예외가 서블릿 컨테이너까지 그대로 전파된다.', 'ExceptionTranslationFilter는 자기보다 뒤에서 던져진 인증·인가 예외만 잡아 401/403으로 바꾼다. 앞선 필터의 예외는 EntryPoint를 타지 못해 컨테이너 기본 오류 처리로 넘어간다.', true),
(9408, 3462, '인증 실패는 accessDeniedHandler가 맡으므로, authenticationEntryPoint 대신 그것을 등록해야 한다.', '401과 403의 담당을 뒤바꾼 오개념. accessDeniedHandler는 인증은 됐지만 권한이 모자란 경우를, EntryPoint는 인증 자체가 없거나 실패한 경우를 맡는다.', false),
(9409, 3462, 'AuthorizationFilter가 인가 규칙을 검사하기 전에 만난 예외를 500 응답으로 변환해 내보낸다.', 'AuthorizationFilter에 예외 변환 역할을 잘못 부여한 오개념. 이 필터는 authorizeHttpRequests 규칙만 검사하고, 예외를 응답으로 바꾸는 일은 하지 않는다.', false),
(9410, 3462, 'EntryPoint는 폼 로그인 체인에서만 호출되므로, 무상태 토큰 방식에서는 동작하지 않는다.', 'EntryPoint를 폼 로그인 전용으로 본 오개념. 인증 방식과 무관하게 ExceptionTranslationFilter가 호출하므로, 예외만 제자리에서 던져지면 토큰 방식에서도 동작한다.', false),

-- 문제 3463
(9411, 3463, '서버를 여러 대로 늘릴 때 세션 방식은 공유 저장소를 두지 않으면, 요청이 다른 서버로 갈 때 로그인 상태가 끊긴다.', '참인 진술. 인증 상태가 특정 서버의 세션에 묶여 있어 그 서버로 가지 않은 요청은 인증을 잃는다. 그래서 Redis 같은 공유 저장소나 고정 세션이 필요하다.', false),
(9412, 3463, '탈취된 자격 증명을 즉시 무력화하기는 세션 방식이 더 쉬우며, 토큰 방식은 짧은 만료와 블랙리스트로 이를 보완한다.', '참인 진술. 세션은 서버가 보관하므로 지우면 곧바로 끊기지만, 토큰은 서명만 맞으면 유효해 만료 시각까지 살아 있다. 그 간극을 메우는 것이 블랙리스트와 리프레시 토큰이다.', false),
(9413, 3463, '헤더에 토큰을 실어 보내는 방식은 브라우저가 자동으로 붙여 주지 않아, CSRF 대응 부담이 세션 방식보다 작다.', '참인 진술. CSRF는 쿠키가 요청에 자동으로 실리는 성질을 노린 공격이라, 코드가 직접 넣어야 하는 헤더 토큰에는 같은 방식이 통하지 않는다.', false),
(9414, 3463, '토큰 방식은 컨텍스트를 저장하지 않으므로, 첫 요청에서 인증에 성공하면 이후 요청에서는 토큰 검증을 생략한다.', '거짓인 진술이라 정답. 저장하지 않는다는 것은 이어 쓸 인증이 남지 않는다는 뜻이므로, 오히려 매 요청 토큰을 검증해 컨텍스트를 새로 채워야 한다.', true),

-- 문제 3464
(9415, 3464, 'getContext()는 호출할 때마다 저장소를 새로 조회하는데, 비동기 블록은 요청 스코프 밖이라 조회가 실패한다.', '홀더를 요청 스코프 빈처럼 본 오개념. 저장소 조회는 체인 앞단에서 한 번 일어나고, 이후 getContext()는 이미 채워진 값을 꺼낼 뿐이다.', false),
(9416, 3464, '인증 정보는 요청을 처리하는 스레드의 ThreadLocal에 담겨 있어, 실행을 넘겨받은 다른 스레드에서는 조회되지 않는다.', 'SecurityContextHolder의 기본 전략이 ThreadLocal이라 값이 스레드에 묶인다. 풀 스레드로 전파하려면 DelegatingSecurityContextExecutor로 실행기를 감싸야 한다.', true),
(9417, 3464, '비동기 작업이 SecurityContextRepository의 컨텍스트 로드보다 먼저 실행되어, 아직 인증이 채워지지 않았다.', '실행 순서를 오해한 것. 컨텍스트 로드는 필터 체인 앞단에서 끝나므로 컨트롤러에 들어온 시점에는 이미 채워져 있고, 실제로 첫 로그는 kim으로 찍혔다.', false),
(9418, 3464, 'CompletableFuture는 스프링이 관리하는 프록시를 거치지 않아, 인증 정보가 주입되지 않는다.', '인증 정보가 AOP 프록시로 주입된다고 본 오개념. 인증은 주입받는 값이 아니라 홀더에서 꺼내 쓰는 값이며, 프록시 유무와는 상관이 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1110, 3465, 'FilterRegistrationBean,Filter Registration Bean,필터레지스트레이션빈,필터 레지스트레이션 빈', '@Component가 붙은 필터는 Spring Boot의 서블릿 필터 자동 등록 대상이 되어, 시큐리티 체인 안과 컨테이너 체인 밖에서 각각 한 번씩 돌게 된다. 같은 필터를 FilterRegistrationBean으로 감싸 setEnabled(false)를 지정하면 컨테이너 등록만 꺼지고 체인 안 실행은 그대로 남는다. @Component를 떼고 설정 클래스에서 new로 만들어 addFilterBefore에만 넘겨도 같은 결과다. forward·include 같은 디스패치 때문에 한 요청 안에서 필터가 여러 번 도는 문제는 원인이 달라 OncePerRequestFilter 상속으로 해결한다는 점과 구분해 두자.'),
       (1111, 3466, 'ROLE_ADMIN,"ROLE_ADMIN",ROLE_ADMIN 권한', 'hasRole("ADMIN")은 내부에서 ROLE_ 접두를 붙여 ROLE_ADMIN이라는 권한 문자열과 비교한다. 권한을 ADMIN으로만 저장하면 문자열이 어긋나 인증은 됐지만 권한이 모자란 상태가 되고, 그래서 401이 아니라 403이 나온다. 저장 값을 ROLE_ADMIN으로 바꾸거나 설정을 hasAuthority("ADMIN")으로 바꾸면 일치하는데, 두 메서드의 차이는 이 접두 처리 유무뿐이다. 인증이 아예 없을 때의 401과 권한 부족의 403을 함께 구분해 두면 좋다.');

-- =====================================================
-- Lesson 705: 인가 규칙 순서와 컨텍스트 명시 저장
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4409, 705, '아래 인가 규칙에서 kim이 보낸 요청의 처리 결과로 옳은 것은?', 'kim은 유효한 JWT로 인증되었고, 가진 권한은 ROLE_USER 하나뿐이다. kim이 GET /api/admin/members 를 호출했다.

```java
http.securityMatcher("/api/**")
    .authorizeHttpRequests(auth -> auth
        .requestMatchers("/api/**").authenticated()
        .requestMatchers("/api/admin/**").hasRole("ADMIN")
        .anyRequest().denyAll());
```', 'OBJECTIVE'),
       (4410, 705, '아래 업그레이드 뒤 나타난 증상의 원인으로 옳은 것은?', '세션 방식의 로그인 API를 컨트롤러로 직접 구현했다. 세션 생성 정책은 따로 지정하지 않았고, CSRF는 꺼 두었으며, 인증이 없으면 401을 내도록 EntryPoint를 등록했다. 스프링 시큐리티 5.7에서 6.2로 올리는 동안 아래 코드는 한 줄도 바꾸지 않았다.

```java
@PostMapping("/api/login")
public void login(@RequestBody LoginRequest req) {
    Authentication auth = authenticationManager.authenticate(
            UsernamePasswordAuthenticationToken.unauthenticated(req.email(), req.password()));
    SecurityContext context = SecurityContextHolder.createEmptyContext();
    context.setAuthentication(auth);
    SecurityContextHolder.setContext(context);
}
```

| 버전 | POST /api/login | 이어서 보낸 GET /api/me |
|---|---|---|
| 5.7 | 200 | 200, 사용자 kim |
| 6.2 | 200 | 401 |', 'OBJECTIVE'),
       (4411, 705, '아래 인가 방식에 대한 설명으로 옳은 것은?', '경로 규칙만으로는 “게시글은 작성자 본인만 수정할 수 있다”처럼 요청 대상 데이터에 따라 달라지는 규칙을 표현하기 어렵다. 이 방식은 규칙을 서비스 메서드 선언부에 붙여 두고, 메서드가 호출되는 순간 넘어온 인자와 현재 인증 정보를 비교해 실행 허용 여부를 정한다.', 'OBJECTIVE'),
       (4412, 705, '아래 증상을 없애는 수정으로 옳은 것은?', '설정에 .requestMatchers("/api/auth/**").permitAll() 이 있는데도, 로그인 전 사용자가 보낸 POST /api/auth/login 이 401로 막힌다. 유효한 토큰을 담은 GET /api/orders 는 정상적으로 200이 나온다.

```java
// addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)로 등록
@Override
protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                FilterChain chain) throws ServletException, IOException {
    String token = resolveToken(request);
    if (token == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        return;
    }
    SecurityContext context = SecurityContextHolder.createEmptyContext();
    context.setAuthentication(tokenProvider.authenticate(token));
    SecurityContextHolder.setContext(context);
    chain.doFilter(request, response);
}
```', 'OBJECTIVE'),
       (4413, 705, '아래 스택 트레이스에서 ?로 가려진 클래스의 이름은?', '스프링 부트 3 애플리케이션의 컨트롤러에서 던져진 예외의 스택 트레이스 일부다. 아래쪽 프레임일수록 먼저 호출되었다. 톰캣에 등록된 필터 이름 목록에서 가려진 클래스는 springSecurityFilterChain 이라는 이름으로 보인다.

```
java.lang.IllegalStateException: 주문 조회 실패
    at com.example.order.OrderController.list(OrderController.java:42)
    ... (DispatcherServlet 프레임 생략)
    at org.springframework.security.web.authentication.AnonymousAuthenticationFilter.doFilter(AnonymousAuthenticationFilter.java:100)
    ... (보안 필터 프레임 생략)
    at org.springframework.security.web.FilterChainProxy.doFilterInternal(FilterChainProxy.java:233)
    at org.springframework.security.web.FilterChainProxy.doFilter(FilterChainProxy.java:191)
    ... (중간 프레임 몇 줄 생략, 톰캣 프레임은 없음)
    at org.springframework.web.filter.?.doFilter(?.java:268)
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:174)
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:149)
```', 'SUBJECTIVE'),
       (4414, 705, '아래 상황에서 /api/** 체인에만 꺼 둔 보호 기능의 이름은?', '한 애플리케이션에 체인 두 개를 두었다. /admin/** 체인은 폼 로그인 뒤 세션 쿠키로 인증하고, /api/** 체인은 Authorization 헤더의 JWT로 인증한다.

| 요청 | /admin/** 체인 | /api/** 체인 |
|---|---|---|
| 인증된 GET | 200 | 200 |
| 인증된 POST | 403 | 200 |
| 인증된 POST + 서버가 폼에 심어 둔 숨은 입력값 | 200 | 200 |

/api/** 체인 설정에는 이 기능을 끄는 한 줄이 들어 있다. /admin/** 체인에도 같은 줄을 넣자 두 번째 행이 200으로 바뀌었지만, 보안 점검 담당자는 /admin/** 체인에는 그 줄을 넣으면 안 된다고 했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4409
(11931, 4409, '더 구체적인 /api/admin/** 규칙이 우선 적용되어, ADMIN 권한이 없으므로 403이 반환된다.', '경로가 좁은 규칙이 이긴다고 본 오개념. 규칙은 선언 순서대로 위에서 아래로 검사해 처음 매칭된 하나로 판정하므로, 구체적인 경로를 앞에 써야 한다.', false),
(11932, 4409, '먼저 선언된 /api/** 규칙에서 판정이 끝나, 인증 여부만 확인되고 컨트롤러까지 전달된다.', 'requestMatchers 규칙은 위에서 아래로 첫 매칭만 적용된다. /api/** 가 먼저 걸려 authenticated()로 통과하고 hasRole 규칙은 검사되지 않는다. 관리자 경로 규칙을 위로 올려야 의도대로 막힌다.', true),
(11933, 4409, '매칭되는 규칙을 모두 검사해 하나라도 거부하면 막으므로, 권한 검사에서 걸려 403이 반환된다.', '규칙이 AND로 누적된다고 본 오개념. AuthorizationFilter는 처음 매칭된 규칙 하나의 결과만 쓰고, 그 뒤 규칙은 보지 않는다.', false),
(11934, 4409, 'ROLE_USER만으로는 authenticated() 조건을 채우지 못해, 인증 실패로 분류되어 401이 반환된다.', 'authenticated()를 특정 권한 요구로 본 오개념. 이 조건은 익명이 아닌 인증 객체면 권한 종류와 상관없이 통과한다. 401은 익명 요청이 거부될 때 EntryPoint가 내는 응답이다.', false),

-- 문제 4410
(11935, 4410, '6.x부터 기본 세션 생성 정책이 STATELESS로 바뀌어, 로그인 응답에서 세션 자체가 만들어지지 않는다.', '기본 정책이 바뀌었다고 본 오개념. 6.x에서도 기본값은 필요할 때만 세션을 만드는 IF_REQUIRED이며, 5.7과 달라진 것은 정책이 아니라 컨텍스트 저장 방식이다.', false),
(11936, 4410, '6.x에서 AuthorizationFilter가 FilterSecurityInterceptor를 대체하면서, 세션에 든 인증을 인가 단계에서 읽지 않는다.', '인가 필터 교체를 컨텍스트 로드 문제로 잘못 이은 오개념. 인증을 읽어 오는 일은 체인 앞단의 SecurityContextHolderFilter 몫이고, 인가 필터는 채워진 인증으로 규칙만 검사한다.', false),
(11937, 4410, '요청이 끝날 때 SecurityContextHolder를 비우는 동작이 6.x에 새로 생겨, 세션에 넣어 둔 인증까지 지워진다.', '홀더 비우기와 세션 삭제를 같은 것으로 본 오개념. 요청 끝에 ThreadLocal을 비우는 동작은 5.x에도 있었고, 세션 저장소에 든 값은 건드리지 않는다.', false),
(11938, 4410, '6.x부터 요청 끝에 컨텍스트가 저장소에 자동 저장되지 않아, 로그인 요청에서 채운 인증이 다음 요청으로 이어지지 않는다.', '6.x의 SecurityContextHolderFilter는 컨텍스트를 읽기만 하고(requireExplicitSave 기본 true) 저장하지 않는다. 컨트롤러에서 securityContextRepository.saveContext()를 직접 불러야 세션에 남는다.', true),

-- 문제 4411
(11939, 4411, '같은 클래스의 다른 메서드가 규칙이 붙은 메서드를 this로 직접 호출하면 검사가 적용되지 않는다.', '메서드 보안은 AOP 프록시가 호출을 가로채 검사하는 구조다. 내부에서 this로 부르면 프록시를 거치지 않아(self-invocation) 규칙이 무시되므로, 검사가 필요한 메서드는 다른 빈을 통해 호출해야 한다.', true),
(11940, 4411, '규칙은 AuthorizationFilter가 요청 경로 규칙과 함께 검사하므로, DispatcherServlet에 닿기 전에 판정된다.', 'URL 기반 인가와 섞은 오개념. 필터 단계에서 검사되는 것은 authorizeHttpRequests 경로 규칙이고, 메서드에 붙인 규칙은 컨트롤러 이후 메서드 호출 시점에 AOP로 검사된다.', false),
(11941, 4411, '여기서 거부되면 필터 체인 밖에서 난 예외라 403으로 바꿀 방법이 없어, 항상 500으로 응답된다.', '변환 수단이 없다고 본 오개념. 메서드에서 던져진 AccessDeniedException은 @ControllerAdvice에서 403으로 바꿀 수 있고, 잡지 않으면 체인으로 되돌아가 ExceptionTranslationFilter가 응답으로 바꾼다.', false),
(11942, 4411, '스프링 시큐리티 6에서도 @EnableGlobalMethodSecurity를 붙여야 켜지며, @EnableMethodSecurity는 URL 규칙용이다.', '세대 변화를 거꾸로 본 오개념. 6.0부터는 @EnableMethodSecurity가 메서드 보안을 켜는 권장 방식이고 @EnableGlobalMethodSecurity는 deprecated 상태다. URL 규칙은 authorizeHttpRequests로 설정한다.', false),

-- 문제 4412
(11943, 4412, '필터를 addFilterAfter(jwtFilter, AuthorizationFilter.class)로 옮겨, permitAll 판정이 토큰 검사보다 먼저 일어나게 한다.', '인가를 먼저 하면 풀린다고 본 오개념. 인가를 통과한 뒤에도 이 필터가 토큰 없는 로그인 요청에 401을 쓰므로 그대로 막히고, 보호 경로는 인증이 채워지기 전에 판정되어 오히려 막힌다.', false),
(11944, 4412, '설정에서 authorizeHttpRequests 호출을 addFilterBefore 호출보다 앞줄에 써서, 인가 규칙이 필터보다 먼저 실행되게 한다.', 'DSL 호출 순서가 실행 순서라고 본 오개념. 체인 안 필터 순서는 정해진 순번과 addFilterBefore의 기준 필터로 정해지며, 설정 코드를 쓴 줄 순서와는 상관없다.', false),
(11945, 4412, '토큰이 없으면 응답을 쓰지 말고 chain.doFilter로 넘겨, 인증이 필요한지는 뒤의 인가 단계가 판단하게 한다.', 'permitAll 경로도 이 필터를 지나므로 여기서 401을 쓰면 공개 API까지 막힌다. 토큰이 없을 때 통과시키면 익명 인증이 채워지고, AuthorizationFilter가 경로 규칙에 따라 허용하거나 막는다.', true),
(11946, 4412, 'OncePerRequestFilter 대신 GenericFilterBean을 상속해, 한 요청에서 토큰 검사가 한 번만 일어나도록 바꾼다.', '중복 실행 문제와 혼동한 오개념. 증상은 토큰 없는 요청에 무조건 401을 쓰는 분기 때문이라 부모 클래스를 바꿔도 그대로다. 한 요청당 한 번 실행을 보장하는 쪽도 OncePerRequestFilter다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1426, 4413, 'DelegatingFilterProxy,Delegating Filter Proxy,델리게이팅필터프록시,델리게이팅 필터 프록시,딜리게이팅 필터 프록시,org.springframework.web.filter.DelegatingFilterProxy', '톰캣 같은 서블릿 컨테이너는 스프링 빈을 모르므로, 컨테이너에는 표준 서블릿 필터인 DelegatingFilterProxy가 springSecurityFilterChain이라는 이름으로 등록된다. 이 필터는 보안 검사를 직접 하지 않고, 같은 이름의 스프링 빈을 찾아 요청을 넘기는 다리 역할만 한다. 그래서 스택 트레이스에서 톰캣의 ApplicationFilterChain 바로 위에 나타나고, 그 위로 FilterChainProxy와 보안 필터들이 이어진다. FilterChainProxy는 스프링 시큐리티의 진입점으로 요청 URL에 맞는 SecurityFilterChain 하나를 고르는 쪽이고, SecurityFilterChain은 실제 보안 필터 목록이라는 점에서 서로 구분된다.'),
       (1427, 4414, 'CSRF,CSRF 보호,CSRF 방어,CSRF 방지,CSRF 토큰,CSRF 토큰 검증,XSRF,CsrfFilter,사이트 간 요청 위조,사이트간 요청 위조,크로스 사이트 요청 위조,Cross-Site Request Forgery,Cross Site Request Forgery', '세션 방식은 인증 수단인 세션 쿠키를 브라우저가 요청마다 자동으로 붙이므로, 다른 사이트가 사용자 몰래 상태를 바꾸는 요청을 보내게 하는 사이트 간 요청 위조(CSRF)에 노출된다. 그래서 CsrfFilter는 GET 같은 안전한 메서드는 통과시키고, POST처럼 상태를 바꾸는 요청에 서버가 발급해 폼에 심어 둔 CSRF 토큰이 없으면 403으로 막는다. 헤더 토큰은 코드가 직접 넣어야 해서 브라우저가 자동으로 실어 주지 않으므로 JWT 방식에서는 보통 끄지만, 세션 방식에서 끄면 방어가 사라진다. 악성 스크립트를 페이지에 주입해 실행시키는 XSS와는 공격 방식이 다르다는 점과 구분하자.');

-- =====================================================
-- Lesson 863: 401·403 판정과 인증 제공자 역할
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5357, 863, '아래 설정에서 두 요청 A·B가 받는 응답 상태 코드로 옳은 것은?', '두 요청 모두 GET /api/admin/stats 를 호출했다. jwtFilter는 토큰이 없으면 아무것도 채우지 않고 chain.doFilter로 넘기며, 토큰이 유효하면 인증 객체를 SecurityContextHolder에 채운다.

```java
http.securityMatcher("/api/**")
    .authorizeHttpRequests(auth -> auth
        .requestMatchers("/api/admin/**").hasRole("ADMIN")
        .anyRequest().authenticated())
    .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)
    .exceptionHandling(e -> e
        .authenticationEntryPoint(new JsonAuthenticationEntryPoint())   // 401 JSON
        .accessDeniedHandler(new JsonAccessDeniedHandler()));           // 403 JSON
```

| 요청 | Authorization 헤더 | 토큰에 담긴 권한 |
|---|---|---|
| A | 없음 | 없음 |
| B | 유효한 JWT | ROLE_USER |', 'OBJECTIVE'),
       (5358, 863, '아래 설정 클래스를 그대로 둔 채 스프링 시큐리티를 6.2로 올렸을 때 일어나는 일로 옳은 것은?', '스프링 시큐리티 5.8에서는 deprecated 경고만 나오고 정상 동작하던 설정이다. 빌드 파일의 버전만 6.2로 바꾸고 코드는 손대지 않았다.

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf().disable()
            .authorizeRequests()
                .anyRequest().authenticated()
            .and()
            .httpBasic();
    }
}
```', 'OBJECTIVE'),
       (5359, 863, '아래 로그에서 드러난 문제의 원인으로 옳은 것은?', '주문 이벤트 소비자는 스레드 2개짜리 풀에서 메시지를 하나씩 처리한다. 사용자 ID가 없는 시스템 메시지는 인증 없이(auth=null) 처리되어야 한다.

```java
public void onMessage(OrderEvent event) {
    if (event.userId() != null) {
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(loadAuthentication(event.userId()));
        SecurityContextHolder.setContext(context);
    }
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    log.info("event={} userId={} auth={}", event.id(), event.userId(),
             auth == null ? "null" : auth.getName());
    orderService.handle(event);
}
```

```
[consumer-1] event=101 userId=kim  auth=kim
[consumer-2] event=102 userId=lee  auth=lee
[consumer-1] event=103 userId=null auth=kim
[consumer-2] event=104 userId=null auth=lee
```', 'OBJECTIVE'),
       (5360, 863, '아래 인증 구성 요소에 대한 설명으로 옳은 것은?', '폼 로그인에서 아이디·비밀번호를 실제로 검증하는 구성 요소다. 로그인 필터가 만든 미인증 토큰은 먼저 AuthenticationManager의 구현체인 ProviderManager로 전달되고, ProviderManager는 그 토큰 종류를 지원하는 이 구성 요소에 검증을 맡긴다. 이 구성 요소는 UserDetailsService로 계정을 불러온 뒤, PasswordEncoder로 입력한 비밀번호와 저장된 값을 맞춰 본다.', 'OBJECTIVE'),
       (5361, 863, '아래 상황에서 필터에 추가로 주입한 빈의 인터페이스 이름은?', 'JWT 필터의 catch 블록이 오류 응답을 직접 쓰고 있어서, @RestControllerAdvice 쪽 오류 형식을 바꿀 때마다 필터 코드도 따로 고쳐야 했다. 이 필터는 addFilterBefore로 UsernamePasswordAuthenticationFilter 앞에 등록되어 있다.

```java
// 수정 전 JwtAuthenticationFilter의 catch 블록
} catch (JwtException e) {
    response.setStatus(401);
    response.setContentType("application/json");
    response.getWriter().write(toJson(ErrorResponse.of("TOKEN_EXPIRED")));
}

// 함께 추가해 둔 핸들러
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(JwtException.class)
    public ResponseEntity<ErrorResponse> handleJwt(JwtException e) {
        return ResponseEntity.status(401).body(ErrorResponse.of("TOKEN_EXPIRED"));
    }
}
```

필터 생성자로 빈 하나를 더 주입받고 catch 블록을 그 빈의 메서드를 호출하는 한 줄로 바꾸자, 만료 토큰 요청의 응답도 위 handleJwt가 만들게 되어 오류 형식이 한곳에서 관리되었다.', 'SUBJECTIVE'),
       (5362, 863, '아래 상황에서 설정 클래스에 추가한 어노테이션의 이름은?', '스프링 시큐리티 6.2 프로젝트다. 설정 클래스에는 처음부터 @Configuration과 @EnableWebSecurity가 붙어 있었고, URL 규칙은 /api/members/** 에 authenticated()만 걸려 있다. 회원 조회 서비스에는 아래 규칙을 달았다. principal은 id 필드를 가진 사용자 객체다.

```java
@PreAuthorize("hasRole(''ADMIN'') or #memberId == authentication.principal.id")
public MemberResponse find(Long memberId) { ... }
```

| 호출자 | 권한 | 호출 | 추가 전 응답 | 추가 후 응답 |
|---|---|---|---|---|
| kim (id=7) | ROLE_USER | find(7) | 200 | 200 |
| kim (id=7) | ROLE_USER | find(12) | 200 | 403 |
| lee (id=3) | ROLE_ADMIN | find(12) | 200 | 200 |

규칙을 달고 배포한 뒤에도 kim이 다른 회원의 정보를 그대로 조회했다. 설정 클래스에 속성 값 없이 어노테이션 하나를 추가하자 응답이 표의 오른쪽 열처럼 바뀌었고, deprecated 경고도 나오지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5357
(14459, 5357, 'A는 403, B는 403', '둘 다 권한 검사에서 AccessDeniedException이 나니 같은 처리기로 간다고 본 오개념. ExceptionTranslationFilter는 현재 인증이 익명이면 AccessDeniedHandler 대신 EntryPoint를 불러 401을 낸다.', false),
(14460, 5357, 'A는 401, B는 403', '토큰이 없는 A는 AnonymousAuthenticationFilter가 채운 익명 인증으로 AuthorizationFilter에서 거부되고, 익명이라 EntryPoint가 401을 낸다. B는 인증은 됐지만 ROLE_ADMIN이 없어 AccessDeniedHandler가 403을 낸다.', true),
(14461, 5357, 'A는 200, B는 403', 'jwtFilter가 넘겨 주면 허용된 것이라고 본 오개념. 인증 필터는 판단 없이 통과시킬 뿐이고, 인증 없는 요청을 최종적으로 막는 것은 뒤에 있는 AuthorizationFilter다.', false),
(14462, 5357, 'A는 401, B는 401', '권한 부족도 인증 실패로 본 오개념. B는 유효한 토큰으로 누구인지 확인이 끝났고 할 수 있는 일이 모자란 경우라, 401이 아니라 403이 맞다.', false),

-- 문제 5358
(14463, 5358, 'and() 연결이 제거되어 컴파일되지 않으며, 상속한 부모 클래스는 deprecated 경고만 남는다.', '두 변화의 시기를 뒤바꾼 오개념. and() 연결은 6.1에서 deprecated되어 7.0에서 제거되므로 6.2에서는 경고만 남고, 부모 클래스는 6.0에서 이미 제거되었다.', false),
(14464, 5358, '5.8과 똑같이 동작하고 deprecated 경고만 늘어나므로, 7.0 전까지는 고치지 않아도 된다.', '5.x의 deprecated 상태가 6.x에도 이어진다고 본 오개념. WebSecurityConfigurerAdapter는 6.0에서 제거되어, 이 클래스는 extends 줄부터 컴파일되지 않는다.', false),
(14465, 5358, '컴파일은 되지만 configure 메서드가 호출되지 않아, 스프링 부트의 기본 보안 설정이 대신 적용된다.', '옛 방식이 조용히 무시된다고 본 오개념. 상속할 부모 클래스 자체가 사라져 컴파일 단계에서 막히므로, 애플리케이션이 기동하는 데까지 가지 못한다.', false),
(14466, 5358, '상속한 부모 클래스가 제거되어 컴파일되지 않으므로, SecurityFilterChain을 반환하는 @Bean 메서드로 옮겨야 한다.', 'WebSecurityConfigurerAdapter는 5.7에서 deprecated되고 6.0에서 제거되었다. 6.x에서는 HttpSecurity를 받아 SecurityFilterChain을 반환하는 @Bean 메서드를 등록하고, 규칙은 .csrf(c -> c.disable())처럼 람다 DSL로 쓰는 것이 표준이다.', true),

-- 문제 5359
(14467, 5359, '작업을 마친 스레드의 ThreadLocal에 인증이 그대로 남아, 그 스레드가 다음 메시지를 처리할 때 다시 쓰였다.', 'SecurityContextHolder의 기본 전략은 ThreadLocal이라 값이 스레드에 붙어 남는다. HTTP 요청은 필터 체인이 끝에서 홀더를 비워 주지만, 체인 밖에서 직접 채운 코드는 finally에서 clearContext()로 스스로 비워야 한다.', true),
(14468, 5359, 'SecurityContextHolder는 모든 스레드가 함께 쓰는 정적 저장소라, 마지막에 넣은 인증이 어디서나 보인다.', '정적 메서드로 접근한다는 점 때문에 전역 공유로 본 오개념. 전역이라면 103에서도 직전에 넣은 lee가 보여야 하지만, 로그는 스레드마다 자신이 넣었던 사용자를 보여 준다.', false),
(14469, 5359, '풀을 DelegatingSecurityContextExecutor로 감싸지 않아, 호출한 스레드의 인증이 작업 스레드로 전파되었다.', '전파 도구의 역할을 거꾸로 본 오개념. 감싸지 않으면 오히려 아무것도 전파되지 않는다. 로그의 kim·lee는 호출한 스레드가 아니라 같은 작업 스레드가 앞서 넣어 둔 값이다.', false),
(14470, 5359, 'SecurityContextRepository가 세션에 남아 있던 직전 인증을 불러와 홀더에 다시 채웠다.', '컨텍스트 로드를 어디서나 일어나는 일로 본 오개념. 저장소에서 컨텍스트를 읽어 오는 것은 HTTP 요청의 필터 체인 앞단이고, 체인을 거치지 않는 메시지 소비자에는 세션도 없다.', false),

-- 문제 5360
(14471, 5360, '자신이 맡은 로그인 URL이 아닌 요청이 오면 검증하지 않고 다음 필터로 그대로 넘긴다.', '로그인 필터의 동작을 갖다 붙인 오개념. 이 구성 요소는 체인에 끼는 필터가 아니라 ProviderManager가 호출하는 검증기라, 요청을 다음 필터로 넘기는 일 자체가 없다.', false),
(14472, 5360, '저장된 비밀번호를 복호화해 입력값과 비교하므로, 인코더에 암호화 키를 따로 설정해야 한다.', '해시를 암호화로 본 오개념. BCrypt 같은 인코더는 되돌릴 수 없는 단방향 해시라, 입력값을 저장값의 솔트로 다시 해시해 결과가 같은지 비교한다.', false),
(14473, 5360, '검증에 성공하면 권한이 채워진 인증 객체를 만들어 돌려줄 뿐, SecurityContextHolder에 넣지는 않는다.', '본문의 구성 요소는 DaoAuthenticationProvider다. 검증을 마치면 인증된 Authentication을 ProviderManager를 거쳐 호출한 쪽에 돌려주고, 그 결과를 홀더에 넣고 저장소에 남기는 일은 인증을 요청한 필터가 맡는다.', true),
(14474, 5360, '검증에 실패하면 직접 401 응답을 써서 내보내고, 뒤에 이어질 필터 실행을 멈춘다.', '응답 작성까지 맡는다고 본 오개념. 검증기는 BadCredentialsException 같은 인증 예외를 던질 뿐이고, 이를 응답으로 바꾸는 일은 로그인 필터의 실패 처리기나 EntryPoint 쪽이 맡는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1742, 5361, 'HandlerExceptionResolver,Handler Exception Resolver,핸들러익셉션리졸버,핸들러 익셉션 리졸버,핸들러 예외 리졸버,핸들러예외리졸버,org.springframework.web.servlet.HandlerExceptionResolver', 'HandlerExceptionResolver는 DispatcherServlet이 컨트롤러에서 난 예외를 @ExceptionHandler 메서드로 보낼 때 쓰는 스프링 MVC 인터페이스다. 필터는 DispatcherServlet보다 앞에서 실행되므로 필터에서 난 예외는 @RestControllerAdvice에 저절로 닿지 않는다. 이 빈을 주입받아 catch 블록에서 resolveException(request, response, null, e)를 부르면 필터 예외도 같은 경로를 타서 handleJwt가 응답을 만든다. 스프링 부트에는 같은 타입의 빈이 둘 이상 있어 보통 @Qualifier("handlerExceptionResolver")로 골라 주입한다. ExceptionTranslationFilter와 AuthenticationEntryPoint는 자기보다 뒤에서 던져진 인증·인가 예외를 401/403으로 바꾸는 시큐리티 쪽 경로라, 그보다 앞에 선 JWT 필터의 예외는 받지 못한다는 점과 구분하자.'),
       (1743, 5362, '@EnableMethodSecurity,EnableMethodSecurity,@EnableMethodSecurity(),인에이블 메서드 시큐리티,인에이블메서드시큐리티,org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity', '@EnableMethodSecurity는 @PreAuthorize·@PostAuthorize 같은 메서드 단위 규칙을 AOP 프록시로 검사하도록 켜는 어노테이션이다. 붙이지 않으면 @PreAuthorize는 아무도 읽지 않는 표시에 그쳐 모든 호출이 통과하고, 붙이면 호출 시점에 인자(memberId)와 현재 인증을 비교해 규칙에 맞지 않으면 AccessDeniedException을 던진다. kim은 인증된 사용자라 이 예외가 401이 아닌 403으로 바뀌었다. 스프링 시큐리티 6.0부터 권장 방식이며 pre/post 검사가 기본으로 켜져 있어 속성 없이 붙이면 된다. 예전 @EnableGlobalMethodSecurity는 deprecated 상태이고 prePostEnabled = true를 따로 지정해야 @PreAuthorize가 동작한다는 점, 필터 체인을 켜는 @EnableWebSecurity와는 역할이 다르다는 점을 구분하자.');
