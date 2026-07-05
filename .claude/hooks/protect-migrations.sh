#!/bin/bash
# PreToolUse hook: 기존 Flyway 마이그레이션 파일 수정 차단
# origin/main에 존재하는(배포됐을 수 있는) 마이그레이션만 불변으로 취급한다.
# 이 브랜치에서 새로 만든 V파일은 자유롭게 Edit/Write 할 수 있다.
# exit 0 = 허용, JSON permissionDecision:"deny" = 차단

command -v jq >/dev/null 2>&1 || { echo "차단됨: jq가 없어 안전 검사를 수행할 수 없습니다." >&2; exit 2; }

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

# 마이그레이션 파일이 아니면 허용
echo "$FILE_PATH" | grep -qE 'db/migration/V[0-9]+__.*\.sql' || exit 0

deny() {
  jq -n --arg reason "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
  exit 0
}

REL="${FILE_PATH#"$CLAUDE_PROJECT_DIR"/}"

if git -C "$CLAUDE_PROJECT_DIR" rev-parse --verify -q origin/main >/dev/null 2>&1; then
  if git -C "$CLAUDE_PROJECT_DIR" cat-file -e "origin/main:$REL" 2>/dev/null; then
    if [ "$TOOL_NAME" = "Edit" ]; then
      deny "이미 origin/main에 존재하는(배포되었을 수 있는) Flyway 마이그레이션은 수정할 수 없습니다. 새 버전 파일을 추가하세요."
    fi
    if [ "$TOOL_NAME" = "Write" ]; then
      deny "이미 origin/main에 존재하는 Flyway 마이그레이션을 덮어쓸 수 없습니다. 새 버전 파일을 추가하세요."
    fi
  fi
  exit 0
fi

# origin/main 참조를 확인할 수 없을 때: 기존 방식대로 보수적으로 차단
if [ "$TOOL_NAME" = "Edit" ]; then
  deny "origin/main 기준을 확인할 수 없어 보수적으로 차단합니다. 기존 Flyway 마이그레이션은 수정할 수 없습니다."
fi
if [ "$TOOL_NAME" = "Write" ] && [ -f "$FILE_PATH" ]; then
  deny "origin/main 기준을 확인할 수 없어 보수적으로 차단합니다. 기존 파일을 덮어쓸 수 없습니다."
fi

exit 0
