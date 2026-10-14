---
name: flow-retro
description: Look back at a finished work item and improve my flow skills, agent instructions files or gates. Use after a work item ships or a session went badly. Do not use mid-build.
---

Learn from what actually happened, not from what should have happened.

# Gather
- Read the work item folder (`decisions.md`, `spec.md`, `tickets.md`) and the diffs or PRs.
- Ask me 3 short questions: where did I have to step in? What did the agent get wrong more than once? What felt like wasted process?

# Find
- Repeated corrections (same mistake twice or more).
- Steps that added no value for this size of work.
- Rules the agent ignored. A rule ignored twice belongs in a hook or a test, not more text.

# Propose
At most 3 changes, each one:
- **What:** the exact line to add, change or remove, and which file (a flow skill, a repo AGENTS.md or CLAUDE.md, the tool's settings, a hook).
- **Why:** the evidence from this item.

Prefer removing work over adding rules. Judge each change by "will I step in less next time?".
Edit nothing until I approve. Then make only the approved edits.

# Close
- Mark the work item done in `tickets.md` if it exists.
- Plain language. No em dashes.
