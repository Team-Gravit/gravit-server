# [PLAN-422] 커밋·푸시 스킬 신설 및 open-issue 브랜치 원격 동기화 개선

> 이슈: #422
> 브랜치: feat/422-commit-push-skill

## 목표

구현(implement) 이후의 커밋·푸시를 표준화하는 `commit-push` 스킬을 신설한다. 또한 `open-issue`가 `git checkout -b {branch} origin/dev`로 브랜치를 만들면서 upstream을 `dev`로 잡아 발생하던 `git push` 브랜치명 불일치 오류·원격 미반영 문제를, 브랜치 생성 직후 `git push -u origin HEAD`로 정정하도록 개선한다.

이 작업의 산출물은 Java 코드가 아니라 `.claude/skills/`의 스킬 문서(Markdown)이므로, 아래 "구현 계획"은 레이어 순서 대신 이슈의 두 산출물(commit-push 신설 / open-issue 수정) 단위로 구성한다. 기존 스킬(`open-pr`, `implement`, `open-issue`)의 프론트매터·Phase·`template/output.md` 컨벤션을 그대로 따른다.

## 영향 범위

### 신규 파일
- `.claude/skills/commit-push/SKILL.md` — 커밋·푸시 스킬 본문 (프론트매터 + Phase 1~5)
- `.claude/skills/commit-push/template/output.md` — 결과 보고 템플릿

### 수정 파일
- `.claude/skills/open-issue/SKILL.md` — Phase 4에 브랜치 생성 직후 `git push -u origin HEAD` 단계 추가, "다음 Phase 조건"에 원격 반영 포함
- `.claude/skills/open-issue/template/output.md` — 브랜치 항목에 원격 push·upstream 설정 완료 표기 추가

## 구현 계획

> 스킬 문서가 산출물이므로, 각 파일의 프론트매터·Phase 구성·핵심 git 명령까지 구체적으로 명시한다.

### 1. `commit-push/SKILL.md` 신설

**프론트매터** (open-pr/implement와 동일 규격):
```yaml
---
name: commit-push
description: |
  변경 사항을 git diff로 직접 확인해 작업 성격별로 묶고, 컨벤션에 맞는 커밋 메시지를 만들어 사용자 확인 후 커밋·푸시한다.
  Trigger: "커밋해줘", "커밋하고 푸시해줘", "커밋 푸시해줘", "푸시해줘", "커밋 올려줘"
  Do NOT use for: 이슈·브랜치 생성(→ open-issue), PR 생성(→ open-pr), 코드 구현(→ implement), 코드 리뷰
  Boundary: 커밋 생성과 원격 push까지만 수행한다. PR 생성·머지·리뷰는 범위 밖이다.
allowed-tools: Bash(git *), Read
---
```

**본문 제목·인트로**: `# 커밋·푸시` + 1~2문장. "이 스킬은 보통 implement 종료 후 호출되지만, plan/implement 산출물은 참고용으로만 보고 실제 변경은 `git diff`로 직접 확인한다"를 명시.

**Phase 1: 변경 사항 파악**
1. `git branch --show-current`로 현재 브랜치 확인. 브랜치명(`{type}/{이슈번호}-{slug}`)에서 이슈 번호 추출. 번호를 못 뽑으면 사용자에게 물어보고(없이 진행 시 메시지의 `(#번호)` 생략).
2. 현재 브랜치가 `main`/`dev`면 "main/dev에 직접 커밋 금지"를 알리고 중단.
3. `git status --short`로 스테이징/미스테이징/untracked 파악.
4. `git diff`(미스테이징)와 `git diff --staged`로 실제 변경 내용을 직접 확인한다. plan/implement 산출물이 있어도 참고용으로만 쓰고 diff로 검증한다.
5. 커밋할 변경이 없으면 그 사실을 알리고 중단.
   > 다음 Phase 조건: 변경 내용과 이슈 번호를 파악했을 때 · Skip 조건: 없음

**Phase 2: 커밋 그룹핑 & 메시지 초안**
1. `.claude/spec/git-convention.md`의 커밋 타입 표를 Read로 확인.
2. 변경 파일을 작업 성격별로 묶는다. 성격이 하나면 단일 커밋, 여러 갈래(예: 기능 + 테스트)면 타입별로 분리한다. 어느 파일이 어느 커밋에 들어가는지(스테이징 계획)를 정한다.
3. 그룹마다 커밋 메시지 초안 작성 — `{type}: 내용(#이슈번호)`. 내용은 "무엇을 왜"를 한 줄 명사형으로(기존 커밋 스타일: `feat: 북마크 기능 구현(#123)`).
   > 다음 Phase 조건: 커밋 그룹과 메시지 초안이 준비됐을 때 · Skip 조건: 없음

**Phase 3: 사용자 확인**
1. 커밋 그룹·메시지 초안·푸시 대상(브랜치, 첫 푸시 여부)을 제시하고 "이렇게 커밋·푸시할까요?"로 확인받는다.
2. 수정 요청 시 반영 후 재확인. 승인 전까지 커밋·푸시하지 않는다.
   > 다음 Phase 조건: 사용자가 승인했을 때 · Skip 조건: 없음

**Phase 4: 커밋 & 푸시**
1. 그룹별로 해당 파일만 스테이징(`git add {files}`) 후 `git commit -m "{메시지}"`. 그룹이 여러 개면 반복한다.
2. upstream 상태를 판별한다:
   ```bash
   git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
   ```
   - 출력이 없거나(첫 푸시) `origin/{현재브랜치}`와 다르면 `git push -u origin HEAD` (원격 반영 + upstream을 동일명 원격 브랜치로 설정)
   - 출력이 `origin/{현재브랜치}`와 일치하면 `git push`
   > 다음 Phase 조건: 커밋·푸시가 완료됐을 때 · Skip 조건: 없음

**Phase 5: 결과 보고**
1. `.claude/skills/commit-push/template/output.md`를 Read로 읽어 가이드대로 채워 보고. (가이드 주석은 출력에 포함하지 않는다.)

### 2. `commit-push/template/output.md` 신설

기존 output.md 규격(주석 가이드 + 표 + `다음`)을 따른다:
```markdown
<!--
작성 가이드 (이 주석은 출력에 포함하지 마라):
- 생성한 커밋을 짧은 해시·메시지 단위로 나열한다.
- 푸시 결과에 원격 브랜치와 upstream 설정 여부(신규/기존)를 명시한다.
- 아래 표·푸시·다음만 채우고 그 외 서술은 덧붙이지 마라.
-->
## 커밋·푸시 완료

| 커밋 | 메시지 |
|------|--------|
| `{짧은해시}` | `{type}: 내용(#번호)` |

- **푸시**: `{브랜치}` → `origin/{브랜치}` ({신규 upstream 설정 / 기존 추적})
- **다음**: `open-pr`
```

### 3. `open-issue/SKILL.md` Phase 4 수정

현재 Phase 4는 항목 2에서 `git checkout -b {종류}/{이슈번호}-{slug} origin/dev`로 끝난다. 여기에 항목 3을 추가한다:
```markdown
3. 브랜치를 원격에 반영하고 upstream을 정정하라:
   ```bash
   git push -u origin HEAD
   ```
   - `git checkout -b ... origin/dev`는 upstream을 `origin/dev`로 잡아, 이후 `git push`가 브랜치명 불일치로 실패하고 브랜치가 원격에 없다. `-u origin HEAD`로 동일명 원격 브랜치를 만들고 upstream을 그쪽으로 재설정해 재발을 막는다.
```

그리고 Phase 4의 "다음 Phase 조건"을 `새 브랜치로 체크아웃되었을 때` → `새 브랜치로 체크아웃되고 원격에 push(-u)되었을 때`로 수정한다.

### 4. `open-issue/template/output.md` 수정

브랜치 항목이 원격 반영을 드러내도록 수정한다:
- 상단 가이드 주석에 "원격 push·upstream 설정이 끝났음을 브랜치 항목에 드러내라" 한 줄 추가
- `- **브랜치**: \`{브랜치명}\` (base: {base})` → `- **브랜치**: \`{브랜치명}\` (base: {base}, 원격 push·upstream 설정 완료)`

## 결정 필요 (Decisions needed)

없음 — 스킬 동작 범위(git diff로 직접 확인 → 성격별 그룹핑 → 컨벤션 타입 커밋 → 사용자 확인 → `-u` 푸시)와 이슈 종류(feat)는 open-issue Phase 1에서 사용자와 확정함. main/dev 직접 푸시 차단, 첫 푸시 시 `-u` 사용은 기존 컨벤션에서 도출된 기본값이다.

## 검증

- **commit-push 스킬**: 이 브랜치(#422)의 변경(스킬 파일들)을 대상으로 스킬을 실제 호출해 드라이런한다 — `git diff`로 변경 인지 → 성격별 그룹핑(스킬 신설/open-issue 수정) → `feat: ...(#422)` 메시지 초안 → 사용자 확인 → 푸시까지 흐름이 동작하는지 확인. upstream 판별 분기(첫 푸시 `-u` vs 일반 `push`)가 의도대로 갈라지는지 점검.
- **open-issue 개선**: 이번 #422 브랜치는 이미 생성 직후 `git push -u origin HEAD`로 원격 반영·upstream 정정(`origin/feat/422-commit-push-skill` 추적)을 적용해 두어, 개선안이 실제로 push 오류를 없앤다는 것을 선반영·검증했다. 다음 이슈 발의 시 open-issue Phase 4가 자동으로 같은 결과를 내는지 회귀 확인.
- **연계**: open-pr Phase 3은 "현재 브랜치가 원격에 push되어 있지 않으면 중단"한다. commit-push의 `-u` 푸시·open-issue의 생성 시 푸시로 브랜치가 항상 원격에 존재하게 되어, 이후 open-pr가 중단 없이 이어진다.

## Deviation Log

- `commit-push/SKILL.md`: 계획서가 인라인으로 적은 `> 다음 Phase 조건: … · Skip 조건: 없음`을 기존 스킬(open-issue/open-pr/implement)과 동일하게 `> 다음 Phase 조건:` / `> Skip 조건: 없음 (필수 Phase)` 두 줄로 렌더링 — 이유: 목표에 명시한 "기존 스킬 컨벤션을 그대로 따른다"에 맞춤.
