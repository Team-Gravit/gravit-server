# [PLAN-596] 웹 로그인 환경 자동 판별과 리프레시 토큰 쿠키 발급

> 이슈: #596
> 브랜치: feat/596-web-login-cookie

## 목표
웹 로그인에서 `dest` 대신 요청의 Origin으로 redirect 호스트를 정하고, 로그인 URL에 `state`를 넣어 로그인 CSRF를 막는다.
웹 로그인의 refreshToken은 body가 아닌 HttpOnly 쿠키로 발급하고, 재발급과 로그아웃이 쿠키를 읽게 한다. 앱 로그인(`/oauth/android/**`, `/oauth/ios/apple`)은 바꾸지 않는다.

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/auth/support/RedirectHostResolver.java` - Origin, dest로 웹 redirect 호스트 판별
- `src/main/java/gravit/code/auth/service/oauth/OAuthStateService.java` - state 발급, 1회용 검증
- `src/main/java/gravit/code/auth/service/port/OAuthStateStore.java` - state 저장 포트
- `src/main/java/gravit/code/auth/infrastructure/redis/RedisOAuthStateStore.java` - state Redis 구현
- `src/main/java/gravit/code/auth/support/RefreshTokenCookieFactory.java` - refreshToken 쿠키 생성, 만료 쿠키 생성
- `src/main/java/gravit/code/auth/infrastructure/config/AuthCookieProps.java` - 환경별 쿠키 SameSite 설정
- `src/main/java/gravit/code/auth/dto/request/WebAuthCodeRequest.java` - 웹 로그인 요청 (code, state)
- `src/main/java/gravit/code/auth/dto/internal/WebLoginDto.java` - 웹 로그인 내부 전달 (code, state, origin, dest)
- `src/main/java/gravit/code/auth/dto/response/LoginUrlResponse.java` - 로그인 URL 응답 (loginUrl, state)
- `src/main/java/gravit/code/auth/dto/response/WebLoginResponse.java` - 웹 로그인 응답 (refreshToken 제외)

### 수정 파일
- `src/main/java/gravit/code/auth/controller/OAuthController.java` - Origin 헤더 수신, dest 선택값, 쿠키 발급, 응답 DTO 교체
- `src/main/java/gravit/code/auth/controller/docs/OAuthControllerDocs.java` - 위 변경 문서화
- `src/main/java/gravit/code/auth/controller/AuthTokenController.java` - 재발급 쿠키 우선, 로그아웃 추가
- `src/main/java/gravit/code/auth/controller/docs/AuthTokenControllerDocs.java` - 재발급 변경, 로그아웃 문서화
- `src/main/java/gravit/code/auth/service/oauth/OAuthLoginUrlService.java` - Origin 판별, state 포함, Apple URL 지원
- `src/main/java/gravit/code/auth/service/oauth/OAuthUserInfoService.java` - `WebLoginDto` 수신, state 검증, 호스트 판별 위임
- `src/main/java/gravit/code/auth/service/oauth/apple/AppleOAuthService.java` - 웹 로그인에 `WebLoginDto` 수신, state 검증, 호스트 판별 위임
- `src/main/java/gravit/code/auth/service/AuthTokenService.java` - 빈 토큰 검증, `logout` 추가
- `src/main/java/gravit/code/auth/service/AuthTokenProvider.java` - `deleteRefreshToken` 추가
- `src/main/java/gravit/code/auth/token/TokenStorage.java` - `deleteToken` 선언 추가
- `src/main/java/gravit/code/auth/infrastructure/redis/RedisTokenStorage.java` - `deleteToken`에 `@Override`
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - `OAUTH_STATE_INVALID` 추가, `DEST_NOT_VALID` 메시지 수정
- `src/main/java/gravit/code/security/config/SecurityConfig.java` - `/api/v1/auth/logout` permitAll
- `src/main/java/gravit/code/security/filter/JwtAuthFilter.java` - `EXCLUDE_ENDPOINTS`에 logout 추가
- `src/main/resources/application-dev.yml`, `application-prod.yml` - `auth.cookie.same-site` (dev `None`, prod `Lax`)
- `src/test/resources/application-test.yml` (있으면) - 위 설정 추가
- `src/test/java/gravit/code/auth/service/oauth/apple/AppleOAuthServiceIntegrationTest.java` - `getUserInfo` 시그니처 변경 반영
- `.claude/spec/service-policy/auth-security.md` - 웹 refreshToken 쿠키 발급, state 검증, 로그아웃 정책 추가

## 구현 계획

1. **Entity / Flyway**: 변경 없음

2. **Repository / 저장소**
   - `OAuthStateStore` (port, `auth/service/port/`)
     - `void save(String state, String provider, Duration ttl)`
     - `Optional<String> consume(String state)` - 조회와 삭제를 한 번에 (1회용)
   - `RedisOAuthStateStore implements OAuthStateStore` (`@Repository`, `RedisTemplate<String, String>`)
     - 키: `private static final String KEY_PREFIX = "oauthState:"` + state
     - `save`: `opsForValue().set(key, provider, ttl)`
     - `consume`: `opsForValue().getAndDelete(key)` (Redis 6.2 이상, local 7.0, dev/prod latest)
   - `TokenStorage`에 `<T extends Token> void deleteToken(Subject subject, Class<T> tokenClass)` 선언. `RedisTokenStorage.deleteToken`은 이미 있으므로 `@Override`만 붙인다

3. **Support**
   - `RedirectHostResolver` (`@Component`)
     - `String resolve(String origin, String dest)`
       1. `origin`이 `RedirectHostConst.DEST_BASE.values()`에 있으면 `origin`을 그대로 반환
       2. 아니면 `RedirectHostConst.DEST_BASE.get(dest)`가 있으면 그 값을 반환 (Swagger처럼 Origin이 등록되지 않은 호출용)
       3. 둘 다 없으면 `RestApiException(DEST_NOT_VALID)`
     - 보안 근거: 판별 결과는 `redirect_uri` 호스트로만 쓰인다. 값을 위조해도 인가 요청 때 쓴 `redirect_uri`와 달라 제공자가 교환을 거절하므로 위조로 얻는 이득이 없다
   - `RefreshTokenCookieFactory` (`@Component`)
     - 상수: `COOKIE_NAME = "refreshToken"` (public, Controller의 `@CookieValue`에서 참조), `COOKIE_PATH = "/api/v1/auth"`
     - `ResponseCookie create(String refreshToken)` - `httpOnly(true)`, `secure(true)`, `path(COOKIE_PATH)`, `sameSite(props.sameSite())`, `maxAge(TokenProperties.getExpireTime(RefreshToken.class))`. Domain은 지정하지 않는다(API 호스트 전용)
     - `ResponseCookie expire()` - 같은 속성, `maxAge(0)`
   - `AuthCookieProps` (`@ConfigurationProperties(prefix = "auth.cookie")`, record `(String sameSite)`)

4. **Service**
   - `OAuthStateService` (`@Service`)
     - 상수: `STATE_TTL = Duration.ofMinutes(10)`
     - `String issue(String provider)` - `UUID.randomUUID().toString()`으로 state 생성 후 `oAuthStateStore.save(state, provider, STATE_TTL)`, state 반환
     - `void verify(String provider, String state)` - state가 null이거나 비어 있으면 `OAUTH_STATE_INVALID`. `consume(state)` 결과가 비었거나 provider와 다르면 `OAUTH_STATE_INVALID`
   - `OAuthLoginUrlService`
     - `LoginUrlResponse generateLoginUrl(String provider, String origin, String dest)`로 변경
       - `validateDest` 제거, `redirectHostResolver.resolve(origin, dest)`로 대체
       - `String state = oAuthStateService.issue(validProvider)` 후 URL에 `state` 쿼리 추가
       - `LoginUrlResponse.of(loginUrl, state)` 반환
     - provider가 `apple`일 때 `generateAppleLoginUrl(baseHost, state)` 분기. `https://appleid.apple.com/auth/authorize`(상수)에 `client_id=props.clientId(AppleClient.WEB)`, `redirect_uri=baseHost + REDIRECT_PATH_PREFIX + apple`, `response_type=code`, `scope=email`, `response_mode=form_post`, `state` 포함. `Provider` enum은 web registration 조회에도 쓰이므로 apple을 넣지 않고 분기로 처리
   - `OAuthUserInfoService`
     - `OAuthUserInfo getUserInfo(String provider, WebLoginDto webLoginDto)`로 변경
       - 순서: `validateAuthCode` → provider 파싱 → `oAuthStateService.verify(validProvider, webLoginDto.state())` → `redirectHostResolver.resolve(origin, dest)` → 기존 교환, 조회
       - private `validateDest` 제거
   - `AppleOAuthService`
     - `AppleLoginDto getUserInfo(WebLoginDto webLoginDto)`로 변경
       - 순서: `validateAuthCode` → `oAuthStateService.verify(AppleUserInfo.PROVIDER, state)` → `redirectHostResolver.resolve` → 기존 `exchangeAndVerify`
       - private `validateDest` 제거. `getIosUserInfo`는 변경 없음
   - `AuthTokenService`
     - `reissue(String requestedRefreshToken)`: 맨 앞에 null 또는 빈 값이면 `TOKEN_EMPTY` 검증 추가
     - `void logout(String refreshToken)` 추가 (`@Transactional` 불필요, Redis만 다룸)
       - null 또는 빈 값이면 바로 반환
       - `authTokenProvider.deleteRefreshToken(refreshToken)` 호출. 만료나 위조로 `RestApiException`이 나면 잡아서 로그만 남기고 반환 (쿠키 만료 응답은 항상 나가야 하므로)
   - `AuthTokenProvider`
     - `void deleteRefreshToken(String refreshToken)` - `isValidRefreshToken`이 true일 때만 `tokenStorage.deleteToken(subject, RefreshToken.class)`. 저장된 값과 다른 토큰으로는 현재 세션을 지우지 못하게 한다

5. **Facade**: 불필요 - auth 단일 도메인 Service 조합

6. **DTO**
   - `WebAuthCodeRequest` (request) - `@NotNull String code`, `@NotNull String state`, 각 `@Schema`
   - `WebLoginDto` (internal) - `String code`, `String state`, `String origin`, `String dest`, `static WebLoginDto of(WebAuthCodeRequest request, String origin, String dest)`
   - `LoginUrlResponse` (response) - `String loginUrl`, `String state`, `static of(...)`. JSON 키 `loginUrl`은 기존 Map 응답과 같다
   - `WebLoginResponse` (response) - `String accessToken`, `@JsonProperty("isOnboarded") boolean isOnboarded`, `Role role`, `static WebLoginResponse from(LoginResponse loginResponse)`
   - `LoginResponse`, `AuthCodeRequest`, `RefreshTokenRequest`는 변경 없음 (앱과 iOS가 계속 사용)

7. **Controller**
   - `OAuthController`
     - `GET /api/v1/oauth/login-url/{provider}` → `authorizeUrl(provider, @RequestHeader(value = ORIGIN, required = false) String origin, @RequestParam(required = false) String dest)` → `ResponseEntity<LoginUrlResponse>`
     - `POST /api/v1/oauth/{provider}` → `oauthLogin(provider, @RequestBody @Valid WebAuthCodeRequest, origin, dest(선택))`
       - 기존 `code == null` 분기 삭제 (`@Valid`로 대체)
       - `LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo)`
       - `ResponseEntity.status(OK).header(SET_COOKIE, refreshTokenCookieFactory.create(loginResponse.refreshToken()).toString()).body(WebLoginResponse.from(loginResponse))`
     - `POST /api/v1/oauth/apple` → `appleLogin(@RequestBody @Valid WebAuthCodeRequest, origin, dest(선택))`, 응답은 위와 같다
   - `AuthTokenController`
     - `POST /api/v1/auth/reissue` → `reissueToken(@CookieValue(name = COOKIE_NAME, required = false) String cookieRefreshToken, @RequestBody(required = false) RefreshTokenRequest request)`
       - 쿠키 값이 있으면 쿠키, 없으면 body의 `refreshToken`을 `authTokenService.reissue`에 넘긴다 (선택 로직은 private 메서드 `selectRefreshToken`)
     - `POST /api/v1/auth/logout` → `logout(cookieRefreshToken, @RequestBody(required = false) RefreshTokenRequest request)`
       - `authTokenService.logout(selectRefreshToken(...))`
       - `ResponseEntity.status(NO_CONTENT).header(SET_COOKIE, refreshTokenCookieFactory.expire().toString()).build()`
       - 인증 없이 호출 가능

8. **Security**
   - `SecurityConfig`: `.requestMatchers("/api/v1/auth/logout").permitAll()` 추가
   - `JwtAuthFilter.EXCLUDE_ENDPOINTS`: `HttpEndpoint.exact("/api/v1/auth/logout", HttpMethod.POST)` 추가

9. **에러코드**
   - `OAUTH_STATE_INVALID(BAD_REQUEST, "AUTH_4011", "유효하지 않은 OAuth state 입니다.")` - `// Auth` 그룹
   - `DEST_NOT_VALID` 메시지를 `"웹 로그인 환경을 판별할 수 없습니다."`로 수정 (코드 `DEST_4001` 유지)

10. **문서, 정책**
    - `OAuthControllerDocs`: dest가 선택값이며 Origin을 우선한다는 설명, state 전달 방법, Set-Cookie 응답, `credentials: 'include'` 필요, `AUTH_4011` 예시
    - `AuthTokenControllerDocs`: 재발급의 쿠키 우선 규칙, 로그아웃 API(204, 쿠키 만료)
    - `auth-security.md`: "웹 로그인은 리프레시 토큰을 HttpOnly 쿠키로 발급하고 응답 본문에는 담지 않는다", "웹 로그인은 서버가 발급한 state가 일치해야 성립하며 state는 10분 뒤 만료되고 한 번만 쓸 수 있다", "로그아웃하면 리프레시 토큰이 무효화되고 쿠키가 지워진다" 추가

## 프론트 계약 변경 (배포 동기화 필요)
- 웹 로그인 응답에서 `refreshToken` 필드 제거. 쿠키로만 발급
- 로그인 URL 응답에 `state` 추가. 콜백 쿼리의 `state`를 로그인 요청 body에 담아 보내야 함
- 로그인, 재발급, 로그아웃 요청은 `credentials: 'include'`
- `dest` 파라미터는 보내지 않아도 됨

## 결정 필요 (Decisions needed)
- [x] 1. Apple 웹 로그인의 state - **A 확정**: `login-url/apple`을 지원해 state를 서버가 발급하고 검증한다. 프론트는 응답의 state를 Apple JS SDK init에 넣는다
- [x] 2. 쿠키 SameSite - **A 확정**: 환경별 설정. prod `Lax`, dev `None`. `AuthCookieProps`를 만들고 `application-dev.yml`, `application-prod.yml`에 `auth.cookie.same-site`를 둔다
- [x] 3. 로그아웃 인증 - **A 확정**: 인증 없이 refreshToken(쿠키 또는 body)으로 처리하고 항상 204와 만료 쿠키를 응답한다. 쿠키 전환 뒤에는 프론트가 HttpOnly 쿠키를 지울 수 없어서, accessToken이 만료된 상태에서도 서버가 쿠키를 지울 수 있어야 하기 때문이다

## 검증
- 대상 테스트
  - `RedirectHostResolverTest` (단위): 등록된 Origin은 그대로 반환, 미등록 Origin이면 dest로 판별, 둘 다 없으면 `DEST_NOT_VALID`
  - `OAuthStateServiceIntegrationTest`: 발급한 state 검증 성공, 같은 state 재사용 시 `OAUTH_STATE_INVALID`, provider 불일치 시 `OAUTH_STATE_INVALID`, 빈 state 시 `OAUTH_STATE_INVALID`
  - `AppleOAuthServiceIntegrationTest`: `WebLoginDto` 시그니처로 갱신, state 불일치 케이스 추가, 미등록 Origin+잘못된 dest 시 `DEST_NOT_VALID`
  - `AuthTokenControllerIntegrationTest`: 쿠키로 재발급 성공, 쿠키가 없으면 body로 재발급, 둘 다 없으면 `TOKEN_EMPTY`, 로그아웃 후 같은 refreshToken으로 재발급 실패, 로그아웃 응답에 `Max-Age=0` 쿠키
  - `OAuthController` 웹 로그인 응답: `Set-Cookie`에 `HttpOnly`, `Secure`, `Path=/api/v1/auth`가 있고 body에 `refreshToken`이 없음
- `./gradlew build` 통과

## Deviation Log
- `src/main/resources/application.yml`: `auth.cookie.same-site: Lax` 추가 — 이유: 이 파일은 `on-profile: local` 전용이라 값이 없으면 로컬 실행 쿠키에서 SameSite 속성이 빠진다. 로컬은 localhost끼리 same-site라 prod와 같은 `Lax`로 둔다
- `OAuthLoginUrlService`: apple 판별을 `Provider.parse` 앞의 private `parseProvider`에서 처리 — 이유: `Provider` enum에 apple이 없어 parse를 먼저 타면 `PROVIDER_INVALID`가 난다. 계획의 "enum에 넣지 않고 분기로 처리"를 지키는 위치
- `OAuthControllerDocs`, `AuthTokenControllerDocs`: Origin 헤더와 refreshToken 쿠키 파라미터에 `@Parameter(hidden = true)` — 이유: Origin은 브라우저 금지 헤더이고 쿠키는 HttpOnly라 Swagger에서 직접 넣을 수 없다. Swagger 호출은 dest와 body로 한다
- `AppleOAuthServiceIntegrationTest`: `웹_로그인(code, dest)` 헬퍼가 `OAuthStateService.issue`로 실제 state를 발급해 `WebLoginDto`를 만든다 — 이유: 시그니처 변경 뒤 기존 케이스가 state 검증을 통과해야 원래 검증 대상(교환, id_token 검증)까지 도달한다
