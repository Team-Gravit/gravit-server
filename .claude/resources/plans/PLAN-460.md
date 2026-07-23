# [PLAN-460] Claude Code 설정 개편 및 리뷰 피드백 검토 스킬 추가

> 이슈: #460
> 브랜치: chore/460-claude-config-revamp

## 목표
에이전트 상호작용 규칙과 주석 규칙을 설정에 명시하고, 코드래빗 피드백을 코드베이스 기준으로 선별하는 스킬과 서비스 정책 SSOT 문서를 신설한다.
정책 문서는 코드가 바뀔 때 함께 갱신되도록 코드 변경 스킬에 갱신 의무를 건다.

## 영향 범위
### 신규 파일
- `.claude/skills/review-feedback/SKILL.md` - 코드래빗 피드백 수집, 타당성 판정, 사용자 선택 기반 수정 스킬
- `.claude/skills/review-feedback/template/output.md` - 검토 결과 보고 템플릿
- `.claude/spec/service-policy.md` - 서비스, 비즈니스 정책 SSOT

### 수정 파일
- `.claude/CLAUDE.md` - 상호작용 규칙 섹션 추가, spec 목록에 `service-policy.md` 한 줄 추가
- `.claude/rules/code-convention/common.md` - 주석 규칙 섹션 추가, 기존 예시 코드의 설명 주석 제거
- `.claude/skills/write-plan/SKILL.md` - 계획 수립 시 정책 문서 참조와 정책 변경 판단 단계 추가
- `.claude/skills/implement/SKILL.md` - 구현으로 정책이 바뀌면 `service-policy.md`를 함께 수정하는 단계 추가

## 구현 계획
> 이번 작업은 Java 레이어 변경이 아니라 `.claude` 설정 변경이다. 레이어 순서 대신 작업 단위 순서로 기술한다.

### 1. 상호작용 규칙 (`.claude/CLAUDE.md`)

`## 규칙 참조` 위에 `## 상호작용 규칙` 섹션을 신설한다. 담을 내용:

- 사용자의 관찰, 의문 표현(`~한 부분이 있네?`, `이거 왜 이렇게 했어?`, `~인 것 같은데`)은 수정 지시가 아니다.
  먼저 해당 코드를 확인하고 **문제인지 아닌지에 대한 판단과 근거**를 제시하라. 수정 여부는 사용자가 정한다.
- 수정에 착수하는 조건은 명시적 지시(`고쳐줘`, `수정해`, `반영해`, `바꿔줘`)뿐이다.
- 사용자의 지적이 사실과 다르면 동의하지 말고 근거를 들어 다른 판단을 말하라. 반복 지적도 동조 사유가 아니다.
- 사용자가 판단을 재확인해도 근거가 바뀐 게 아니면 결론을 뒤집지 마라.

CLAUDE.md는 항상 로드되므로 `rules/`(paths 매칭 자동 로드)가 아니라 여기에 둔다.

### 2. 주석 규칙 (`.claude/rules/code-convention/common.md`)

`## 네이밍` 뒤에 `## 주석` 섹션을 추가한다. 담을 내용:

- 메인 코드에 설명 주석을 달지 마라. 이름과 구조로 드러내라
- 유지하는 예외: `CustomErrorCode`의 카테고리 그룹 주석(`// User`, `// Auth` 등)처럼 이미 구조를 나누는 용도의 주석
- 배경과 정책 설명이 필요하면 주석이 아니라 `.claude/spec/service-policy.md`에 남겨라

같은 파일 `## 메서드 본문 구성`의 예시 코드블록에 있는 `// 한 도메인/단계 처리`, `// 다음 도메인/단계 처리`, `// 응답 조립` 세 줄을 제거한다.
규칙과 예시가 서로 충돌하기 때문이다. 빈 줄 구분이 이미 예시의 요점이므로 주석 없이도 의도는 전달된다.

> 기존 메인 코드에 남아있는 주석 241줄(68개 파일) 일괄 제거는 이번 이슈 범위 밖이다. 규칙 추가까지만 한다.

### 3. 리뷰 피드백 검토 스킬 (`.claude/skills/review-feedback/SKILL.md`)

frontmatter:
```yaml
name: review-feedback
description: |
  PR에 달린 코드래빗 피드백을 수집해 코드베이스 기준으로 타당성을 상중하로 판정하고, 사용자가 고른 항목만 수정한다.
  Trigger: "코드래빗 피드백 봐줘", "리뷰 피드백 검토해줘", "PR 리뷰 확인해줘", "코드래빗 뭐라는지 봐줘"
  Do NOT use for: 자체 코드 리뷰(→ logic-reviewer 등 에이전트), PR 생성(→ open-pr), 구현(→ implement)
  Boundary: 피드백 판정과 사용자가 선택한 항목의 수정까지 수행한다. 판정만으로 코드를 고치지 않는다.
allowed-tools: Read, Grep, Glob, Edit, Bash(gh *), Bash(git *)
model: opus
effort: xhigh
```

Phase 구성:

**Phase 1: 대상 PR 확정**
- `$ARGUMENTS`에 PR 번호가 있으면 그것을, 없으면 `gh pr view --json number,title,headRefName --jq` 로 현재 브랜치의 PR을 쓴다
- PR이 없으면 "PR이 없습니다. 먼저 `open-pr`를 실행하세요"로 중단

**Phase 2: 피드백 수집**
- 인라인: `gh api repos/:owner/:repo/pulls/{n}/comments --jq '[.[] | select(.user.login == "coderabbitai[bot]") | select(.in_reply_to_id == null) | {id, path, line, body}]'`
- 요약 리뷰(Nitpick 포함): `gh api repos/:owner/:repo/pulls/{n}/reviews --jq '.[] | select(.user.login == "coderabbitai[bot]") | .body'`
- 코드래빗 본문 머리의 자체 심각도(`🔴 Critical` / `🟠 Major` / `🟡 Minor` / `🔵 Trivial`)와 카테고리를 함께 뽑되, **이 값을 그대로 판정에 옮기지 마라**. 코드래빗은 diff만 보고 매기고, 이 스킬은 코드베이스 전체를 보고 매긴다
- 이미 사용자가 답글을 단 스레드(`in_reply_to_id != null`인 자식 코멘트가 있는 스레드)는 처리 이력이 있으므로 표시만 하고 판정 대상에서 뺀다
- 코드래빗 피드백이 0건이면 그 사실을 알리고 종료

**Phase 3: 타당성 판정**
- 항목마다 지목된 파일과 호출부, 관련 컨벤션(`.claude/rules/`), `.claude/spec/service-policy.md`를 실제로 읽고 판정한다. 피드백 본문만 읽고 판정하지 마라
- 판정 기준:
  - **상**: 코드베이스에서 재현 경로가 확인되는 결함이거나, 컨벤션 또는 서비스 정책 위반
  - **중**: 지적은 맞지만 현재 동작에 문제는 없음. 개선 여지 또는 트레이드오프 선택의 문제
  - **하**: 이 코드베이스에서는 부적절. 이미 다른 계층에서 방어됨, 컨벤션과 충돌, 근거 없는 일반론
- 판정마다 근거를 한 줄로 남긴다. 근거에는 확인한 클래스명을 쓰되 파일 경로 전체는 쓰지 않는다

**Phase 4: 보고**
- 상 → 중 → 하 순으로 전체를 표로 보고한다. 컬럼: `번호 | 판정 | 대상(클래스:라인) | 지적 요지 | 판정 근거`
- **이 시점에 코드를 수정하지 마라.** 상으로 판정한 항목도 마찬가지다

**Phase 5: 사용자 선택 후 수정**
- 사용자가 고른 번호만 수정한다. 선택하지 않은 항목은 건드리지 않는다
- 수정이 서비스 정책을 바꾸면 `.claude/spec/service-policy.md`도 함께 고친다
- 수정 범위가 계획서 한 건 수준으로 커지면 여기서 멈추고 `write-plan`을 권한다

**Phase 6: 결과 보고**
- `.claude/skills/review-feedback/template/output.md`를 Read해서 채운다

### 4. 보고 템플릿 (`.claude/skills/review-feedback/template/output.md`)

기존 템플릿들과 같은 형식(상단 HTML 주석 가이드 + 본문)으로 작성한다.

```
## 피드백 검토 완료

- **대상 PR**: [#{번호}]({URL})
- **수집**: 총 {N}건 (상 {a} / 중 {b} / 하 {c}, 처리 이력 있어 제외 {d})
- **수정**: {수정한 항목 번호와 한 줄 요약, 없으면 "없음"}
- **정책 문서**: {service-policy.md 갱신 여부}
- **다음**: `commit-push`
```

### 5. 서비스 정책 SSOT (`.claude/spec/service-policy.md`)

frontmatter `description`: 서비스, 비즈니스 관점의 도메인 정책 단일 출처

문서 앞머리에 작성 규칙을 박아둔다:
- 담는 것: 사용자에게 드러나는 규칙과 판정 기준 (지급/미지급 조건, 성공/실패 조건, 산정 기준, 주기와 초기화 시점, 권한 범위)
- 담지 않는 것: 클래스 구조, 파일 경로, 메서드 시그니처, 쿼리, 트랜잭션 처리 방식
- 위치 표기가 꼭 필요할 때만 `LearningFacade:81` 수준의 클래스명과 라인까지만 쓴다
- 정책이 코드와 어긋나면 코드가 아니라 이 문서를 기준으로 삼고, 어긋난 사실을 사용자에게 보고한다

섹션은 이슈 템플릿의 Related Domain 분류를 그대로 따라 14개로 나눈다:
`Auth / Security`, `User`, `Friend / Social`, `Chapter / Unit / Lesson / Problem / Option`,
`Learning / Answer / DailyLearningRecord`, `Bookmark / WrongAnsweredNote`, `CS Note`,
`League / Season / UserLeague / LeagueHistory`, `Mission / Badge`, `Notification / FCM`,
`Notice`, `Inquiry`, `Admin / Report`, `Version`

정책 추출 방법(implement 단계에서 수행):
- 도메인별 Service와 Facade, Entity의 상태 전이 메서드를 읽고 **분기 조건과 계산식**만 뽑는다
- 뽑은 문장은 "무엇을 하면 무엇이 된다" 형태로 쓴다. 예: `이미 제출한 레슨을 다시 제출하면 경험치와 미션 진행도를 지급하지 않는다`
- CRUD만 있어 정책이 없는 도메인은 섹션에 `- 별도 정책 없음`으로 남긴다. 섹션 자체를 빼지 않는다(누락과 구분되지 않기 때문)

### 6. 정책 문서 갱신 의무 명시

- `.claude/skills/write-plan/SKILL.md` Phase 3(컨벤션 확인)에 한 항목 추가:
  `.claude/spec/service-policy.md`에서 대상 도메인 섹션을 Read하고, 이번 작업이 정책을 바꾸면 계획서 "영향 범위 - 수정 파일"에 정책 문서를 넣어라
- `.claude/skills/implement/SKILL.md` Phase 2에 한 항목 추가:
  구현 결과로 서비스 정책이 바뀌거나 새 정책이 생기면 같은 작업에서 `.claude/spec/service-policy.md`의 해당 도메인 섹션을 수정하라. 코드만 바꾸고 문서를 두고 가지 마라
- `.claude/CLAUDE.md`의 `.claude/spec/` 목록에 `- 서비스 정책 (도메인별 비즈니스 규칙) → service-policy.md` 추가

## 결정 필요 (Decisions needed)
- [x] 새 스킬 이름 - `review-feedback`
- [x] 정책 문서 구성 - ~~단일 파일~~ → 구현 후 사용자 요청으로 도메인별 분할 `.claude/spec/service-policy/{도메인}.md`로 변경 (Deviation Log 참조)
- [x] 담당 범위 밖(이벤트 리스너, 어드민) 피드백 처리 - 일반 항목과 동일하게 판정한다. 별도 분류를 두지 않는다
- [x] 정책 추출 범위 - 전체 14개 섹션을 이번 구현에서 모두 채운다

## 검증
- 자동 테스트 대상 없음 (`.claude` 설정 변경이라 Java 테스트에 영향 없음). `./gradlew build`로 기존 빌드 무영향만 확인
- `review-feedback` 스킬은 PR #459(코드래빗 인라인 3건, Nitpick 2건)를 대상으로 1회 실행해 수집과 판정, 보고까지 동작하는지 확인한다. 수정은 하지 않는다
- `service-policy.md`는 이미 알려진 정책 두 건이 문서에 있는지로 확인한다: 레슨 재제출 시 경험치 미지급, 레벨 XP 구간표 기준

## Deviation Log
- `.claude/spec/service-policy.md`: 새 콘텐츠 알림을 "레슨 운영 승격 시 전체 발송"으로 적으려다 미연결 상태로 기록 - 이유: `sendNewContentAlerts`에 운영 경로 호출자가 없고 QA 경로만 존재함
- `.claude/spec/service-policy.md`: 공지 알림을 무조건 발송으로 적으려다 게시 상태일 때만 발송으로 정정 - 이유: `AdminNoticeService`가 PUBLISHED일 때만 이벤트를 발행함
- `.claude/spec/service-policy.md`: 북마크, 오답 노트의 유닛 접근 제어를 서버 차단으로 적으려다 응답 플래그 제공으로 정정 - 이유: 서버는 존재 여부만 내려주고 차단하지 않음
- 정책 문서를 단일 파일에서 `.claude/spec/service-policy/` 디렉토리 + 도메인별 14개 파일 + `README.md`로 분할 - 이유: 스킬이 한 도메인 정책을 보려고 전체 152줄을 Read하는 게 컨텍스트 낭비라는 사용자 판단. 문서 작성 규칙과 파일 목록은 README로 옮기고, 도메인 간 중복은 `{파일명}을 따른다` 상호참조로 처리했다
- `.claude/skills/review-feedback/template/verdict-table.md` 신설, SKILL.md Phase 4를 템플릿 참조 두 줄로 축약 - 이유: 표 형식과 예시가 SKILL.md 본문을 길게 만들어 사용자가 분리를 요청함
- 검증: `review-feedback` 스킬 전체 실행 대신 Phase 2 수집 명령만 PR #459로 실검증 - 이유: 스킬 전 과정은 Phase 4에서 사용자 선택 대기로 멈추므로 실제 리뷰가 달린 PR에서 별도로 돌리는 게 맞음
