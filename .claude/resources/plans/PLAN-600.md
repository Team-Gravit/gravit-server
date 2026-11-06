# [PLAN-600] 웹, 앱 동시 로그인 지원

> 이슈: #600
> 브랜치: feat/600-refresh-token-session

## 목표
리프레시 토큰이 사용자당 1개(`refreshToken:{userId}`)라 한 클라이언트의 로그인이 다른 클라이언트의 세션을 끊는다.
저장 칸을 기기 종류(웹, 안드로이드, iOS)별로 나눠 웹과 앱의 동시 로그인을 허용한다. 로그아웃은 그 기기 종류의 칸만 비우고, 탈퇴는 모든 칸을 비운다. 쿠키와 요청, 응답 형식은 바꾸지 않는다.

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
- `AuthTokenService`, `AuthTokenController`, `OAuthIosController`, `RefreshTokenCookieFactory`, 요청, 응답 DTO, Swagger 문서
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

## 결정 필요 (Decisions needed)
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
