---
name: review-changes
description: Review the current diff, a branch, a PR or named files and report verified findings with file and line. Use when asked to review, check or audit code, or before opening a PR.
context: fork
---

# Review changes

Find what is wrong in the changed code and report it. Don't fix anything: a review is a list of findings.

## 1. Load the stack overlay

If `.agents/overlays/review.md` exists, read it first. Its commands and checks complete the steps below.

## 2. Scope

- Default: uncommitted changes plus the branch commits. Find the base with
  `git symbolic-ref --short refs/remotes/origin/HEAD`, then `git diff $(git merge-base HEAD <base>)`.
- A PR number: `gh pr diff <n>`. Named files: those files, whole.
- Start from `git diff --stat`. Review changed lines and what they break; old code is out of scope otherwise.

## 3. Context, within limits

- Read project rules not already in context, and the tooling configuration.
- Open one neighbour per kind of changed file, not one per file.
- Check the callers of changed public APIs only, with a search or a code index rather than whole files.

## 4. Run the tools

Run the project's formatter check, static analysis and the tests touching the change, on changed files when the tool
allows it. Limit the output. A tool finding is a finding; for formatting, just say "run the formatter".

## 5. Read the change, in this order

1. **Correctness**: wrong condition, off-by-one, missing null handling, swallowed error, undeclared behaviour change.
2. **Security**: unescaped input, secrets, weak randomness, missing authorization next to code that has it.
3. **Contracts**: public signature, serialised format, schema or config key changed silently; callers not updated.
4. **Design and readability**: rules of the project and of the overlay.
5. **Tests**: behaviour change without a test, bug fix without a failing-first test.
6. **Performance**: query or HTTP call in a loop, loading a whole table.

## 6. Verify each finding

Check it against the code. Drop what has no concrete scenario; mark what is likely but unproven.

## 7. Report

Most severe first:

```
[severity] path/to/file:42: what is wrong, in one sentence.
  Scenario: the input or state that makes it fail, and what happens.
  Fix: the change, in one line.
```

Severities: `bug`, `contract`, `rule`, `suggestion`. End with tool results and what you could not check. If nothing
survives verification, say so.
