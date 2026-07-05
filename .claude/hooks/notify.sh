#!/bin/bash
# 공통 알림 발송: notify.sh <title> <message>
# macOS: terminal-notifier가 있으면 사용 — 클릭 시 IDE 활성화(-activate),
#        같은 그룹 알림은 치환(-group)되어 알림센터에 쌓이지 않는다.
#        없으면 osascript 폴백 — argv 전달로 따옴표/특수문자 인젝션 방지.

TITLE="${1:-Claude Code}"
MSG="${2:-알림}"

# 클릭 시 활성화할 앱 번들 ID (기본: IntelliJ IDEA)
ACTIVATE_APP="${CLAUDE_NOTIFY_ACTIVATE:-com.jetbrains.intellij}"

OS=$(uname -s)
if [ "$OS" = "Darwin" ]; then
  TN=$(command -v terminal-notifier)
  [ -z "$TN" ] && [ -x /opt/homebrew/bin/terminal-notifier ] && TN=/opt/homebrew/bin/terminal-notifier
  if [ -n "$TN" ]; then
    "$TN" -title "$TITLE" -message "$MSG" -activate "$ACTIVATE_APP" \
      -group claude-code -sound Glass >/dev/null 2>&1
  else
    osascript - "$TITLE" "$MSG" <<'EOF' 2>/dev/null
on run argv
  display notification (item 2 of argv) with title (item 1 of argv) sound name "Glass"
end run
EOF
  fi
elif grep -qi microsoft /proc/version 2>/dev/null; then
  PS_TITLE=$(printf '%s' "$TITLE" | sed "s/'/''/g")
  PS_MSG=$(printf '%s' "$MSG" | sed "s/'/''/g")
  powershell.exe -Command "[void](New-BurntToastNotification -Text '$PS_TITLE','$PS_MSG')" 2>/dev/null \
    || powershell.exe -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('$PS_MSG','$PS_TITLE')" 2>/dev/null
else
  notify-send "$TITLE" "$MSG" 2>/dev/null
fi

exit 0
