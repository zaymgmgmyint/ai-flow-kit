---
name: flow-spec
description: Write a spec as a decision record for multi-session or multi-repo work, so a fresh session can continue. Use after decisions are made. Do not use to decide things (use flow-grill) or for work that fits one session.
---

The spec records what was decided. It does not invent anything.

# Before writing
- Read `decisions.md` if it exists, plus the code the work touches.
- If a decision the spec needs is missing, stop and ask. Do not fill the gap yourself.

# Seams first
Agree the test seams before the prose. A seam is a public boundary where behaviour is tested: REST endpoint, service method, message handler, UI component.
- Prefer existing seams, and the highest one that works. Ideally one seam per change.
- List them and ask me to confirm. Tests later go only at confirmed seams.

# Spec file
Save `~/flow/<project>/<item-slug>/spec.md` with these sections:
1. **Goal** (one sentence)
2. **Repos touched** and what changes in each
3. **Behaviour** as short user stories or "when X, then Y" rules
4. **Data and API changes:** tables, columns, migrations, endpoints, payloads, events
5. **Test seams** (confirmed)
6. **Out of scope**
7. **Risks and open questions**

# Rules
- Anything in the spec I never said is a defect. Flag guesses as open questions.
- Keep it short. Link to code paths, don't paste code.
- The spec is disposable after shipping. Lasting decisions go in the repo docs (ADR, AGENTS.md or CLAUDE.md), and only if I agree.
- Point me at the seams and out-of-scope sections to review. That's where a wrong call is cheapest to catch.

Plain language. No em dashes.
