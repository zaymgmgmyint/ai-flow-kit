#!/usr/bin/env bash
# Check the kit before you push: file structure, metadata, links, and the installer.
#   ./scripts/validate.sh
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
errors=0
fail() { echo "FAIL  $1"; errors=$((errors + 1)); }
ok()   { echo "ok    $1"; }

field() {  # field <file> <key>: value of a frontmatter key
  awk -v k="$2" 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1 && index($0, k": ")==1 {sub(k": ", ""); print; exit}' "$1"
}

echo "== Skills"
for d in skills/*/; do
  n="$(basename "$d")"; f="$d/SKILL.md"
  [ -f "$f" ] || { fail "$n: no SKILL.md"; continue; }
  name="$(field "$f" name)"; desc="$(field "$f" description)"
  [ "$name" = "$n" ] || fail "$n: frontmatter name '$name' does not match folder"
  [ -n "$desc" ] || fail "$n: missing description"
  [ "${#desc}" -le 1024 ] || fail "$n: description longer than 1024 characters"
  grep -q "—" "$f" && fail "$n: contains an em dash"
  [ "$name" = "$n" ] && [ -n "$desc" ] && ok "$n"
done

echo "== Sub-agents"
for f in agents/*.md; do
  n="$(basename "$f" .md)"
  [ "$(field "$f" name)" = "$n" ] || fail "$n: frontmatter name does not match file name"
  [ -n "$(field "$f" description)" ] || fail "$n: missing description"
  grep -qE '^(tools|model):' "$f" && fail "$n: has tool-specific frontmatter (tools/model). Keep agents portable; install.sh adds these for Claude Code"
  grep -q "never start other sub-agents" "$f" || fail "$n: missing the no-nested-sub-agents rule"
  ok "$n"
done

echo "== Skill references"
for ref in $(grep -oh '`flow-[a-z-]*`' skills/*/SKILL.md agents/*.md | sort -u | tr -d '`'); do
  [ -d "skills/$ref" ] || [ -f "agents/$ref.md" ] || fail "reference to unknown skill or agent: $ref"
done
[ -f skills/flow-pr-review/review-template.md ] || fail "flow-pr-review: review-template.md missing"
ok "references"

echo "== README links"
for link in $(grep -oE '\]\([^)#:]+\)' README.md | sed -E 's/^\]\(//; s/\)$//' | sort -u); do
  [ -e "$link" ] || fail "README links to missing file: $link"
done
ok "links"

echo "== Installer"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/.claude" "$T/.gemini"
HOME="$T" bash install.sh >/dev/null || fail "install.sh failed"
skills_count=$(ls skills | wc -l | tr -d ' ')
for dir in .agents/skills .claude/skills .gemini/antigravity-cli/skills .gemini/config/skills; do
  c=$(ls "$T/$dir" 2>/dev/null | wc -l | tr -d ' ')
  [ "$c" = "$skills_count" ] || fail "install: $dir has $c skills, expected $skills_count"
done
[ "$(ls "$T/.claude/agents" | wc -l | tr -d ' ')" = "$(ls agents | wc -l | tr -d ' ')" ] || fail "install: Claude agents missing"
grep -q '^model:' "$T/.claude/agents/flow-reviewer.md" || fail "install: Claude agent settings not added"
second=$(HOME="$T" bash install.sh | grep -c '^added' || true)
[ "$second" = "0" ] || fail "install: second run added $second entries (should add none)"
HOME="$T" bash install.sh --uninstall >/dev/null || fail "uninstall failed"
left=$(find "$T/.agents" "$T/.claude" "$T/.gemini" -name 'flow-*' | wc -l | tr -d ' ')
[ "$left" = "0" ] || fail "uninstall left $left entries"
bash install.sh --target nope >/dev/null 2>&1 && fail "install accepted a bad --target"
ok "install, rerun, uninstall, bad input"

echo
if [ "$errors" -eq 0 ]; then echo "All checks passed."; else echo "$errors check(s) failed."; exit 1; fi
