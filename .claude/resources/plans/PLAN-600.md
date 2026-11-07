# [PLAN-600] 웹, 앱 동시 로그인 지원

> 이슈: #600
> 브랜치: feat/600-refresh-token-session

## 목표
리프레시 토큰이 사용자당 1개(`refreshToken:{userId}`)라 한 클라이언트의 로그인이 다른 클라이언트의 세션을 끊는다.
저장 칸을 기기 종류(웹, 안드로이드, iOS)별로 나눠 웹과 앱의 동시 로그인을 허용한다. 로그아웃은 그 기기 종류의 칸만 비우고, 탈퇴는 모든 칸을 비운다. 쿠키와 요청, 응답 형식은 바꾸지 않는다.
iOS 앱의 Google, Kakao, Naver 로그인도 `IOS` 칸에 저장되도록 iOS 전용 엔드포인트와 검증 설정을 추가한다 (아래 "추가 범위 - iOS 소셜 로그인 분리").

## 방식 선택
- **기기 종류별 칸**을 쓴다. 세션 ID별 칸은 같은 종류 기기 여러 대(PC 브라우저와 폰 브라우저 등)까지 지원하지만, 사용자별 세션 목록과 상한, 만료 정리가 필요하다. 이슈의 문제(웹 로그인이 앱을 끊음)는 기기 종류별 칸으로 해결된다
- 같은 기기 종류끼리는 지금처럼 나중 로그인이 앞 로그인을 덮어쓴다. 나중에 필요해지면 세션 ID 방식으로 바꿔도 프론트 변경은 없다

## 현황 확인 결과
- 리프레시 토큰을 저장, 조회, 삭제하는 곳은 `AuthTokenProvider` 한 곳뿐이고 `TokenStorage`(구현 `RedisTokenStorage`)는 리프레시 토큰에만 쓰인다. 액세스 토큰은 저장하지 않는다
- `JwtAuthFilter`는 액세스 토큰의 서명, 만료만 확인하고 Redis를 보지 않는다. Redis의 리프레시 토큰은 재발급(`AuthTokenService.reissue`)과 로그아웃(`AuthTokenService.logout`)에서만 쓰인다
- 로그인 진입점이 기기 종류별로 나뉘어 있다. 모두 `OAuthLoginProcessor`를 거쳐 `issueLoginResponse`에서 리프레시 토큰을 발급한다
  - 웹: `OAuthController.oauthLogin` → `process`, `OAuthController.appleLogin` → `processApple`(`AppleClient.WEB`)
  - 안드로이드: `OAuthAndroidController.oauthLogin`, `oauthNaverLogin` → `process`
  - iOS: `OAuthIosController.appleLogin` → `processApple`(`AppleClient.IOS`)
- 재발급은 리프레시 토큰을 새로 발급(회전)하지 않는다. 로그인 후 14일이 지나면 재로그인이 필요하다
- 탈퇴한 사용자는 `User`의 `@SQLRestriction("deleted_at IS NULL")` 때문에 `parseUser`가 `USER_NOT_FOUND`를 던져 이미 재발급할 수 없다. 탈퇴 시 칸을 비우는 이유는 **7일 안에 복구했을 때 탈퇴 전 로그인이 되살아나지 않게 하는 것**과 Redis 정리다
- 탈퇴 확정 시 `UserDeletionService.confirmDeleteByMailAuthCode`가 `UserWithdrawnEvent`를 발행하고, `AppleTokenRevokeListener`가 AFTER_COMMIT으로 받는 선례가 있다

## Redis 저장 구조
| 키 | 값 | TTL |
|---|---|---|
| `refreshToken:{userId}:WEB` | 웹 리프레시 토큰 원문 | 14일 |
| `refreshToken:{userId}:ANDROID` | 안드로이드 리프레시 토큰 원문 | 14일 |
| `refreshToken:{userId}:IOS` | iOS 리프레시 토큰 원문 | 14일 |

- 접두사는 기존 설정 `token.refresh.storage-key-prefix`(`refreshToken:`)를 그대로 쓴다. 기존 키 `refreshToken:{userId}`와 겹치지 않는다
- 칸이 3개로 고정이라 사용자별 목록, 상한, 만료 정리가 필요 없다. 탈퇴 시에는 `LoginClient.values()`로 키 3개를 만들어 지운다
- 어느 칸인지는 리프레시 토큰의 `client` 클레임으로 판별한다. 쿠키로 왔는지 본문으로 왔는지는 기준으로 쓰지 않는다 (재발급, 로그아웃이 둘 다 받는 대체 경로라서)

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/auth/domain/LoginClient.java` — 로그인한 기기 종류 enum (`WEB`, `ANDROID`, `IOS`)
- `src/main/java/gravit/code/auth/service/port/RefreshTokenStore.java` — 기기 종류별 리프레시 토큰 저장 포트 (`OAuthStateStore`와 같은 위치, 같은 방식)
- `src/main/java/gravit/code/auth/infrastructure/redis/RedisRefreshTokenStore.java` — 위 포트의 Redis 구현 (`@Repository`)
- `src/main/java/gravit/code/auth/listener/RefreshTokenRevokeListener.java` — 탈퇴 확정 시 그 사용자의 모든 칸 삭제

### 수정 파일
- `src/main/java/gravit/code/auth/service/AuthTokenProvider.java` — 발급에 기기 종류를 받아 클레임과 저장 칸에 반영, 칸 기준 검증과 삭제, 전체 삭제 추가. `TokenStorage` 의존 제거
- `src/main/java/gravit/code/auth/token/JwtProvider.java` — 커스텀 클레임 조회 메서드 추가
- `src/main/java/gravit/code/auth/service/oauth/OAuthLoginProcessor.java` — `process`에 기기 종류 파라미터 추가, `processApple`은 `AppleClient`에서 기기 종류를 얻음
- `src/main/java/gravit/code/auth/controller/OAuthController.java` — `process` 호출에 `LoginClient.WEB` 전달
- `src/main/java/gravit/code/auth/controller/OAuthAndroidController.java` — `process` 호출 2곳에 `LoginClient.ANDROID` 전달
- `src/main/java/gravit/code/test/user/TestUserCheatCreateController.java` — `generateRefreshToken` 호출 2곳에 `LoginClient.ANDROID` 전달 (QA API는 토큰을 본문으로 주는 앱 방식이라서)
- `.claude/spec/service-policy/auth-security.md` — 기기 종류별 동시 로그인, 로그아웃 범위, 탈퇴 시 로그인 무효화 정책 추가

### 삭제 파일
- `src/main/java/gravit/code/auth/token/TokenStorage.java` — `RefreshTokenStore`로 대체. 제네릭 `Class<T>` 기반 API에 기기 종류 칸을 끼울 자리가 없고, 리프레시 토큰 외 사용처가 없다
- `src/main/java/gravit/code/auth/infrastructure/redis/RedisTokenStorage.java` — 같은 이유

### 바뀌지 않는 것
- `AuthTokenService`, `AuthTokenController`, `RefreshTokenCookieFactory`, 요청, 응답 DTO, 기존 엔드포인트의 Swagger 문서 (`OAuthIosController`와 그 Docs는 추가 범위에서 바뀐다)
- `AppleClient`와 Apple 연결 토큰 보관 로직. `AppleClient`는 Apple 연결 해제용 구분이라 그대로 두고, `LoginClient`로 바꿔 쓰는 메서드만 둔다
- yml의 `token.refresh` 설정

## 구현 계획
1. **Entity / Flyway**: 없음 (Redis만 변경)

2. **Domain**
   - `LoginClient` enum: `WEB`, `ANDROID`, `IOS`
     - `static LoginClient from(AppleClient appleClient)`: `WEB` → `WEB`, `IOS` → `IOS` (`switch` 식)
     - `static Optional<LoginClient> fromClaim(String claim)`: `null`이거나 상수명이 아니면 `Optional.empty()`

3. **Repository (Redis 포트, 구현)**
   - `RefreshTokenStore` (interface)
     - `void save(long userId, LoginClient client, String refreshToken, Duration ttl);`
     - `Optional<String> find(long userId, LoginClient client);`
     - `void delete(long userId, LoginClient client);`
     - `void deleteAll(long userId);`
   - `RedisRefreshTokenStore implements RefreshTokenStore`
     - 상수: `KEY_DELIMITER = ":"`
     - 주입: `RedisTemplate<String, String> redisTemplate`
     - `save`: `opsForValue().set(key(userId, client), refreshToken, ttl)`
     - `find`: `Optional.ofNullable(opsForValue().get(key(userId, client)))`
     - `delete`: `redisTemplate.delete(key(userId, client))`
     - `deleteAll`: `Arrays.stream(LoginClient.values()).map(client -> key(userId, client)).toList()`를 `redisTemplate.delete(Collection)`로 한 번에 삭제
     - private `key(long userId, LoginClient client)`: `TokenProperties.getStorageKeyPrefix(RefreshToken.class) + userId + KEY_DELIMITER + client.name()`

4. **Service**
   - `JwtProvider.parseClaim(String token, String claimKey)` → `String` (없으면 `null`): `extractClaims(token).get(claimKey, String.class)`. 서명, 만료 예외 처리는 기존 `handleJwtException`을 그대로 탄다
   - `AuthTokenProvider`
     - 상수 추가: `CLIENT_CLAIM_KEY = "client"`
     - 주입 변경: `TokenStorage tokenStorage` → `RefreshTokenStore refreshTokenStore`
     - `RefreshToken generateRefreshToken(User user, LoginClient client)` (시그니처 변경): `jwtProvider.generateToken(subject, Map.of(CLIENT_CLAIM_KEY, client.name()), refreshExpire)` → `refreshTokenStore.save(user.getId(), client, token, refreshExpire)` → `new RefreshToken(token)` 반환
     - `boolean isValidRefreshToken(String requestedRefreshToken)`: 주체에서 `userId`, `parseClient(token)`에서 기기 종류를 꺼낸다. 기기 종류가 없으면 `false`(결정 1). `refreshTokenStore.find(userId, client)`가 요청 토큰과 같을 때만 `true`
     - private `Optional<LoginClient> parseClient(String token)`: `LoginClient.fromClaim(jwtProvider.parseClaim(token, CLIENT_CLAIM_KEY))`
     - `void deleteRefreshToken(String refreshToken)`: 기존처럼 `isValidRefreshToken`이 거짓이면 종료 → `refreshTokenStore.delete(userId, client)`. 다른 기기 종류의 칸은 건드리지 않는다
     - `void deleteAllRefreshTokens(long userId)` 신규: `refreshTokenStore.deleteAll(userId)`
   - `OAuthLoginProcessor`
     - `LoginResponse process(OAuthUserInfo oAuthUserInfo, LoginClient client)` (파라미터 추가) → `issueLoginResponse(user, client)`
     - `LoginResponse processApple(AppleLoginDto appleLoginDto)` (시그니처 유지) → `issueLoginResponse(user, LoginClient.from(appleLoginDto.client()))`
     - private `issueLoginResponse(User user, LoginClient client)` → `authTokenProvider.generateRefreshToken(user, client)`
   - `AuthTokenService`: 변경 없음

5. **Facade**: 불필요 — 단일 Service(`AuthTokenProvider`)

6. **Listener**
   - `RefreshTokenRevokeListener.handleUserWithdrawn(UserWithdrawnEvent event)`
     - `@TransactionalEventListener(phase = AFTER_COMMIT)`. 탈퇴 커밋 뒤에 지워, 탈퇴가 롤백되면 로그인이 남게 한다
     - `authTokenProvider.deleteAllRefreshTokens(event.userId())`
     - 예외는 잡아서 `log.error`만 남긴다. 탈퇴 사용자는 이미 재발급할 수 없어 탈퇴 확정을 막을 이유가 없다. 실패하면 남은 키는 14일 TTL로 사라지지만, 그 사이 복구하면 옛 로그인이 살아날 수 있다는 점은 감수한다

7. **DTO**: 변경 없음

8. **Controller**
   - `POST /api/v1/oauth/{provider}` → `OAuthController.oauthLogin`: `oAuthLoginProcessor.process(userInfo, LoginClient.WEB)`
   - 안드로이드 로그인 2개(`OAuthAndroidController.oauthLogin`, `oauthNaverLogin`): `oAuthLoginProcessor.process(userInfo, LoginClient.ANDROID)`
   - Apple 웹, iOS 로그인: 변경 없음 (`AppleLoginDto.client()`로 판별)
   - 요청, 응답 형식은 모두 그대로

9. **정책 문서** `auth-security.md`
   - 추가: "웹, 안드로이드, iOS에 동시에 로그인할 수 있다. 같은 종류 기기에서 다시 로그인하면 그 종류의 이전 로그인은 끊긴다"
   - 수정: 로그아웃 항목에 "로그아웃은 그 기기 종류의 로그인만 끊고 다른 종류의 로그인은 유지한다"
   - 추가: "탈퇴를 확정하면 그 계정의 모든 로그인이 끊긴다. 복구해도 탈퇴 전 로그인은 되살아나지 않는다"

## 추가 범위 - iOS 소셜 로그인 분리
> #602로 발의했다가 #600에 합친 범위. 위 1~9는 구현이 끝났고, 이 절은 그 위에 더한다.

### 배경과 현황
- iOS 앱(웹뷰, 서버 호출은 `apps/web`)은 Google, Kakao, Naver 로그인에 안드로이드 엔드포인트(`/api/v1/oauth/android?provider=`, `/android/naver`)를 호출하고, 세 가지 모두 성공한 상태다. 그래서 iOS 로그인이 `ANDROID` 칸에 저장되어 안드로이드와 iOS가 서로의 로그인을 끊는다
- 안드로이드에만 해당하는 건 컨트롤러의 경로와 `LoginClient.ANDROID`뿐이다. `OAuthAndroidUserInfoService`, `NaverAndroidUserInfoService`, `AndroidUserInfoFactory`, `dto/oauth/android/*`는 이름만 android이고 동작은 플랫폼과 무관하다
- idToken 검증은 `OAuthAndroidUserInfoService`가 `OAuthAndroidProps`(`oauth.android.*`)의 issuer와 client-id로 한다. client-id 실제 값은 플랫폼 공용이다
  - Google: `GOOGLE_CLIENT_ID`(웹 client ID). 안드로이드, iOS 앱 모두 `webClientId`를 넘겨 aud가 이 값이다
  - Kakao: `KAKAO_NATIVE_APP_KEY`. 카카오 앱 하나에 하나라 플랫폼 공용이다
  - Naver: accessToken으로 사용자 정보를 직접 조회해 aud 검증이 없다. 설정이 필요 없다
- `OidcConfig`(`jwtDecoderMap`)는 `@Profile("!test")`라 테스트 컨텍스트에서는 디코더가 없다. `application-test.yml`에는 `oauth.android` 블록이 없다
- `SecurityConfig`가 `/api/v1/oauth/**`를 `permitAll`로 열어 두어 보안 설정 변경은 없다. 웹의 `POST /api/v1/oauth/{provider}`와 경로가 겹쳐 보이지만, 리터럴 경로 `/api/v1/oauth/ios`가 더 구체적이라 우선한다 (`/android`와 같은 구조)

### 방식
- **엔드포인트만 분리하고 Service는 공유한다.** iOS 컨트롤러가 기존 두 Service를 호출하고 `LoginClient.IOS`를 넘긴다
- **검증 설정은 iOS용 키(`oauth.ios.*`)로 분리한다.** 나중에 iOS 값이 달라져도 안드로이드 설정을 건드리지 않게 하려는 것이다
- **GitHub 시크릿은 새로 만들지 않는다.** CD 워크플로에서 `oauth.ios.*`에 기존 `GOOGLE_CLIENT_ID`, `KAKAO_NATIVE_APP_KEY`를 주입한다. 값이 실제로 달라질 때 새 시크릿을 만들고 워크플로 한 줄만 바꾼다
- **iOS 설정은 안드로이드와 같은 구조(issuer, client-id)로 둔다.** issuer는 제공자가 정하는 고정값이라 분리할 필요는 없지만, 두 Props가 같은 인터페이스로 검증 값을 내주게 하려고 구조를 맞춘다
- **안드로이드 경로는 바꾸지 않는다.** `OAuthAndroidController`, `OAuthAndroidUserInfoService.parseIdToken(String, String)` 시그니처, `oauth.android.*` 키, 기존 워크플로 주입 줄은 그대로 둔다

### 영향 범위
#### 신규 파일
- `src/main/java/gravit/code/auth/infrastructure/config/OAuthIdTokenProps.java` — idToken 검증 값(issuer, client-id)을 provider별로 내주는 인터페이스. `OAuthAndroidProps`, `OAuthIosProps`가 구현
- `src/main/java/gravit/code/auth/infrastructure/config/OAuthIosProps.java` — `oauth.ios` 설정 record
- `src/test/java/gravit/code/auth/service/oauth/android/OAuthAndroidUserInfoServiceIntegrationTest.java` — 기기 종류별로 다른 client-id로 aud를 검증하는지 확인

#### 수정 파일
- `src/main/java/gravit/code/auth/infrastructure/config/OAuthAndroidProps.java` — `implements OAuthIdTokenProps`만 추가. 필드와 메서드 동작은 그대로
- `src/main/java/gravit/code/auth/service/oauth/android/OAuthAndroidUserInfoService.java` — `parseIosIdToken` 추가, 검증 흐름을 Props를 받는 private 메서드로 옮김
- `src/main/java/gravit/code/auth/controller/OAuthIosController.java` — Google, Kakao, Naver 로그인 엔드포인트 2개 추가
- `src/main/java/gravit/code/auth/controller/docs/OAuthIosControllerDocs.java` — 위 2개 엔드포인트 문서 추가
- `src/main/resources/application.yml`, `application-dev.yml`, `application-prod.yml` — `oauth.ios` 블록 추가
- `src/test/resources/application-test.yml` — `oauth.android`, `oauth.ios` 블록 추가 (서로 다른 더미 client-id)
- `.github/workflows/cd-dev.yml`, `.github/workflows/cd-prod.yml` — `oauth.ios.google.client-id`, `oauth.ios.kakao.client-id` 주입 2줄씩 추가
- `src/test/java/gravit/code/auth/controller/OAuthIosControllerIntegrationTest.java` — iOS 소셜 로그인 시나리오 추가
- `.claude/spec/service-policy/auth-security.md` — 앱 로그인 전달 방식 문장을 안드로이드, iOS 공통으로 수정
- `.claude/spec/secret-convention.md` — `GOOGLE_CLIENT_ID`, `KAKAO_NATIVE_APP_KEY`를 안드로이드, iOS 검증 설정이 함께 참조한다는 점과 분리 시점 기록

### 구현 계획
1. **Entity / Flyway**: 없음

2. **설정 (Props)**
   - `OAuthIdTokenProps` (interface)
     - `String getIssuer(String provider);`
     - `String getClientId(String provider);`
   - `OAuthAndroidProps`: 선언부에 `implements OAuthIdTokenProps` 추가. 기존 `getIssuer`, `getClientId`가 그대로 구현이 된다
   - `OAuthIosProps` (`@ConfigurationProperties(prefix = "oauth.ios")`, `implements OAuthIdTokenProps`)
     - 구성: `Google google`, `Kakao kakao`. 중첩 record `Google(String issuer, String clientId)`, `Kakao(String issuer, String clientId)`. 안드로이드 record를 재사용하지 않고 따로 둔다 (한쪽 구조를 바꿔도 다른 쪽에 번지지 않게)
     - `getIssuer`, `getClientId`: `OAuthAndroidProps`와 같은 `switch (provider.toLowerCase())`, 그 외는 `PROVIDER_INVALID`
     - 기동 검증 (결정 2): 클래스에 `@Validated`, 필드 `@Valid @NotNull Google google`, `@Valid @NotNull Kakao kakao`, 중첩 record 필드 `@NotBlank String issuer`, `@NotBlank String clientId`
   - `@ConfigurationPropertiesScan`이 있어 등록 설정은 필요 없다

3. **Service** `OAuthAndroidUserInfoService`
   - 주입 추가: `OAuthIosProps iosProps` (기존 `OAuthAndroidProps androidProps` 옆, 같은 설정 묶음)
   - `OAuthUserInfo parseIdToken(String provider, String idToken)` (시그니처 유지): `return parseIdToken(provider, idToken, androidProps);`
   - `OAuthUserInfo parseIosIdToken(String provider, String idToken)` 신규: `return parseIdToken(provider, idToken, iosProps);`. `AppleOAuthService.getUserInfo` / `getIosUserInfo`와 같은 이름 짓기
   - private `OAuthUserInfo parseIdToken(String provider, String idToken, OAuthIdTokenProps props)`: 기존 public 본문을 옮긴다. 순서(빈 토큰 검사 → 디코더 선택 → 디코딩 → issuer 검증 → aud 검증 → `AndroidUserInfoFactory.fromClaims`)와 에러코드는 그대로
   - private `validateIssuer(Jwt jwt, String provider, OAuthIdTokenProps props)`, `validateAudience(Jwt jwt, String provider, OAuthIdTokenProps props)`: `androidProps` 대신 인자로 받은 `props`를 쓴다. 로그 문구는 그대로
   - `NaverAndroidUserInfoService`: 변경 없음 (설정을 쓰지 않음)

4. **Facade**: 불필요 — 단일 Service 위임

5. **DTO**: 변경 없음. 기존 `IdTokenRequest`, `AccessTokenRequest`(`dto/oauth/android`)를 그대로 쓴다

6. **Controller** `OAuthIosController` (`/api/v1/oauth/ios`)
   - 주입 추가: `OAuthAndroidUserInfoService oAuthAndroidUserInfoService`, `NaverAndroidUserInfoService naverAndroidUserInfoService` (기존 `AppleOAuthService`, `OAuthLoginProcessor`와 같은 Service 묶음)
   - `POST /api/v1/oauth/ios?provider={google|kakao}` → `ResponseEntity<LoginResponse> oauthLogin(@RequestParam("provider") String provider, @RequestBody IdTokenRequest request)`
     - `oAuthAndroidUserInfoService.parseIosIdToken(provider, request.idToken())` → `oAuthLoginProcessor.process(userInfo, LoginClient.IOS)` → `status(OK).body(...)`
   - `POST /api/v1/oauth/ios/naver` → `ResponseEntity<LoginResponse> oauthNaverLogin(@RequestBody @Valid AccessTokenRequest request)`
     - `naverAndroidUserInfoService.getUserInfo(request.accessToken())` → `oAuthLoginProcessor.process(userInfo, LoginClient.IOS)` → `status(OK).body(...)`
   - 요청, 응답 형식은 안드로이드 엔드포인트와 같다 (리프레시 토큰은 응답 본문)
   - `OAuthIosControllerDocs`: `@Tag`는 그대로 두고 메서드 2개 추가. summary, 응답 예시(400 `PROVIDER_INVALID`, `OAUTH_ID_TOKEN_INVALID`, `FAIL_DECODE_ID_TOKEN_TO_JWT`, `ISSUER_NOT_MATCHING`, `AUDIENCE_IS_EMPTY`, `AUDIENCE_NOT_MATCHING` / Naver는 `OAUTH_ACCESS_TOKEN_INVALID`, `OAUTH_USER_INFO_INVALID`, 502, 500 `GLOBAL_5001`)는 `OAuthAndroidControllerDocs`의 같은 메서드를 따르고, description의 "Android"를 "iOS 앱"으로 바꾼다. Google은 `webClientId`로 발급한 idToken을 보내야 한다는 점을 description에 적는다

7. **설정 파일**
   - `application.yml` (로컬): `oauth.android` 아래에 `oauth.ios.google.issuer: https://accounts.google.com`, `client-id`는 안드로이드와 같은 웹 client ID, `oauth.ios.kakao.issuer: https://kauth.kakao.com`, `client-id`는 안드로이드와 같은 앱 키
   - `application-dev.yml`, `application-prod.yml`: `oauth.ios.google.client-id: ${GOOGLE_CLIENT_ID}`, `oauth.ios.kakao.client-id: ${KAKAO_NATIVE_APP_KEY}`, issuer는 안드로이드와 같은 상수
   - `application-test.yml`: `oauth.android`와 `oauth.ios`를 추가하고 client-id를 서로 다른 더미로 둔다 (`test-android-google-client-id`, `test-ios-google-client-id` 등). 검증 설정이 기기 종류별로 갈리는지 테스트로 확인하기 위함
   - `cd-dev.yml`, `cd-prod.yml`: 기존 `oauth.android.*` 두 줄 아래에 `oauth.ios.google.client-id: ${{ secrets.GOOGLE_CLIENT_ID }}`, `oauth.ios.kakao.client-id: ${{ secrets.KAKAO_NATIVE_APP_KEY }}`

8. **정책, 운영 문서**
   - `auth-security.md`: "안드로이드 로그인은 Google, Kakao는 id_token을, Naver는 액세스 토큰을 서버에 전달한다" → "앱 로그인(안드로이드, iOS)은 Google, Kakao는 id_token을, Naver는 액세스 토큰을 서버에 전달한다. 안드로이드와 iOS는 로그인 경로가 나뉘어 있어 같은 제공자로 로그인해도 서로 다른 기기 종류로 구분된다"
   - `secret-convention.md`: `GOOGLE_CLIENT_ID`, `KAKAO_NATIVE_APP_KEY`는 `oauth.android.*`와 `oauth.ios.*`에 함께 주입한다. iOS 값이 달라지면 iOS용 시크릿을 새로 만들고 `oauth.ios.*` 주입 줄만 바꾼다

### 배포 순서
- 서버 먼저: 새 엔드포인트는 추가뿐이라 기존 호출(iOS의 안드로이드 엔드포인트 사용 포함)은 그대로 동작한다
- 웹 다음: `apps/web`이 `APP_INFO` 브릿지로 iOS를 판별해 `/api/v1/oauth/ios` 계열을 호출하게 바꾼다. 앱 재배포는 필요 없다
- iOS 앱이 출시 전이라 `ANDROID` 칸에 남은 iOS 세션을 옮길 필요가 없다

### 검증
- `OAuthIosControllerIntegrationTest` 추가 시나리오 (`OAuthAndroidUserInfoService`, `NaverAndroidUserInfoService`는 `@MockitoBean`으로 대체, 외부 연동 대체 용도)
  - iOS 구글 로그인에 성공하면 토큰이 발급되고 리프레시 토큰이 `IOS` 칸에 저장되며 `ANDROID` 칸은 비어 있다
  - iOS 네이버 로그인에 성공하면 리프레시 토큰이 `IOS` 칸에 저장된다
  - iOS 로그인은 `parseIosIdToken`을 호출하고 `parseIdToken`(안드로이드)은 호출하지 않는다
  - idToken 검증에 실패하면 회원가입도 토큰 발급도 되지 않는다 (errorCode 검증)
  - 같은 사용자가 안드로이드와 iOS로 각각 로그인하면 두 리프레시 토큰이 모두 유효하다
- `OAuthAndroidUserInfoServiceIntegrationTest` 신규 (`@MockitoBean(name = "google") JwtDecoder`로 JWKS 조회를 대체. 테스트 컨텍스트에는 `jwtDecoderMap`이 없어 빈 이름 `google`이 맵 키가 된다)
  - iOS client-id를 aud로 가진 idToken은 `parseIosIdToken`을 통과하고 `parseIdToken`에서는 `AUDIENCE_NOT_MATCHING`
  - 안드로이드 client-id를 aud로 가진 idToken은 그 반대
  - issuer가 다르면 `ISSUER_NOT_MATCHING`
- 결정 2의 기동 검증: `oauth.ios` 값이 비면 컨텍스트가 뜨지 않는지 확인 (`ApplicationContextRunner`로 Props만 바인딩)
- 기존 `OAuthAndroidControllerIntegrationTest`가 수정 없이 통과해야 한다

## 결정 필요 (Decisions needed)
- [x] **결정 2 - `oauth.ios.*` 기동 검증 방식** — **A로 확정: `@Validated` + 필드 `@NotBlank`, 중첩 record에 `@Valid @NotNull`** / (기각) B: `AppleClientSecretGenerator`처럼 생성 시점에 직접 검사하고 `RestApiException`(새 에러코드 `OAUTH_CONFIG_INVALID`)을 던짐
  - A 근거: Spring 표준 설정 검증이라 실패 시 어떤 키가 비었는지 바인딩 오류에 그대로 나오고, 에러코드를 추가하지 않는다. 프로젝트 첫 Props 검증 선례가 된다
  - B 기각 이유: 설정 오류에 API 에러코드를 쓰게 되고, 키마다 검사 코드를 손으로 써야 한다
  - 적용 범위는 `OAuthIosProps`만이다. `OAuthAndroidProps`에는 넣지 않는다 (안드로이드 경로는 바꾸지 않는다는 방식에 따라)
- [x] **결정 1 - 배포 시점에 이미 발급된 토큰(`client` 클레임 없음) 처리** — **A로 확정: 배포 즉시 무효화, 전원 재로그인**. 클레임 없는 토큰은 `isValidRefreshToken`이 `false`를 돌려준다. 이 사실은 정책이 아니라 PR에 남긴다 / (기각) B: 14일 호환 기간 동안 클레임 없는 토큰은 기존 키 `refreshToken:{userId}`로 검증
  - A 근거: 재발급이 리프레시 토큰을 연장하지 않아 사용자는 이미 최대 14일마다 재로그인한다. A는 그 시점을 한 번 앞당기는 것이고, 액세스 토큰(최대 2시간)이 만료될 때 재로그인한다. 기존 키는 TTL로 자연 만료되어 정리 작업이 없다
  - B 비용: 검증, 로그아웃, 탈퇴 삭제 세 곳에 기존 키 분기가 들어가고, 14일 뒤 제거 작업이 하나 더 생긴다

## 검증
- 기존 테스트 수정 (시그니처와 Redis 키 형식이 바뀌어 깨진다)
  - `AuthTokenControllerIntegrationTest`: `setUp`의 `generateRefreshToken(user)` → 기기 종류 추가. `저장된_토큰()` 헬퍼가 `refreshToken:{userId}`를 읽는다 → `refreshToken:{userId}:{client}`로 변경. `저장되지_않은_토큰()`은 `client` 클레임을 넣어 만들어야 "저장된 값과 다른 토큰" 시나리오가 유지된다
  - `OAuthControllerIntegrationTest`: 저장 여부를 확인하는 헬퍼를 `refreshToken:{userId}:WEB` 기준으로 변경
- `AuthTokenProviderIntegrationTest` 추가 시나리오
  - 웹과 안드로이드로 각각 발급하면 두 토큰 모두 유효하다 (동시 로그인)
  - 같은 기기 종류로 두 번 발급하면 먼저 발급한 토큰은 무효가 된다
  - 웹 토큰을 삭제해도 안드로이드 토큰은 유효하다
  - 전체 삭제하면 모든 기기 종류의 토큰이 무효가 된다
  - `client` 클레임이 없는 토큰은 유효하지 않다 (결정 1)
- `AuthTokenControllerIntegrationTest` 추가 시나리오
  - 웹 쿠키로 로그아웃해도 앱 토큰(본문)으로는 계속 재발급된다
- `OAuthLoginProcessorIntegrationTest` 추가 시나리오
  - Apple iOS 로그인은 `IOS` 칸에, Apple 웹 로그인은 `WEB` 칸에 저장된다
- `RefreshTokenRevokeListenerIntegrationTest` 신규 (`AppleTokenRevokeListenerIntegrationTest` 형식)
  - 탈퇴 이벤트를 받으면 그 사용자의 세 칸이 모두 지워진다
  - 다른 사용자의 칸은 남는다

## Deviation Log
- `AuthTokenProvider`: private `parseUserId(String token)` 추가 — 이유: `isValidRefreshToken`과 `deleteRefreshToken`이 모두 주체에서 `long userId`를 꺼내야 해서 같은 변환을 한곳에 모음
- `OAuthIosControllerDocs`: iOS 소셜 로그인 2개 엔드포인트의 400 응답 예시를 하나의 `@ApiResponse(responseCode = "400")` 안에 `examples`로 묶음 (안드로이드 Docs는 400을 예시마다 따로 선언) — 이유: 같은 파일의 Apple 로그인 문서가 이 형식이고, springdoc은 같은 상태 코드의 `@ApiResponse`를 여러 개 선언하면 마지막 것만 남겨 앞의 예시가 문서에서 사라진다
- 앱 로그인 공용 클래스 이름과 패키지를 android에서 app으로 변경 (사용자 요청) — `service/oauth/android/OAuthAndroidUserInfoService` → `service/oauth/app/OAuthAppUserInfoService`, `NaverAndroidUserInfoService` → `NaverAppUserInfoService`, `strategy/android/AndroidUserInfoFactory` → `strategy/app/AppUserInfoFactory`, `dto/oauth/android/*` → `dto/oauth/app/*`(`GoogleAndroidUserInfo` → `GoogleAppUserInfo`, `KakaoAndroidUserInfo` → `KakaoAppUserInfo`, `IdTokenRequest`, `AccessTokenRequest`는 이름 유지), 테스트 `NaverAppUserInfoServiceIntegrationTest`, `AppUserInfoFactoryIntegrationTest`도 같은 패키지로 이동. `OAuthAndroidProps`는 안드로이드 전용 설정이라 유지 — 이유: 안드로이드와 iOS가 함께 쓰는 클래스인데 이름이 android라 `OAuthIosController`가 Android Service를 주입하는 모양이 됨. 클라이언트 계약(경로, JSON)은 바뀌지 않음. 계획서 본문의 옛 이름은 이 항목으로 대체한다
- `OAuthAppUserInfoService.parseIdToken(String, String)` → `parseAndroidIdToken(String, String)` (사용자 요청) — 이유: 클래스 이름이 플랫폼 중립이 되면서 안드로이드 설정으로 검증하는 메서드가 공용처럼 읽혀, `parseIosIdToken`과 짝을 맞춤. 호출부는 `OAuthAndroidController.oauthLogin` 한 곳
