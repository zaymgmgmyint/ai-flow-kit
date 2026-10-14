#!/usr/bin/env bash
# Install ai-flow-kit skills (and sub-agents where supported) for your AI coding tools.
#
#   ./install.sh                 # auto: shared folder + every supported tool found
#   ./install.sh --target agents # only ~/.agents/skills (Codex, OpenCode, other tools that read it)
#   ./install.sh --target claude # only Claude Code (~/.claude/skills + ~/.claude/agents)
#   ./install.sh --target antigravity # only Google Antigravity CLI (agy) and IDE
#   ./install.sh --copy          # copy skills instead of symlinking
#
# Skills are symlinked by default, so `git pull` updates them.
# Existing entries with the same name are skipped, never overwritten.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
MODE="link"
TARGET="auto"

while [ $# -gt 0 ]; do
  case "$1" in
    --copy) MODE="copy" ;;
    --target) TARGET="${2:-}"; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

place() {  # place <from> <to>
  local from="$1" to="$2"
  if [ -e "$to" ] || [ -L "$to" ]; then echo "skip   $to (already exists)"; return; fi
  if [ "$MODE" = "copy" ]; then cp -R "$from" "$to"; else ln -s "$from" "$to"; fi
  echo "added  $to"
}

install_skills() {  # install_skills <dir>
  mkdir -p "$1"
  for d in "$SRC"/skills/*/; do place "${d%/}" "$1/$(basename "$d")"; done
}

# Claude Code sub-agents: add Claude-only settings (read-only tools, model) on install.
install_claude_agents() {
  local dir="$HOME/.claude/agents"
  mkdir -p "$dir"
  for f in "$SRC"/agents/*.md; do
    local name to extra
    name="$(basename "$f" .md)"
    to="$dir/$name.md"
    if [ -e "$to" ] || [ -L "$to" ]; then echo "skip   $to (already exists)"; continue; fi
    case "$name" in
      flow-reviewer) extra="tools: Read, Glob, Grep, Bash\nmodel: sonnet" ;;
      *)             extra="tools: Read, Glob, Grep, Bash\nmodel: haiku" ;;
    esac
    awk -v extra="$extra" '
      /^description:/ && !done { print; gsub(/\\n/, "\n", extra); print extra; done=1; next }
      { print }' "$f" > "$to"
    echo "added  $to"
  done
}

did=""
if [ "$TARGET" = "auto" ] || [ "$TARGET" = "agents" ]; then
  echo "== Shared skills folder (~/.agents/skills)"
  install_skills "$HOME/.agents/skills"
  did="$did agents"
fi
if [ "$TARGET" = "claude" ] || { [ "$TARGET" = "auto" ] && [ -d "$HOME/.claude" ]; }; then
  echo "== Claude Code (~/.claude)"
  install_skills "$HOME/.claude/skills"
  install_claude_agents
  did="$did claude"
fi
if [ "$TARGET" = "antigravity" ] || { [ "$TARGET" = "auto" ] && [ -d "$HOME/.gemini" ]; }; then
  echo "== Google Antigravity (~/.gemini)"
  install_skills "$HOME/.gemini/antigravity-cli/skills"   # CLI (agy)
  install_skills "$HOME/.gemini/config/skills"            # IDE
  did="$did antigravity"
fi
[ -z "$did" ] && { echo "Nothing installed. Use --target agents, claude or antigravity."; exit 1; }

mkdir -p "$HOME/flow"
echo "Done. Restart your AI coding tool, then try: /flow-bug or /flow-start"
