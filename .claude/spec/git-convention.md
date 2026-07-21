---
description: 커밋, 브랜치, PR 등 Git 작업 시 적용되는 규칙
---

# Git Convention

## 커밋 메시지

형식: `{type}: 커밋 내용(#{이슈번호})`

| type | 용도 | 이슈 라벨        |
|---|---|--------------|
| feat | 새로운 기능 | 🌼 Feat      |
| hotfix | 긴급 수정 | 🔥 HotFix    |
| fix | 버그 수정 | 🔨 Fix       |
| docs | 문서 변경 | 📚 Docs      |
| test | 테스트 추가/수정 | 🙆🏻‍♂️ Test |
| cicd | CI/CD 설정 변경 | 🚦CICD       |
| refactor | 리팩토링 | 🧹Refactor   |
| chore | 빌드, 설정 등 기타 | ⚡️Chore      |
| analysis | 코드 동작 분석, 조사 | 🧪 Analysis  |

> `type`은 커밋 접두사(`{type}:`), 브랜치 접두사(`{type}/`), GitHub 이슈 라벨에 공통으로 쓰인다.

예시: `feat: 북마크 기능 구현(#123)`

## 제목 규칙

이슈, PR, 커밋 메시지의 제목에 공통으로 적용한다.

- 40자 이내로, 명사형으로 끊어 쓴다
- 대상을 나열하지 말고 "무엇을 해결했는지"를 남긴다
- 클래스명 나열과 괄호 중첩을 쓰지 않는다
- 한국 개발자가 읽어 바로 이해되는 어휘를 쓴다 (번역투, 불필요한 영어 혼용 금지)

| 지양 | 지향 |
|---|---|
| `refactor: 이벤트 리스너 실패 처리 및 복원력 개선 (LearningEventListener/MissionEventListener/DailyLearningRecordListener)` | `refactor: 학습 이벤트 리스너 실패 유실 방지` |
| `hotfix: main-pages 연속 학습일(consecutiveSolvedDays) 응답 위치 이동(learning→weekly-record)` | `hotfix: 연속 학습일 응답 위치 수정` |

## 표기 규칙

- 가운데점(`·`)을 쓰지 않고 콤마(`,`)를 쓴다. (예: `이슈·라벨` → `이슈, 라벨`)
- 적용 범위는 이슈와 PR의 제목과 본문, 그리고 커밋 메시지다.
- 가운데점은 나열인지 수식인지 모호하고, 검색과 복사가 불편하다.

## 팀 로스터

`sukangpunch`, `Jungseokhwan`, `xunssoie`

- PR 리뷰어 자동 지정의 기준 목록이다. 인원이 바뀌면 이 목록만 고친다.

## 브랜치 전략

- `main` → `dev` → 각자 개발 브랜치
- main/dev에 직접 커밋하지 마라
- 개발 브랜치 네이밍: `{type}/{이슈번호}-{간단한설명}` (예: `feat/123-bookmark`)
