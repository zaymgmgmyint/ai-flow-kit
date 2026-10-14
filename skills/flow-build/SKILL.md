---
name: flow-build
description: Build one ticket or one planned change with red-green tests, across one or more repos, and prove it works. Also handles tiny changes (typo, config, rename) in a light mode. Use when the plan or ticket is agreed. Do not use when design decisions are still open, or for bugs (use flow-bug).
---

Build exactly one ticket. Make it observable, then make it pass.

# Set up
- Read the ticket (from `tickets.md` or the plan in chat) and each repo's agent instructions file (AGENTS.md or CLAUDE.md).
- One git worktree per repo touched, on a branch named `<ticket-id>-<short-slug>`. Reuse a worktree if it already exists.
- Find each repo's verify command (AGENTS.md or CLAUDE.md, build file, README). If you can't find one, ask.

# Tiny mode
For typos, config values, renames and copy changes with no behaviour change:
- No plan approval, no new test.
- Make the change, run the verify command, report.
- If it turns out to change behaviour, stop and switch to normal mode with a short plan.

# Pick the verification mode
Say which one you use and why, in one line:
- **Test-first** (default for any behaviour change): red-green loop below.
- **Test-supported:** the behaviour can't be isolated in a failing test first. Say why, add the best test you can after, run all checks.
- **Manual:** docs, config, visual or infra changes that automation can't prove. Write the steps, expected result and what you observed.

Never pick a weaker mode just because the test is hard to write.

# Loop (red-green)
- One test → watch it fail for the right reason (not a setup error) → minimal code to pass → next test.
- No batch of tests up front.
- Prefer the test seams the ticket or spec names. If one doesn't fit, use the closest existing seam that proves the behaviour and say so in the report. Stop and ask only if the change of seam changes behaviour, acceptance criteria or architecture, or adds real work.
- Mock only real boundaries: external APIs, devices, time, randomness. Never mock our own modules.
- Avoid tests that break on an internal rename, or that compute the expected value the same way the code does.
- Backend contract changes come before the frontend or edge code that uses them.
- E2E or browser tests come after the behaviour works.

# Stay in scope
- Build only what the ticket says. Note other issues in "Found along the way". Don't fix them.
- Batch small choices and report them at the end. Stop only if a choice changes the ticket's behaviour or data.
- Stuck after two attempts on the same failure? Stop and report what you tried and what you need.

# Ask first, every time
Commit, push, merge, deploy, delete data, destructive database commands (drop, truncate, delete or update without a filter), and changes to shared environments or infrastructure. One "yes" covers that one action only.

# Done means
- Every acceptance box is backed by a passing test, or by manual steps if the mode is manual.
- Verify command passes in every repo touched. A check that could not run is **blocked**, not passed.
- Run the `flow-reviewer` sub-agent on the diff. No sub-agents? Do a separate review pass yourself: wrong behaviour, data loss, security, broken contracts, retries, tests. Open the file at each finding and confirm it before acting. Fix real findings, list the rest.
- Update the ticket's `Status:` line in `tickets.md` if it exists.

# Report
- **Mode:** tiny / test-first / test-supported / manual.
- Commands run and their results (pass / fail / blocked, and any skipped tests).
- Per repo: files changed, one line each.
- **Verified** (test or command proves it) vs **Not verified** (needs my eyes, e.g. UI look, device behaviour).
- Found along the way.
- **Status:** implementation done, waiting for your review. It is not accepted until you say so.

Plain language. No em dashes.
