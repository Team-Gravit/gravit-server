#!/bin/bash
# Notification(permission_prompt|idle_prompt) hook: 권한 승인·입력 대기 알림
# stdin의 .message를 60자로 잘라 전달해 어떤 도구가 왜 멈췄는지 알 수 있게 한다.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INPUT=$(cat)
MSG=$(echo "$INPUT" | jq -r '(.message // "권한 승인이 필요합니다.")
  | gsub("\\s+"; " ")
  | if length > 60 then .[:60] + "…" else . end')

"$DIR/notify.sh" "Claude Code" "$MSG"

exit 0
