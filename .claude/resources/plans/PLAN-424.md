# [PLAN-424] Claude Code 훅 안전장치·알림 개선

> 이슈: #424
> 브랜치: chore/424-claude-hooks

## 목표
`.claude/hooks/`의 위험 명령 차단이 오탐(문자열 언급만으로 차단)과 우회(공백·플래그 변형, Bash 경유 마이그레이션 수정, 훅 자기수정, `flywayClean`)를 동시에 가진 문제를 해소한다. 차단 로직을 deny/ask 2단 구조로 재설계하고, notify 훅이 프로젝트·권한 요청 내용·마지막 응답 요약을 전달하게 한다.

## 영향 범위
### 신규 파일
- `.claude/hooks/notify.sh` — OS별 알림 발송 공통 스크립트 (osascript argv 전달로 인젝션 방지)
- `.claude/hooks/protect-claude-config.sh` — `.claude/hooks/**`·`settings*.json` 대상 Edit/Write를 ask로 승격하는 자기보호 훅
- `.claude/hooks/test-hooks.sh` — 픽스처 JSON을 각 훅에 파이프해 exit code·JSON 출력을 검증하는 자가 테스트

### 수정 파일
- `.claude/hooks/block-dangerous-commands.sh` — 공백 정규화 + 컨텍스트 기반 매칭 + deny/ask 2단 구조 + fail-closed 가드로 재설계
- `.claude/hooks/protect-migrations.sh` — origin/main에 존재하는 마이그레이션만 불변 처리, JSON deny 출력으로 전환
- `.claude/hooks/notify-permission.sh` — stdin JSON의 `.message`·`.cwd` 활용, notify.sh 호출로 축소
- `.claude/hooks/notify-stop.sh` — transcript에서 마지막 assistant 응답 요약 추출, 브랜치명 표시
- `.claude/settings.json` — deny 변형 보강, `permissions.ask` 신설, protect-claude-config.sh 훅 등록

## 구현 계획
> Java 코드 미변경 이슈로, 레이어(Entity~Controller) 대신 파일 단위로 기술한다. Facade: 불필요 — Java 코드 미변경.

### 1. `block-dangerous-commands.sh` 재설계
- **fail-closed 가드**: 스크립트 첫머리에 `command -v jq >/dev/null 2>&1 || { echo "jq 미설치: 안전 훅 실행 불가" >&2; exit 2; }`. 현재는 jq 부재 시 COMMAND가 빈 문자열이 되어 전부 통과(fail-open).
- **정규화**: `NORM=$(printf '%s' "$COMMAND" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]' ' ')` — `DROP  DATABASE`(공백 2개) 류 우회 봉쇄.
- **출력 함수 2개**:
  - `deny()` — stderr 사유 + `exit 2` (즉시 차단, 사유가 모델에 전달됨)
  - `ask()` — stdout에 `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"<사유>"}}` + `exit 0` (사용자 확인으로 에스컬레이션 — 오탐이 차단 대신 확인으로 흡수됨)
- **DENY 티어** (무조건 파괴적):
  - 포크밤: `grep -qF ':(){ :|:& };:'` (fixed-string 매칭으로 정규식 의미론 불안정 제거)
  - 디스크 디바이스 쓰기: `(>|of=) ?/dev/(sd[a-z]|nvme|r?disk)` — 기존 `> /dev/sda`는 `dd of=/dev/sda`를 놓침(세션 실증)
  - `mkfs\.`
  - 루트/홈 재귀 삭제: rm + 재귀 플래그 + 대상이 `/`·`~`·`$home`인 경우
- **ASK 티어** (맥락상 위험, 사용자 판단 필요):
  - SQL DDL은 DB 클라이언트 컨텍스트에서만: NORM에 `(psql|mysql|mariadb|docker exec)` 존재 AND `(drop (database|table|schema)|truncate table)` 매칭 시 ask. 검색 명령(`rg "DROP TABLE"`, `git log --grep`)은 클라이언트가 없으므로 통과 → 세션에서 실증한 오탐 2건 해소
  - chmod 변형: `chmod`와 `777` 동시 존재 (기존 `chmod -R 777` 고정 문자열은 `-R 0777`·`777 -R` 순서 변형을 놓침 — 실증)
  - rm 재귀 변형: `\brm -[a-z]*r` (`-fr`, `-Rf`, `--recursive`) — settings deny(`rm -rf *`·`rm -r *`)가 못 잡는 변형을 ask로 수용
  - `find … -delete`, `xargs … rm`
  - git 강제/파괴: `git push … +{ref}`(refspec force — `--force*` deny 우회 경로), `git clean`
  - Flyway 파괴 태스크: `flyway ?clean|flywayrepair` (gradle 외 flyway CLI 대비 벨트앤서스펜더)
  - 마이그레이션 Bash 우회: NORM에 `db/migration` 존재 AND 쓰기 동사(`sed -i|mv |rm |tee |>>|>`) 매칭 → ask, 사유 "적용된 마이그레이션은 불변 — 새 V파일로 추가하라"
  - `.claude` 자기수정: 원본 COMMAND에 `\.claude/(hooks|settings)` AND (`sed -i|tee|>>|>|mv |rm |chmod `) → ask
- **평가 순서**: settings.json deny(정확 표기 변형)가 먼저 차단 → 훅 DENY → 훅 ASK → 통과.

### 2. `protect-migrations.sh` 정밀화
- 경로 매칭 엄격화: `db/migration/V.*\.sql` → `db/migration/V[0-9]+__.*\.sql`
- 상대경로 변환: `REL=${FILE_PATH#"$CLAUDE_PROJECT_DIR"/}`
- **main 기준 불변 판정**: `git -C "$CLAUDE_PROJECT_DIR" cat-file -e "origin/main:$REL" 2>/dev/null`
  - 존재(배포됐을 수 있음) → JSON `permissionDecision:"deny"` + 사유 (exit 2 방식에서 전환 — 사유가 모델에 전달돼 새 버전 파일 생성으로 스스로 경로 변경 가능)
  - 미존재(이 브랜치에서 만든 신규 파일) → Edit/Write 허용. 현재는 방금 만든 파일의 오타 수정도 차단되는 오탐(실증)
- **폴백**: git 실패·origin/main 부재 시 기존 로직(Edit 차단, Write는 기존 파일만 차단) 유지 — 보수적 동작 보존. `.claude/rules/migration.md`의 "적용된 파일은 절대 수정·삭제 금지" 규칙과 의미론 일치.

### 3. `protect-claude-config.sh` 신설
- 입력: `.tool_input.file_path`. 매칭: `*/.claude/hooks/*`, `*/.claude/settings.json`, `*/.claude/settings.local.json`
- 매칭 시 ask JSON 출력 (사유: "훅·권한 설정 변경은 사용자 승인 필요"). 그 외 exit 0
- 배경: settings.json의 훅 *설정*은 ConfigChange로 감지되지만 훅 스크립트 *본문*은 매 호출 fresh 실행이라 세션 중 Edit 한 번으로 무력화 가능(구조적 공백)
- settings.json의 기존 `Edit|Write` matcher 그룹에 command로 추가 등록

### 4. `notify.sh` 신설 (공통 발송)
- 시그니처: `notify.sh <title> <message>`
- macOS: heredoc `on run argv` 방식으로 osascript에 **argv 전달** — 현재 문자열 보간 방식은 메시지에 `"` 포함 시 조용히 실패(인젝션 취약)
  ```
  osascript - "$TITLE" "$MSG" <<'EOF'
  on run argv
    display notification (item 2 of argv) with title (item 1 of argv) sound name "Glass"
  end run
  EOF
  ```
- WSL: powershell 인자 single-quote escape(`'`→`''`) 후 기존 BurntToast/MessageBox 폴백 유지
- Linux: `notify-send "$TITLE" "$MSG"`
- notify-permission.sh·notify-stop.sh의 중복 OS 분기 15줄이 이 파일로 수렴

### 5. `notify-permission.sh` 개선
- stdin JSON 파싱: `MSG=$(jq -r '.message // "권한 승인이 필요합니다."' <<<"$INPUT")`, `CWD=$(jq -r '.cwd // ""')`
- 제목: `Claude Code — $(basename "$CWD")` — 멀티 세션 시 어느 프로젝트인지 식별
- 본문: `.message` 원문("Claude needs your permission to use Bash" 류) — 어떤 도구가 왜 멈췄는지 전달
- 호출: `"$(cd "$(dirname "$0")" && pwd)/notify.sh" "$TITLE" "$MSG"`

### 6. `notify-stop.sh` 개선
- stdin에서 `.transcript_path`·`.cwd` 추출
- 마지막 응답 요약 (이 세션에서 실제 transcript로 검증 완료):
  ```
  jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text' "$TRANSCRIPT" | tail -1 | tr '\n' ' ' | cut -c1-100
  ```
- 브랜치: `git -C "$CWD" branch --show-current 2>/dev/null`
- 제목 `Claude Code — {project} ({branch})`, 본문은 요약(비어 있으면 "작업이 완료되었습니다." 폴백)

### 7. `settings.json` 보강
- `permissions.deny` 추가: `Bash(rm -fr *)`, `Bash(rm -Rf *)`, `Bash(rm -rF *)`, `Bash(rm -R *)`, `Bash(./gradlew flywayClean*)`, `Bash(./gradlew *flywayClean*)`
- `permissions.ask` 신설: `Bash(git clean*)` (+ 결정 필요 1 결과에 따라 `Bash(git push*)`)
- `hooks.PreToolUse`의 `Edit|Write` matcher 그룹에 `protect-claude-config.sh` 추가
- (결정 필요 2 결과에 따라) `Notification` matcher를 `permission_prompt|idle_prompt`로 확장
- 참고: `settings.local.json`의 `Bash(git *)` allow보다 deny/ask가 우선 평가되므로 로컬 설정 변경 불요

### 8. `test-hooks.sh` 신설 (자가 테스트)
- 픽스처 JSON(`{"tool_name":"Bash","tool_input":{"command":"…"}}`)을 heredoc으로 생성해 각 훅에 파이프, 기대 exit code와 stdout의 `permissionDecision`을 assert
- 케이스: 세션 실증 우회 5종(dd of=/dev/sda, DROP␣␣DATABASE, chmod -R 0777, chmod 777 -R, psql DROP SCHEMA) → 전부 deny/ask, 오탐 2종(rg "DROP TABLE", git log --grep) → 통과, 포크밤 → deny, flywayClean → ask, `.claude` 자기수정 → ask, 마이그레이션 3케이스(main 존재 Edit → deny / 신규 V파일 Edit → 허용 / 신규 Write → 허용)
- 패턴 문자열이 Bash 명령 인자에 노출되지 않도록 스크립트 파일 실행형으로 작성 (이 세션에서 겪은 훅 자기차단 회피)

## 결정 필요 (Decisions needed)
- [x] `git push` ask 승격 여부 — **B 확정**: 일반 push는 현행 유지. force 계열은 deny(기존), refspec `+` force만 훅 ask로 통제. `permissions.ask`에는 `Bash(git clean*)`만 추가.
- [x] Notification matcher 확장 — **A 확정**: `permission_prompt|idle_prompt`로 확장. 입력 대기(60초+) 알림 추가.
- [x] `.claude` 자기보호 수위 — **A 확정**: ask 승격. 정당한 훅 수정은 사용자 승인으로 진행.

## 검증
- `bash .claude/hooks/test-hooks.sh` 전 케이스 통과
- 수동 확인: ① `rg "DROP TABLE" src/main/resources/db/migration/` 정상 실행(오탐 해소) ② 신규 V파일 생성 후 Edit 허용, 기존 V1 Edit 시 deny 사유 표시 ③ 따옴표 포함 메시지로 notify.sh 호출 시 알림 정상 표시 ④ Stop 알림에 브랜치·요약 표시
- `./gradlew test` 불요 — Java 코드 미변경

## Deviation Log
- `settings.json`: 계획서상 순서(7번)보다 늦춰 test-hooks.sh(8번) 작성 이후 마지막에 적용 — 이유: protect-claude-config.sh 등록이 활성화되면 이후 `.claude/hooks/**` Edit이 ask로 승격되어, 같은 구현 세션에서 남은 훅 파일 작성이 매번 사용자 확인을 요구하게 됨. 모든 훅 파일을 먼저 완성한 뒤 마지막에 settings.json을 갱신해 불필요한 중단을 피함. 로직·범위는 계획과 동일.

### 검수 후 수정 (구현 검수에서 발견)
- `block-dangerous-commands.sh`: 루트/홈 rm deny 정규식의 트레일링 클래스에서 `/` 제거, `~/?`·`\$home/?`로 교체 — 이유: `rm -rf ~/하위경로`가 계획 의도(ask)와 달리 deny로 과잉 차단됨. 홈 자체(`~`, `~/`)는 여전히 deny.
- `block-dangerous-commands.sh`: 마이그레이션 쓰기 동사에 `cp ` 추가, flyway 패턴을 `flyway ?(clean|repair)`로 통합 — 이유: `cp`로 V파일 덮어쓰기와 `flyway repair`(공백 변형)가 통과함. 계획서 목록 자체의 누락.
- `protect-migrations.sh`·`protect-claude-config.sh`: jq fail-closed 가드 추가 — 이유: jq 부재 시 FILE_PATH가 빈 값이 되어 보호가 조용히 꺼짐(fail-open). block-dangerous와 일관성 확보.
- `notify-stop.sh`: 요약 추출을 jq slurp(`-s`) 방식으로 교체해 마지막 텍스트 블록 전체를 집계 — 이유: 계획서의 `tail -1` 파이프라인은 마지막 '줄'만 추출해 알림에 마크다운 꼬리표가 노출됨.
- `notify-stop.sh`·`notify-permission.sh`: 알림 본문을 공백 정리 후 60자 + `…`로 절단 — 이유: 사용자 피드백(알림 본문 과다). jq 코드포인트 단위 절단으로 한글 바이트 깨짐 방지(`cut -c` 대체).
- `test-hooks.sh`: `expect_decision`에 "none" 센티널 도입, 검수 발견 케이스를 회귀 테스트로 추가해 26케이스로 확장 — 이유: 기존 allow 케이스는 훅이 ask를 뱉어도 PASS되어 오탐 해소 검증이 무력했음.
- `notify.sh`: macOS 발송을 terminal-notifier 우선(-activate로 클릭 시 IntelliJ 활성화, -group으로 알림 치환)으로 전환, osascript는 폴백 유지. 알림 제목은 프로젝트·브랜치 없이 "Claude Code"로 고정 — 이유: 사용자 요청(제목 간소화 + 클릭 시 IDE 이동). 활성화 앱은 `CLAUDE_NOTIFY_ACTIVATE` 환경변수로 교체 가능.
