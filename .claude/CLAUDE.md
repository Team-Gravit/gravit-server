# Gravit Server

CS(Computer Science) 학습 보조 서비스 백엔드. IT 취준생이 CS 핵심 개념을 반복 학습할 수 있도록 돕는 플랫폼.

## 기술 스택

- Java 21 / Spring Boot 3.5.11 / Gradle
- JPA + PostgreSQL + Flyway (스키마 마이그레이션)
- Redis (캐싱, 메일 인증 코드)
- Spring Security + OAuth2 (Google, Kakao, Naver) + JWT
- springdoc-openapi (Swagger UI)
- Testcontainers (통합 테스트) / H2 (단위 테스트)
- Prometheus + Grafana + Loki (모니터링)
- GitHub Actions CI/CD → Docker Hub → 서버 배포

## 빌드 & 실행

```bash
./gradlew build      # 빌드 (flyway validate 포함)
./gradlew test       # 테스트
./gradlew bootRun    # 로컬 실행 (Docker Compose로 PostgreSQL, Redis 필요)
```

## 규칙 참조

`.claude/rules/` — paths 매칭 파일 작업 시 자동 로드

- 프로젝트 구조 (패키지 배치) → `project-structure.md`
- Flyway 마이그레이션 / SQL → `migration.md`
- 코드 컨벤션 → `code-convention/`
  - 공통 (네이밍, 포맷팅, 예외, 객체 생성, 상수, 레이어 흐름) → `common.md`
  - Entity(domain) + DB 매핑 → `domain.md`
  - DTO(Request/Response) → `dto.md`
  - Controller → `controller.md`
  - Facade → `facade.md`
  - Service → `service.md`
  - Repository → `repository.md`

`.claude/spec/` — 스킬·작업에서 필요할 때만 참조 (자동 로드 아님)

- Git 작업 (커밋, 브랜치, PR) → `git-convention.md`
- 테스트 작성 규칙 → `test-convention.md`
- API 문서 작성 규칙 → `api-docs-convention.md`