---
name: write-plan
description: |
  현재 브랜치에 연결된 GitHub 이슈를 읽어, 클래스·메서드 단위의 구체 구현 계획서를 작성한다.
  Trigger: "계획 세워줘", "작업 계획 만들어줘", "계획서 써줘", "이 이슈 어떻게 구현할지 계획"
  Do NOT use for: 이슈 발의(→ open-issue), 실제 구현(→ implement), 계획서 없이 바로 코딩
  Boundary: 계획서(.claude/resources/plans/PLAN-{번호}.md) 작성까지만 수행한다. 실제 코드 수정은 이 스킬 범위 밖이다.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
model: opus
effort: xhigh
---

# 작업 계획 수립

본 스킬의 산출물은 계획서이며, 사람이 검토하는 핵심 게이트가 이 계획서이다.
추상화 정도를 낮게 유지하라. 어떤 클래스의 어떤 메서드를 어떻게 추가/수정할지까지 명시한다.
실제 코드는 이 스킬에서 절대 수정하지 않는다.

## Phase 1: 이슈 로드

1. 현재 브랜치명에서 이슈 번호를 파싱하라:
   ```bash
   git branch --show-current
   ```
   - 브랜치 컨벤션은 `{type}/{이슈번호}-{slug}` (예: `feat/417-...` → 417).
   - 번호를 못 뽑으면 사용자에게 이슈 번호를 물어보고 중단하라.
2. 이슈 내용을 읽어라:
   ```bash
   gh issue view {번호}
   ```
   - Description, Issue Task, Related Domain을 정리하라.

> 다음 Phase 조건: 이슈 번호와 내용을 확보했을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 2: 코드베이스 파악

1. 이슈의 연관 도메인 패키지를 Glob으로 탐색하라
   - 예: `src/main/java/gravit/code/{domain}/**/*.java`
2. 동일 도메인의 Controller, Facade, Service, Repository를 Read로 읽어 기존 패턴을 파악하라.
3. 관련 Entity의 필드와 연관관계를 확인하라.

> 다음 Phase 조건: 손댈 파일과 기존 패턴이 파악되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 3: 컨벤션 확인

1. 손댈 레이어·타입에 맞는 코드 컨벤션을 `.claude/rules/code-convention/`에서 Read로 읽어라 (공통 `common.md`, 그리고 domain / dto / controller / facade / service / repository 중 해당하는 것).
2. DB 변경이 필요하면 `.claude/rules/migration.md`를 Read로 읽어라.
3. `.claude/spec/service-policy/`에서 대상 도메인 파일만 Read로 읽어라 (어느 파일인지는 같은 디렉토리의 `README.md` 목록에서 찾는다).
   - 기존 정책과 어긋나는 구현을 계획하지 마라. 어긋나야 한다면 그것이 정책 변경임을 계획서에 드러내라.
   - 이번 작업이 정책을 바꾸거나 새 정책을 만들면, 계획서 "영향 범위 - 수정 파일"에 해당 정책 파일을 넣어라.

> 다음 Phase 조건: 관련 컨벤션 파일과 대상 도메인의 서비스 정책 파일을 모두 읽었을 때.
> 정책이 바뀌는 작업이면 계획서 "영향 범위 - 수정 파일"에 해당 정책 파일이 들어갔을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 4: 계획서 작성

1. 계획서 템플릿을 Read로 읽어라: `.claude/skills/write-plan/template/PLAN-template.md`
2. 템플릿의 각 자리표시자를 Phase 1~3에서 파악한 내용으로 채워
   `.claude/resources/plans/PLAN-{번호}.md`로 작성하라
3. 작성 시 지켜야 할 것:
   - 구현 계획은 실제로 수정/추가할 파일의 경로와 클래스+메서드 시그니처를 담는다.
   - Facade 필요 여부를 명확히 판단(여러 도메인의 Service 결합이 있는 경우만)하라.
   - Deviation Log 섹션은 비워둔다.

> 다음 Phase 조건: 계획서 파일이 저장되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 5: 미결정 사항 확정

1. 계획서에 "결정 필요" 항목이 존재하면, 사용자와의 인터렉션을 통해 확정하라
   - 사용자 답변을 반영해 계획서를 수정하고 해당 항목을 `- [x]`로 체크하라.
2. 결정 필요 항목이 없으면 이 Phase를 스킵한다.

> 다음 Phase 조건: 결정 필요 항목이 모두 해소되었을 때

> Skip 조건: "결정 필요" 항목이 애초에 없을 때

## Phase 6: 결과 보고

1. 보고 템플릿을 Read로 읽어라: `.claude/skills/write-plan/template/output.md`
2. 템플릿 상단 작성 가이드에 따라 항목을 채워 보고하라. (가이드 주석은 출력에 포함하지 않는다.)

> Skip 조건: 없음 (필수 Phase)
