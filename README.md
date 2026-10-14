# ai-flow-kit

Skills and agents for AI coding agents: fix bugs test-first, build tickets in small slices, and review PRs with evidence.

8 skills and 3 sub-agents in plain markdown. Not tied to one tool: skills use the open `SKILL.md` format, so they work in Claude Code, Codex, OpenCode and other agents that read skill folders. Bugs get a reproduce-first path, changes get process sized to the work, and every path ends at the same checks.

## Install

Two ways. Pick one.

| | Option A: `npx skills` | Option B: clone + `install.sh` |
|---|---|---|
| Installs | 8 skills | 8 skills + 3 sub-agents (Claude Code) |
| Needs | Node.js | git, bash |
| Update | Run the add command again | `git pull` |
| Best for | Quick setup, any tool | Editing the skills yourself |

### Option A: one command with `npx skills`

Uses the [skills](https://github.com/vercel-labs/skills) installer. It reads this repo straight from GitHub, finds every `skills/<name>/SKILL.md`, and puts them in the right folder for each AI tool it detects (Claude Code, Codex, OpenCode, Cursor, Gemini CLI and more).

```bash
# See what's inside first (installs nothing)
npx skills add zaymgmgmyint/ai-flow-kit --list

# Install for your user, in every project
npx skills add zaymgmgmyint/ai-flow-kit -g

# Install into one project only (run inside that project's folder)
cd ~/work/my-project
npx skills add zaymgmgmyint/ai-flow-kit
```

More options:

```bash
# Only some skills
npx skills add zaymgmgmyint/ai-flow-kit -g --skill flow-bug --skill flow-pr-review

# Only some tools
npx skills add zaymgmgmyint/ai-flow-kit -g -a claude-code -a opencode
```

| Scope | Where skills go | Works in |
|---|---|---|
| Global (`-g`) | Your home folder, e.g. `~/.claude/skills`, `~/.agents/skills` | Every project |
| Project (no `-g`) | Inside the project, e.g. `./.claude/skills`, `./.agents/skills` | Only that project |

Project installs can be committed so the whole team gets the skills when they clone the repo. If you don't want that, add those folders to the project's `.gitignore`.

To update, run the same `add` command again.

### Option B: clone and run the install script

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

### Check it worked

Restart your AI tool, then:

- **Claude Code:** type `/skills`. You should see the 8 `flow-*` skills. Type `/agents` for the sub-agents (Option B only).
- **Other tools:** ask "what skills do you have?" or check the folder, e.g. `ls ~/.agents/skills`.

## Use

Open your AI tool **in the project folder** (or the parent folder of your backend and frontend repos), then call a skill.

**Claude Code and tools with slash commands:**

```
/flow-bug <paste the bug ticket>
/flow-start <paste any ticket or request>
/flow-pr-review 123
```

**Tools without slash commands:** ask for the skill by name.

```
Use flow-bug on this ticket: <paste the ticket>
```

### Which skill when

| You have... | Run | You get |
|---|---|---|
| A bug ticket (small or medium) | `/flow-bug <ticket>` | Failing test, cause, fix, proof, ticket note |
| Any ticket, not sure what kind | `/flow-start <ticket>` | Bug or change, size, and the next skill to run |
| A clear, small change | `/flow-build <ticket>` | Short plan to approve, then code with tests |
| A fuzzy idea | `/flow-grill <idea>` | Questions with recommended answers, then decisions.md |
| A big, multi-session feature | `/flow-spec`, then `/flow-tickets` | spec.md, then paste-ready tickets |
| One of those tickets | `/flow-build T3` | That ticket built and verified |
| A teammate's pull request | `/flow-pr-review <number, URL or branch>` | Verdict and draft review comments |
| A few finished items | `/flow-retro` | Up to 3 changes to improve the skills |

### What you do

- Answer a question only when the ticket is missing something that blocks the work.
- Approve the plan for a change (`flow-build`).
- Review the final report and the diff, then **commit yourself**. The skills never commit, push or merge.
- For PR reviews, edit the draft and post it, or say "post it".

### Before your first run

Make sure each repo has an `AGENTS.md` or `CLAUDE.md` with its verify command (see [Project setup](#project-setup)). Without it, the agent will ask you which command runs the tests.

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
| flow-pr-review | Teammate's PR: spec check, build, deep review, every finding verified | review in a fixed format (see `review-template.md`), posts only if you say so |

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

## PR review format

`/flow-pr-review` always drafts the same two-part review, defined in [`skills/flow-pr-review/review-template.md`](skills/flow-pr-review/review-template.md):

1. **Summary comment:** verdict, what the PR does, merge danger (easy or hard to undo), **Spec** (does it do what the ticket asks?) and **Standards** (build result, blocking and non-blocking findings), questions, and one thing done well.
2. **Line comments:** one per finding, each starting with a label.

| Label | Author must... |
|---|---|
| `issue (blocking)` | Fix before merge |
| `suggestion (non-blocking)` | Decide |
| `question` | Answer |
| `nit` | Optional |
| `praise` | Nothing |

Every finding is checked against the actual file before it's kept, and names its source: a rule from AGENTS.md or CLAUDE.md, a quoted ticket line, or a named practice. Any blocking issue or a red build means **Request changes**.

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
