# [PLAN-582] iOS 앱 Apple 로그인 추가

> 이슈: #582
> 브랜치: feat/582-apple-ios-login

## 목표
iOS 앱(React Native)이 네이티브 Sign in with Apple 모듈로 받은 인가 코드를 서버가 Apple과 교환하고 id_token을 검증해, 웹과 같은 Apple 계정(`sub`)으로 로그인하게 한다.
Apple 토큰을 보관할 때 어느 클라이언트(웹 Services ID, iOS Bundle ID)로 발급받았는지 함께 저장해, 탈퇴 시 같은 client_id로 철회한다. #580 리뷰 수정 2건(인가 코드 디코딩 제거, 실제 삭제 시 토큰 조회 실패 격리)은 작업 트리에 반영되어 있으며 이 작업과 함께 커밋한다.

## 참고: moyeo-server 방식과 우리 방식
RN 개발자가 함께 작업한 moyeo-server(`Central-MakeUs/moyeo-server`)의 Apple 네이티브 로그인은 다음과 같다.

| 항목 | moyeo-server | 우리(이 계획) |
|---|---|---|
| 엔드포인트 | `POST /api/auth/apple/native` body `{identityToken, authorizationCode, nonce}` | `POST /api/v1/oauth/ios/apple` body `{code}` (결정 1, 2) |
| 클라이언트 식별 | 웹 Services ID와 네이티브 App ID(Bundle ID)를 각각 설정, 네이티브는 `APPLE_NATIVE_ENABLED` 플래그로 on/off | `oauth.apple.ios-bundle-id` 추가. 플래그 없음(값이 비면 기동 실패, #580의 fail-fast 결정 유지) |
| 검증 | SDK identityToken을 JWKS로 검증 + 인가 코드 교환으로 받은 id_token도 검증 → 두 `sub` 일치 확인, nonce 원문 일치 확인 | 인가 코드 교환으로 받은 id_token만 검증(iss, aud=Bundle ID, 서명/만료). 클라이언트가 보낸 토큰은 받지 않는다. nonce는 결정 2 |
| 토큰 교환 | native는 `redirect_uri` 없이 `client_id=App ID`, `client_secret`의 `sub=App ID` | 동일 |
| refresh_token 보관 | `social_accounts.provider_refresh_token_ciphertext` + `apple_refresh_token_client(WEB/NATIVE)`, AES-GCM AAD에 `sub` 바인딩 | `apple_credential`에 `client(WEB/IOS)` 컬럼 추가. 암호화는 기존 `AppleTokenCipher` 유지 |
| 탈퇴 철회 | 저장된 client에 맞는 client_id, client_secret으로 `/auth/revoke`. 실패하면 탈퇴 자체를 503으로 거부 | 저장된 client로 철회. 실패해도 탈퇴는 확정하고 실제 삭제 때 재시도(#580 정책 유지) |
| 네이티브 refresh_token 누락 | 503으로 로그인 거부 | 경고 로그만 남기고 로그인 진행(#580과 동일) |

클라이언트 쪽 전제: RN 라이브러리(`@invertase/react-native-apple-authentication`)는 `performRequest` 응답으로 `authorizationCode`, `identityToken`, `nonce`, `user`를 준다. 우리는 `authorizationCode`만 받는다. 앱은 `requestedScopes`에 `EMAIL`을 포함해야 한다(id_token에 email이 없으면 `OAUTH_USER_INFO_INVALID`로 거부, 웹과 동일).

Apple Developer 쪽 전제: 앱의 App ID(Bundle ID)에 Sign in with Apple capability를 켜고, 기존 웹 Services ID가 이 App ID를 primary로 그룹핑하고 있어야 같은 `sub`가 나온다. 키(.p8), Team ID는 그대로 쓴다.

## 영향 범위
### 신규 파일
- `src/main/resources/db/migration/V49__add_client_to_apple_credential.sql` - `apple_credential.client` 컬럼
- `src/main/java/gravit/code/auth/domain/AppleClient.java` - Apple 토큰을 발급한 클라이언트 enum (`WEB`, `IOS`)
- `src/main/java/gravit/code/auth/dto/internal/AppleStoredTokenDto.java` - 복호화한 refresh_token + 발급 client
- `src/main/java/gravit/code/auth/controller/OAuthIosController.java` - `POST /api/v1/oauth/ios/apple`
- `src/main/java/gravit/code/auth/controller/docs/OAuthIosControllerDocs.java` - Swagger 문서

### 수정 파일
- `src/main/java/gravit/code/auth/infrastructure/config/AppleOAuthProps.java` - `iosBundleId` 추가, `clientId(AppleClient)` 조회 메서드
- `src/main/java/gravit/code/auth/support/AppleClientSecretGenerator.java` - `generate(AppleClient)`로 client별 `sub` 서명
- `src/main/java/gravit/code/auth/service/oauth/apple/AppleOAuthService.java` - iOS 인가 코드 교환 `getIosUserInfo`, 공통 검증부 분리, `revokeRefreshToken(token, client)`
- `src/main/java/gravit/code/auth/dto/internal/AppleLoginDto.java` - `client` 필드 추가
- `src/main/java/gravit/code/auth/domain/AppleCredential.java` - `client` 필드, 생성/갱신 시그니처
- `src/main/java/gravit/code/auth/service/oauth/apple/AppleCredentialService.java` - `save(userId, token, client)`, `findRefreshToken`이 `AppleStoredTokenDto` 반환
- `src/main/java/gravit/code/auth/service/oauth/OAuthLoginProcessor.java` - `processApple`에서 client 전달
- `src/main/java/gravit/code/auth/listener/AppleTokenRevokeListener.java` - 저장된 client로 철회
- `src/main/java/gravit/code/user/facade/UserDeletionFacade.java` - 저장된 client로 철회 (조회 실패 격리는 반영 완료, 작업 트리)
- `src/main/java/gravit/code/auth/service/oauth/apple/AppleOAuthService.java` - 인가 코드 URL 디코딩 제거 (반영 완료, 작업 트리)
- `src/main/resources/application-dev.yml`, `application-prod.yml` - `oauth.apple.ios-bundle-id: ${APPLE_IOS_BUNDLE_ID}`
- `src/test/resources/application-test.yml` - `oauth.apple.ios-bundle-id` 더미 값
- `.github/workflows/cd-dev.yml`, `cd-prod.yml` - `oauth.apple.ios-bundle-id: ${{ secrets.APPLE_IOS_BUNDLE_ID }}` 주입
- `.claude/spec/secret-convention.md` - Apple 공유 시크릿 목록에 `APPLE_IOS_BUNDLE_ID` 추가
- `.claude/spec/service-policy/auth-security.md` - 정책 변경: Apple 로그인을 iOS 앱에서도 지원, 발급 클라이언트 보관
- `.claude/spec/service-policy/user.md` - 정책 변경: 탈퇴 시 연결 해제는 토큰을 발급한 클라이언트 기준

## 구현 계획

### 1. Flyway - `V49__add_client_to_apple_credential.sql`
```sql
-- V49__add_client_to_apple_credential.sql

-- Apple refresh_token을 발급한 클라이언트. 철회 때 같은 client_id를 써야 하므로 보관한다. 기존 행은 모두 웹에서 발급됐다
ALTER TABLE apple_credential
    ADD COLUMN client VARCHAR(255) NOT NULL DEFAULT 'WEB';

ALTER TABLE apple_credential
    ADD CONSTRAINT ck_apple_credential_client CHECK (client IN ('WEB', 'IOS'));
```
- `DEFAULT 'WEB'`은 기존 행 채움용이며 유지해도 무방하다(엔티티는 항상 값을 넣는다)

### 2. Entity, enum
- `AppleClient` (`auth/domain`): `WEB`, `IOS`. 메서드 없음
- `AppleCredential`
  - 필드 추가: `@Enumerated(EnumType.STRING) @Column(name = "client", nullable = false) AppleClient client`
  - `static AppleCredential create(long userId, String encryptedRefreshToken, AppleClient client)`
  - `void updateRefreshToken(String encryptedRefreshToken, AppleClient client)` - 토큰과 client를 함께 바꾼다(웹에서 가입한 사용자가 앱으로 로그인하면 IOS로 바뀜)

### 3. Repository
- `AppleCredentialRepository` 변경 없음

### 4. 설정, 지원 컴포넌트
- `AppleOAuthProps` - 필드 `String iosBundleId` 추가. `String clientId(AppleClient client)` → `WEB`이면 `clientId`, `IOS`면 `iosBundleId`
- `AppleClientSecretGenerator`
  - 생성자에서 `iosBundleId`가 비면 `RestApiException(APPLE_CONFIG_INVALID)` (privateKey와 같은 fail-fast)
  - `String generate(AppleClient client)` - `subject(props.clientId(client))`. 기존 `generate()`는 제거하고 호출부를 모두 `generate(AppleClient.WEB)`으로 바꾼다
- `AppleTokenCipher`, `AppleIdTokenDecoder` 변경 없음

### 5. DTO
- `AppleLoginDto(OAuthUserInfo userInfo, String refreshToken, AppleClient client)` - `of(userInfo, refreshToken, client)`
- `AppleStoredTokenDto(String refreshToken, AppleClient client)` (`dto/internal`) - 복호화 결과
- 요청 DTO: 기존 `AuthCodeRequest(code)` 재사용 (결정 1)

### 6. Service
- `AppleOAuthService`
  - `AppleLoginDto getUserInfo(String authCode, String dest)` (웹, 기존) - `validateAuthCode` → `validateDest` → `redirectUri` 계산 → `exchangeAndVerify(webTokenRequest(authCode, redirectUri), AppleClient.WEB)`
  - `AppleLoginDto getIosUserInfo(String authCode)` (신규) - `validateAuthCode` → `exchangeAndVerify(iosTokenRequest(authCode), AppleClient.IOS)`
  - `private MultiValueMap<String, String> webTokenRequest(String authCode, String redirectUri)` - `grant_type`, `client_id=props.clientId(WEB)`, `client_secret=generator.generate(WEB)`, `redirect_uri`, `code`
  - `private MultiValueMap<String, String> iosTokenRequest(String authCode)` - `grant_type`, `client_id=props.clientId(IOS)`, `client_secret=generator.generate(IOS)`, `code`. `redirect_uri` 없음
  - `private AppleLoginDto exchangeAndVerify(MultiValueMap<String, String> tokenRequest, AppleClient client)` - `oAuthClient.getAccessTokenResponse(props.tokenUri(), tokenRequest)` → `decodeIdToken` → `validateIssuer` → `validateAudience(idToken, props.clientId(client))` → `AppleUserInfo` + `OAuthUserInfoValidator.validate` → `AppleLoginDto.of(userInfo, refreshToken, client)`
  - `validateAudience(Jwt idToken, String expectedClientId)` - 기존 로직에서 기대값을 인자로 받도록 변경
  - `void revokeRefreshToken(String refreshToken, AppleClient client)` - `client_id=props.clientId(client)`, `client_secret=generator.generate(client)`. 기존 단일 인자 메서드는 제거
- `AppleCredentialService`
  - `@Transactional void save(long userId, String refreshToken, AppleClient client)` - 있으면 `updateRefreshToken(encrypted, client)`, 없으면 `create(userId, encrypted, client)`
  - `@Transactional(readOnly = true) Optional<AppleStoredTokenDto> findRefreshToken(long userId)` - 복호화한 토큰과 `credential.getClient()`를 담아 반환
  - `deleteByUserId` 변경 없음
- `OAuthLoginProcessor.processApple(AppleLoginDto)` - `saveAppleRefreshToken(user, dto.refreshToken(), dto.client())` → `appleCredentialService.save(user.getId(), token, client)`. 웹, iOS 모두 이 메서드를 탄다

### 7. Listener - `AppleTokenRevokeListener.handleUserWithdrawn`
- `findRefreshToken(userId).ifPresent(stored -> appleOAuthService.revokeRefreshToken(stored.refreshToken(), stored.client()); deleteByUserId(userId))`. 나머지 동일

### 8. Facade - `UserDeletionFacade.cleanUserDeletion` (기존 Facade, user + interview + auth 조합)
- `Optional<AppleStoredTokenDto> appleToken = findAppleRefreshToken(userId)` (try/catch 격리는 작업 트리에 반영 완료)
- `appleToken.ifPresent(stored -> revokeAppleToken(userId, stored))` → `appleOAuthService.revokeRefreshToken(stored.refreshToken(), stored.client())`

### 9. Controller - `OAuthIosController` (`@RequestMapping("/api/v1/oauth/ios")`, `OAuthIosControllerDocs` implements)
- `POST /api/v1/oauth/ios/apple` body `@Valid AuthCodeRequest` → `appleOAuthService.getIosUserInfo(code)` → `oAuthLoginProcessor.processApple(dto)` → `200 LoginResponse`
- `dest` 파라미터 없음(네이티브 교환은 redirect_uri를 쓰지 않는다)
- 보안: `/api/v1/oauth/**`가 이미 `permitAll`, `JwtAuthFilter` 제외 대상이라 추가 설정 없음
- Docs: `@Tag("OAuth2.0 iOS API")`. 응답은 `OAuthControllerDocs.appleLogin`과 같은 에러 목록(`AUTH_4004`, `AUTH_4005`, `AUTH_4007`~`AUTH_4010`, `AUTH_502`, `GLOBAL_5001`)에서 `DEST_4001`만 뺀다

### 10. 설정, CI/CD
- `application-dev.yml`, `application-prod.yml` `oauth.apple` 블록에 `ios-bundle-id: ${APPLE_IOS_BUNDLE_ID}`
- `application-test.yml` `oauth.apple.ios-bundle-id: kr.inuappcenter.gravit.test`
- `cd-dev.yml`, `cd-prod.yml` variable-substitution에 `oauth.apple.ios-bundle-id: ${{ secrets.APPLE_IOS_BUNDLE_ID }}` 추가. dev, prod 앱이 같은 Bundle ID를 쓰므로 접두사 없는 공유 시크릿(결정 3). 워크플로 머지 전에 시크릿을 먼저 등록한다
- `secret-convention.md` "의도적으로 공유하는 값" Apple 항목에 `APPLE_IOS_BUNDLE_ID` 추가

### 11. 정책 문서
- `auth-security.md`: "Apple 로그인은 웹에서만 지원한다" → 웹과 iOS 앱에서 지원. iOS 앱은 네이티브 모듈이 받은 인가 코드를 서버가 Apple에 직접 교환하고, id_token의 대상이 Gravit iOS 앱인지 확인한 뒤에만 성립. 웹과 iOS는 같은 Apple 계정으로 이어진다. 연결 토큰은 어느 클라이언트에서 발급했는지 함께 보관하고, 마지막 로그인 기준으로 바뀐다
- `user.md`: Apple 연결 해제는 토큰을 발급한 클라이언트(웹, iOS) 기준으로 한다

## 결정 필요 (Decisions needed)
> 권장안을 앞에 둔다. 2026-10-28 사용자가 권장안으로 모두 확정했다.
- [x] 1. 요청 본문 - **기존 `AuthCodeRequest` 재사용, body `{ "code": ... }`** / moyeo와 같은 `{ "authorizationCode": ... }` 전용 DTO
  - 근거: 웹 Apple, `/{provider}` 로그인과 같은 형태다. RN 쪽은 라이브러리 응답의 `authorizationCode`를 `code`에 담으면 된다
- [x] 2. nonce 검증 - **하지 않는다(인가 코드 교환만)** / 앱이 nonce 원문을 보내고 서버가 `SHA256(nonce)`을 id_token `nonce` claim과 비교
  - 근거: nonce는 클라이언트가 id_token을 직접 제출하는 흐름에서 재사용을 막는 장치다. 우리는 id_token을 받지 않고 1회용 인가 코드를 우리 client_secret으로 교환하므로 코드 자체가 우리 앱에 묶인다. 웹 Apple 로그인도 nonce 없이 동작한다. 하기로 하면 RN 라이브러리가 nonce를 SHA256으로 해시해 Apple에 보내므로 서버도 해시해 비교해야 한다(moyeo처럼 원문 비교하면 항상 실패)
- [x] 3. Bundle ID 시크릿 - **`APPLE_IOS_BUNDLE_ID` 하나를 dev, prod 공유** / `DEV_`, `PROD_` 분리
  - 근거: 다른 Apple 값(`APPLE_CLIENT_ID` 등)과 같은 기준. dev 빌드가 별도 Bundle ID(예: `.dev`)를 쓰게 되면 그때 분리한다
- [x] 4. 웹에서 가입한 사용자가 앱으로 로그인할 때 - **보관 토큰과 client를 IOS로 덮어쓴다** / 웹 토큰을 유지
  - 근거: 토큰과 발급 client는 한 쌍으로만 철회에 쓸 수 있다. 웹 Services ID는 앱 App ID 그룹에 묶여 있어 어느 client 토큰이든 한 번 철회하면 권한이 통째로 끊기므로 최신 쌍 하나만 보관하면 된다. #580 "로그인할 때마다 최신 값으로 바꾼다" 정책과 같다
- [x] 5. 엔드포인트 - **`OAuthIosController`에 `POST /api/v1/oauth/ios/apple`** / `OAuthController`에 `POST /api/v1/oauth/apple/ios`
  - 근거: 안드로이드가 `/api/v1/oauth/android`로 분리되어 있어 플랫폼별 컨트롤러가 대칭이다

## 검증
- 컴파일과 기존 테스트: `./gradlew build` (flywayValidate 포함). `generate()`, `revokeRefreshToken(String)`, `save(long, String)`, `findRefreshToken` 시그니처 변경에 따라 기존 Apple 테스트 6종을 함께 고친다
- `AppleOAuthServiceIntegrationTest` 추가 - iOS: 토큰 요청 form에 `client_id`=Bundle ID, `redirect_uri` 없음, `client_secret`의 `sub`=Bundle ID. id_token `aud`가 웹 Services ID면 `AUDIENCE_NOT_MATCHING`. `revokeRefreshToken(token, IOS)`가 Bundle ID와 그 client_secret으로 요청. 인가 코드를 디코딩하지 않고 그대로 보냄(작업 트리에 반영 완료)
- `AppleClientSecretGeneratorTest` 추가 - `generate(IOS)`의 `sub`=Bundle ID, `generate(WEB)`의 `sub`=Services ID
- `AppleCredentialServiceIntegrationTest` 추가 - client 저장, WEB→IOS 덮어쓰기, 조회 시 client 반환
- `OAuthLoginProcessorIntegrationTest` 추가 - iOS `AppleLoginDto`로 가입 시 `client=IOS` 저장
- `AppleTokenRevokeListenerIntegrationTest`, `UserDeletionFacadeIntegrationTest` 추가 - IOS로 보관한 토큰은 Bundle ID로 철회. 복호화 실패 시 철회 없이 삭제(작업 트리에 반영 완료)
- `OAuthIosControllerIntegrationTest` (MockMvc) - 200 + `LoginResponse`, `code` 누락 400
- 실연동: dev 배포 후 iOS 앱(또는 TestFlight)에서 Apple 로그인 → 같은 Apple 계정으로 웹 로그인 시 같은 사용자인지 확인 → 탈퇴 확정 후 Apple 설정의 "Apple로 로그인" 목록에서 연결이 사라지는지 확인

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
- 기존 Apple 테스트 7개 파일(`AppleClientSecretGeneratorTest`, `AppleTokenCipherTest`, `AppleOAuthServiceIntegrationTest`, `AppleCredentialServiceIntegrationTest`, `OAuthLoginProcessorIntegrationTest`, `AppleTokenRevokeListenerIntegrationTest`, `UserDeletionFacadeIntegrationTest`): 호출부를 새 시그니처(`generate(AppleClient)`, `save(userId, token, client)`, `findRefreshToken` → `Optional<AppleStoredTokenDto>`, `revokeRefreshToken(token, client)`, `AppleLoginDto.of(..., client)`, `AppleCredential.create(..., client)`)로만 맞췄다 — 이유: 시그니처 변경으로 테스트 컴파일이 깨져 `./gradlew build`가 실패한다. 새 시나리오(iOS 교환, client 저장과 철회)는 `write-test`에서 추가한다
- `src/main/resources/application.yml`(gitignore 대상, 로컬 전용): `oauth.apple.ios-bundle-id` 자리 값 추가 — 이유: `AppleClientSecretGenerator`가 기동 시 Bundle ID를 검증하므로 없으면 로컬 `bootRun`이 실패한다. 실제 Bundle ID로 바꿔야 한다
- `OAuthIosControllerDocs`: 400 예시에 `AUTH_4002`(유효하지 않은 AuthCode)를 포함 — 이유: 계획 본문의 "웹 Apple 문서와 같은 목록에서 `DEST_4001`만 뺀다"를 따랐다. 괄호 안 나열에는 빠져 있었으나 `validateAuthCode`가 실제로 던지는 코드다
