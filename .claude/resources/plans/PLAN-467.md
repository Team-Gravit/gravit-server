# [PLAN-467] OAuth 환경 분리와 검증 구조 통합

> 이슈: #467
> 브랜치: 갈래별로 분리한다. 아래 갈래 구성 참조

## 갈래 구성

이슈 본문의 지시(`성격이 달라 커밋과 PR을 갈래별로 나눈다`)에 따라 세 갈래를 각각의 브랜치와 PR로 진행한다.
계획서는 이슈 단위로 하나(`PLAN-467.md`)를 유지하고, 각 갈래를 시작할 때 해당 섹션을 채운다.

| 갈래 | 브랜치 | 상태 |
|---|---|---|
| A. 환경 경계 | `refactor/467-oauth-env-boundary` | 계획 작성 완료 |
| B. 사용자 정보 매핑 통합 | `refactor/467-oauth-userinfo-mapping` | 미착수 (스텁) |
| C. 안드로이드 검증 구조 통합 | `refactor/467-android-token-verifier` | 미착수 (스텁) |

B와 C의 상세를 지금 쓰지 않는 이유는 두 가지다.
C의 엔드포인트 단일화 여부가 안드로이드 팀 합의에 걸려 있어 지금 쓰면 추측이 되고,
B는 A가 바꿔놓은 설정 구조 위에서 설계해야 한다.

---

# 갈래 A - 환경 경계

> 브랜치: `refactor/467-oauth-env-boundary`

## 목표

리다이렉트 목적지 화이트리스트와 OAuth 클라이언트 자격증명이 프로필과 무관하게 동작하는 상태를 없앤다.
운영 서버가 로컬 주소를 목적지로 받아 인가 코드를 배달할 수 없게 하고, dev와 prod가 같은 OAuth 앱을 공유하지 않게 한다.

## 현재 상태 (확인한 사실)

- `RedirectHostConst.DEST_BASE`는 `prod`, `local`, `dev`, `admin` 4개를 상수 Map으로 고정한다.
  프로필과 무관하므로 prod 서버도 `dest=local`을 받아 `http://localhost:5173`으로 인가 코드를 배달한다.
- 같은 dest 검증 로직이 `OAuthLoginUrlService.validateDest`, `OAuthUserInfoService.validateDest`,
  `UserDeletionService.makeDeleteLink` 세 곳에 중복되어 있다.
- dev와 prod가 `${GOOGLE_CLIENT_ID}`, `${GOOGLE_CLIENT_SECRET}`, `${KAKAO_CLIENT_ID}`, `${KAKAO_CLIENT_SECRET}`,
  `${NAVER_CLIENT_ID}`, `${NAVER_CLIENT_SECRET}`, `${KAKAO_NATIVE_APP_KEY}` 7종을 같은 이름으로 참조한다.
  `.claude/spec/secret-convention.md`가 이미 이를 미분리 항목으로 기록하고 분리를 #467 범위로 명시했다.
- `registration.*.redirect-uri`는 런타임에서 참조되지 않는다. `getRedirectUri()` 호출부가 코드베이스에 0건이고,
  `oauth2Login()` 설정도 없다. 실제 redirect_uri는 `baseHost + "/login/oauth2/code/" + provider`로 매번 조립된다.

> **중요**: `redirect-uri`를 yml에서 그냥 삭제하면 애플리케이션이 부팅되지 않는다.
> `ClientRegistration.Builder`(spring-security-oauth2-client 6.5.8)가 authorization_code 등록에 대해
> `redirectUri cannot be empty`를 단언한다. 또한 `provider` 블록을 직접 선언한 등록이라
> Spring Boot 3.5.11의 `OAuth2ClientPropertiesMapper`가 `CommonOAuth2Provider`의 기본값을 채워주지 않는다.
> 따라서 "정리"는 삭제가 아니라 시크릿 의존을 끊고 고정 리터럴로 대체하는 방식이어야 한다.

## 영향 범위

### 신규 파일

- `src/main/java/gravit/code/global/config/RedirectDestProps.java` — dest 화이트리스트를 프로필 설정에서 읽고 해석하는 프로퍼티

### 수정 파일

- `src/main/java/gravit/code/auth/service/oauth/OAuthLoginUrlService.java` — `RedirectHostConst` 의존 제거, `RedirectDestProps` 주입, `validateDest` 삭제
- `src/main/java/gravit/code/auth/service/oauth/OAuthUserInfoService.java` — 위와 동일
- `src/main/java/gravit/code/user/service/UserDeletionService.java` — `makeDeleteLink`가 `RedirectDestProps`를 쓰도록 변경
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` — `DEST_NOT_VALID` 메시지에서 `(local/prod 만 유효합니다.)` 제거
- `src/main/resources/application-dev.yml` — `redirect.dests` 추가, 자격증명 `DEV_` 접두사, `redirect-uri` 리터럴화
- `src/main/resources/application-prod.yml` — `redirect.dests` 추가, 자격증명 `PROD_` 접두사, `redirect-uri` 리터럴화
- `src/main/resources/application-local.yml` — `redirect.dests` 추가 (추적되지 않는 로컬 전용 파일이라 각자 로컬에서 반영해야 한다)
- `src/test/resources/application-test.yml` — `redirect.dests` 추가 (없으면 컨텍스트 로딩이 실패한다)
- `.github/workflows/cd-dev.yml` — 자격증명 시크릿 참조를 `DEV_` 접두사로, `redirect-uri` 주입 3줄 삭제
- `.github/workflows/cd-prod.yml` — 자격증명 시크릿 참조를 `PROD_` 접두사로, `redirect-uri` 주입 3줄 삭제
- `.claude/spec/secret-convention.md` — 분리 상태 표 갱신, provider 콘솔 환경별 등록 절차 추가
- `.claude/spec/service-policy/auth-security.md` — dest 허용 범위가 환경별로 다르다는 정책 한 줄 추가

### 삭제 파일

- `src/main/java/gravit/code/global/consts/RedirectHostConst.java`

## 구현 계획

### 1. Entity / Flyway

DB 변경 없음.

### 2. Repository

변경 없음.

### 3. 설정 프로퍼티

`gravit.code.global.config.RedirectDestProps`

```java
@ConfigurationProperties(prefix = "redirect")
public record RedirectDestProps(
        Map<String, String> dests
) {
    public String resolveBaseUrl(String dest) {
        String baseUrl = (dest == null) ? null : dests.get(dest);

        if (baseUrl == null || baseUrl.isBlank()) {
            throw new RestApiException(CustomErrorCode.DEST_NOT_VALID);
        }

        return baseUrl;
    }
}
```

- `GravitApplication`에 `@ConfigurationPropertiesScan`이 이미 있으므로 별도 등록은 불필요하다.
- `auth`와 `user` 두 도메인이 함께 쓰므로 `global` 아래에 둔다. `AdminWhitelistProps`, `OAuthAndroidProps`가 record 프로퍼티 패턴의 선례다.
- 검증 로직을 프로퍼티가 직접 갖는 이유는 세 곳에 흩어진 같은 판정을 한 군데로 모으기 위함이다.

### 4. Service

- `OAuthLoginUrlService`
  - 필드 추가: `private final RedirectDestProps redirectDestProps;`
  - `generateLoginUrl(String provider, String dest)`: `String baseHost = validateDest(dest);` → `String baseHost = redirectDestProps.resolveBaseUrl(dest);`
  - `private String validateDest(String dest)` 삭제
- `OAuthUserInfoService`
  - 필드 추가: `private final RedirectDestProps redirectDestProps;`
  - `getUserInfo(String authCode, String provider, String dest)`: 위와 동일하게 교체
  - `private String validateDest(String dest)` 삭제
- `UserDeletionService`
  - 필드 추가: `private final RedirectDestProps redirectDestProps;`
  - `private String makeDeleteLink(String dest)`: 본문을 `return redirectDestProps.resolveBaseUrl(dest) + "/user/me/delete/page";`로 교체

### 5. Facade

불필요. 단일 Service 내부 변경이다.

### 6. DTO / Controller

변경 없음. `dest`는 기존대로 `@RequestParam`으로 받고 시그니처도 그대로다.

### 7. 프로필 설정

`application-dev.yml`

```yaml
redirect:
  dests:
    dev: https://dev.gravit.inuappcenter.kr
    local: http://localhost:5173
```

`application-prod.yml`

```yaml
redirect:
  dests:
    prod: https://gravit.inuappcenter.kr
    admin: https://gravit-admin.inuappcenter.kr
```

`application-local.yml`, `src/test/resources/application-test.yml`

```yaml
redirect:
  dests:
    local: http://localhost:5173
```

프로필별 허용 목록을 표로 정리하면 다음과 같다.

| dest | local | dev | prod |
|---|---|---|---|
| `local` | 허용 | 허용 | **차단** |
| `dev` | 차단 | 허용 | 차단 |
| `prod` | 차단 | 차단 | 허용 |
| `admin` | 차단 | 차단 | 허용 |

`prod` 열의 `local` 차단이 이번 작업의 핵심이다. dev가 `local`을 허용하는 이유는
프론트가 로컬 5173에서 dev 서버를 붙어 개발하는 흐름을 유지하기 위함이다.

### 8. 자격증명 환경별 분기

`.claude/spec/secret-convention.md`의 네이밍 규칙(환경별로 값이 달라야 하는 시크릿은 `DEV_`, `PROD_` 접두사)을 따른다.

| yml 키 | dev | prod |
|---|---|---|
| `registration.google.client-id` | `${DEV_GOOGLE_CLIENT_ID}` | `${PROD_GOOGLE_CLIENT_ID}` |
| `registration.google.client-secret` | `${DEV_GOOGLE_CLIENT_SECRET}` | `${PROD_GOOGLE_CLIENT_SECRET}` |
| `registration.kakao.client-id` | `${DEV_KAKAO_CLIENT_ID}` | `${PROD_KAKAO_CLIENT_ID}` |
| `registration.kakao.client-secret` | `${DEV_KAKAO_CLIENT_SECRET}` | `${PROD_KAKAO_CLIENT_SECRET}` |
| `registration.naver.client-id` | `${DEV_NAVER_CLIENT_ID}` | `${PROD_NAVER_CLIENT_ID}` |
| `registration.naver.client-secret` | `${DEV_NAVER_CLIENT_SECRET}` | `${PROD_NAVER_CLIENT_SECRET}` |
| `oauth.android.kakao.client-id` | `${DEV_KAKAO_NATIVE_APP_KEY}` | `${PROD_KAKAO_NATIVE_APP_KEY}` |
| `oauth.android.google.client-id` | `${DEV_GOOGLE_ANDROID_CLIENT_ID}` | `${PROD_GOOGLE_ANDROID_CLIENT_ID}` |

`cd-dev.yml`, `cd-prod.yml`의 `microsoft/variable-substitution` env 블록도 같은 이름으로 바꾼다.

**값을 실제로 분리하는 범위는 웹 자격증명 6종까지다.**

| 시크릿 | 이름 분리 | 값 분리 | 비고 |
|---|---|---|---|
| `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` | O | O | Google Cloud Console에 dev용 OAuth 클라이언트 신규 등록 |
| `KAKAO_CLIENT_ID`, `KAKAO_CLIENT_SECRET` | O | O | Kakao Developers에 dev용 앱 신규 등록 |
| `NAVER_CLIENT_ID`, `NAVER_CLIENT_SECRET` | O | O | Naver Developers에 dev용 앱 신규 등록 |
| `KAKAO_NATIVE_APP_KEY` | O | X (같은 값) | 안드로이드 앱 빌드에 영향. 갈래 C 이후 안드로이드 팀과 합의 |
| `GOOGLE_ANDROID_CLIENT_ID` | O (신설) | X (같은 값) | 위와 동일. id_token의 audience라 앱 빌드 설정과 짝을 이룬다 |

안드로이드 키 2종을 지금 값까지 나누지 않는 이유는, 안드로이드 앱이 접속 환경에 따라 다른 키로 빌드돼야 하고
그 변경은 안드로이드 팀 합의 없이는 dev 빌드의 로그인을 깨뜨리기 때문이다.
이름은 지금 나눠두므로, 합의가 끝나면 `DEV_` 쪽 값만 교체하면 되고 서버 코드와 워크플로는 손대지 않는다.

> **`GOOGLE_ANDROID_CLIENT_ID`를 신설하는 이유**: 현재 `oauth.android.google.client-id`는 웹 등록과 같은
> `${GOOGLE_CLIENT_ID}`를 참조한다. 이 값은 `OAuthAndroidUserInfoService.validateAudience`가 쓰는
> id_token의 기대 audience다. 웹 구글 자격증명 값을 dev용으로 새로 발급하면서 같은 변수를 계속 공유하면,
> 안드로이드 기대 audience까지 새 값으로 바뀌어 기존 클라이언트 ID로 빌드된 앱의 id_token이
> `AUDIENCE_NOT_MATCHING`으로 전부 거부된다. 따라서 웹과 변수를 끊고 전용 이름에 기존 값을 고정한다.
> `KAKAO_NATIVE_APP_KEY`는 원래부터 독립 변수라 이 조치가 필요 없다.

> **적용 순서**: GitHub Secrets에 새 이름 16종을 먼저 등록하고, 그 다음 워크플로를 머지한다.
> 순서가 어긋나면 클라이언트 자격증명이 빈 값으로 주입되어 해당 환경의 소셜 로그인이 전부 실패한다.
> 이는 `secret-convention.md`의 JWT 교체 절차에 적힌 경고와 같은 성격이다.

> **선행 조건**: 웹 6종의 값을 실제로 나누려면 provider 콘솔에 dev용 앱 등록이 먼저 끝나야 한다.
> 등록 시 각 콘솔에 넣을 리다이렉트 URI는 `https://dev.gravit.inuappcenter.kr/login/oauth2/code/{provider}`와
> `http://localhost:5173/login/oauth2/code/{provider}` 두 개다(dev 프로필이 `local`을 허용하므로).

### 9. redirect-uri 정리

세 프로필과 테스트 프로필의 `registration.*.redirect-uri` 값을 시크릿 참조에서 고정 리터럴로 바꾼다.

```yaml
redirect-uri: "{baseUrl}/login/oauth2/code/{registrationId}"
```

- 런타임에서 읽지 않는 값이므로 내용 자체는 의미가 없다. `ClientRegistration.Builder`의 비어 있지 않음 단언을 만족시키는 것이 유일한 목적이다.
- Spring이 쓰는 표준 템플릿 문자열을 그대로 쓰는 이유는, 나중에 표준 `oauth2Login()` 흐름으로 옮길 때 그대로 동작하기 때문이다.
- `cd-dev.yml`, `cd-prod.yml`에서 `redirect-uri` 주입 줄 6개를 삭제한다.
- 배포 확인 후 GitHub Secrets에서 `DEV_GOOGLE_REDIRECT_URI`, `DEV_KAKAO_REDIRECT_URI`, `DEV_NAVER_REDIRECT_URI`,
  `GOOGLE_REDIRECT_URI`, `KAKAO_REDIRECT_URI`, `NAVER_REDIRECT_URI` 6종을 삭제한다.

### 10. 문서

`.claude/spec/secret-convention.md`

- "환경별로 분리된 값" 표에 OAuth 클라이언트 7종을 추가한다.
- "아직 분리되지 않은 값"에서 OAuth 클라이언트 줄을 제거한다.
- redirect-uri 계열 6종에 대한 문단을, 시크릿을 삭제하고 고정 리터럴로 대체했다는 내용으로 고친다.
- 새 섹션 "OAuth 리다이렉트 URI"에 규칙 두 줄만 적는다. URI 형식이 `{redirect.dests 값}/login/oauth2/code/{provider}`라는 것과,
  dests에 dest를 추가하면 콘솔에도 대응 URI를 등록해야 한다는 것이다.
  dev용 앱 생성과 시크릿 등록 순서는 이번 작업 1회성 실행 항목이라 §8에 두고 convention에 옮기지 않는다.

`.claude/spec/service-policy/auth-security.md`

- 다음 한 줄을 추가한다. 사용자에게 드러나는 판정 기준이므로 정책 파일에 남긴다.
  `- 로그인 후 돌아갈 목적지(dest)의 허용 목록은 서버 환경마다 다르다. 운영 서버는 운영 도메인만 허용한다`

## 결정 필요 (Decisions needed)

- [x] **dev 프로필에 `local` dest를 허용할지** — **허용한다.** 프론트가 로컬 5173에서 dev 서버를 붙어 개발하는 흐름을 유지한다. prod에서 `local`을 막는 이번 작업의 목적은 그대로 달성된다
- [x] **`admin` dest를 어느 프로필에 둘지** — **prod에만 둔다.** 어드민 호스트가 `gravit-admin.inuappcenter.kr` 하나뿐이라 dev 서버가 운영 어드민 주소로 인가 코드를 배달할 이유가 없다
- [x] **자격증명 분리 범위** — **웹 6종만 값까지 분리한다.** 안드로이드 키 2종(`GOOGLE_ANDROID_CLIENT_ID`, `KAKAO_NATIVE_APP_KEY`)은 이름만 `DEV_`, `PROD_`로 나누고 같은 값을 넣는다. 안드로이드 앱 빌드에 영향을 주는 변경이라 안드로이드 팀 합의가 선행돼야 한다
- [x] **안드로이드 구글 audience 변수** — **`GOOGLE_ANDROID_CLIENT_ID`를 신설해 웹 `GOOGLE_CLIENT_ID`와 분리한다.** 웹 값을 dev용으로 새로 발급하는 이번 변경이 안드로이드 id_token 검증까지 끌고 들어가는 것을 막는다
- [x] **redirect-uri 처리 방식** — **고정 리터럴 `"{baseUrl}/login/oauth2/code/{registrationId}"`로 대체한다.** `spring.security.oauth2.client` 설정 자체를 자체 프로퍼티로 걷어내는 방식은 두 Service의 구조 변경을 동반해 갈래 A의 범위를 넘으므로 채택하지 않는다

## 검증

- 신규 단위 테스트 `RedirectDestPropsTest`
  - 허용 목록에 있는 dest면 base URL을 반환한다
  - 허용 목록에 없는 dest면 `DEST_NOT_VALID`를 던진다
  - dest가 `null`이거나 빈 문자열이면 `DEST_NOT_VALID`를 던진다
  - 운영 환경 구성(`Map.of("prod", ...)`)에서 `local`을 요청하면 차단된다 — 이번 작업의 핵심 시나리오
- 기존 테스트 영향
  - `UserDeletionServiceIntegrationTest.유효하지_않은_dest이면_예외를_던진다` — 동작이 유지되어야 한다
  - `UserDeletionServiceIntegrationTest.유효한_유저와_dest이면_메일을_발송한다` — `application-test.yml`에 `redirect.dests`를 넣지 않으면 실패한다
  - `OAuthLoginUrlServiceTest`, `OAuthClientServiceTest`는 현재 전체가 주석 처리되어 있어 영향 없다. 이번 작업에서 되살리지 않는다
- 빌드: `./gradlew build`로 컨텍스트 로딩과 flyway validate까지 확인한다
- 배포 후 수동 확인 (`GET /api/v1/oauth/login-url/google?dest={dest}`)
  - prod 서버에서 `dest=local` → `DEST_NOT_VALID`로 차단. 이번 작업의 핵심 확인 항목이다
  - prod 서버에서 `dest=prod`, `dest=admin` → 정상 발급
  - dev 서버에서 `dest=prod` → `DEST_NOT_VALID`로 차단
  - dev 서버에서 `dest=dev`, `dest=local` → 정상 발급
- 배포 후 소셜 로그인 실제 성공 확인: dev용 앱을 새로 등록한 3사 각각에 대해 dev 환경에서 로그인 한 번씩 통과시킨다.
  자격증명 값이 실제로 바뀌는 변경이라 이 확인 없이 prod로 넘기지 않는다

---

# 갈래 B - 사용자 정보 매핑 통합 (미착수)

> 브랜치: `refactor/467-oauth-userinfo-mapping` (미생성)

## 범위

이슈 #467의 갈래 B 태스크를 그대로 옮긴 것이다. 상세 계획은 이 갈래를 시작할 때 이 섹션에 채운다.

- `GoogleUserInfo`와 `GoogleAndroidUserInfo` 통합 (읽는 키가 `sub`, `email`, `name`으로 OIDC 규격상 동일)
- 클레임 누락 시 예외 처리 기준 통일 (`OAUTH_USER_INFO_INVALID`)
- `AndroidUserInfoFactory`(static switch)와 `OAuthResponseFactory`(Strategy 빈) 통합
- 카카오 안드로이드 매핑을 통합 구조에 태우는 방식 결정 (웹은 카카오 고유 REST 응답, 안드로이드는 OIDC 클레임이라 구조가 실제로 다름)
- 안드로이드 전용 DTO 패키지 정리

## 선행 조건

갈래 A 머지. A가 설정 계층을 바꾸므로 그 위에서 설계한다.

---

# 갈래 C - 안드로이드 검증 구조 통합 (미착수)

> 브랜치: `refactor/467-android-token-verifier` (미생성)

## 범위

이슈 #467의 갈래 C 태스크를 그대로 옮긴 것이다. 상세 계획은 이 갈래를 시작할 때 이 섹션에 채운다.

- `AndroidTokenVerifier` 인터페이스 도입, provider별 구현 분리 (Google, Kakao는 서명 검증, Naver는 제공자 조회)
- `OAuthAndroidUserInfoService`와 `NaverAndroidUserInfoService`를 단일 진입점으로 통합
- 안드로이드 엔드포인트 단일화 여부를 안드로이드 팀과 합의
- 웹 네이버 경로의 resultcode 검증 누락 수정 (검증 위치를 `NaverUserInfo`로 이동)
- `Provider` enum에 값 접근자 추가, `"naver"` 문자열 중복 4곳 제거
- `OAuthAndroidUserInfoService`의 id_token 검증 분기 테스트 작성 (현재 무커버리지)

## 선행 조건

안드로이드 팀과의 엔드포인트 단일화 합의. 합의 결과에 따라 요청 바디 필드명(`idToken` vs `accessToken`) 처리 방식이 달라진다.

---

## Deviation Log

> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다.

- `RedirectDestProps.resolveBaseUrl`: 계획서 코드 조각의 `dest == null` 검사에 `dests == null`을 함께 넣음 — 이유: 프로필에 `redirect` 블록이 통째로 빠지면 `dests`가 null이 되어 `DEST_NOT_VALID` 대신 NPE로 500이 난다. 계획서가 "`application-test.yml`에 없으면 컨텍스트 로딩이 실패한다"고 본 것과 달리 부팅은 정상이고 요청 시점에 터진다
- `UserDeletionService.requestDeleteMailWithMailAuthCode`: `// local, prod 환경별로 다름` 주석 삭제 — 이유: dest 목록이 프로필 설정으로 옮겨져 내용이 사실과 어긋나고, `common.md`가 메인 코드 설명 주석을 금지한다
- `.claude/spec/secret-convention.md`: §10이 지시한 "OAuth 앱 환경별 등록 절차" 섹션 대신 "OAuth 리다이렉트 URI" 규칙 두 줄만 추가 — 이유: 콘솔 앱 생성과 시크릿 등록 순서는 §8에 이미 있는 1회성 실행 항목이라 중복이고, 다른 spec 파일이 규칙 나열 형식을 유지한다. §10 지시도 함께 수정함
- `application-dev.yml`, `application-prod.yml`: `oauth.android.google.client-id`를 `${DEV_GOOGLE_ANDROID_CLIENT_ID}`, `${PROD_GOOGLE_ANDROID_CLIENT_ID}`로 분리 — 이유: 구현 착수 전 검증에서 발견한 계획 결함. §8 표와 결정 항목에 반영 완료
