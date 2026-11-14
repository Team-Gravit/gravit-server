# [PLAN-632] 토큰 없는 인증 요청의 401 응답 처리

> 이슈: #632
> 브랜치: fix/632-missing-token-401

## 목표
인증이 필요한 API를 토큰 없이(또는 `Bearer ` 형식이 아닌 헤더로) 호출하면 지금은 Spring Security 기본값(`Http403ForbiddenEntryPoint`)으로 본문 없는 403이 응답된다.
다른 토큰 오류와 같이 401 `JWT_4013`(빈 토큰)과 본문으로 응답해, 클라이언트가 401 흐름(재발급, 로그아웃)을 타고 원인을 알 수 있게 한다.

## 영향 범위
### 신규 파일
- `src/test/java/gravit/code/security/config/SecurityConfigIntegrationTest.java` - 보안 필터 체인 전체를 거치는 인증 실패 응답 검증

### 수정 파일
- `src/main/java/gravit/code/security/config/SecurityConfig.java` - `exceptionHandling`에 `authenticationEntryPoint` 등록
- `src/main/java/gravit/code/security/exception/CustomAuthenticationEntryPoint.java` - `CustomAuthenticationException`이 아닌 인증 예외는 `TOKEN_EMPTY`로 응답
- `.claude/spec/service-policy/auth-security.md` - 토큰 없는 요청 응답 정책 추가 (정책 추가)

## 구현 계획
1. **Entity / Flyway**: 변경 없음
2. **Repository**: 변경 없음
3. **Security 설정**: `SecurityConfig.filterChain(HttpSecurity http)`
   - `http.exceptionHandling(exception -> exception.authenticationEntryPoint(authenticationEntryPoint).accessDeniedHandler(accessDeniedHandler));`
   - `authenticationEntryPoint`는 이미 주입받고 있으므로 필드 추가 없음
   - 흐름: 익명 사용자가 `authenticated()` 경로에 접근 -> `AuthorizationFilter`가 `AccessDeniedException` -> `ExceptionTranslationFilter`가 익명임을 보고 `InsufficientAuthenticationException`으로 entry point 호출
4. **Entry point**: `CustomAuthenticationEntryPoint.resolveErrorCode(AuthenticationException authException)`
   - `authException instanceof CustomAuthenticationException customAuthenticationException`이면 그 errorCode, 아니면 `TOKEN_EMPTY`
   - `JwtAuthFilter`가 직접 넘기는 `CustomAuthenticationException`(만료, 위조, 탈퇴 계정 등)의 응답은 바뀌지 않음
   - 강제 캐스팅을 없애 등록 후 `ClassCastException`이 나지 않게 함
5. **Facade / Service / DTO / Controller**: 변경 없음
6. **정책 문서**: `auth-security.md` 마지막 줄 아래에 추가
   - `- 인증이 필요한 API를 토큰 없이 호출하면 인증 실패(401)로 응답한다. 로그인은 했지만 권한이 없는 요청(관리자 API 등)만 접근 거부(403)로 응답한다`

### 동작 변화
- 토큰 없는 요청, `Bearer `로 시작하지 않는 Authorization 헤더: 403(본문 없음) -> 401 `JWT_4013`
- 로그인한 일반 사용자의 관리자 API 요청: 403 `A_D_403` 그대로
- `permitAll` 경로: 변경 없음

## 결정 필요 (Decisions needed)
- 없음

## 검증
- 대상 테스트: `SecurityConfigIntegrationTest` (`@TCSpringBootTest` + `@AutoConfigureMockMvc`)
  - 토큰 없이 `GET /api/v1/users` -> 401, `$.error` = `JWT_4013`
  - `Authorization: abc`(Bearer 아님)로 `GET /api/v1/users` -> 401, `$.error` = `JWT_4013`
  - `ROLE_USER` 인증으로 `GET /api/v1/admin/dashboard/summary` -> 403, `$.error` = `A_D_403` (회귀)
  - 토큰 없이 `GET /api/v1/version` -> 401이 아님 (permitAll 회귀)
- 회귀 확인: `JwtAuthFilterIntegrationTest`, `AuthTokenControllerIntegrationTest`, `AdminDashboardControllerIntegrationTest`

## Deviation Log
