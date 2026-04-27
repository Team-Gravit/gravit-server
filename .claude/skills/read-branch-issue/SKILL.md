---
name: read-branch-issue
description: |
  현재 작업 브랜치와 연결된 GitHub 이슈를 읽어 컨텍스트로 숙지한다.
  Trigger: "브랜치 이슈 읽어줘", "이 브랜치 이슈 확인해줘", "현재 작업 이슈 알려줘", "이슈 숙지해줘"
  Do NOT use for: 특정 이슈 번호로 직접 조회(`gh issue view <번호>` 직접 사용), 이슈 생성/수정, PR 조회
  Boundary: 이슈 내용 조회와 핵심 요약까지만 수행한다. 이슈 기반 구현은 사용자 확인 후 별도로 진행한다.
allowed-tools: Bash(git branch*), Bash(git rev-parse*), Bash(gh issue view*)
---

# 브랜치 이슈 숙지

## Phase 1: 브랜치에서 이슈 번호 추출

1. `git rev-parse --abbrev-ref HEAD`로 현재 브랜치명을 확인하라
2. 브랜치명에서 이슈 번호를 추출하라 (예: `feat/325-back-office-auth` → `325`)
   - 패턴: `{type}/{number}-{slug}` 또는 `{type}/{number}` 형태
   - 숫자가 여러 개면 가장 앞의 숫자 사용
3. 이슈 번호를 추출할 수 없으면 사용자에게 보고하고 종료하라

> 다음 Phase 조건: 이슈 번호가 추출되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 2: 이슈 조회

1. `gh issue view {번호}`로 이슈를 조회하라
2. 조회 실패(존재하지 않거나 권한 없음) 시 에러 메시지를 사용자에게 보고하고 종료하라

> 다음 Phase 조건: 이슈 본문이 정상 조회되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 3: 숙지 및 요약 보고

1. 이슈 본문에서 다음 항목을 추출하라:
   - **제목**: 이슈 제목 한 줄
   - **목적**: Issue Description 또는 본문 첫 단락 요약 (1~2문장)
   - **Task 목록**: 체크박스(`- [ ]` / `- [x]`) 항목을 그대로 나열, 완료 여부 표시 유지
   - **관련 도메인**: Related Domain 섹션의 체크된 항목
   - **상태/라벨/담당자**: state, labels, assignees
2. 사용자에게 위 항목을 구조화해서 보고하라
3. 보고 마지막에 다음 한 줄을 덧붙여라: "이 이슈 컨텍스트로 작업 진행할게. 어디부터 시작할까?"

> Skip 조건: 없음 (필수 Phase)