# [PLAN-466] 인증 우회 경로 차단과 토큰 키 분리

> 이슈: #466
> 브랜치: fix/466-auth-bypass

## 목표
안드로이드 네이버 로그인이 클라이언트가 보낸 사용자 정보를 무검증으로 신뢰해 임의 계정 로그인과 어드민 탈취가 가능한 문제를, 네이버 액세스 토큰을 서버가 직접 검증하는 방식으로 바꿔 차단한다. 함께 dev와 prod가 공유하던 JWT 서명 키를 환경별로 분리해 dev 토큰이 prod에서 통용되지 않게 한다.

## 핵심 근거

### 결함 1: 안드로이드 네이버 로그인에 검증 주체가 없다
- `OAuthAndroidController.oauthNaverLogin`(41-53행)은 `NaverAndroidUserInfoRequest`의 `providerId`, `email`, `nickname`을 그대로 `NaverAndroidUserInfo`로 감싸 `OAuthLoginProcessor.process`에 넘긴다. 제공자에게 확인하는 단계가 한 곳도 없다.
- `SecurityConfig`(47행)가 `/api/v1/oauth/**`를 `permitAll`로 열어두고 `JwtAuthFilter`(33행)도 같은 prefix를 제외 대상으로 두므로, 이 엔드포인트는 무인증으로 호출된다.
- `OAuthLoginProcessor.findOrCreateUser`는 `naver_{providerId}`로 사용자를 찾으므로, 타인의 `providerId`를 알면 그 계정의 액세스 토큰과 리프레시 토큰을 받는다.
- 더해 `promoteToAdminByWhitelist`(78행)와 `registerNewUser`(60행)가 `oAuthUserInfo.getEmail()`을 그대로 `AdminPromotionPolicy`에 넘긴다. 요청 바디의 `email`에 `ADMIN_BOOTSTRAP_EMAILS` 값을 넣으면 어드민 권한이 부여된다.
- 웹 네이버 로그인(`OAuthUserInfoService`)은 authorization code를 토큰으로 교환하고 `openapi.naver.com/v1/nid/me`를 서버가 조회하는 정상 경로다. 즉 결함은 안드로이드 전용 경로에만 있다.

### 결함 2: dev와 prod가 같은 JWT 서명 키를 쓴다
- `cd-dev.yml:33`과 `cd-prod.yml:32`가 모두 `secrets.JWT_SECRET`을 주입한다.
- 토큰 subject는 `AuthTokenProvider.toSubject`(75행)가 만드는 `user.getId()` 문자열이고, `JwtProvider`는 HS256 대칭키로 서명한다.
- dev 서버는 소셜 로그인으로 누구나 가입할 수 있으므로, dev에서 받은 액세스 토큰을 prod에 그대로 제시하면 서명 검증을 통과하고 `AuthTokenProvider.parseUser`가 prod DB에서 같은 숫자 id의 사용자를 조회해 인증이 성립한다.
- 권한은 `JwtProvider.getAuthentication`이 DB의 `user.getRole()`에서 다시 읽으므로 role 클레임 위조는 성립하지 않는다. 성립하는 것은 신원 사칭이다.

### 해결 방향: 네이버는 액세스 토큰 검증으로 간다
- 네이버는 안드로이드 SDK에서 OIDC id_token을 발급하지 않는다. `OidcConfig.jwtDecoderMap`에 naver 항목이 없는 것도 그래서다. 기존 id_token 검증 경로(`OAuthAndroidUserInfoService`)를 그대로 재사용할 수 없다.
- 대신 안드로이드가 네이버 SDK로 받은 **액세스 토큰**을 보내고, 서버가 `openapi.naver.com/v1/nid/me`를 조회해 사용자 정보를 확정한다. 이 방식은 이미 있는 부품을 그대로 쓴다.
  - userinfo 엔드포인트: `ClientRegistration`(naver)의 `user-info-uri` - 이미 `application-{profile}.yml`에 설정되어 있다
  - 호출: `OAuthClient.getUserInfoWithAccessToken` - 이미 존재한다
  - 응답 파싱: `NaverOAuthResponseStrategy` → `NaverUserInfo` - 이미 `response` 래핑을 처리한다
- **잔존 위험(방어 불가, 명시적으로 남긴다)**: 네이버는 액세스 토큰이 어느 애플리케이션에 발급됐는지 확인할 수 있는 tokeninfo 엔드포인트를 공개하지 않는다. 따라서 다른 네이버 앱이 발급받은 토큰으로도 `nid/me` 조회는 성공한다(token substitution). 현재의 "검증 전무" 대비 공격 난이도는 크게 오르지만 완전한 클라이언트 바인딩은 아니다. Google, Kakao는 id_token의 `aud` 검증으로 이 문제가 없다.

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/auth/dto/oauth/android/AccessTokenRequest.java` — 안드로이드가 보내는 제공자 액세스 토큰 요청 DTO
- `src/main/java/gravit/code/auth/service/oauth/android/NaverAndroidUserInfoService.java` — 네이버 액세스 토큰으로 제공자에게 사용자 정보를 조회, 검증
- `src/test/java/gravit/code/auth/service/oauth/android/NaverAndroidUserInfoServiceIntegrationTest.java` — 액세스 토큰 검증 성공, 실패 시나리오
- `src/test/java/gravit/code/auth/controller/OAuthAndroidControllerIntegrationTest.java` — 네이버 로그인 엔드포인트 요청 규격, 무검증 우회 차단 회귀 방지
- `.claude/spec/secret-convention.md` — 환경별 시크릿 네이밍 규칙과 발급, 교체 절차

### 수정 파일
- `src/main/java/gravit/code/auth/controller/OAuthAndroidController.java` — `oauthNaverLogin`이 `AccessTokenRequest`를 받아 `NaverAndroidUserInfoService`에 위임하도록 변경
- `src/main/java/gravit/code/auth/controller/docs/OAuthAndroidControllerDocs.java` — 네이버 엔드포인트 시그니처와 응답 명세 갱신
- `src/main/java/gravit/code/auth/infrastructure/client/OAuthHttpClientAdapter.java` — `getUserInfoWithAccessToken`에 401 처리 추가
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` — `// Auth` 그룹에 `OAUTH_USER_INFO_INVALID` 추가
- `.github/workflows/cd-dev.yml` — `jwt.secret` 주입을 `secrets.DEV_JWT_SECRET`으로 변경
- `.github/workflows/cd-prod.yml` — `jwt.secret` 주입을 `secrets.PROD_JWT_SECRET`으로 변경
- `.claude/spec/service-policy/auth-security.md` — 소셜 로그인 성립 조건(제공자 검증)을 정책으로 명시
- `.claude/CLAUDE.md` — `.claude/spec/` 목록에 `secret-convention.md` 한 줄 추가

### 삭제 파일
- `src/main/java/gravit/code/auth/dto/oauth/android/NaverAndroidUserInfoRequest.java` — 무검증 입력 규격, `AccessTokenRequest`로 대체
- `src/main/java/gravit/code/auth/dto/oauth/android/NaverAndroidUserInfo.java` — `NaverUserInfo`가 제공자 응답을 파싱하므로 불필요

## 구현 계획
> 레이어 순으로, 클래스, 메서드 단위까지 구체적으로.

1. **Entity / Flyway**: DB 변경 없음.

2. **Repository**: 변경 없음.

3. **CustomErrorCode**: `// Auth` 그룹 끝(33행 `AUDIENCE_NOT_MATCHING` 다음)에 추가한다.
   ```java
   OAUTH_USER_INFO_INVALID(HttpStatus.BAD_REQUEST, "AUTH_4010", "OAuth 제공자로부터 유효한 사용자 정보를 받지 못했습니다."),
   ```
   기존 `OAUTH_ACCESS_TOKEN_INVALID`는 그대로 재사용한다(액세스 토큰 자체가 거부된 경우).

4. **Infrastructure**: `OAuthHttpClientAdapter.getUserInfoWithAccessToken`의 catch 절에 `HttpClientErrorException.BadRequest` 다음, `RestClientException` 앞 위치로 추가한다.
   ```java
   } catch (HttpClientErrorException.Unauthorized e) {
       log.warn("만료되었거나 유효하지 않은 AccessToken 요청 : {}", e.getMessage());
       throw new RestApiException(CustomErrorCode.OAUTH_ACCESS_TOKEN_INVALID);
   }
   ```
   근거: 네이버 `nid/me`는 유효하지 않은 토큰에 401을 반환한다. 현재는 400만 잡고 있어 401이 `RestClientException`으로 흘러 `OAUTH_SERVER_ERROR`(502)로 잘못 응답한다.

5. **Service**: `NaverAndroidUserInfoService`를 신규 작성한다. 패키지는 기존 안드로이드 서비스와 같은 `gravit.code.auth.service.oauth.android`.
   ```java
   @Service
   @RequiredArgsConstructor
   @Slf4j
   public class NaverAndroidUserInfoService {

       private static final String PROVIDER = "naver";
       private static final String RESULT_CODE_KEY = "resultcode";
       private static final String RESULT_CODE_SUCCESS = "00";

       private final ClientRegistrationRepository clientRegistrationRepository;
       private final OAuthClient oAuthClient;
       private final OAuthResponseFactory oAuthResponseFactory;

       public OAuthUserInfo getUserInfo(String accessToken) { ... }

       private void validateAccessToken(String accessToken) { ... }

       private void validateResultCode(Map<String, Object> userInfo) { ... }
   }
   ```
   - `getUserInfo(String accessToken)`
     1. `validateAccessToken(accessToken)` — null이거나 blank면 `OAUTH_ACCESS_TOKEN_INVALID`
     2. `clientRegistrationRepository.findByRegistrationId(PROVIDER)`로 `ClientRegistration`을 얻고 `getProviderDetails().getUserInfoEndpoint().getUri()`로 userinfo URI를 꺼낸다
     3. `oAuthClient.getUserInfoWithAccessToken(userInfoUri, accessToken)` 호출
     4. `validateResultCode(userInfo)`
     5. `oAuthResponseFactory.createOAuthUserInfo(PROVIDER, userInfo)`를 반환
   - `validateResultCode(Map<String, Object> userInfo)` — `userInfo.get(RESULT_CODE_KEY)`가 `RESULT_CODE_SUCCESS`가 아니거나 `response` 키가 없으면 `OAUTH_USER_INFO_INVALID`
     근거: 네이버는 인증 실패 시 200으로 `{"resultcode":"024","message":"Authentication failed"}`를 돌려주는 경우가 있고, 이때 `NaverUserInfo`의 compact 생성자가 `attributes.get("response")`로 null을 받아 이후 `getProviderId()`에서 NPE가 난다.
   - `@Transactional`을 붙이지 않는다. DB에 접근하지 않고 외부 호출만 한다.

6. **Facade**: 불필요 — 단일 Service 위임이며 도메인 결합이 없다.

7. **DTO**:
   - 신규 `AccessTokenRequest`
     ```java
     public record AccessTokenRequest(

             @Schema(description = "제공자가 발급한 액세스 토큰")
             @NotNull(message = "액세스 토큰이 비어있습니다.")
             String accessToken
     ) {
     }
     ```
     위치는 기존 `IdTokenRequest`와 같은 `auth/dto/oauth/android/`에 둔다. `dto.md`의 `dto/request/` 분리 규칙과는 어긋나지만, 이번 작업 범위를 벗어난 기존 OAuth DTO 전체 이동을 유발하므로 형제 파일과의 일관성을 택한다. 패키지 정리는 #467에서 다룬다.
   - 삭제 `NaverAndroidUserInfoRequest`, `NaverAndroidUserInfo`

8. **Controller**: `OAuthAndroidController`
   - 의존성에 `NaverAndroidUserInfoService naverAndroidUserInfoService`를 추가한다
   - `POST /api/v1/oauth/android/naver`
     ```java
     @PostMapping("/naver")
     public ResponseEntity<LoginResponse> oauthNaverLogin(
             @RequestBody @Valid AccessTokenRequest request
     ){
         OAuthUserInfo userInfo = naverAndroidUserInfoService.getUserInfo(request.accessToken());

         LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo);

         return ResponseEntity.status(HttpStatus.OK).body(loginResponse);
     }
     ```
   - `POST /api/v1/oauth/android`(google, kakao)는 변경하지 않는다

9. **API 문서**: `OAuthAndroidControllerDocs.oauthNaverLogin`
   - 파라미터를 `AccessTokenRequest`로 교체
   - description을 "네이버는 IdToken 방식을 지원하지 않아 안드로이드가 SDK로 발급받은 액세스 토큰을 전달하고, 서버가 네이버에 사용자 정보를 조회해 검증한다"로 갱신
   - `@ApiResponses`에 400 `AUTH4003`(유효하지 않은 액세스 토큰), 400 `AUTH_4010`(사용자 정보 조회 실패), 502 `AUTH_502`(제공자 통신 실패)를 추가

10. **CD 워크플로**:
    - `.github/workflows/cd-dev.yml` 33행: `jwt.secret: ${{secrets.JWT_SECRET}}` → `jwt.secret: ${{secrets.DEV_JWT_SECRET}}`
    - `.github/workflows/cd-prod.yml` 32행: `jwt.secret: ${{secrets.JWT_SECRET}}` → `jwt.secret: ${{secrets.PROD_JWT_SECRET}}`
    - `PROD_JWT_SECRET`에는 기존 `JWT_SECRET` 값을 그대로 등록한다(결정 사항). prod 사용자 세션이 유지된다.
    - `DEV_JWT_SECRET`에는 새로 생성한 값을 등록한다. dev의 기존 발급 토큰은 모두 무효가 되며 dev 사용자는 재로그인한다.
    - GitHub Secrets 등록은 저장소 관리자가 직접 수행한다. 워크플로 머지 전에 두 시크릿이 등록되어 있어야 하며, 순서가 어긋나면 `jwt.secret`이 빈 값으로 주입되어 배포된 서버가 토큰을 발급하지 못한다.
    - 구 `JWT_SECRET` 시크릿은 두 워크플로가 모두 새 이름을 참조하는 것이 확인된 뒤 삭제한다.

12. **시크릿 운영 문서**: `.claude/spec/secret-convention.md`를 신규 작성한다. 담을 내용은 다음과 같다.
    - 환경별 시크릿 네이밍 규칙: 환경에 따라 값이 달라야 하는 시크릿은 `DEV_`, `PROD_` 접두사를 붙인다. 환경과 무관한 값만 접두사 없이 쓴다
    - 현재 환경 분리 대상과 미분리 대상 목록. 미분리 항목(OAuth client-id, client-secret, `KAKAO_NATIVE_APP_KEY`, `ADMIN_BOOTSTRAP_EMAILS`, DB 계정)은 #467에서 다룬다는 사실을 명시한다
    - JWT 시크릿 교체 절차: 새 값 생성 → GitHub Secrets 등록 → 워크플로 참조 변경 → 배포 → 구 시크릿 삭제. prod 교체 시 전 사용자 로그아웃과 Redis 리프레시 토큰 무효화가 동반된다는 점을 경고로 남긴다
    - `.claude/CLAUDE.md`의 `.claude/spec/` 목록에 `- 시크릿 운영 (환경별 네이밍, 발급, 교체) → secret-convention.md` 한 줄을 추가한다

13. **정책 문서**: `.claude/spec/service-policy/auth-security.md`에 다음 항목을 추가한다.
    - `소셜 로그인은 제공자가 발급한 토큰을 서버가 제공자에게 확인한 뒤에만 성립한다. 클라이언트가 보낸 사용자 정보를 그대로 신뢰하지 않는다`
    - `안드로이드 로그인은 Google, Kakao는 id_token, Naver는 액세스 토큰을 서버에 전달한다`

## 결정 필요 (Decisions needed)
- [x] **prod JWT 시크릿 값** — **기존 값 유지**로 확정. 기존 `JWT_SECRET` 값을 `PROD_JWT_SECRET`으로 그대로 옮기고 `DEV_JWT_SECRET`만 새로 발급한다. 이번 이슈의 목적인 환경 간 통용 차단은 이것으로 달성되고, prod 사용자 세션과 Redis 리프레시 토큰이 유지된다. 구 키가 외부로 유출된 정황이 확인되면 그때 prod도 교체한다.
- [x] **안드로이드 요청 규격 변경 합의** — **한 번에 교체**로 확정. `POST /api/v1/oauth/android/naver`의 요청 바디를 `{email, providerId, nickname}`에서 `{accessToken}`으로 바꾸고, 구 규격은 남기지 않는다. 파괴적 변경이므로 **안드로이드 클라이언트 동시 배포가 선행 조건**이다. 서버를 먼저 배포하면 그 사이 안드로이드 네이버 로그인이 400으로 실패한다. 배포 순서는 PR 머지 전에 안드로이드 팀과 맞춘다.
- [x] **시크릿 운영 절차 문서 위치** — **`.claude/spec/` 신규 문서**로 확정. `.claude/spec/secret-convention.md`를 만들고 `.claude/CLAUDE.md`의 목록에 한 줄 추가한다.

## 검증
- 대상 테스트
  - `NaverAndroidUserInfoServiceIntegrationTest`
    - `유효한_액세스_토큰으로_네이버_사용자_정보를_조회한다` — `OAuthHttpClientAdapter`를 `@MockitoBean`으로 두고 `{resultcode:"00", response:{id, email, name}}`을 반환시켜 `OAuthUserInfo`의 provider, providerId, email, name을 검증
    - `액세스_토큰이_비어있으면_예외가_발생한다` — null, blank 각각 `OAUTH_ACCESS_TOKEN_INVALID`
    - `제공자가_실패_결과를_반환하면_예외가_발생한다` — `{resultcode:"024"}` → `OAUTH_USER_INFO_INVALID`
    - `제공자가_액세스_토큰을_거부하면_예외가_발생한다` — 어댑터가 `OAUTH_ACCESS_TOKEN_INVALID`를 던질 때 그대로 전파되는지
  - `OAuthAndroidControllerIntegrationTest`
    - `네이버_액세스_토큰으로_로그인에_성공한다` — 200과 `LoginResponse` 필드 검증
    - `사용자_정보를_직접_보내면_로그인에_실패한다` — `{email, providerId, nickname}` 바디로 요청 시 `accessToken`이 null이라 400. 이번 결함의 회귀 방지 케이스다
    - `제공자_검증에_실패하면_토큰이_발급되지_않는다` — 어댑터가 예외를 던질 때 사용자가 생성되지 않는지 `UserRepository`로 확인
  - 예외 케이스는 `test-convention.md`에 따라 `errorCode`까지 검증하고 `CustomErrorCode`는 static import로 쓴다
- 회귀 확인
  - `OAuthLoginProcessorTest`, `OAuthLoginUrlServiceTest`가 그대로 통과하는지
  - `./gradlew build`로 flyway validate 포함 전체 빌드
- 수동 확인
  - dev 배포 후 안드로이드 네이버 로그인이 새 규격으로 동작하는지
  - dev에서 발급한 액세스 토큰으로 prod의 인증 필요 API 호출 시 401이 나는지 (결함 2 해소 확인)

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다.

- `NaverAndroidUserInfoService`: `response` 키 검증을 존재 여부(`containsKey`) 대신 `instanceof Map`으로 구현 — 이유: `NaverUserInfo`의 compact 생성자가 `(Map) attributes.get("response")`로 캐스팅하므로, 키가 있어도 Map이 아니면 `ClassCastException`이 난다. 타입까지 확인해야 계획이 의도한 NPE, 캐스팅 예외 차단이 완성된다. 상수 `RESPONSE_KEY`를 함께 추가했다.
- `NaverAndroidUserInfoServiceIntegrationTest`: 계획의 4개 시나리오에 `사용자_정보_본문이_없으면_예외가_발생한다`를 추가해 5개로 작성 — 이유: 위 `response` 검증 분기가 `resultcode` 검증과 별개 분기라 계획의 `제공자가_실패_결과를_반환하면_예외가_발생한다`만으로는 커버되지 않는다.
- `NaverAndroidUserInfoServiceIntegrationTest`: 액세스 토큰 null, blank 검증을 `@ParameterizedTest` + `@NullSource`, `@ValueSource`로 묶음 — 이유: 동일 분기에 대한 입력만 다른 케이스라 테스트 메서드를 나눌 실익이 없다.
- `SecurityConfig`, `JwtAuthFilter`: 수정하지 않음 — 이유: 엔드포인트 경로(`/api/v1/oauth/android/naver`)가 그대로이고 요청 바디 규격만 바뀌었다. 두 파일 모두 `/api/v1/oauth` prefix로 이미 열려 있어 변경이 불필요하다.
