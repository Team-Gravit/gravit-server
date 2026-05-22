---
name: implement
description: |
  요구사항 파일(REQ-{번호})을 읽고 기능을 구현한다.
  Trigger: "REQ-{번호} 개발해줘", "REQ-{번호} 구현해줘", "REQ-{번호} 만들어줘"
  Do NOT use for: 테스트 작성(→ write-test), PR 생성(→ create-pr), 요구사항 파일 수정(직접 Edit)
  Boundary: 구현 완료 후 요구사항 파일을 todo → done으로 이동한다. 테스트 코드 작성은 이 스킬 범위 밖이다.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---

# 기능 구현

대상: $ARGUMENTS

## Phase 1: 요구사항 파악

1. `.claude/requirements/todo/REQ-{번호}.md`를 Read로 읽어라
   - 파일이 없으면 `.claude/requirements/done/REQ-{번호}.md`를 확인하라
   - done에 있으면 "이미 완료된 요구사항입니다"를 사용자에게 알리고 중단하라
   - 둘 다 없으면 "요구사항 파일이 존재하지 않습니다"를 알리고 중단하라
2. API 스펙, 비즈니스 규칙, 관련 엔티티를 정리하라

> 다음 Phase 조건: 요구사항 내용이 파악되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 2: 코드베이스 파악

1. 요구사항의 도메인 패키지를 Glob으로 탐색하라
   - 예: `src/main/java/gravit/code/{domain}/**/*.java`
2. 동일 도메인의 Controller, Facade, Service, Repository 파일을 Read로 읽어 기존 패턴을 파악하라
3. 관련 Entity 파일을 찾아 필드와 연관관계를 확인하라

> 다음 Phase 조건: 관련 도메인의 기존 코드 패턴이 파악되었을 때

> Skip 조건: 해당 도메인이 신규라면 유사 도메인 하나를 참고 패턴으로 선택

## Phase 3: 컨벤션 확인

1. `.claude/rules/layer-convention.md`를 Read로 읽어라
2. `.claude/rules/common-code-convention.md`를 Read로 읽어라
3. DB 변경이 필요하면 `.claude/rules/database.md`를 Read로 읽어라

> 다음 Phase 조건: 관련 컨벤션 파일을 모두 읽었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 4: 구현

1. **Facade 필요 여부를 먼저 판단하라**:
   - 여러 도메인 Service를 조합해야 하는 경우 → Facade 사용
   - 단일 Service 호출로 충분한 경우 → Facade 없이 Controller에서 Service 직접 주입
   - 판단 결과를 사용자에게 한 줄로 보고하라 (예: "단일 Service 호출이므로 Facade 없이 진행합니다")

2. 판단 결과에 따라 아래 순서로 구현하라:
   - Entity / Flyway 마이그레이션 (DB 변경 필요 시)
   - Repository
   - Service
   - Facade (Phase 4-1에서 필요하다고 판단한 경우에만)
   - DTO (Request/Response)
   - Controller

3. 각 파일 작성 전, 이미 존재하는지 Glob으로 확인하고 존재하면 Edit으로 추가하라

> 다음 Phase 조건: 요구사항의 모든 API와 비즈니스 규칙이 구현되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 5: 완료 처리

1. 구현한 파일 목록을 정리하라
2. 아래 명령으로 요구사항 파일을 todo → done으로 이동하라:
   ```bash
   mv .claude/requirements/todo/REQ-{번호}.md .claude/requirements/done/REQ-{번호}.md
   ```
3. `.claude/requirements/index.md`를 Read로 읽은 뒤, 해당 항목을 Todo 테이블에서 Done 테이블로 이동하라
4. 구현 완료 사항을 사용자에게 보고하라:
   - 구현된 파일 경로 목록
   - 요구사항 파일 이동 완료 여부

> Skip 조건: 없음 (필수 Phase)
