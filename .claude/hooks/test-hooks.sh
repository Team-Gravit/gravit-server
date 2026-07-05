#!/bin/bash
# 훅 자가 테스트: 픽스처 JSON을 각 훅에 파이프해 exit code·JSON 출력을 검증한다.
# 사용: bash .claude/hooks/test-hooks.sh
#
# expect_decision:
#   "ask"/"deny" = 해당 permissionDecision JSON이 있어야 통과
#   "none"       = decision이 없어야 통과 (allow 케이스가 ask로 새는 것을 잡는다)

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$HOOKS_DIR/../.." && pwd)}"

PASS=0
FAIL=0

assert_case() {
  local desc="$1" hook="$2" input="$3" expect_exit="$4" expect_decision="$5"

  local out exit_code decision
  out=$(printf '%s' "$input" | bash "$HOOKS_DIR/$hook" 2>/dev/null)
  exit_code=$?
  decision=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null)

  local ok=1
  [ "$exit_code" = "$expect_exit" ] || ok=0
  if [ "$expect_decision" = "none" ]; then
    [ -z "$decision" ] || ok=0
  elif [ -n "$expect_decision" ]; then
    [ "$decision" = "$expect_decision" ] || ok=0
  fi

  if [ "$ok" = "1" ]; then
    PASS=$((PASS + 1))
    echo "PASS: $desc"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: $desc (exit=$exit_code expect_exit=$expect_exit decision=${decision:-none} expect_decision=$expect_decision)"
  fi
}

bash_input() {
  jq -n --arg cmd "$1" '{tool_name: "Bash", tool_input: {command: $cmd}}'
}

edit_input() {
  jq -n --arg path "$1" '{tool_name: "Edit", tool_input: {file_path: $path}}'
}

write_input() {
  jq -n --arg path "$1" '{tool_name: "Write", tool_input: {file_path: $path}}'
}

echo "=== block-dangerous-commands.sh: DENY 티어 ==="
assert_case "dd of=/dev/sda 차단" block-dangerous-commands.sh "$(bash_input 'dd if=/dev/zero of=/dev/sda')" 2 "none"
assert_case "포크밤 차단" block-dangerous-commands.sh "$(bash_input ':(){ :|:& };:')" 2 "none"
assert_case "rm -rf ~ (홈 자체) 차단" block-dangerous-commands.sh "$(bash_input 'rm -rf ~')" 2 "none"
assert_case "rm -rf ~/ (홈 자체, 슬래시) 차단" block-dangerous-commands.sh "$(bash_input 'rm -rf ~/')" 2 "none"

echo ""
echo "=== block-dangerous-commands.sh: ASK 티어 ==="
assert_case "DROP  DATABASE(공백2) 확인요청" block-dangerous-commands.sh "$(bash_input 'psql -c "DROP  DATABASE gravit"')" 0 "ask"
assert_case "psql DROP SCHEMA 확인요청" block-dangerous-commands.sh "$(bash_input 'psql -c "DROP SCHEMA public CASCADE"')" 0 "ask"
assert_case "chmod -R 0777 확인요청" block-dangerous-commands.sh "$(bash_input 'chmod -R 0777 /')" 0 "ask"
assert_case "chmod 777 -R 확인요청" block-dangerous-commands.sh "$(bash_input 'chmod 777 -R /')" 0 "ask"
assert_case "rm -rf ~/하위경로는 deny 아닌 ask" block-dangerous-commands.sh "$(bash_input 'rm -rf ~/some/project/node_modules')" 0 "ask"
assert_case "rm -rf /tmp/build 확인요청" block-dangerous-commands.sh "$(bash_input 'rm -rf /tmp/build')" 0 "ask"
assert_case "flywayClean 확인요청" block-dangerous-commands.sh "$(bash_input './gradlew flywayClean')" 0 "ask"
assert_case "flywayRepair 확인요청" block-dangerous-commands.sh "$(bash_input './gradlew flywayRepair')" 0 "ask"
assert_case "flyway repair(공백 변형) 확인요청" block-dangerous-commands.sh "$(bash_input 'flyway repair -url=jdbc:postgresql://localhost/db')" 0 "ask"
assert_case "cp로 마이그레이션 덮어쓰기 확인요청" block-dangerous-commands.sh "$(bash_input 'cp /tmp/evil.sql src/main/resources/db/migration/V1__init_tables.sql')" 0 "ask"
assert_case "git push refspec force(+) 확인요청" block-dangerous-commands.sh "$(bash_input 'git push origin +main')" 0 "ask"
assert_case ".claude 훅 자기수정 확인요청" block-dangerous-commands.sh "$(bash_input 'sed -i "" "s/exit 2/exit 0/" .claude/hooks/block-dangerous-commands.sh')" 0 "ask"

echo ""
echo "=== block-dangerous-commands.sh: 통과(오탐 해소) ==="
assert_case "rg DROP TABLE 검색 통과" block-dangerous-commands.sh "$(bash_input 'rg "DROP TABLE" src/main/resources/db/migration/')" 0 "none"
assert_case "git log --grep truncate 통과" block-dangerous-commands.sh "$(bash_input 'git log --grep="truncate table"')" 0 "none"
assert_case "일반 git push 통과" block-dangerous-commands.sh "$(bash_input 'git push -u origin HEAD')" 0 "none"

echo ""
echo "=== protect-migrations.sh ==="
EXISTING_MIGRATION=$(git -C "$CLAUDE_PROJECT_DIR" ls-tree -r --name-only origin/main -- src/main/resources/db/migration 2>/dev/null | grep -E 'V[0-9]+__.*\.sql' | head -1)
if [ -n "$EXISTING_MIGRATION" ]; then
  assert_case "origin/main 존재 마이그레이션 Edit 차단" protect-migrations.sh "$(edit_input "$CLAUDE_PROJECT_DIR/$EXISTING_MIGRATION")" 0 "deny"
  assert_case "origin/main 존재 마이그레이션 Write 차단" protect-migrations.sh "$(write_input "$CLAUDE_PROJECT_DIR/$EXISTING_MIGRATION")" 0 "deny"
else
  echo "SKIP: origin/main 마이그레이션을 찾지 못해 케이스 생략"
fi
assert_case "신규 V파일 Edit 허용" protect-migrations.sh "$(edit_input "$CLAUDE_PROJECT_DIR/src/main/resources/db/migration/V9999__test_never_exists.sql")" 0 "none"
assert_case "신규 V파일 Write 허용" protect-migrations.sh "$(write_input "$CLAUDE_PROJECT_DIR/src/main/resources/db/migration/V9999__test_never_exists.sql")" 0 "none"

echo ""
echo "=== protect-claude-config.sh ==="
assert_case "훅 스크립트 Edit 확인요청" protect-claude-config.sh "$(edit_input "$CLAUDE_PROJECT_DIR/.claude/hooks/block-dangerous-commands.sh")" 0 "ask"
assert_case "settings.json Edit 확인요청" protect-claude-config.sh "$(edit_input "$CLAUDE_PROJECT_DIR/.claude/settings.json")" 0 "ask"
assert_case "일반 파일 Edit 허용" protect-claude-config.sh "$(edit_input "$CLAUDE_PROJECT_DIR/src/main/java/gravit/Foo.java")" 0 "none"

echo ""
echo "결과: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
