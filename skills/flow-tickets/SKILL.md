---
name: flow-tickets
description: Break a spec into vertical-slice tickets I can paste into any ticket tool. Use after flow-spec. Do not use for a single-session change, and do not create tickets in any tool yourself.
---

Turn the spec into thin, complete slices. Each one can be demoed on its own and fits one fresh session.

# Slicing rules
- **Vertical, not layers.** Each ticket goes through every layer it needs (migration, API, UI, tests) for one small behaviour. "All backend first" is a horizontal slice. Don't.
- Test for every ticket: "What can I demo when this is done?" No answer means it's horizontal. Re-slice.
- **Prefactor first.** If code must be reshaped to make the change easy, that is its own ticket, ordered first.
- **Wide changes** (rename a column, change a shared contract): expand → migrate in batches → contract, so builds stay green.
- Each ticket lists its **blocking tickets**.
- Don't over-split. If two tickets can't be demoed apart, merge them.

# Acceptance criteria
- Each criterion is testable at a confirmed seam.
- Each must fail today. If one already passes, drop it or fix it.

# Show before saving
Show a numbered list first: title, repos, blocked by, demo line. Ask me to approve, merge, split or reorder. Only then write the file.

# Ticket file
Save `~/flow/<project>/<item-slug>/tickets.md`. One block per ticket, ready to copy:

```
## T<n>: <short title>
Repos: <repo-a>, <repo-b>
Blocked by: T<x> | none
Why: <one line>
Build:
- <change per repo>
Acceptance:
- [ ] <testable rule>
Demo: <what I can show when done>
Out of scope: <one line>
Status: todo
```

No links, no tool-specific fields. I copy these into my ticket tool myself.
Plain language. No em dashes.
