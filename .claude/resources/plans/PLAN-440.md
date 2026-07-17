# [PLAN-440] Admin API 스웨거 문서 노출 제외

> 이슈: #440
> 브랜치: docs/440-exclude-admin-api-from-swagger

## 목표

백오피스 전용 Admin API 11개 컨트롤러(`/api/v1/admin/**`)를 모든 환경의 OpenAPI 스펙에서 제외한다. `springdoc.paths-to-exclude`를 `application.yml`에 추가해 경로 기반으로 걸러내므로, 향후 Admin 컨트롤러가 추가돼도 자동 적용된다.

> 보안이 아니라 문서 위생 작업이다. `SecurityConfig:58`이 이미 `/api/v1/admin/**`에 `hasRole("ADMIN")`을 걸어 인가를 통제하고 있고, 이번 변경은 문서에서 감추기만 한다. 엔드포인트는 그대로 살아 있으므로 "숨겼으니 안전하다"고 취급하면 안 된다.

## 영향 범위

### 신규 파일
- 없음

### 수정 파일
- `src/main/resources/application.yml` — 최상위에 `springdoc` 블록 신설 (현재 이 파일에 `springdoc` 키 없음) + `paths-to-exclude`
- `src/main/resources/application-dev.yml:127` — 기존 `springdoc` 블록에 `paths-to-exclude` 추가
- `src/main/resources/application-prod.yml:131` — 기존 `springdoc` 블록에 `paths-to-exclude` 추가

> **세 곳에 중복 선언하는 이유**: Spring Boot는 프로파일 yml을 키 단위로 병합하므로 `application.yml` 한 곳이면 dev/prod에도 적용된다. 즉 dev/prod 선언은 기능상 불필요하다. 그럼에도 명시하는 건 이 프로젝트의 프로파일 yml이 **오버레이가 아니라 자립형 설정**으로 쓰이기 때문이다 — `application-prod.yml`은 `jwt`·`token`·`scheduler`·`user-delete-mail`·`admin`·`firebase`·`app.version`을 application.yml과 같은 값으로 전부 재선언한다. 그 관행을 따른다.
> **트레이드오프**: 같은 값이 3곳에 있어 한 곳만 고치면 조용히 어긋난다. 값이 상수(`/api/v1/admin/**`)이고 프로파일별로 달라질 이유가 없어 감수한다.

### 수정하지 않는 파일 (확인 완료)
- `src/test/resources/application-test.yml` — `springdoc` 키 없음 → 공통 설정이 test 프로파일에도 그대로 적용된다.
- `src/main/java/gravit/code/global/config/SwaggerConfig.java` — 변경 불필요. `tagOrderCustomizer()`는 springdoc이 채운 태그 목록을 정렬만 하므로, Admin 태그가 애초에 생성되지 않으면 자동으로 대상에서 빠진다.
- `src/main/java/gravit/code/admin/controller/docs/*.java` (11개) — `@Hidden` 부착하지 않음. 경로 기반 제외와 중복이라 한쪽만 고칠 때 어긋난다.

## 구현 계획

1. **Entity / Flyway**: 불필요 — DB 변경 없음.

2. **Repository / Service / Facade / DTO / Controller**: 불필요 — 런타임 코드 변경 없음. 설정 한 곳만 바꾼다.

3. **설정**: 세 파일에 `springdoc.paths-to-exclude: /api/v1/admin/**`를 넣는다.

   | 파일 | 위치 |
   |---|---|
   | `application.yml` | `app:` 블록(120행) 앞에 `springdoc` 블록 신설 |
   | `application-dev.yml` | 기존 `springdoc` 블록(127행) 안, `server-url` 아래 |
   | `application-prod.yml` | 기존 `springdoc` 블록(131행) 안, `server-url` 아래 |

   ```yaml
   springdoc:
     server-url: ...          # 기존 (dev/prod만)
     paths-to-exclude: /api/v1/admin/**
   ```

   - `springdoc.paths-to-exclude`는 springdoc-openapi 2.8.9의 `List<String>` 프로퍼티(`spring-configuration-metadata.json`에서 확인)로, 단일 값도 리스트로 바인딩된다.
   - Ant 패턴 매칭이라 `/api/v1/admin/**`가 하위 11개 경로(`/dashboard`, `/me`, `/problems`, `/lessons`, `/units`, `/reports`, `/chapters`, `/notices`, `/users`, `/inquiries`, `/staging`)를 모두 덮는다. **예외 경로 없음을 전수 확인함.**
   - 주석은 `application.yml`에만 단다(중복 주석 방지). 남길 것: 백오피스 전용이라 공개 문서에서 제외한다는 의도, 인가는 SecurityConfig가 담당한다는 것, 그리고 **이 제외가 `/api/v1/admin/**` 경로 컨벤션에 의존하므로 Admin 컨트롤러는 이 접두사를 벗어나면 안 된다**는 제약.

4. **테스트**: 신규 테스트를 작성하지 **않는다**.
   - 이 프로젝트의 테스트 컨벤션상 모든 테스트가 `@TCSpringBootTest`(PostgreSQL·Redis 컨테이너)라, yml 한 줄을 검증하려고 컨테이너를 띄우는 건 비용 대비 가치가 낮다. `paths-to-exclude` 준수는 springdoc이 보증할 몫이다.
   - **감수하는 리스크**: 향후 누군가 `/api/v1/admin/**` 밖 경로에 Admin 컨트롤러를 만들면 조용히 문서에 노출된다. 경로 컨벤션 준수에 의존한다는 뜻이며, 기존 `SwaggerTagOrderIntegrationTest`도 이 케이스는 잡지 못한다. 아래 3번의 yml 주석으로 경로 규칙 의존을 명시해 완화한다.

5. **기존 테스트 영향**: `SwaggerTagOrderIntegrationTest`는 **수정 불필요**로 판단.
   - 이 테스트는 `Admin` 태그를 이름으로 특정하지 않는다. `businessTags`(정렬 여부)·`testTags`(맨 아래 그룹) 두 그룹만 본다.
   - Admin 태그가 빠져도 `businessTags`는 여전히 비어있지 않고(Chapter/User/League 등 잔존) 알파벳순이 유지되므로 그대로 통과한다.
   - 단, 실제 실행으로 확인한 뒤 결과를 Deviation Log에 남긴다.

## 결정 필요 (Decisions needed)

- [x] 제외 검증 테스트 작성 여부 — **작성하지 않음**으로 확정. 컨테이너 기반 통합 테스트만 가능한 구조라 yml 한 줄 대비 비용이 과하다. (2026-07-17, 사용자 결정)
- [x] 선언 위치 — **application.yml + dev + prod 세 곳 모두**로 확정. 기능상 공통 한 곳이면 충분하지만, 프로파일 yml을 자립형으로 쓰는 기존 관행을 따른다. (2026-07-17, 사용자 결정)

## 검증

- 회귀 테스트: `SwaggerTagOrderIntegrationTest` — 무수정 통과 확인 (`./gradlew test --tests "*Swagger*"`)
- 수동 확인: `./gradlew bootRun` 후 `/v3/api-docs`와 `/swagger-ui/index.html`에서
  - `Admin *` 태그 11개 소멸, `paths`에 `/api/v1/admin/` 키 없음
  - 일반 API·`Test *` 태그는 기존과 동일하게 잔존 (제외 규칙이 과하게 먹지 않았는지)
  - Admin 엔드포인트 자체는 살아 있음 (문서에서만 감춘 것이므로 호출은 여전히 200/403으로 응답)

## Deviation Log

- **`application.yml`은 gitignore 대상이었다 (계획의 전제 오류)** — `.gitignore:25`에 등록된 로컬 전용 파일로, 실제 시크릿(`jwt.secret`, OAuth client-secret, SMTP 비번)이 평문으로 들어있고 리포지토리에 없다(`git ls-files` 확인). CI(`cd-prod.yml:64`)는 체크아웃 후 `-Dspring.profiles.active=prod`로 빌드하며 `application-prod.yml`에만 환경변수를 주입하므로, **배포 산출물에 `application.yml`이 존재하지 않는다.**
  - 따라서 "공통 yml 한 곳이면 프로파일에 병합된다"는 계획의 근거는 이 프로젝트에 성립하지 않는다. 병합할 원본이 배포본에 없다.
  - **dev/prod 선언은 관행이 아니라 기능상 필수**였다. 공통에만 넣었다면 운영에서 Admin API가 그대로 노출됐다.
  - `application-prod.yml`이 `jwt`·`token`·`admin` 등을 재선언하는 것도 스타일이 아니라 필연이었다.
  - 실질 산출물은 `application-dev.yml`·`application-prod.yml` 2개다. `application.yml`에도 넣었으나 커밋되지 않으며 로컬 무프로파일 실행용으로만 남는다.
- **테스트를 만들었다면 CI에서 깨졌을 것** — 테스트는 `test` 프로파일로 도는데 `application-test.yml`에 `springdoc` 키가 없다. 로컬은 `application.yml`이 있어 통과하지만 CI(`ci-common.yml`)는 그 파일이 없어 실패했을 것이다. 테스트를 넣으려면 `application-test.yml`에도 선언이 필요하다.
- **검증 방식 변경** — 계획의 `bootRun` 수동 확인은 로컬 DB 인증 실패로 불가(`postgres_data_local`에 기존 데이터가 있어 컨테이너가 `POSTGRES_PASSWORD`를 무시함. 사용자 데이터라 미조치). 대신 Testcontainers 기반 임시 프로브 2개를 작성해 `/v3/api-docs`를 직접 관측한 뒤 삭제했다.

  | 조건 | Admin 경로 | Admin 태그 | 비고 |
  |---|---|---|---|
  | `paths-to-exclude` 적용 (현재) | 0 | 0 | 일반 경로 81개·`Test *` 태그 5개는 잔존 |
  | `paths-to-exclude` 무력화 (대조군) | 32 | 11 | 규칙이 실제 원인임을 확인 |

  `SwaggerTagOrderIntegrationTest`는 예상대로 무수정 통과.
