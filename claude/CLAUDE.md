# Personal usage rules (James — not team policy)

These apply in addition to the project `CLAUDE.md`. Prefer saving tokens over thoroughness unless I say otherwise.

## Subagents

- Do **not** spawn subagents unless I explicitly ask (e.g. "use a subagent", "run in parallel").
- For codebase search only, do the work in the main thread with Grep/Read, or delegate to **Explore** — never **general-purpose** for pure search.
- Never spawn multiple subagents in parallel.
- Subagent outputs: short bullet summary only; no full file dumps back to the parent.

## Context

- Prefer narrow file paths I give over repo-wide exploration.
- After a large investigation, suggest `/compact` before the next major step.
- When I switch to a unrelated task, suggest `/clear`.
