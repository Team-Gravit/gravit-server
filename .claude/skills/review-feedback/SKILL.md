---
name: review-feedback
description: |
  PR에 달린 코드래빗 피드백을 수집해 코드베이스 기준으로 타당성을 상중하로 판정하고, 사용자가 고른 항목만 수정한다.
  Trigger: "코드래빗 피드백 봐줘", "리뷰 피드백 검토해줘", "PR 리뷰 확인해줘", "코드래빗 뭐라는지 봐줘"
  Do NOT use for: 자체 코드 리뷰(→ logic-reviewer 등 리뷰 에이전트), PR 생성(→ open-pr), 계획 기반 구현(→ implement)
  Boundary: 피드백 판정, 사용자가 선택한 항목의 수정, 반영한 항목의 스레드 resolve까지 수행한다. 판정만으로 코드를 고치지 않는다.
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
   gh pr view --json number,title,headRefName,url
   ```
   - PR이 없으면 "PR이 없습니다. 먼저 `open-pr`를 실행하세요"를 알리고 중단하라.
3. Phase 7 보고에 PR URL이 필요하다. $ARGUMENTS로 번호를 받은 경우에도
   `gh pr view {번호} --json number,title,headRefName,url`로 URL까지 확보하라.

> 다음 Phase 조건: 대상 PR 번호와 URL을 확보했을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 2: 피드백 수집

아래 세 호출 모두 `--paginate`를 빼지 마라. 코멘트와 리뷰는 컬렉션 엔드포인트라 기본 30건까지만 내려주고,
빠뜨린 페이지는 오류 없이 조용히 사라진다. `--slurp`은 `--jq`와 같이 못 쓰므로(gh가 거부한다)
페이지마다 적용되는 스트리밍 필터로 쓴다.

1. 판정 대상인 코드래빗 최상위 인라인 피드백을 가져와라:
   ```bash
   gh api --paginate "repos/{owner}/{repo}/pulls/{번호}/comments" \
     --jq '.[] | select(.user.login == "coderabbitai[bot]") | select(.in_reply_to_id == null) | {id, path, line, body}'
   ```
2. 답글이 달린 원본 코멘트 id를 따로 모아라. 1번은 답글과 사람 코멘트를 이미 걸러낸 결과라
   여기서 답글 여부를 판정할 수 없다. 작성자를 가리지 말고 전부 가져와야 사람이 단 답글도 잡힌다:
   ```bash
   gh api --paginate "repos/{owner}/{repo}/pulls/{번호}/comments" \
     --jq '.[] | select(.in_reply_to_id != null) | .in_reply_to_id'
   ```
3. 요약 리뷰를 가져와라 (Nitpick과 Outside diff range 항목이 여기에 접혀 있다):
   ```bash
   gh api --paginate "repos/{owner}/{repo}/pulls/{번호}/reviews" \
     --jq '.[] | select(.user.login == "coderabbitai[bot]") | .body'
   ```
4. 항목마다 대상과 라인, 지적 요지를 정리하라.
   본문 머리의 코드래빗 자체 심각도(`🔴 Critical`, `🟠 Major`, `🟡 Minor`, `🔵 Trivial`)는 참고로만 기록하고,
   **판정에 그대로 옮기지 마라.** 코드래빗은 diff만 보고 매긴 값이다.
5. 1번 결과 중 `id`가 2번 목록에 있는 항목은 처리 이력이 있으므로 판정 대상에서 빼고 개수만 보고에 남겨라.
6. 코드래빗 피드백이 0건이면 그 사실을 알리고 종료하라.

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
4. 판정마다 근거를 한 줄로 남겨라. 근거에는 확인한 대상의 이름까지만 쓰고 파일 경로 전체는 쓰지 마라.
   Java 코드는 클래스명(필요하면 `클래스:라인`), 클래스가 없는 대상(마이그레이션 SQL, 설정, 문서)은 파일명과
   필요하면 행 번호를 쓴다. 대상 표기 규칙은 `template/verdict-table.md`와 같다.

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

## Phase 6: 반영 항목 resolve 처리

수정해서 반영한 항목만 스레드를 resolve로 바꾼다. 판정만 하고 넘어간 항목은 그대로 둔다.
사용자가 나중에 무엇이 미처리로 남았는지 스레드 상태만 보고 알 수 있어야 하기 때문이다.

1. 스레드 id를 가져와라. 인라인 코멘트 id(`databaseId`)로 스레드를 찾는다:
   ```bash
   gh api graphql -f query='
     query($owner:String!, $repo:String!, $pr:Int!) {
       repository(owner:$owner, name:$repo) {
         pullRequest(number:$pr) {
           reviewThreads(first:100) {
             nodes { id isResolved comments(first:1) { nodes { databaseId } } }
           }
         }
       }
     }' -F owner={owner} -F repo={repo} -F pr={번호} \
     --jq '.data.repository.pullRequest.reviewThreads.nodes[]
           | select(.isResolved | not)
           | {threadId: .id, commentId: .comments.nodes[0].databaseId}'
   ```
2. Phase 5에서 반영한 항목의 코멘트 id에 해당하는 스레드만 resolve 하라:
   ```bash
   gh api graphql -f query='
     mutation($threadId:ID!) {
       resolveReviewThread(input: {threadId: $threadId}) { thread { id isResolved } }
     }' -F threadId={스레드 id}
   ```
3. 요약 리뷰에 접혀 있던 Nitpick과 Outside diff range 항목은 인라인 스레드가 없어 resolve 대상이 아니다.
   반영했더라도 스레드 상태는 바꿀 수 없으니 보고에만 남겨라.

> 다음 Phase 조건: 반영한 인라인 항목의 스레드가 모두 resolve 되었을 때

> Skip 조건: Phase 5를 스킵했을 때(반영한 항목이 없을 때)

## Phase 7: 결과 보고

1. 보고 템플릿을 Read로 읽어라: `.claude/skills/review-feedback/template/output.md`
2. 템플릿 상단 작성 가이드에 따라 항목을 채워 보고하라. (가이드 주석은 출력에 포함하지 않는다.)

> Skip 조건: 없음 (필수 Phase)
