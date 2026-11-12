#!/bin/bash
# PreToolUse hook: 훅 스크립트·권한 설정 파일 자기보호
# .claude/hooks/** 또는 .claude/settings(.local).json을 Edit/Write하려는 시도를
# 사용자 확인으로 승격한다. 훅 스크립트는 매 호출마다 fresh 실행되므로,
# 이 훅 자체가 없으면 세션 중 Edit 한 번으로 다른 모든 안전장치가 무력화될 수 있다.
# exit 0 = 허용, JSON permissionDecision:"ask" = 사용자 확인

command -v jq >/dev/null 2>&1 || { echo "차단됨: jq가 없어 안전 검사를 수행할 수 없습니다." >&2; exit 2; }

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

if echo "$FILE_PATH" | grep -qE '\.claude/hooks/|\.claude/settings(\.local)?\.json$'; then
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: "훅·권한 설정 변경은 사용자 승인이 필요합니다."}}'
  exit 0
fi

exit 0
