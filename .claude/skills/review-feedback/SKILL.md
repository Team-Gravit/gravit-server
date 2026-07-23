---
name: review-feedback
description: |
  PR에 달린 코드래빗 피드백을 수집해 코드베이스 기준으로 타당성을 상중하로 판정하고, 사용자가 고른 항목만 수정한다.
  Trigger: "코드래빗 피드백 봐줘", "리뷰 피드백 검토해줘", "PR 리뷰 확인해줘", "코드래빗 뭐라는지 봐줘"
  Do NOT use for: 자체 코드 리뷰(→ logic-reviewer 등 리뷰 에이전트), PR 생성(→ open-pr), 계획 기반 구현(→ implement)
  Boundary: 피드백 판정과 사용자가 선택한 항목의 수정까지 수행한다. 판정만으로 코드를 고치지 않는다.
allowed-tools: Read, Grep, Glob, Edit, Bash(gh *), Bash(git *)
model: opus
effort: xhigh
---

# 리뷰 피드백 검토

현재 PR에 코드리뷰를 남기는 코드래빗은 변경된 파일과 관련된 일부를 기준으로 피드백을 남긴다.
따라서, 피드백을 그대로 수용하지 않고 코드베이스를 이해하고 있는 본 스킬을 통해 코드를 직접 확인한 뒤 타당성을 판정하도록 한다.

대상 PR: $ARGUMENTS (비어있으면 현재 브랜치의 PR)

## Phase 1: 대상 PR 확정

1. $ARGUMENTS에 PR 번호가 있으면 그것을 쓴다.
2. 없으면 현재 브랜치의 PR을 찾아라:
   ```bash
   gh pr view --json number,title,headRefName
   ```
   - PR이 없으면 "PR이 없습니다. 먼저 `open-pr`를 실행하세요"를 알리고 중단하라.

> 다음 Phase 조건: 대상 PR 번호를 확보했을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 2: 피드백 수집

1. 인라인 피드백을 가져와라:
   ```bash
   gh api repos/:owner/:repo/pulls/{번호}/comments \
     --jq '.[] | select(.user.login == "coderabbitai[bot]") | select(.in_reply_to_id == null) | {id, path, line, body}'
   ```
2. 요약 리뷰를 가져와라 (Nitpick과 Outside diff range 항목이 여기에 접혀 있다):
   ```bash
   gh api repos/:owner/:repo/pulls/{번호}/reviews \
     --jq '.[] | select(.user.login == "coderabbitai[bot]") | .body'
   ```
3. 항목마다 대상 클래스와 라인, 지적 요지를 정리하라.
   본문 머리의 코드래빗 자체 심각도(`🔴 Critical`, `🟠 Major`, `🟡 Minor`, `🔵 Trivial`)는 참고로만 기록하고,
   **판정에 그대로 옮기지 마라.** 코드래빗은 diff만 보고 매긴 값이다.
4. 이미 답글이 달린 스레드(같은 PR의 코멘트 중 `in_reply_to_id`가 그 항목을 가리키는 게 있는 경우)는 처리 이력이 있으므로 판정 대상에서 빼고 개수만 보고에 남겨라.
5. 코드래빗 피드백이 0건이면 그 사실을 알리고 종료하라.

> 다음 Phase 조건: 판정 대상 항목 목록이 정리되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 3: 타당성 판정

1. 항목마다 지목된 파일과 그 호출부들을 Read로 직접 읽어라. **피드백 본문만 읽고 판정하지 마라.**
2. 판정 근거로 아래를 확인하라:
   - `.claude/rules/code-convention/` - 컨벤션과 충돌하는 제안인지
   - `.claude/spec/service-policy/`의 해당 도메인 파일 - 서비스 정책에 어긋나는 제안인지
   - 상위, 하위 레이어 - 지적한 위험이 이미 다른 계층에서 막히는지
3. 아래 기준으로 상, 중, 하를 매겨라:
   - **상**: 코드베이스에서 재현 경로가 확인되는 결함이거나, 컨벤션 또는 서비스 정책 위반
   - **중**: 지적 자체는 맞지만 현재 동작에 문제는 없다. 개선 여지 또는 트레이드오프 선택의 문제
   - **하**: 이 코드베이스에서는 부적절하다. 이미 다른 계층에서 방어되거나, 컨벤션과 충돌하거나, 근거 없는 일반론
4. 판정마다 근거를 한 줄로 남겨라. 근거에는 확인한 클래스명까지만 쓰고 파일 경로 전체는 쓰지 마라.

> 다음 Phase 조건: 모든 항목에 판정과 근거가 붙었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 4: 판정 보고

1. [template/verdict-table.md](template/verdict-table.md)를 읽어 그 형식대로 **전체 항목**을 표로 보고하라.
2. **이 시점에 코드를 수정하지 마라.** 상으로 판정한 항목도 예외가 아니다.

> 다음 Phase 조건: 표를 보고하고 사용자 선택을 기다릴 때

> Skip 조건: 없음 (필수 Phase)

## Phase 5: 선택 항목 수정

1. 사용자가 고른 번호만 수정하라. 고르지 않은 항목은 건드리지 마라.
2. 수정은 `.claude/rules/code-convention/`을 따른다. 코드래빗이 제안한 diff를 그대로 붙여넣지 말고, 이 코드베이스의 패턴에 맞춰 다시 써라.
3. 수정으로 서비스 정책이 바뀌면 `.claude/spec/service-policy/`의 해당 도메인 파일도 함께 고쳐라.
4. 수정 범위가 계획서 한 건 수준으로 커지면 여기서 멈추고 `write-plan`을 권하라.

> 다음 Phase 조건: 선택된 항목이 모두 반영되었을 때

> Skip 조건: 사용자가 아무 항목도 고르지 않았을 때

## Phase 6: 결과 보고

1. 보고 템플릿을 Read로 읽어라: `.claude/skills/review-feedback/template/output.md`
2. 템플릿 상단 작성 가이드에 따라 항목을 채워 보고하라. (가이드 주석은 출력에 포함하지 않는다.)

> Skip 조건: 없음 (필수 Phase)
