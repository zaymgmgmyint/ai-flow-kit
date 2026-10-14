---
name: flow-pr-review
description: Review a teammate's pull request (PR number, URL, or branch) and draft comments I can post, in a fixed format. Checks it against its ticket, runs the build, finds problems that matter. Do not use for my own uncommitted changes (flow-build and flow-bug already review those).
---

Help me decide: approve, approve with comments, or request changes. Give the author enough evidence to act.

Best run in a fresh session, not the one that wrote the code, so the review doesn't inherit the author's assumptions.

# 1. Get the PR
- GitHub: `gh pr view <n>` for title, description, base branch, size. `gh pr diff <n>` for the diff.
- Other hosts or a plain branch: `git fetch` then `git diff <base>...<branch>`.
- Check it out in a separate worktree (e.g. `../wt/pr-<n>`), so my current work is never touched.
- Read the PR description and the linked ticket text if it's there. If there is no ticket or description, that is the first blocking finding.
- Read the repo's AGENTS.md or CLAUDE.md for its rules and verify command.

# 2. Size and risk
- Over about 600 changed lines (not counting generated files or lock files): say so, review by area, and suggest how it could have been split.
- Related PRs in other repos (backend + frontend): ask for them and review them together.
- Decide the **merge danger** now: easy to undo or hard to undo (migrations, removed API fields, data written in a new format, messages to devices). Hard to undo means read those parts line by line.

# 3. Spec: does it do what the ticket asks?
- List each thing the ticket asks for and mark it **done**, **partly done**, or **missing**.
- Flag changes the ticket didn't ask for.

# 4. Standards: is it built right?
- Use the `flow-verifier` sub-agent on the PR worktree, or run the verify command yourself if your tool has no sub-agents. A red build is a blocking finding.
- Check that new behaviour has tests, and that they would fail if the change were removed.
- Run the `flow-reviewer` sub-agent with the diff, the PR description and the ticket. No sub-agents? Review it yourself in a fresh pass with the same priorities: wrong behaviour, data loss, security, broken contracts, retries, tests, frontend states.
- Sub-agents do their own work. They must not start more sub-agents or re-run this skill.

# 5. Check every finding before keeping it
For each finding, from a sub-agent or your own:
- Open the file at that line and confirm the code says what the finding claims.
- Confirm the case is real: you can describe the input that triggers it.
- Name its source: a rule from AGENTS.md or CLAUDE.md, a quoted ticket line, or a named general practice.
- Can't confirm all three? Drop it, or turn it into a `question`.

Do not fill a quota. Do not re-run the review hoping for more findings.

# 6. Draft the review
Follow `review-template.md` in this skill's folder exactly:
- **Summary comment:** verdict, what the PR does, merge danger, Spec, Standards (build, blocking, non-blocking), questions, good.
- **Line comments:** one per finding, with a label: `issue (blocking)`, `suggestion (non-blocking)`, `question`, `nit`, `praise`.
- Verdict follows the template's rules: any blocking issue or red build means request changes.

Write for the author, who may be junior: kind, specific, explain *why*.

# 7. Post only if I say so
- Default: show me the draft. I edit and post it myself.
- If I say "post it" and `gh` is set up: confirm the account first (`gh auth status`), then post the summary with `gh pr review <n>` and `--comment`, `--approve` or `--request-changes` as I choose. If posting line comments isn't possible, put each one under its finding in the summary instead.
- Never merge.
- Remove the PR worktree when I'm done.

Plain language. No em dashes.
