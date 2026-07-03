---
description: 커밋, 브랜치, PR 등 Git 작업 시 적용되는 규칙
---

# Git Convention

## 커밋 메시지

형식: `{type}: 커밋 내용(#{이슈번호})`

| type | 용도 | 이슈 라벨 |
|---|---|---|
| feat | 새로운 기능 | 🌼 Feat |
| hotfix | 긴급 수정 | 🔥 HotFix |
| fix | 버그 수정 | 🔨 Fix |
| docs | 문서 변경 | 📚 Docs |
| test | 테스트 추가/수정 | 🙆🏻‍♂️ Test |
| cicd | CI/CD 설정 변경 | 🚦CICD |
| refactor | 리팩토링 | 🧹Refactor |
| chore | 빌드·설정 등 기타 | ⚡️Chore |

> `type`은 커밋 접두사(`{type}:`), 브랜치 접두사(`{type}/`), GitHub 이슈 라벨에 공통으로 쓰인다.

예시: `feat: 북마크 기능 구현(#123)`

## 브랜치 전략

- `main` → `dev` → 각자 개발 브랜치
- main/dev에 직접 커밋하지 마라
- 개발 브랜치 네이밍: `{type}/{이슈번호}-{간단한설명}` (예: `feat/123-bookmark`)
