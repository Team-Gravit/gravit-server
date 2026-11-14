# [PLAN-629] 탈퇴 계정 토큰 요청의 인증 실패 응답 처리

> 이슈: #629
> 브랜치: fix/629-withdrawn-user-token-401

## 목표
탈퇴(소프트 딜리트)한 계정의 액세스 토큰으로 요청하면 지금은 404 `USER_4041`이 응답되어, 클라이언트가 인증 실패로 인식하지 못한다.
토큰 주체를 찾지 못하면 401 전용 코드(`JWT_4017`)로 응답해, 클라이언트의 기존 흐름(401 -> 재발급 실패 -> 로그아웃)으로 처리되게 한다.

## 영향 범위
### 신규 파일
- 없음

### 수정 파일
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - `// JWT` 그룹에 `TOKEN_USER_NOT_FOUND` 추가
- `src/main/java/gravit/code/auth/service/AuthTokenProvider.java` - `parseUser`의 예외 코드를 `USER_NOT_FOUND`에서 `TOKEN_USER_NOT_FOUND`로 교체
- `src/main/java/gravit/code/auth/controller/docs/AuthTokenControllerDocs.java` - 재발급 API의 404 `USER_4041` 응답을 401 `JWT_4017` 예시로 옮김
- `src/test/java/gravit/code/security/filter/JwtAuthFilterIntegrationTest.java` - 없는 유저와 탈퇴 유저 토큰 케이스의 기대값을 401 `JWT_4017`로 변경
- `src/test/java/gravit/code/auth/service/AuthTokenProviderIntegrationTest.java` - `parseUser` 실패 케이스 기대 errorCode를 `TOKEN_USER_NOT_FOUND`로 변경
- `.claude/spec/service-policy/auth-security.md` - 탈퇴 후 남은 액세스 토큰 요청은 인증 실패(401)로 응답한다는 정책 추가 (정책 추가)

## 구현 계획
1. **Entity / Flyway**: 변경 없음
2. **Repository**: 변경 없음
3. **ErrorCode**: `CustomErrorCode`의 `// JWT` 그룹 마지막(`REFRESH_TOKEN_EXPIRED` 아래)에 추가
   - `TOKEN_USER_NOT_FOUND(UNAUTHORIZED, "JWT_4017", "탈퇴했거나 존재하지 않는 사용자의 토큰입니다.")`
4. **Service**: `AuthTokenProvider.parseUser(String token)`
   - `.orElseThrow(() -> new RestApiException(TOKEN_USER_NOT_FOUND))`로 교체
   - static import를 `USER_NOT_FOUND`에서 `TOKEN_USER_NOT_FOUND`로 교체 (이 클래스에서 `USER_NOT_FOUND`를 쓰는 곳은 여기뿐)
   - 호출처 영향
     - `JwtAuthFilter.doFilterInternal` - `RestApiException`을 잡아 `CustomAuthenticationEntryPoint`로 넘기므로 401 `JWT_4017`이 응답됨. 필터 코드는 변경 없음
     - `AuthTokenService.reissue` - 리프레시 토큰 검사(`JWT_4016`)를 먼저 통과해야 도달함. 탈퇴 시 리프레시 토큰이 지워지므로 평소엔 `JWT_4016`이고, 삭제 리스너가 실패한 경우에만 404 대신 401 `JWT_4017`이 나감
     - `TestUserCheatCreateController.generateCustomToken` (QA API) - 탈퇴 유저면 401로 바뀜. Docs에 404를 적어두지 않았으므로 문서 변경 없음
5. **Facade**: 불필요 - 단일 Service 내부 예외 코드 교체
6. **DTO**: 변경 없음
7. **Controller / Docs**: `AuthTokenControllerDocs.reissueToken`
   - 401 응답의 `examples`에 `@ExampleObject(name = "탈퇴했거나 존재하지 않는 사용자", value = "{\"error\" : \"JWT_4017\", \"message\" : \"탈퇴했거나 존재하지 않는 사용자의 토큰입니다.\"}")` 추가, description을 `"🚨 비어 있거나 만료된 리프레시 토큰, 또는 탈퇴한 사용자"`로 변경
   - 404 `USER_4041` `@ApiResponse` 삭제 (더 이상 응답되지 않음)
8. **정책 문서**: `auth-security.md` 마지막 줄("탈퇴를 확정하면 그 계정의 모든 로그인이 끊긴다...") 아래에 추가
   - `- 탈퇴한 계정의 액세스 토큰은 만료 전이라도 쓸 수 없고, 요청하면 인증 실패(401)로 응답한다. 클라이언트는 이를 받으면 다른 인증 실패와 같이 재발급을 시도하고, 재발급도 실패하면 로그아웃한다`

## 결정 필요 (Decisions needed)
- [x] 응답 코드 - 새 코드 `JWT_4017` 추가 / 기존 `TOKEN_INVALID(JWT_4011)` 재사용 -> 새 코드 추가 (이슈 생성 시 확정. 로그에서 위조, 손상 토큰과 구분하기 위함)

## 검증
- 대상 테스트
  - `JwtAuthFilterIntegrationTest.InvalidToken`
    - `존재하지_않는_유저의_토큰이면_TOKEN_USER_NOT_FOUND를_응답한다` - 401, body에 `JWT_4017`, 다음 필터 미호출, 인증 객체 없음
    - `탈퇴한_유저의_토큰이면_TOKEN_USER_NOT_FOUND를_응답한다` - 401, body에 `JWT_4017`, 다음 필터 미호출, 인증 객체 없음
  - `AuthTokenProviderIntegrationTest` `parseUser` 그룹
    - `존재하지_않는_유저이면_예외를_던진다`, `탈퇴한_유저이면_예외를_던진다` - errorCode `TOKEN_USER_NOT_FOUND`
  - 회귀 확인: `AuthTokenControllerIntegrationTest` 전체 (재발급, 로그아웃)

## Deviation Log
- `JwtAuthFilterIntegrationTest`: `탈퇴한_유저의_토큰이면_TOKEN_USER_NOT_FOUND를_응답한다`에 `filterChain.getRequest()` null 검증 추가 - 이유: 계획서 검증 항목(다음 필터 미호출)이 기존 테스트에 빠져 있어, 없는 유저 케이스와 검증 범위를 맞춤
