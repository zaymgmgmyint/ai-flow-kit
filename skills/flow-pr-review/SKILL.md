---
name: flow-pr-review
description: Review a teammate's pull request (PR number, URL, or branch) and draft comments I can post. Checks it against its ticket, runs the build, finds problems that matter. Do not use for my own uncommitted changes (flow-build and flow-bug already review those).
---

Help me decide: approve, approve with comments, or request changes. Give the author enough evidence to act.

# 1. Get the PR
- GitHub: `gh pr view <n>` for title, description, base branch, size. `gh pr diff <n>` for the diff.
- Other hosts or a plain branch: `git fetch` then `git diff <base>...<branch>`.
- Check it out in a separate worktree (e.g. `../wt/pr-<n>`), so my current work is never touched.
- Read the PR description and the linked ticket text if it's there. If there is no ticket or description, say so as the first finding.

# 2. Size check
- Over about 600 changed lines (not counting generated files or lock files): say so, review by area, and suggest how it could have been split.
- Related PRs in other repos (backend + frontend): ask for them and review them together.

# 3. Does it do what the ticket says?
- List each thing the ticket asks for and mark it **done**, **partly done**, or **missing**.
- Flag changes the ticket didn't ask for (scope creep).

# 4. Run the checks
- Use the `flow-verifier` sub-agent on the PR worktree, or run the verify command yourself if your tool has no sub-agents. A red build is a blocking finding.
- Check that new behaviour has tests, and that tests would fail if the fix were removed.

# 5. Deep review
- Run the `flow-reviewer` sub-agent with the diff, the PR description and the ticket. No sub-agents? Review it yourself in a fresh pass with the same priorities: wrong behaviour, data loss, security, broken contracts, retries, tests, frontend states.
- Read its findings yourself. Drop anything you can't back with a file:line and a real case.

# 6. Draft the review
Write it for the author, who may be junior:
- **Verdict:** approve / approve with comments / request changes, with one line why.
- **Summary:** 2 to 3 lines on what the PR does.
- **Blocking:** must fix before merge. Each one: file:line, the case, the impact, a suggested fix.
- **Non-blocking:** suggestions, marked "nit" if small. Max 5.
- **Questions:** things to ask the author, kept separate from findings.
- **Good:** one line on what was done well, only if true.

Comments are kind and specific: say *why*, not just *what*. No sarcasm, no "just do X".
Do not fill a quota. If nothing blocks, say so.

# 7. Post only if I say so
- Default: show me the draft. I edit and post it myself.
- If I say "post it" and `gh` is set up, use `gh pr review <n>` with `--comment`, `--approve` or `--request-changes` as I choose. Confirm the account first (`gh auth status`).
- Never merge.
- Remove the PR worktree when I'm done.

Plain language. No em dashes.
