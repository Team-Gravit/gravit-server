---
name: open-pr
description: |
  PR을 생성한다. PULL_REQUEST_TEMPLATE.md 규격에 맞춰 본문을 작성하고, 담당자와 리뷰어를 지정해 gh pr create를 실행한다.
  Trigger: "PR 날려줘", "PR 만들어줘", "PR 생성해줘", "PR 올려줘"
  Do NOT use for: 커밋 생성(직접 git commit), 브랜치 생성, 코드 리뷰
  Boundary: PR 생성과 담당자, 리뷰어 지정까지만 수행한다. 머지와 코드 리뷰는 범위 밖이다.
allowed-tools: Bash(git *), Bash(gh *), Read, Write
model: sonnet
effort: xhigh
---

# PR 생성

대상 브랜치: $ARGUMENTS (비어있으면 dev)

## Phase 1: 현재 브랜치 및 변경 사항 파악

1. `git branch --show-current`로 현재 브랜치명을 확인하라
2. 브랜치명에서 이슈 번호를 추출하라 (형식: `{type}/{이슈번호}-{설명}`)
   - 예: `feat/123-bookmark` → 이슈 번호 `123`
   - 이슈 번호가 없으면 사용자에게 물어보라
3. `git log dev..HEAD --oneline` (또는 $ARGUMENTS..HEAD)으로 이 브랜치의 커밋 목록을 확인하라
4. `git diff dev...HEAD --stat`으로 변경된 파일 목록을 파악하라

> 다음 Phase 조건: 이슈 번호와 변경 사항이 파악되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 2: PR 제목 및 본문 작성

**이 PR 본문은 이력서와 경험 기술서의 소스로 쓰인다.**
Problem과 Solution만 읽어도 "무엇이 왜 문제였고, 어떤 방법을 왜 골랐는지"가 서술로 남게 써라.

1. `.github/PULL_REQUEST_TEMPLATE.md`를 Read로 읽어 섹션 구조(`PR Summary`, `Problem`, `Solution`, `Related Issue`)를 그대로 따르라.
   - 템플릿의 HTML 주석(`<!-- ... -->`)은 작성 가이드다. 본문에 포함하지 마라.
   - 섹션 제목은 `##`, 섹션 사이의 `<br>`은 렌더링 장식이다. 지우거나 바꾸지 말고 그대로 유지하라.
2. `.claude/spec/git-convention.md`를 Read로 읽어 커밋 메시지 형식, 제목 규칙, 표기 규칙을 확인하라.
3. PR 제목은 `{type}: {설명}(#{이슈번호})` 형식으로, git-convention.md의 제목 규칙을 따른다.
   - (지양) `refactor: 알림/소셜피드/유저리그 리스너 Redis 재시도 큐 기반으로 전환`
   - (지향) `refactor: 이벤트 리스너 실패 유실 방지용 재시도 큐 도입(#434)`
4. 문체
   - 본문 서술은 존댓말(`~합니다`, `~했습니다`)
   - 소제목은 명사형으로 끊어라 (예: `**해결 2 - 전파 속성을 REQUIRES_NEW로 변경**`)
   - 표기 규칙(가운데점 대신 콤마, 긴 대시 대신 짧은 대시)을 지켜라
5. 섹션별 작성 규칙
   - **PR Summary**: 변경 사항을 1~2문장으로. 여기서 전체 그림이 잡히게 하라
   - **Problem**: 문제 상황과 원인. 그래서 무엇이 잘못되고 있었는지(영향)를 반드시 드러내라
   - **Solution**: 채택한 방법과 그것을 고른 이유. 접근의 핵심이 되는 클래스나 설정명만 필요할 때 언급하라
   - **Related Issue**: `- close #{이슈번호}`
6. 문제가 여러 개면 번호로 분기하고, Problem과 Solution의 번호를 1:1로 맞춰라.
   문제가 하나면 번호를 붙이지 말고 문단으로만 써라.

   ```
   ## Problem
   **문제 1 - 커밋 이후 처리 실패 유실**
   ...
   **문제 2 - 유저리그 생성 시 매 호출 예외 발생**
   ...

   ## Solution
   **해결 1 - 이벤트 적재와 처리 분리**
   ...
   **해결 2 - 전파 속성을 `REQUIRES_NEW`로 변경**
   ...
   ```

7. 금지 사항
   - 변경 파일과 메서드를 나열하지 마라. diff가 이미 보여준다
   - 각 문단은 2~4문장으로 유지하라. 내용이 없는데 분량을 채우지 마라 (작은 변경은 짧은 게 정상이다)
   - 커밋 메시지를 그대로 복사하지 마라. 변경을 이해한 뒤 문제와 해결의 언어로 다시 써라

> 다음 Phase 조건: 제목과 본문이 완성되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 3: PR 생성

1. 대상 브랜치를 결정하라:
   - $ARGUMENTS가 있으면 해당 브랜치로
   - 없으면 `dev`로
2. 현재 브랜치가 원격에 push되어 있는지 `git status`로 확인하라
   - push되지 않았으면 사용자에게 알리고 중단하라
3. 담당자와 리뷰어를 산출하라:
   ```bash
   gh api user --jq .login
   ```
   - 담당자: 호출자 본인(`@me`)
   - 리뷰어: `.claude/spec/git-convention.md`의 팀 로스터에서 호출자를 제외한 나머지
   - 호출자가 로스터에 없으면 리뷰어 지정을 건너뛰고, 그 사실을 보고에 남겨라
4. 본문은 스크래치 파일에 저장한 뒤 `--body-file`로 넘겨라 (긴 본문의 셸 이스케이프 사고를 막는다).
5. 다음 명령으로 PR을 생성하라:
   ```bash
   gh pr create --title "{제목}" --body-file {본문파일} --base {대상 브랜치} \
     --assignee @me --reviewer {리뷰어1},{리뷰어2}
   ```
   - `--reviewer`가 실패해도 PR 생성 자체는 되돌리지 마라. `gh pr edit {번호} --add-reviewer {리뷰어}`로 1회 재시도하고,
     그래도 실패하면 실패 사실을 보고에 남겨라 (권한이 없는 계정일 수 있다).

> 다음 Phase 조건: PR이 생성되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 4: 결과 보고

1. 보고 템플릿을 Read로 읽어라: `.claude/skills/open-pr/template/output.md`
2. 템플릿 상단 작성 가이드에 따라 항목을 채워 보고하라. (가이드 주석은 출력에 포함하지 않는다.)

> Skip 조건: 없음 (필수 Phase)
