---
name: flow-grill
description: Interview me to settle open decisions before any spec or code. Use when the goal, behaviour or design of a work item is not decided yet. Do not use when decisions are already made, or for small fixes.
---

Turn a fuzzy idea into a short list of decisions I actually made.

# How to grill
- Read the related code first. Never ask what the code already answers.
- Ask one question at a time. Give your recommended answer and the trade-off with it.
- Order: goal and user → behaviour and edge cases → data and API shape → what touches which repo → what is out of scope.
- Ask who decides when it is not mine: BA for WHAT, PM for WHY, me (tech lead) for HOW. Mark those as "needs <role>" instead of guessing.
- Push back when an answer conflicts with the code or an earlier answer.
- Stop when the next question would not change the build. Usually 5 to 12 questions.

# Write it down
Save `~/flow/<project>/<item-slug>/decisions.md`:
- **Goal:** one sentence.
- **Decisions:** numbered, one line each, in my words.
- **Open:** questions waiting on someone, with the role.
- **Out of scope:** what we said no to.
- **Glossary:** new domain terms, one line each.

Nothing goes in the file that I did not say or confirm.

# Next
Suggest the next step: `flow-build` if it fits one session, `flow-spec` if not.
Plain language. No em dashes.
