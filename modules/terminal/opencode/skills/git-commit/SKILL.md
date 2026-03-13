---
name: git commit
description: Follow my git commit workflow and safety preferences
---

## Purpose

Keep git commits aligned with my preferred workflow.

## Rules

- Never run `git push`.
- Only create commits when I explicitly ask for it.
- Every commit message should clearly explain both what changed and why.

## Commit policy

- Every commit MUST contain exactly one intent.
- If changes include multiple intents, I MUST split into multiple commits.
- I should do this automatically without asking, unless the user explicitly asks for a single combined commit.

## Intent grouping rules (strict)

Do NOT combine these in one commit:
- feature or behavior changes
- bug fixes
- refactors (no behavior change)
- configuration or metadata changes
- tooling or workflow changes (CI, lint, hooks, scripts)
- formatting-only changes
- tests-only changes
- docs/content-only changes

If changes span multiple categories, split them into separate commits, even when the same file is involved.

## Required workflow (every commit task)

1. Run `git status --short` and `git diff` to classify all changes by intent.
2. Produce an internal commit plan with one intent per commit and file/hunk mapping.
3. Stage only one intent (use partial staging when needed).
4. Commit.
5. Repeat until all requested changes are committed.
6. Print a final report with:
   - commit hash
   - subject
   - files included
   - remaining uncommitted files (if any)

## Commit message rule

Each commit message must describe one intent only:
- Subject: what changed (single intent)
- Body: why it was needed
- If the message needs "and" to describe multiple different intents, split the commit.

If one file contains multiple intents:
- Use `git add -p` and split by hunk.
- If hunk split is impossible, make the smallest safe split and explain why.

## Safety

- Do not use destructive git commands unless explicitly requested.
- Do not amend existing commits unless explicitly requested.
- Before any amend/rebase/revert workflow, verify whether the affected commit(s) are already pushed (for example via `git status -sb` and upstream checks).
- If commits are already pushed, avoid history-rewriting operations unless explicitly requested; prefer a new follow-up commit.
- If commits are not pushed and the user has asked for the outcome, prefer amend/rebase/revert workflows to keep history clean.
