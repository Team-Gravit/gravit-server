---
name: implement
description: |
  계획서(PLAN-{번호})를 읽고 그대로 기능을 구현한다.
  Trigger: "구현해줘", "PLAN-{번호} 구현해줘", "계획서대로 만들어줘", "이 계획 구현 시작"
  Do NOT use for: 계획 수립(→ write-plan), 이슈 발의(→ open-issue), 테스트 작성(→ write-test), PR 생성(→ open-pr)
  Boundary: 계획서대로 코드를 구현한다. 계획을 새로 짜지 않는다. 테스트 코드 작성은 이 스킬 범위 밖이다.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
effort: xhigh
---

# 기능 구현 (계획서 기반)

본 스킬은 이미 검토된 계획서를 기준으로 구현되며, 계획에 대한 추가와 수정, 삭제를 금지한다.
구현 중 이슈가 발생하면, 심각도에 따라 다르게 처리하며, 분기는 아래와 같다.

**critical**
1. 계획에 논리적 오류가 존재하는 경우
2. 결정되지 않은 사항이 발견된 경우

> 진행을 멈추고 사용자와의 인터렉션을 통해 명확한 답을 받은 뒤 진행

**trivial**
1. 로직 자체에는 오류가 없지만, 사용자 직관이 더해지면 좋은 경우
2. 기존 계획된 로직을 우아하게 개선이 가능한 경우

> 계획서의 `Deviation Log`에 `- {파일}: {바꾼 것} — 이유: {이유}` 형식으로 기록하고 게속 진행한다.

## Phase 1: 계획서 로드

1. 대상 계획서를 찾아라:
   - $ARGUMENTS에 번호가 있으면 `.claude/resources/plans/PLAN-{번호}.md`
   - 없으면 현재 브랜치명에서 이슈 번호를 파싱해 사용하라 (`git branch --show-current`).
2. 계획서를 Read로 읽어라.
   - 파일이 없으면 "계획서가 없습니다. 먼저 `write-plan` 스킬을 실행하세요"를 알리고 중단하라.
   - "결정 필요"에 미체크 항목이 남아있으면, 이는 치명적이므로 사용자에게 확정을 요청하고 반영(계획서 Edit) 전까지 구현을 시작하지 마라.

> 다음 Phase 조건: 계획서를 읽었고 미결정 항목이 없을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 2: 구현

1. 계획서 "구현 계획"에 명시된 순서(레이어 순)대로 구현하라:
   - Entity / Flyway 마이그레이션 → Repository → Service → Facade(계획서가 필요하다고 한 경우만) → DTO → Controller
2. 각 파일 작성 전 이미 존재하는지 Glob으로 확인하고, 존재하면 Edit으로 추가하라.
3. 계획서에 적힌 클래스·메서드 시그니처와 경로를 그대로 따르라.
4. public 엔드포인트를 추가·변경하면 `SecurityConfig`의 `permitAll()`과 `JwtAuthFilter.EXCLUDE_ENDPOINTS`를 함께 수정하라 (한쪽만 바꾸면 인증 우회 또는 401). Admin 전용 경로는 `.hasRole("ADMIN")`.

> 다음 Phase 조건: 계획서의 모든 항목이 구현되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 3: 완료 처리

1. 보고 템플릿을 Read로 읽어라: `.claude/skills/implement/template/output.md`
2. 템플릿 상단 작성 가이드에 따라 항목을 채워 보고하라. (가이드 주석은 출력에 포함하지 않는다.)

> Skip 조건: 없음 (필수 Phase)
