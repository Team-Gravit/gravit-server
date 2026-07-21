# [PLAN-446] 이슈, PR 작성 컨벤션 개편

> 이슈: #446
> 브랜치: docs/446-issue-pr-convention

## 목표

PR 본문을 "구현 사항 나열"에서 "Problem, Solution 서술"로 바꿔, PR만 읽어도 무엇이 왜 문제였고 어떤 방법을 왜 골랐는지가 남게 한다. 이슈와 PR의 제목 규칙, 표기 규칙, assignee와 reviewer 자동 지정까지 함께 정리해 `open-issue`, `open-pr` 스킬이 매번 같은 결과를 내도록 만든다.

> 코드 변경은 없다. 마크다운 템플릿 2종과 스킬 문서 2종, 컨벤션 문서 1종만 손댄다.

## 영향 범위

### 신규 파일

- `.claude/skills/open-pr/template/output.md` — open-pr 결과 보고 템플릿. 현재 open-pr만 보고 템플릿이 없어 `open-issue`, `commit-push`, `implement`와 형태가 어긋난다.

### 수정 파일

- `.github/PULL_REQUEST_TEMPLATE.md` — 2개 섹션(`1. 연관 이슈`, `2. 구현 사항`)을 4개 섹션(`PR Summary`, `Problem`, `Solution`, `Related Issue`)으로 전면 교체
- `.claude/skills/open-pr/SKILL.md` — Phase 2를 새 섹션 구조에 맞게 재작성, Phase 3에 assignee와 reviewer 지정 추가, Phase 4(결과 보고) 신설
- `.claude/skills/open-issue/SKILL.md` — Phase 1에 제목 규칙 추가, Phase 3에 `--assignee @me` 추가
- `.claude/spec/git-convention.md` — 제목 규칙, 표기 규칙, 팀 로스터 3개 섹션 추가
- `.claude/skills/open-issue/template/output.md` — 가운데점 제거, assignee 표기 추가

### 수정하지 않는 파일 (확인 완료)

- `.github/ISSUE_TEMPLATE/*.md` (6종) — 본문 구조는 그대로 둔다. frontmatter의 `assignees:`를 특정 계정으로 고정하면 웹 UI로 이슈를 여는 다른 팀원에게 잘못 배정되므로, assignee는 스킬의 `--assignee @me`로만 처리한다. 라벨은 이미 타입별로 frontmatter에 박혀 있고 스킬도 `--label`로 명시하므로 추가 작업이 없다.
- `.claude/skills/commit-push/SKILL.md` — 커밋 메시지 형식은 `git-convention.md`를 참조하는 구조라, 컨벤션 문서만 고치면 자동으로 따라온다.
- `.claude/resources/plans/*.md` — 과거 계획서는 기록물이므로 표기 규칙을 소급 적용하지 않는다.

## 구현 계획

1. **Entity / Flyway / Repository / Service / Facade / DTO / Controller**: 전부 불필요 — 런타임 코드 변경 없음.

2. **`.github/PULL_REQUEST_TEMPLATE.md` 전면 교체**

   기존 `---` 구분선과 `<br>` 장식은 제거한다. 작성 가이드는 HTML 주석으로 넣어 렌더링된 PR에는 보이지 않게 한다.

   ```markdown
   ### PR Summary

   <!-- 변경 사항을 1~2문장으로 요약해주세요. -->

   ### Problem

   <!--
   해결하려고 했던 문제 상황과 원인을 적어주세요.
   문제가 여러 개면 `**문제 1 — {한 줄 요약}**` 형태로 나눠주세요.
   -->

   ### Solution

   <!--
   채택한 해결 방법과 그 이유를 적어주세요.
   Problem을 나눴다면 `**해결 1 — {한 줄 요약}**`으로 번호를 맞춰주세요.
   -->

   ### Related Issue

   - close #이슈번호
   ```

3. **`.claude/spec/git-convention.md`에 3개 섹션 추가**

   커밋 타입 표 아래, 브랜치 전략 위에 넣는다.

   - **제목 규칙** (이슈, PR, 커밋 공통)
     - 40자 이내, 명사형으로 끊는다
     - 대상을 나열하지 말고 무엇을 해결했는지를 남긴다
     - 클래스명 나열과 괄호 중첩 금지
     - 한국 개발자가 읽어 바로 이해되는 어휘를 쓴다 (번역투, 불필요한 영어 혼용 금지)
     - 대조 예시를 함께 싣는다:

       | 지양 | 지향 |
       |---|---|
       | `refactor: 이벤트 리스너 실패 처리 및 복원력 개선 (LearningEventListener/MissionEventListener/DailyLearningRecordListener)` | `refactor: 학습 이벤트 리스너 실패 유실 방지` |
       | `hotfix: main-pages 연속 학습일(consecutiveSolvedDays) 응답 위치 이동(learning→weekly-record)` | `hotfix: 연속 학습일 응답 위치 수정` |

   - **표기 규칙**
     - 가운데점(`·`)을 쓰지 않고 콤마(`,`)를 쓴다. (예: `이슈·라벨` → `이슈, 라벨`)
     - 적용 범위는 이슈와 PR의 제목, 본문, 그리고 커밋 메시지다.
     - 근거를 한 줄 남긴다: 가운데점은 나열인지 수식인지 모호하고 검색과 복사가 불편하다.

   - **팀 로스터**
     ```
     sukangpunch, Jungseokhwan, xunssoie
     ```
     - PR 리뷰어 자동 지정의 기준 목록. 로스터를 스킬이 아니라 컨벤션 문서에 두어, 인원 변동 시 한 곳만 고치게 한다.

4. **`.claude/skills/open-pr/SKILL.md` 수정**

   - **Phase 2 (제목, 본문 작성) 재작성**
     - 섹션 구조 참조를 `PR Summary`, `Problem`, `Solution`, `Related Issue`로 교체
     - 템플릿의 HTML 주석은 가이드이므로 본문에 포함하지 말 것을 명시
     - 제목 규칙은 `git-convention.md`를 참조하되, PR 한정 예시 1쌍을 남긴다
     - **이 PR 본문은 이력서와 경험 기술서의 소스로 쓰인다**는 목적을 명시한다
     - 문체: 본문 서술은 존댓말(`~합니다`), 소제목은 명사형으로 끊는다
       (예: `**해결 2 — 전파 속성을 REQUIRES_NEW로 변경**`)
     - 섹션별 규칙
       - PR Summary: 1~2문장
       - Problem: 문제 상황과 원인, 그래서 무엇이 잘못되고 있었는지(영향)까지
       - Solution: 채택한 방법과 고른 이유. 접근의 핵심이 되는 클래스나 설정명만 필요할 때 언급
       - Related Issue: `- close #{이슈번호}`
     - 문제가 여러 개면 `**문제 N — {요약}**`, `**해결 N — {요약}**`으로 번호를 1:1 대응. 하나면 번호 없이 문단으로만 쓴다
     - 금지: 변경 파일과 메서드 나열(diff가 대신함), 커밋 메시지 복붙, 분량 채우기. 각 문단 2~4문장 유지

   - **Phase 3 (PR 생성)에 담당자, 리뷰어 지정 추가**
     ```bash
     gh api user --jq .login                    # 호출자 판별
     gh pr create --title "{제목}" --body-file {본문파일} --base {대상} \
       --assignee @me --reviewer {로스터 - 호출자}
     ```
     - 로스터는 `git-convention.md`에서 읽는다
     - 호출자가 로스터에 없으면 리뷰어 지정을 건너뛰고 그 사실을 보고에 남긴다
     - `--reviewer`가 실패해도 PR 생성 자체는 유지하고 `gh pr edit --add-reviewer`로 1회 재시도한 뒤, 그래도 실패하면 보고에 남긴다
       (`Jungseokhwan`은 push 권한이 없는 collaborator다. read 권한만 있어도 리뷰 요청은 가능하지만 실패 대비를 남긴다)
     - 본문은 스크래치 파일에 저장해 `--body-file`로 넘긴다 (open-issue와 동일하게, 긴 본문의 셸 이스케이프 사고를 막는다)

   - **Phase 4 (결과 보고) 신설** — `.claude/skills/open-pr/template/output.md`를 Read해 채운다

5. **`.claude/skills/open-pr/template/output.md` 신설**

   `open-issue/template/output.md`와 같은 형태(상단 HTML 주석 가이드 + 항목)로 만든다.

   ```markdown
   ## PR 생성 완료

   - **PR**: [#{번호}]({URL}) · {type}
   - **대상**: {base 브랜치} ← {현재 브랜치}
   - **담당자**: {assignee} / **리뷰어**: {reviewer 목록}
   ```
   > 위 예시의 가운데점은 실제 작성 시 콤마로 바꾼다.

6. **`.claude/skills/open-issue/SKILL.md` 수정**

   - Phase 1의 확정 요소 중 "제목"에 규칙을 붙인다: 40자 이내 명사형, 클래스명 나열과 괄호 중첩 금지, `git-convention.md`의 제목 규칙 참조
   - Phase 3의 생성 명령에 `--assignee @me` 추가
     ```bash
     gh issue create --title "{접두}: {제목}" --body-file {본문파일} --label "{라벨}" --assignee @me
     ```
   - Phase 2에 본문도 표기 규칙(가운데점 대신 콤마)을 따른다는 한 줄 추가

7. **표기 규칙 소급 적용 (대상 파일 한정)**

   수정 대상 파일에 남아 있는 가운데점을 콤마로 바꾼다. 총 16개.

   | 파일 | 개수 |
   |---|---|
   | `.claude/skills/open-issue/SKILL.md` | 10 |
   | `.claude/skills/open-issue/template/output.md` | 3 |
   | `.claude/spec/git-convention.md` | 2 |
   | `.claude/skills/open-pr/SKILL.md` | 1 |

   - 스킬 문서의 표기가 규칙과 어긋나 있으면 모델이 주변 문장을 모방해 산출물에도 가운데점이 새어 나온다. 그래서 이번 대상 파일만큼은 함께 정리한다.
   - 다른 스킬 문서(`implement`, `write-plan` 등)까지 훑는 것은 이번 범위가 아니다.

## 결정 필요 (Decisions needed)

- [x] `Changes` 섹션 존치 여부 — **제거**로 확정. 파일 단위 변경은 diff가 이미 보여주므로, 본문에는 문제와 해결 서술만 남긴다. (2026-07-21, 사용자 결정)
- [x] 문제가 여러 개일 때의 표현 — **`문제 N`, `해결 N` 번호 1:1 대응**으로 확정. (2026-07-21, 사용자 결정)
- [x] 문체 — **본문 서술은 존댓말, 소제목은 명사형**으로 확정. (2026-07-21, 사용자 결정)
- [x] 리뷰어 지정 방식 — **로스터에서 호출자 제외**로 확정. 로스터는 `sukangpunch`, `Jungseokhwan`, `xunssoie` 3명. (2026-07-21, 사용자 결정)
- [x] 이슈 템플릿 frontmatter에 assignee 고정 여부 — **고정하지 않음**. 웹 UI로 이슈를 여는 다른 팀원에게 잘못 배정되므로 스킬의 `--assignee @me`로만 처리한다.

## 검증

- 테스트 없음 — 런타임 코드 변경이 아니라 마크다운 문서 변경이다.
- `git diff`로 5개 파일의 변경을 육안 확인한다.
- 대상 파일에 가운데점이 남아 있지 않은지 확인한다:
  ```bash
  grep -rn '·' .github/PULL_REQUEST_TEMPLATE.md .claude/skills/open-pr .claude/skills/open-issue .claude/spec/git-convention.md
  ```
- 실사용 검증은 이 브랜치의 PR을 새 템플릿으로 직접 만들어 확인한다. 즉 **이 작업의 PR이 첫 번째 적용 사례**가 된다. 이때 확인할 것:
  - Problem, Solution 4개 섹션이 렌더링되고 HTML 주석은 보이지 않는다
  - assignee가 `xunssoie`로, reviewer가 `sukangpunch`, `Jungseokhwan`으로 지정된다

## Deviation Log

- `.claude/skills/open-pr/SKILL.md`: frontmatter `allowed-tools`에 `Write` 추가 — 이유: Phase 3에서 본문을 스크래치 파일로 저장해 `--body-file`로 넘기도록 했는데, 기존 목록(`Bash`, `Read`)만으로는 파일 생성이 불가능하다.
- `.claude/skills/open-pr/SKILL.md`: frontmatter의 description과 Boundary 문구 수정 — 이유: 리뷰어 지정이 스킬 범위에 들어왔는데 기존 Boundary가 "리뷰 요청은 범위 밖"이라고 못박고 있어 서로 모순된다.
- `.claude/skills/open-pr/template/output.md`: 계획서 예시의 구분자 `·`를 `—`와 콤마로 대체 — 이유: 이번에 신설하는 표기 규칙을 산출물 템플릿 자신이 어기면 안 된다.
- `.claude/spec/git-convention.md:43`: 표기 규칙 설명의 예시(`이슈·라벨` → `이슈, 라벨`)에는 가운데점을 그대로 남김 - 이유: 무엇을 쓰지 말라는지 보여주는 대조 예시라 제거하면 규칙이 성립하지 않는다.
- `.github/PULL_REQUEST_TEMPLATE.md`: 제목 아래 `---`과 섹션 사이 `<br>` 장식을 되살림 - 이유: 계획에서는 걷어내기로 했으나 실제 렌더링에서 섹션 구분이 약했다. 사용자 요청으로 기존 스타일을 유지하고, open-pr 스킬에는 이 장식을 지우지 말라는 지시를 추가했다.
- 표기 규칙에 "긴 대시(`—`) 대신 짧은 대시(`-`)"를 추가하고 대상 파일의 긴 대시 8곳을 일괄 교체 - 이유: 계획 수립 시점에는 없던 규칙으로, 사용자 요청으로 추가했다. 긴 대시는 키보드로 바로 입력할 수 없어 손으로 고칠 때 표기가 어긋난다.
