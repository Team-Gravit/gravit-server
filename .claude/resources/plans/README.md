# 작업 계획서 (Plans)

`write-plan` 스킬이 생성하는 **구체 구현 계획서**를 보관하는 디렉토리다.

- 파일명: `PLAN-{이슈번호}.md`
- 템플릿: `.claude/skills/write-plan/template/PLAN-template.md`
- 내용: 클래스·메서드 단위의 구현 계획 + `## 결정 필요` + `## Deviation Log`
- 생명주기: `open-issue`(이슈·브랜치) → `write-plan`(계획서 작성·검토) → `implement`(계획서대로 구현)

계획서는 "어떻게 구현할지(how)"의 단일 출처다.
"무엇을/왜(what)"는 GitHub 이슈가 담당한다 — 둘을 중복 기술하지 마라.

구현 중 계획을 벗어난 지점은 `implement` 스킬이 각 계획서의 `## Deviation Log`에 기록한다.