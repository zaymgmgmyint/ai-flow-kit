---
name: flow-bug
description: Fix a small or medium bug from a ticket or report. Reproduce it with a failing test first, find the cause, make the smallest fix, prove it. Use for any bug, even a tiny one. Do not use for new features or open design questions.
---

Make the failure observable before changing any code.

# 1. Restate the ticket
- Rewrite it as: **Steps**, **Expected**, **Actual**, **Repos touched**.
- If something blocks reproduction (missing input, environment, version), ask only about that. Don't ask what the code can answer.
- If the ticket says one thing and the code clearly intends another, say so before going on.

# 2. Find the code path
- Trace from the entry point (endpoint, handler, UI action, message) to where it goes wrong.
- If the search is wide, use the `flow-explorer` sub-agent if your tool has sub-agents; otherwise search yourself and keep only short notes.
- Read each repo's agent instructions file (AGENTS.md or CLAUDE.md) for its verify command and test style.

# 3. Reproduce with a test
- Write a regression test at the highest sensible seam: endpoint or service test before a deep unit test.
- Run it before any fix. It must fail for the reason in the ticket, not a setup or compile error.
- Can't reproduce? Stop. Report what you tried, what happened, and what you need. Do not guess a fix.
- If a test truly can't cover it (UI look, real device, timing), write the manual steps that show the bug and mark them **manual**.

# 4. Root cause
- 2 to 3 lines: what goes wrong, where (file:line), and why.
- Mark it **confirmed** (the test proves it) or **suspected**. Never present a suspicion as confirmed.
- If the same cause can hit other places, list them. Don't fix them.

# 5. Fix
- Smallest change that fixes the cause, not just the symptom.
- One git worktree per repo touched, branch `<ticket-id>-<short-slug>`.
- No refactors or cleanups. Put them in "Found along the way".
- Two failed fix attempts on the same cause? Stop and report.

# 6. Prove it
- Regression test passes.
- Verify command passes in every repo touched.
- Run the `flow-reviewer` sub-agent on the diff. No sub-agents? Do a separate review pass yourself: wrong behaviour, data loss, security, broken contracts, retries, tests. Open the file at each finding and confirm it before acting. Fix real findings, list the rest.

# 7. Report
- **Cause** (confirmed / suspected) and **Fix**, one line each.
- **Test:** name, file, failed before / passes after.
- **Commands run** and results.
- **Not verified:** what needs my eyes.
- **Found along the way.**
- **Ticket note:** 3 to 5 plain lines I can paste into the ticket (cause, fix, how it was tested).
- Do not commit or push unless I say so.

Plain language. No em dashes.
