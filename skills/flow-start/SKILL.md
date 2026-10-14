---
name: flow-start
description: Start any new piece of dev work from a ticket or request (bug, feature, change, idea). Sorts it and picks the next step. Use at the start of a task. Do not use for a code review.
---

Decide what kind of work this is and how much process it needs, then hand off. Do not write code here, not even for tiny work. This skill only routes.

# Bug or not?
- If the ticket describes something that worked wrong (error, wrong data, wrong behaviour, crash, timeout), it's a bug. Go `flow-bug`, whatever its size.
- If it looks like a bug but is really a missing feature or a changed requirement, say so and treat it as a change.

# Read first
- Read the agent instructions file (AGENTS.md or CLAUDE.md) of every repo the work touches.
- Look at the code the request points to. Skim, don't read everything. For a wide search, use the `flow-explorer` sub-agent if your tool has sub-agents; otherwise search yourself and keep only short notes.
- Find which repos the work touches (backend, frontend, edge, infra...). Name them in the plan.

# Size the work (not a bug)
Pick one size and say why in one line:
- **Tiny:** one file or a few lines, no decision to make (typo, config, rename, copy change). Go `flow-build` in tiny mode.
- **One session:** decisions are clear and it fits one context window. Write a short plan (goal, files, test, verify command) and wait for "go". Then use `flow-build`.
- **Multi-session:** spans several sessions or several repos, or has many steps. Go `flow-spec` then `flow-tickets`.
- **Not decided yet:** goal or behaviour is unclear, or there are open design choices. Go `flow-grill` first.

If unsure between two sizes, pick the smaller and say so.

# Workspace
- Each work item gets a folder: `~/flow/<project>/<item-slug>/`. `<project>` is the product name, `<item-slug>` is a short kebab name.
- Create the folder only when a file is needed. Do not create empty files.

# Output
- Bug or change, size, one-line reason, repos touched, next skill.
- Plain language. No em dashes.
