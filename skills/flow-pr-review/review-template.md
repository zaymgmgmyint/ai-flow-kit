# PR review template

Use this layout for every review drafted by flow-pr-review. It has two parts: one **summary comment** for the PR, and one **line comment** per finding.

Structure comes from Matt Pocock's AI Hero skills (Spec and Standards as separate axes, Merge Danger from `/pr`). Comment labels come from Conventional Comments (conventionalcomments.org).

---

## Part 1: Summary comment

```markdown
## Review: <Approve | Approve with comments | Request changes>

**What this PR does:** <one or two plain sentences>

**Merge danger:** <Easy to undo | Hard to undo>. <What breaks, and for whom, if this is wrong.>

### Spec: does it do what the ticket asks?
- [x] <requirement, quoted or close to the ticket>
- [ ] <requirement> (<missing | partly done: what is missing>)
- Not asked for: <changes outside the ticket, or "none">

### Standards: is it built right?
**Build:** `<verify command>` <passed | failed> (<test count or key error>)

**Blocking (<n>)**
1. <short title> (<file>:<line>)

**Non-blocking (<n>)**
- <short title> (<file>:<line>)

### Questions
- <question for the author>

**Good:** <one specific thing done well, only if true>
```

Rules for the summary:
- Leave out any section that is empty, except Verdict, What this PR does, Merge danger and Build.
- No ticket or description on the PR? Make that the first blocking item under Spec.
- Max 5 non-blocking items. Pick the most useful ones.

### Merge danger

| Say | When |
|---|---|
| **Easy to undo** | Reverting the commit fully restores the old behaviour: code-only changes, new endpoints, UI changes |
| **Hard to undo** | A revert is not enough: DB migrations that drop or change data, removed or renamed API fields used by another repo, data written in a new format, messages sent to devices or other systems |

Always add the blast radius: who or what is affected if it's wrong (one screen, one tenant, all users, other services).

---

## Part 2: Line comments

One comment per finding, attached to the line it refers to.

```markdown
**<label>:** <one-line statement of the problem or idea>

Case: <the input or situation that triggers it>
Impact: <what goes wrong, and for whom>
Fix: <a concrete suggestion, with a code snippet if short>
Source: <the rule from AGENTS.md / CLAUDE.md, or the quoted ticket line, or "general practice: <name>">
```

`Case`, `Impact` and `Fix` are required for `issue (blocking)`. For other labels, use only the lines that help.

### Labels

| Label | Meaning | Author must... |
|---|---|---|
| `issue (blocking)` | Wrong behaviour, data loss, security hole, broken contract, red build, missing requirement | Fix before merge |
| `suggestion (non-blocking)` | A clearer, safer or simpler way | Decide. Fine to skip with a reason |
| `question` | Something the reviewer needs to understand | Answer. Change only if the answer shows a problem |
| `nit` | Tiny: naming, typo, small style point not covered by a linter | Optional |
| `praise` | Something done well, specific and true | Nothing |

### Examples

```markdown
**issue (blocking):** Search text is joined straight into the SQL query.

Case: searching for `' OR '1'='1` returns every user.
Impact: any logged-in user can read all user records.
Fix: pass it as a parameter: `where name like :search` with `setParameter("search", "%" + term + "%")`.
Source: AGENTS.md "Never build SQL from strings"
```

```markdown
**issue (blocking):** Page 2 loses the status filter.

Case: filter by "inactive", then go to page 2.
Impact: page 2 shows all users, so the list looks wrong.
Fix: pass `status` through to the pageable query in `UserController.list()`.
Source: ticket "Filter must stay applied when paging"
```

```markdown
**suggestion (non-blocking):** `QueryUtils.like()` already escapes `%` and `_`. Reusing it keeps search behaviour the same everywhere.
```

```markdown
**question:** Should a blank search return all users or none? The ticket doesn't say.
```

```markdown
**nit:** Typo in the method name: `serach` → `search`.
```

```markdown
**praise:** The filter tests cover every status, including the empty case. Easy to trust.
```

---

## Verdict rules

| Findings | Verdict |
|---|---|
| Any `issue (blocking)`, or the build is red | **Request changes** |
| Only suggestions, questions or nits | **Approve with comments** |
| Nothing | **Approve** |

A question alone never blocks, unless the answer is needed to judge whether the PR is safe. Then say so in the question.

---

## Tone

- Write for the author, who may be junior. Explain *why*, not just *what*.
- Talk about the code, not the person: "this query" not "you forgot".
- No sarcasm, no "just do X", no "obviously".
- Don't fill a quota. If nothing blocks, say so plainly.
- Plain language. No em dashes.
