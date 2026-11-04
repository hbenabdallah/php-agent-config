---
name: refactor-safely
description: Refactor code without changing its behaviour, in small verified steps. Use when asked to clean up, simplify, refactor or make code readable.
---

# Refactor safely

A refactoring changes the structure, never the behaviour. If `.agents/overlays/refactor.md` exists, read it first.

## 1. Agree on the target

- Name the code and the goal. If asked for "everything", list candidates and do them one kind at a time.
- Check who depends on it. A public signature, serialised output, database column or config key that would change is
  not a refactoring: stop and state it.

## 2. Lock the behaviour

- Run the tests covering the code; they must pass before you start.
- If it isn't covered, first write characterisation tests through the public API, edge cases included, asserting the
  current output even when it looks wrong. A suspected bug is reported, not fixed in the same change.
- For code producing output, keep a before-sample to diff.

## 3. Change in small steps

One kind of transformation per step, then run the formatter, static analysis and the tests. Touch nothing outside the
target.

## 4. Verify and report

- Full tests pass, static analysis is at least as clean, the output sample is identical.
- Every hunk of the diff is pure restructuring; anything else is split out or reported.
- Report what changed, how behaviour was kept, and what was left alone.
