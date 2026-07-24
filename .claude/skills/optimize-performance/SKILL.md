---
name: optimize-performance
description: |
  지정한 API의 성능을 측정, 진단하고 개선 기법을 근거와 함께 제시한다. 기법 선택과 부하 테스트 실행은 호출자가 한다.
  Trigger: "/optimize-performance {엔드포인트}", "이 API 성능 개선하자", "느린 API 최적화하자"
  Do NOT use for: 코드만 보고 하는 정적 성능 리뷰(→ performance-reviewer), 구현 계획 수립(→ write-plan), 계획 기반 구현(→ implement)
  Boundary: 측정 설계, 결과 진단, 기법 제시, 호출자와의 설계 협의, 확정된 설계의 적용, 기록까지 수행한다. 부하 테스트와 DB 조회 실행은 호출자가 직접 한다. 어떤 기법을 쓸지와 어떻게 설계할지는 스킬이 단독으로 정하지 않는다.
allowed-tools: Read, Grep, Glob, Edit, Write, Skill, Bash(git *), Bash(gh *)
model: opus
effort: xhigh
---

# 성능 최적화
각 단계에서 확인할 항목을 호출자에게 안내하고, 관측 결과를 근거로 선택지를 제시한다.
어떤 기법을 채택할지, 어떤 트레이드오프를 감수할지는 호출자가 결정한다.

애플리케이션 기동, k6 부하 테스트, 데이터베이스 쿼리는 호출자가 직접 실행하며, 명령어와 입력 형식을 제시하고 결과를 받는다.

대상 API: $ARGUMENTS

## 진입 지시

1. 현재 브랜치에서 이슈 번호를 파싱해(`git branch --show-current`) `.claude/resources/perf/{이슈번호}/record.md`를 찾는다.
   - 있으면 `Read(limit: 25)`로 최상단 **진행 상태** 표만 읽고,
     ⏳로 표기된 가장 이른 Phase 파일을 Read해 그 지점부터 재개한다. 전체를 읽지 마라.
   - 없거나 이슈 번호를 못 뽑으면 `phases/phase-1-target.md`부터 시작한다.
2. Phase 간 이동은 항상 현재 phase 파일의 **다음 Phase 조건**을 따른다.
3. 각 Phase를 마치면 `.claude/resources/perf/{이슈번호}/record.md`의 **진행 상태**를 갱신한다.
   이 표가 유일한 상태 저장소다. 별도 state 파일을 두지 마라.

## 산출물 규약

작업 디렉토리는 대상 하나당 `.claude/resources/perf/{이슈번호}/` 하나다. 산출물은 모두 그 안에 둔다.

호출자에게 제시하는 셸 명령에서는 Phase 1에서 잡은 `$PERF_DIR`를 쓴다.
Read와 Write의 대상 경로에는 셸 변수가 통하지 않는다. 전체 경로를 쓴다.

| 파일 | 만드는 Phase | 템플릿 |
|---|---|---|
| `record.md` | 1 | `template/PERF-template.md` |
| `test-script.js` | 3 | `template/k6-script-template.js` |
| `tokens.json` | 4, 8 | - |
| `seeds.sql` | 3 (시드가 필요한 경우만) | `template/seeds-template.sql` |
| `k6-test-summary-{n}.json` | 4, 8 | - |
| `query-stats-{n}.txt` | 4, 8 | - |
| `query-plan-{n}.txt` | 6, 8 | - |

템플릿 상단의 **작성 규칙**이 해당 산출물의 작성 기준이다. phase 파일에 규칙을 중복해 적지 마라.

### 파일명의 `{n}`

`{n}`은 사이클 번호가 아니라 **코드의 상태 번호**다.

| n | 상태 | 만드는 Phase |
|---|---|---|
| 0 | 아무것도 적용하지 않은 원본 | 4 (요약, 통계), 6 (실행계획) |
| 1 | 사이클 1의 기법을 적용한 상태 | 8 |
| 2 | 사이클 2까지 적용한 상태 | 8 |

사이클 n의 **개선 전** 자료는 `-{n-1}`, **개선 후** 자료는 `-{n}`이다.

### 원본과 해석의 분리

- 비교 대상이 되는 측정 출력은 전부 파일로 남기고, 스킬은 그 파일을 Read로 읽는다.
- `k6-test-summary-{n}.json`은 k6 원본이 아니라 스크립트가 선별해 내보낸 기록이다.
  담기지 않은 지표가 필요해지면 재측정해야 한다.
- 터미널 출력을 붙여넣게 하지 마라.
- 앞선 상태의 파일을 덮어쓰지 마라.
- `record.md`에는 원본을 옮겨 적지 않고 해석과 판정만 적는다.
- 비교 대상이 아닌 일회성 조회(Phase 3의 행 수 확인, Phase 5-B의 `\d`와 `pg_stats`)는 파일로 남기지 않는다.

## Phase 인덱스

| Phase | 파일 | 한 줄 요약 |
|---|---|---|
| 1 | `phases/phase-1-target.md` | 이슈와 브랜치 확보, 엔드포인트 확정, 실행 경로 파악, `record.md` 생성 |
| 2 | `phases/phase-2-environment.md` | perf 프로파일, 히스토그램, `pg_stat_statements`, 캐시 제어 점검 **(게이트)** |
| 3 | `phases/phase-3-dataset.md` | 데이터 규모, 카디널리티, 부하 조건 확정, 시드 SQL, k6 스크립트 작성 |
| 4 | `phases/phase-4-baseline.md` | 기준선 측정 결과를 받아 병목의 성격을 판정 |
| 5 | `phases/phase-5-design.md` | 근거와 함께 기법 제시 → 호출자가 선택 → 설계를 함께 확정 **(게이트)** |
| 6 | `phases/phase-6-snapshot.md` | 개선 전 지표와 실행계획 캡처 **(비가역)** |
| 7 | `phases/phase-7-apply.md` | Phase 5에서 확정한 설계 그대로 적용 (기법 하나만) |
| 8 | `phases/phase-8-verify.md` | 동일 조건 재측정, 종료 판정 |
| 9 | `phases/phase-9-report.md` | 결과 보고 |

**분기 요약**

- Phase 1~4는 대상당 1회 수행한다. Phase 5~8은 사이클마다 반복한다.
- Phase 3: 2회차 이상이고 스크립트와 데이터가 준비되어 있으면 → **Phase 4** (건너뜀)
- Phase 8: 개선이 멈췄거나 호출자가 종료를 선택 → **Phase 9**
- Phase 8: 호출자가 계속을 선택 → **Phase 5** (사이클 번호 +1)
