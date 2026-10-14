#!/usr/bin/env bash
# Install ai-flow-kit skills (and sub-agents where supported) for your AI coding tools.
#
#   ./install.sh                      # auto: shared folder + every supported tool found
#   ./install.sh --target agents      # only ~/.agents/skills (Codex, OpenCode, other tools that read it)
#   ./install.sh --target claude      # only Claude Code (~/.claude/skills + ~/.claude/agents)
#   ./install.sh --target antigravity # only Google Antigravity CLI (agy) and IDE
#   ./install.sh --copy               # copy skills instead of symlinking
#   ./install.sh --uninstall          # remove ai-flow-kit entries (same --target rules apply)
#   ./install.sh --help
#
# Skills are symlinked by default, so `git pull` updates them.
# Existing entries with the same name are skipped, never overwritten.
# Safe to run again: it only adds what is missing.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
MODE="link"
TARGET="auto"
ACTION="install"

usage() { sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --copy) MODE="copy" ;;
    --target) TARGET="${2:-}"; shift ;;
    --uninstall) ACTION="uninstall" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; echo; usage; exit 1 ;;
  esac
  shift
done

case "$TARGET" in
  auto|agents|claude|antigravity) ;;
  *) echo "Unknown target: '$TARGET'. Use agents, claude or antigravity."; exit 1 ;;
esac

# Check the kit itself before touching anything.
[ -d "$SRC/skills" ] && [ -d "$SRC/agents" ] || { echo "Run this from an ai-flow-kit checkout (skills/ and agents/ not found in $SRC)."; exit 1; }
for d in "$SRC"/skills/*/; do
  [ -f "$d/SKILL.md" ] || { echo "Broken kit: $d has no SKILL.md"; exit 1; }
done

SKILL_NAMES=$(for d in "$SRC"/skills/*/; do basename "$d"; done)
AGENT_NAMES=$(for f in "$SRC"/agents/*.md; do basename "$f" .md; done)

place() {  # place <from> <to>
  local from="$1" to="$2"
  if [ -e "$to" ] || [ -L "$to" ]; then echo "skip     $to (already exists)"; return; fi
  if [ "$MODE" = "copy" ]; then cp -R "$from" "$to"; else ln -s "$from" "$to"; fi
  echo "added    $to"
}

install_skills() {  # install_skills <dir>
  mkdir -p "$1"
  for n in $SKILL_NAMES; do place "$SRC/skills/$n" "$1/$n"; done
}

# Claude Code sub-agents: add Claude-only settings (read-only tools, model) on install.
install_claude_agents() {
  local dir="$HOME/.claude/agents"
  mkdir -p "$dir"
  for name in $AGENT_NAMES; do
    local to="$dir/$name.md" extra
    if [ -e "$to" ] || [ -L "$to" ]; then echo "skip     $to (already exists)"; continue; fi
    case "$name" in
      flow-reviewer) extra="tools: Read, Glob, Grep, Bash\nmodel: sonnet" ;;
      *)             extra="tools: Read, Glob, Grep, Bash\nmodel: haiku" ;;
    esac
    awk -v extra="$extra" '
      /^description:/ && !done { print; gsub(/\\n/, "\n", extra); print extra; done=1; next }
      { print }' "$SRC/agents/$name.md" > "$to"
    echo "added    $to"
  done
}

# Remove only entries with our names. Anything else in these folders is left alone.
remove_entry() {  # remove_entry <path>
  if [ -L "$1" ] || [ -e "$1" ]; then rm -rf "$1"; echo "removed  $1"; fi
}
uninstall_skills() {  # uninstall_skills <dir>
  [ -d "$1" ] || return 0
  for n in $SKILL_NAMES; do remove_entry "$1/$n"; done
}
uninstall_claude_agents() {
  for n in $AGENT_NAMES; do remove_entry "$HOME/.claude/agents/$n.md"; done
}

want() {  # want <target> <marker-dir>: should this target run?
  [ "$TARGET" = "$1" ] || { [ "$TARGET" = "auto" ] && { [ -z "$2" ] || [ -d "$2" ]; }; }
}

did=""
if want agents ""; then
  echo "== Shared skills folder (~/.agents/skills)"
  if [ "$ACTION" = "install" ]; then install_skills "$HOME/.agents/skills"; else uninstall_skills "$HOME/.agents/skills"; fi
  did="$did agents"
fi
if want claude "$HOME/.claude"; then
  echo "== Claude Code (~/.claude)"
  if [ "$ACTION" = "install" ]; then install_skills "$HOME/.claude/skills"; install_claude_agents
  else uninstall_skills "$HOME/.claude/skills"; uninstall_claude_agents; fi
  did="$did claude"
fi
if want antigravity "$HOME/.gemini"; then
  echo "== Google Antigravity (~/.gemini)"
  for dir in "$HOME/.gemini/antigravity-cli/skills" "$HOME/.gemini/config/skills"; do   # CLI (agy), IDE
    if [ "$ACTION" = "install" ]; then install_skills "$dir"; else uninstall_skills "$dir"; fi
  done
  did="$did antigravity"
fi
[ -z "$did" ] && { echo "Nothing to do. Use --target agents, claude or antigravity."; exit 1; }

if [ "$ACTION" = "install" ]; then
  mkdir -p "$HOME/flow"
  echo "Done. Restart your AI coding tool, then try: /flow-bug or /flow-start"
else
  echo "Done. Your ~/flow work notes were kept."
fi
