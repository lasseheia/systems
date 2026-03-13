---
name: git commit
description: Follow my git commit workflow and safety preferences
---

## Purpose

Keep git commits aligned with my preferred workflow.

## Rules

- Never run `git push`.
- Only create commits when I explicitly ask for it.
- Keep commits atomic by intent; never combine unrelated changes in one commit.
- Every commit message should clearly explain both what changed and why.

## Atomic commit policy (strict)

A commit is atomic only if it contains exactly one intent.

Do not mix these intent categories in one commit:
- behavior/feature changes
- bug fixes
- refactors (no behavior change)
- config/metadata changes
- tooling/workflow changes (CI, lint, hooks)
- formatting-only changes
- docs/content-only changes

If changes span multiple categories, split them into separate commits, even when the same file is involved.

## Required pre-commit classification

Before each commit:
1. Run `git status --short`.
2. Review changed files/hunks and classify each by intent.
3. Stage only one intent category.
4. If a file contains mixed intents, use partial staging (`git add -p`).
5. Commit that single intent, then repeat for remaining intents.

## Commit message rule

Each commit message must describe one intent only:
- Subject: what changed (single intent)
- Body: why it was needed
- If the message needs "and" to describe multiple different intents, split the commit.

## Commit workflow

1. Classify changes by intent and split staging accordingly.
2. Draft a concise message that states both what changed and why.
3. Create commit only after explicit request.
4. Verify with `git status` after commit.

## Safety

- Do not use destructive git commands unless explicitly requested.
- Do not amend existing commits unless explicitly requested.
- Before any amend/rebase/revert workflow, verify whether the affected commit(s) are already pushed (for example via `git status -sb` and upstream checks).
- If commits are already pushed, avoid history-rewriting operations unless explicitly requested; prefer a new follow-up commit.
- If commits are not pushed and the user has asked for the outcome, prefer amend/rebase/revert workflows to keep history clean.
