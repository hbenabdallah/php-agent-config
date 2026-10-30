---
name: php-review
description: Review PHP changes (the current diff, a branch, a PR or named files) against the PHP coding rules of AGENTS.md and the project's own conventions, and report findings with file and line. Use when asked to review, check or audit PHP code, before opening a PR, or after finishing a PHP change.
---

# Review PHP code

Find what is wrong or worse than it should be in the changed PHP code, and report it. Don't fix anything unless the
user asks; a review is a list of findings.

## 1. Scope

- Default: the uncommitted changes plus the commits of the branch not on the base branch
  (`git diff $(git merge-base HEAD origin/main)`; use the project's base branch).
- A PR number: `gh pr diff <n>`. Files named by the user: those files, whole.
- Review only the changed lines and what they break; old code nearby is out of scope unless the change makes it wrong.

## 2. Context before judging

- Read the project's rules: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, and the tooling config
  (`.php-cs-fixer.dist.php`, `pint.json`, `phpstan.neon*`, `rector.php`, `phpcs.xml`). They win over the generic rules.
- For each changed file, open one or two neighbours of the same kind: what the project does is the reference.
- Read the callers of every changed public method (grep, or phpgraph `impact_of` when available).

## 3. Run the tools

Run what the project has, on the changed files when the tool allows it, and keep the output:

- formatter in check mode (`vendor/bin/php-cs-fixer check --diff`, `vendor/bin/pint --test`, `vendor/bin/phpcs`);
- static analysis (`vendor/bin/phpstan analyse`, `vendor/bin/psalm`);
- `vendor/bin/rector --dry-run`;
- the tests touching the change, then the whole suite if it is fast.

A tool finding is a finding; don't repeat what the formatter would fix by itself, just say "run the formatter".

## 4. Read the change, in this order

1. **Correctness**: wrong condition, off-by-one, null not handled, wrong comparison (`==`, truthiness), missing
   `return`, mutated shared state, exception swallowed, resource not closed, a behaviour change the description
   doesn't mention.
2. **Security**: input reaching SQL, shell, paths, HTML or headers without escaping; `unserialize`/`eval`; secrets in
   code; weak randomness for tokens; missing authorization check next to similar code that has one.
3. **Contracts**: public method signature, serialised format, database schema or config key changed without being
   stated; callers not updated.
4. **Types**: missing native types, `mixed` or bare `array` where the shape is known, PHPDoc repeating native types,
   arrays used as structures between classes, casts silencing the checker, new ignores or baseline entries.
5. **Design at class level**: class not `final`, value object with setters or not `readonly`, wider visibility than
   needed, dependency created with `new` or fetched from a container instead of injected, static state, boolean
   flag parameter, method doing several things.
6. **Readability**: nested ternary, chain of conditional array unions, assignment in a condition, deep nesting
   instead of guard clauses, `else` after `return`, names that don't say intent, comments saying what the code does,
   commented-out code, debugging leftovers.
7. **Tests**: behaviour change without test, bug fix without a failing-first test, test of private methods, mocks of
   value objects, real clock/random/network, `assertEquals` where `assertSame` fits, test names that don't read as a
   sentence.
8. **Performance**: query or HTTP call in a loop, loading a whole table, repeated work inside a loop.

## 5. Verify each finding

Before reporting, check it against the code: open the file, follow the call, run the snippet or the test. Drop what
you cannot back with a concrete scenario. Mark what is likely but unproven as such.

## 6. Report

Most severe first, one finding per entry:

```
[severity] path/to/File.php:42 — what is wrong, in one sentence.
  Scenario: the input or state that makes it fail, and what happens.
  Fix: the change, in one line (no full rewrite).
```

Severities: `bug` (wrong result, crash, security), `contract` (breaks a caller or a format), `rule` (breaks a rule of
AGENTS.md or the project), `suggestion` (better but optional). End with the tool results (passed / failed with the
output) and anything you could not check. If nothing survives verification, say so plainly.
