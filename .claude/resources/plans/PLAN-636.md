# [PLAN-636] 운영 관측 설정 보완

> 이슈: #636
> 브랜치: chore/636-observability-config

## 목표
운영에 p95, p99를 낼 히스토그램과 `application` 태그를 넣어 개발과 맞추고, actuator를 외부에 공개된 메인 포트에서 내려 관리 포트(8081)로 옮긴다.
중앙 모니터링 스택이 external로 참조하는 compose 네트워크 이름을 지금 값 그대로 고정해, 배포 디렉터리 이름에 기대지 않게 한다.

## 영향 범위
### 신규 파일
- `src/test/java/gravit/code/security/config/SecurityConfigManagementPortIntegrationTest.java` - 관리 포트 분리 시 메인 포트, 관리 포트 응답과 로그 검증

### 수정 파일
- `src/main/resources/application-prod.yml` - management 블록을 개발과 같게 맞추고 관리 포트 8081 추가
- `src/main/resources/application-dev.yml` - 관리 포트 8081 추가, histogram 키 표기를 운영과 같게 맞춤
- `src/main/java/gravit/code/security/config/SecurityConfig.java` - actuator 허용 매처를 `EndpointRequest.toAnyEndpoint()`로 교체
- `docker-compose-prod.yml` - `gravit-prod` 네트워크를 `name: prod_gravit-prod`, `external: true`로 고정
- `docker-compose-dev.yml` - `gravit-dev` 네트워크를 `name: dev_gravit-dev`, `external: true`로 고정
- `.github/workflows/cd-prod.yml` - `prod_gravit-prod` 존재 보장 한 줄 추가
- `.github/workflows/rollback-prod.yml` - `prod_gravit-prod` 존재 보장 한 줄 추가
- `.github/workflows/cd-dev.yml` - `dev_gravit-dev` 존재 보장 한 줄 추가

## 구현 계획
1. **설정 (application-prod.yml)**: 기존 `management` 블록을 아래로 바꾼다
   ```yaml
   management:
     server:
       port: 8081
     endpoints:
       web:
         exposure:
           include: health, prometheus
     metrics:
       tags:
         application: gravit-prod
       distribution:
         percentiles-histogram:
           "[http.server.requests]": true
         slo:
           "[http.server.requests]": 100ms,200ms,500ms,1s
   ```
2. **설정 (application-dev.yml)**: `management.server.port: 8081`을 추가하고, `percentiles-histogram`의 키를 `"[http.server.requests]"`로 바꿔 운영과 블록 모양을 같게 한다. 값(태그 `gravit-dev`, slo)은 그대로
3. **SecurityConfig.filterChain**: `.requestMatchers("/actuator/**").permitAll()`을 `.requestMatchers(EndpointRequest.toAnyEndpoint()).permitAll()`로 바꾼다. 라벨 주석 `// 모니터링 경로`는 유지
   - 관리 포트를 분리하면 Spring Boot가 부모 컨텍스트의 `springSecurityFilterChain`을 관리 포트 자식 컨텍스트에도 등록한다(`ServletManagementChildContextConfiguration`). 그래서 관리 포트 요청도 이 체인을 지나고, actuator 허용 규칙은 그대로 필요하다
   - 지금 매처(`/actuator/**`)를 두면 메인 포트의 `/actuator/prometheus`가 인증을 통과해 `DispatcherServlet`까지 가고, 정적 리소스 핸들러가 `NoResourceFoundException`을 던진다. `GlobalExceptionHandler.handleException`이 이를 500과 ERROR 스택 트레이스로 남긴다. 전환 기간에 중앙 Prometheus가 :8080을 계속 긁으면 스크랩마다 ERROR 로그와 5xx 지표가 쌓인다
   - `EndpointRequest`는 관리 포트가 다르면 관리 컨텍스트(서버 네임스페이스 `management`)에서만 일치한다. 메인 포트의 `/actuator/**`는 `anyRequest().authenticated()`로 떨어져 401(`TOKEN_EMPTY`)이 되고 ERROR 로그를 남기지 않는다. 관리 포트를 분리하지 않는 local, test, perf 프로파일에서는 지금처럼 노출된 엔드포인트를 허용한다
4. **JwtAuthFilter, WebMvcConfig, HttpLoggingFilter**: 변경 없음. 관리 포트에서도 요청 경로가 `/actuator/**`라 각 제외 규칙이 그대로 일치한다
   - `JwtAuthFilter`는 보안 체인 안에 있어 관리 포트에서도 돌고, `GET /actuator` 접두 제외로 토큰을 보지 않는다
   - `HttpLoggingFilter`는 부모 컨텍스트의 `FilterRegistrationBean`이라 관리 포트 서블릿 컨텍스트에는 등록되지 않는다. 메인 포트에서는 `/actuator/**` 제외가 계속 동작한다
   - `WebMvcConfig` 인터셉터는 `/actuator/**`를 제외하고, actuator 핸들러 매핑에는 붙지 않는다
5. **compose (docker-compose-prod.yml)**: `networks.gravit-prod`를 아래로 바꾼다. `driver: bridge`는 external 네트워크에 쓸 수 없어 뺀다. `gravit-server-prod`의 `ports`는 `"8520:8080"` 그대로 두고 8081은 공개하지 않는다
   ```yaml
   networks:
     gravit-prod:
       name: prod_gravit-prod
       external: true
   ```
6. **compose (docker-compose-dev.yml)**: 같은 방식으로 `networks.gravit-dev`에 `name: dev_gravit-dev`, `external: true`. `ports`는 `"8521:8080"` 그대로
7. **배포 스크립트**: `llm-net` 보장 줄 바로 아래에 같은 형식으로 추가한다
   - `cd-prod.yml`, `rollback-prod.yml`: `docker network inspect prod_gravit-prod >/dev/null 2>&1 || docker network create prod_gravit-prod`
   - `cd-dev.yml`: `docker network inspect dev_gravit-dev >/dev/null 2>&1 || docker network create dev_gravit-dev`
8. **Facade / Service / Repository / DTO / Controller / Flyway**: 불필요 - 설정과 보안 체인만 바뀐다

## 결정 필요 (Decisions needed)
- [x] 메인 포트의 actuator 경로 처리 - `EndpointRequest.toAnyEndpoint()`로 교체해 401로 응답 (`/actuator/**` 유지 시 500과 ERROR 로그). `NoResourceFoundException`을 404로 바꾸는 전역 처리는 모든 미매핑 경로의 응답을 바꾸므로 이번 범위에 넣지 않는다

## 검증
- 대상 테스트: `SecurityConfigManagementPortIntegrationTest` (`RANDOM_PORT`, `management.server.port=0`, exposure `health, prometheus`)
  - 관리 포트로 요청할 때
    - 인증 없이 `/actuator/prometheus`를 200으로 응답한다
    - 유효하지 않은 Bearer 토큰이 있어도 `/actuator/prometheus`를 200으로 응답한다 (`JwtAuthFilter` 제외)
    - 인증 없이 `/actuator/health`를 200으로 응답한다
    - 요청 로그와 API 성능 로그를 남기지 않는다 (같은 테스트에서 메인 포트 API 요청은 남는지 대조)
  - 메인 포트로 요청할 때
    - `/actuator/prometheus`, `/actuator/health`는 401로 응답하고 메트릭을 내보내지 않는다
    - ERROR 로그(`예외 발생`)를 남기지 않는다
- 회귀: `SecurityConfigIntegrationTest`, `JwtAuthFilterIntegrationTest`
- 로컬 기동: `prod`, `dev` 프로파일로 띄워 `:8081/actuator/prometheus`에 `http_server_requests_seconds_bucket`과 `application` 태그가 있고 `:8080/actuator/prometheus`가 메트릭을 내보내지 않는지 확인
- compose: 변경 전 compose로 `-p prod` 인프라 서비스를 띄운 뒤 변경 후 compose로 배포 스크립트와 같은 `up -d --no-deps`를 실행해 컨테이너 ID, 생성 시각 비교

## Deviation Log
- `SecurityConfigManagementPortIntegrationTest`에 `@AutoConfigureObservability(tracing = false)`를 추가했다. `@SpringBootTest`는 기본으로 메트릭 내보내기를 끄므로 Prometheus 레지스트리와 `prometheus` 엔드포인트가 만들어지지 않는다(기동 로그 `Exposing 1 endpoint`). 엔드포인트가 없으면 `EndpointRequest.toAnyEndpoint()`가 그 경로를 포함하지 않아 관리 포트 `/actuator/prometheus`도 401이 된다. 운영 코드에는 영향 없다
- 대조 실험: 매처를 `/actuator/**`로 되돌리면 메인 포트 테스트 3개가 모두 실패한다(500, `예외 발생` ERROR 로그). 계획의 결정이 테스트로 고정되는 것을 확인했다
