#!/bin/bash
# PreToolUse hook: 위험한 Bash 명령 차단/확인 요청
# settings.json의 deny와 중복되는 패턴은 제외 (deny가 먼저 차단하므로)
# 이 hook은 deny에서 커버하지 못하는 추가 패턴을 처리한다.
#
# 두 단계로 나뉜다:
#   DENY : 되돌릴 수 없이 파괴적인 명령 -> stderr 사유 + exit 2 (즉시 차단)
#   ASK  : 맥락상 위험하지만 정당한 사용도 있는 명령 -> JSON permissionDecision:"ask" (사용자 확인)
# exit 0(사유 없음) = 허용

command -v jq >/dev/null 2>&1 || { echo "차단됨: jq가 없어 안전 검사를 수행할 수 없습니다." >&2; exit 2; }

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0

deny() {
  echo "차단됨: $1" >&2
  exit 2
}

ask() {
  jq -n --arg reason "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $reason}}'
  exit 0
}

# 공백을 정규화해 "DROP   DATABASE" 같은 다중 공백 우회를 방지
NORM=$(printf '%s' "$COMMAND" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]' ' ')

# ── DENY: 무조건 파괴적인 명령 ──────────────────────────────

echo "$NORM" | grep -qF ':(){ :|:& };:' && deny "포크밤으로 의심되는 명령입니다."

echo "$NORM" | grep -qE '(>|of=) *\/dev\/(sd[a-z]|nvme|r?disk)' \
  && deny "디스크 디바이스에 직접 쓰는 명령입니다."

echo "$NORM" | grep -qE 'mkfs(\.| )' && deny "파일시스템을 새로 생성(mkfs)하는 명령입니다."

echo "$NORM" | grep -qE 'rm +-[a-z]*r[a-z]* +(-[a-z]+ +)*(/|~/?|\$home/?)(\*|[[:space:]]|$)' \
  && deny "루트/홈 디렉터리를 재귀 삭제하는 것으로 의심되는 명령입니다."

# ── ASK: 맥락상 위험 — 사용자 확인 필요 ──────────────────────

if echo "$NORM" | grep -qE '(psql|mysql|mariadb|docker exec)'; then
  echo "$NORM" | grep -qE 'drop +(database|table|schema)|truncate table' \
    && ask "DB 클라이언트 컨텍스트에서 DDL 파괴 명령(DROP/TRUNCATE)이 감지되었습니다."
fi

if echo "$NORM" | grep -q 'chmod' && echo "$NORM" | grep -q '777'; then
  ask "권한을 777로 변경하는 명령입니다."
fi

echo "$NORM" | grep -qE 'rm +-[a-z]*r[a-z]*( |$)|rm +--recursive' \
  && ask "재귀 삭제(rm -r 계열) 명령입니다. 대상 경로를 확인하세요."

echo "$NORM" | grep -qE 'find .*-delete|xargs .*rm' \
  && ask "find/xargs를 통한 일괄 삭제 명령입니다."

echo "$NORM" | grep -qE 'git push .*[[:space:]]\+[a-z0-9]' \
  && ask "refspec force-push(+) 패턴이 감지되었습니다."

echo "$NORM" | grep -qE 'git clean' \
  && ask "git clean은 추적되지 않는 파일/디렉터리를 삭제합니다."

echo "$NORM" | grep -qE 'flyway ?(clean|repair)' \
  && ask "Flyway 파괴적 태스크(clean/repair)가 감지되었습니다."

if echo "$NORM" | grep -q 'db/migration'; then
  echo "$NORM" | grep -qE 'sed -i|mv |rm |cp |tee |>>|>' \
    && ask "적용된 마이그레이션은 불변입니다 — 새 버전 파일로 추가하세요."
fi

echo "$COMMAND" | grep -qE '\.claude/(hooks|settings)' \
  && echo "$COMMAND" | grep -qE 'sed -i|tee|>>|>|mv |rm |chmod ' \
  && ask ".claude 훅/설정 파일을 변경하는 명령입니다. 사용자 승인이 필요합니다."

exit 0
