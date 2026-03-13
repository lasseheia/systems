---
name: git-commit-preferences
description: Follow my git commit workflow and safety preferences
---

## Purpose

Keep git commits aligned with my preferred workflow.

## Rules

- Never run `git push`.
- Only create commits when I explicitly ask for it.
- Keep commits atomic by intent; never combine unrelated changes in one commit.
- Every commit message should clearly explain both what changed and why.

## Commit workflow

1. Check `git status --short`.
2. Split staged changes into atomic commits by intent.
3. Draft a concise message that states both what changed and why.
4. Create commit only after explicit request.
5. Verify with `git status` after commit.

## Safety

- Do not use destructive git commands unless explicitly requested.
- Do not amend existing commits unless explicitly requested.
- Before any amend/rebase/revert workflow, verify whether the affected commit(s) are already pushed (for example via `git status -sb` and upstream checks).
- If commits are already pushed, avoid history-rewriting operations unless explicitly requested; prefer a new follow-up commit.
- If commits are not pushed and the user has asked for the outcome, prefer amend/rebase/revert workflows to keep history clean.
