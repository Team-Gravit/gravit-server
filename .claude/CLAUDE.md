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

세부 규칙은 `.claude/rules/`에 정의되어 있으며, 관련 파일 작업 시 자동 로드된다.

- Git 작업 (커밋, 브랜치, PR) → `git-convention.md`
- 공통 (네이밍, 포맷팅, 예외, 레이어 구조) → `common-code-convention.md`
- 레이어별 (Controller, Facade, Service, Repository) → `layer-convention.md`
- 클래스 타입별 (Entity, DTO) → `class-convention.md`
- 프로젝트 구조 (패키지 배치) → `project-structure.md`
- DB / 마이그레이션 → `database.md`
- 보안 / 인증 / 시크릿 → `security.md`

## Git 작업 (커밋, PR)

커밋·PR은 별도 agent 없이 main Claude가 직접 처리한다. 컨벤션은 `git-convention.md`를 따른다.