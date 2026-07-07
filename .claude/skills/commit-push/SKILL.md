---
name: commit-push
description: |
  변경 사항을 git diff로 직접 확인해 작업 성격별로 묶고, 컨벤션에 맞는 커밋 메시지를 만들어 사용자 확인 후 커밋·푸시한다.
  Trigger: "커밋해줘", "커밋하고 푸시해줘", "커밋 푸시해줘", "푸시해줘", "커밋 올려줘"
  Do NOT use for: 이슈·브랜치 생성(→ open-issue), PR 생성(→ open-pr), 코드 구현(→ implement), 코드 리뷰
  Boundary: 커밋 생성과 원격 push까지만 수행한다. PR 생성·머지·리뷰는 범위 밖이다.
allowed-tools: Bash(git *), Read
model: sonnet
effort: xhigh
---

# 커밋·푸시

본 스킬은 변경 사항을 커밋하고 원격에 push한다. 보통 `implement` 종료 후 호출되지만,
plan·implement 산출물은 참고용으로만 보고 실제 변경은 `git diff`로 직접 확인한다.

## Phase 1: 변경 사항 파악

1. `git branch --show-current`로 현재 브랜치를 확인하라. 브랜치명(`{type}/{이슈번호}-{slug}`)에서 이슈 번호를 추출하라.
   - 번호를 못 뽑으면 사용자에게 물어보라. 끝내 없으면 커밋 메시지의 `(#이슈번호)`는 생략한다.
2. 현재 브랜치가 `main` 또는 `dev`면 "main/dev에는 직접 커밋하지 않는다"를 알리고 중단하라.
3. `git status --short`로 스테이징·미스테이징·untracked 상태를 파악하라.
4. `git diff`(미스테이징)와 `git diff --staged`로 실제 변경 내용을 직접 확인하라.
   plan·implement 산출물이 있어도 참고용으로만 쓰고, 무엇이 어떻게 바뀌었는지는 diff로 검증하라.
5. 커밋할 변경이 없으면 그 사실을 알리고 중단하라.

> 다음 Phase 조건: 변경 내용과 이슈 번호를 파악했을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 2: 커밋 그룹핑 & 메시지 초안

1. `.claude/spec/git-convention.md`의 커밋 타입 표를 Read로 확인하라.
2. 변경 파일을 작업 성격별로 묶어라. 성격이 하나면 단일 커밋, 여러 갈래(예: 기능 + 테스트)면 타입별로 분리하고,
   어느 파일이 어느 커밋에 들어가는지(스테이징 계획)를 정하라.
3. 그룹마다 커밋 메시지 초안을 작성하라 — `{type}: 내용(#이슈번호)`.
   내용은 "무엇을 왜"를 한 줄 명사형으로 쓴다 (예: `feat: 북마크 기능 구현(#123)`).

> 다음 Phase 조건: 커밋 그룹과 메시지 초안이 준비되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 3: 사용자 확인

1. 커밋 그룹·메시지 초안·푸시 대상(브랜치, 첫 푸시 여부)을 사용자에게 제시하고 "이렇게 커밋·푸시할까요?"로 확인받아라.
2. 수정 요청이 있으면 반영 후 다시 확인하라. 사용자가 승인하기 전까지 커밋·푸시하지 마라.

> 다음 Phase 조건: 사용자가 승인했을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 4: 커밋 & 푸시

1. 그룹별로 해당 파일만 스테이징(`git add {파일들}`)한 뒤 `git commit -m "{메시지}"`로 커밋하라. 그룹이 여러 개면 반복한다.
2. upstream 상태를 판별해 push하라:
   ```bash
   git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
   ```
   - 출력이 없거나(첫 푸시) `origin/{현재브랜치}`와 다르면 `git push -u origin HEAD`
     (원격 반영 + upstream을 동일명 원격 브랜치로 설정)
   - 출력이 `origin/{현재브랜치}`와 일치하면 `git push`

> 다음 Phase 조건: 커밋·푸시가 완료되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 5: 결과 보고

1. 보고 템플릿을 Read로 읽어라: `.claude/skills/commit-push/template/output.md`
2. 템플릿 상단 작성 가이드에 따라 항목을 채워 보고하라. (가이드 주석은 출력에 포함하지 않는다.)

> Skip 조건: 없음 (필수 Phase)
