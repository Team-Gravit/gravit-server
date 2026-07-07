#!/bin/bash
# Stop hook: 작업 완료 알림
# transcript의 마지막 assistant 응답을 60자로 요약해 전달한다.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')

# 마지막 assistant 텍스트 블록 전체를 집계한 뒤 공백을 접고 60자에서 자른다.
# (jq는 UTF-8 코드포인트 단위로 세므로 한글이 중간에서 깨지지 않는다)
SUMMARY=""
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  SUMMARY=$(jq -r -s '[.[] | select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text] | last // ""
    | gsub("\\s+"; " ")
    | if length > 60 then .[:60] + "…" else . end' "$TRANSCRIPT" 2>/dev/null)
fi

"$DIR/notify.sh" "Claude Code" "${SUMMARY:-작업이 완료되었습니다.}"

exit 0
