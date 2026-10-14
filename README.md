# ai-flow-kit

Skills and agents for AI coding agents: fix bugs test-first, build tickets in small slices, and review PRs with evidence.

8 skills and 3 sub-agents in plain markdown. Not tied to one tool: skills use the open `SKILL.md` format, so they work in Claude Code, Codex, OpenCode and other agents that read skill folders. Bugs get a reproduce-first path, changes get process sized to the work, and every path ends at the same checks.

## Install

```bash
git clone https://github.com/zaymgmgmyint/ai-flow-kit.git ~/dev-tools/ai-flow-kit
cd ~/dev-tools/ai-flow-kit
./install.sh
```

The script symlinks the skills, so `git pull` updates them. It never overwrites an existing entry.

| Tool | What `./install.sh` sets up |
|---|---|
| Shared folder `~/.agents/skills` | All 8 skills. Read by Codex and OpenCode, among others |
| Claude Code (if `~/.claude` exists) | Skills in `~/.claude/skills`, sub-agents in `~/.claude/agents` |
| Any other tool | Copy or link `skills/*` into the folder that tool reads skills from |

Options: `--target agents` (shared folder only), `--target claude` (Claude Code only), `--copy` (copy instead of symlink).

Restart your tool after installing.

## The flow

```
/flow-start  →  bug or change?
   ├─ bug (any size)  → /flow-bug: restate → reproduce with a failing test → cause → fix → prove
   └─ change
        ├─ tiny            → just do it, verify
        ├─ one session     → short plan → /flow-build
        ├─ multi-session   → /flow-spec → /flow-tickets → /flow-build (per ticket)
        └─ not decided     → /flow-grill → then one of the above
after shipping            → /flow-retro

teammate's PR             → /flow-pr-review <number | URL | branch>
```

Most daily work (small and medium bugs with a ticket) goes straight to `/flow-bug`. Skip `/flow-start` when you already know it's a bug. If your tool doesn't use slash commands, ask for the skill by name ("use flow-bug on this ticket").

| Skill | Does | Writes |
|---|---|---|
| flow-start | Bug or change, size, repos touched, next step | nothing |
| flow-bug | Failing regression test first, root cause, smallest fix, ticket note | code + report |
| flow-grill | One-question-at-a-time interview with recommended answers | decisions.md |
| flow-spec | Decision record, test seams agreed first | spec.md |
| flow-tickets | Vertical slices, blocking order, paste-ready blocks | tickets.md |
| flow-build | One ticket, worktree per repo, red-green, verify, review | code + report |
| flow-retro | Max 3 evidence-based changes to the setup | edits after approval |
| flow-pr-review | Teammate's PR: ticket match, build, deep review, draft comments | review draft (posts only if you say so) |

## Sub-agents

| Agent | Job |
|---|---|
| flow-explorer | Read-only code map, short report |
| flow-reviewer | Read-only review, findings with file:line and impact |
| flow-verifier | Runs build and tests, reports pass/fail without log noise |

The files in `agents/` are plain prompts with only `name` and `description`, so they stay portable. Sub-agent formats differ between tools:

- **Claude Code:** the install script adds read-only tools and a model (haiku, or sonnet for the reviewer).
- **Other tools:** use their own sub-agent feature with these prompts, or skip them. Every skill has a fallback and does the step itself when no sub-agent exists.

## Example: a small bug

```
/flow-bug User list still shows deactivated users. Should only show active ones.
```

What comes back (shortened):

```
Cause (confirmed): findAll() has no status filter. UserRepository.java:42
Fix: query now filters status = ACTIVE.
Test: UserListTest.excludesDeactivatedUsers  failed before, passes after.
Commands: ./mvnw verify  passed (212 tests).
Not verified: nothing.
Ticket note:
  Deactivated users appeared because the list query had no status filter.
  Added the filter and a regression test. All tests pass.
```

Nothing is committed or pushed. You review the diff and commit.

## Project setup

Each repo needs an agent instructions file with its **verify command**. Use `AGENTS.md` (read by most tools) or `CLAUDE.md` (Claude Code), or both.

```markdown
# Verify
./mvnw verify
```

For work across backend and frontend, keep repos side by side and start your tool in the parent folder:

```
~/work/<project>/
├── AGENTS.md      ← what each repo is, verify commands, "backend first"
├── backend/
└── frontend/
```

## Where files go

`~/flow/<project>/<item-slug>/` holds decisions.md, spec.md, tickets.md. It sits outside the repos so one work item can span several repos. Tickets are plain markdown: copy them into whatever ticket tool you use. Bugs usually need no files here.

## Make it yours

- Change the work folder: replace `~/flow/` in the skills.
- After a few work items, run `/flow-retro` and let the evidence change the skills.

## Credits

This kit adapts ideas from:

- **Matt Pocock, AI Hero skills** ([aihero.dev/skills](https://www.aihero.dev/skills), [mattpocock/skills](https://github.com/mattpocock/skills)): grill → spec → tickets → implement, test seams, vertical slices ("tracer bullets, not layers"), red-green TDD rules.
- **Dan Vega** ([danvega/skills](https://github.com/danvega/skills), [claude-code-start-simple](https://github.com/danvega/claude-code-start-simple)): short skills with "when not to use", bug-repro and code-review rules, verified vs unverified reporting, "gates, not babysitting".

The engineering habits underneath are older: TDD (Kent Beck), tracer bullets (*The Pragmatic Programmer*), parallel change, ADRs, and plain old code review.

## License

[MIT](LICENSE)
