---
name: php-refactor
description: Refactor PHP code without changing its behaviour - split long methods, remove nested ternaries and conditional array unions, add types, replace arrays with value objects, introduce guard clauses, make classes final/readonly - in small verified steps. Use when asked to clean up, simplify, refactor or "make readable" PHP code, or to apply a rule of AGENTS.md to existing code.
---

# Refactor PHP code safely

A refactoring changes the structure, never the behaviour. Every step keeps the tests green and the output identical.

## 1. Agree on the target

- Name the code (files, classes, methods) and the goal (which rule, which smell). If the user asked for "everything",
  list the candidates first (grep, static analysis, phpgraph `query_graph`) and do them one kind at a time.
- Read the project's rules and tooling config; the refactored code must look like the code around it.
- Check who depends on it (callers, serialised output, public API). A public signature, a JSON/array output, a
  database column or a config key that would change is not a refactoring: stop and state it.

## 2. Lock the behaviour

- Find the tests covering the code. Run them; they must pass before you start.
- If the code isn't covered, write characterisation tests first: call the public API with representative inputs,
  including edge cases (empty, null, one element, limits), and assert the current output exactly, even when it looks
  wrong. A suspected bug is reported, not fixed in the same change.
- For output-producing code (reports, JSON, generated files), keep a before-sample to diff against after.

## 3. Change in small steps

One kind of transformation per step, then run the formatter, static analysis and the tests. Common steps:

- **Nested ternary** → successive `if`/`return`, or `match (true)` when each branch is one value, or a private method
  named after what it computes.
- **Conditional array unions** (`[...] + ($x === null ? [] : ['k' => $x])`) → base array, then one `if` per optional
  key. Keep the key order identical when the array is serialised.
- **Expression doing several things** → named intermediate variables, or a private method per sub-computation.
- **Deep nesting** → guard clauses with early `return`/`continue`/`throw`; drop the `else` after them.
- **Assignment in a condition** → assignment on its own line, then the test.
- **Long method** → extract private methods, each at one level of abstraction, named by intent; the original method
  reads as a list of steps.
- **Boolean flag parameter** → two methods, or an enum parameter; update the callers.
- **Array as a structure** passed between classes → `final readonly class` with typed properties; convert at the
  boundary where the array comes from.
- **Missing types** → native types first, then precise PHPDoc shapes; a type that turns out wider than expected is a
  finding to report, not something to hide with `mixed`.
- **Open class** → `final`, if nothing extends it (search the code and the tests); `readonly` when no property is
  written after construction.
- **`switch` mapping values** → `match`; make sure every case is covered or the default is kept.

Don't change formatting, names or files outside the target in the same step.

## 4. Verify

- The whole test suite passes, static analysis is at least as clean as before, the formatter has nothing to say.
- Diff the before-sample of any produced output: it must be identical.
- Re-read the diff: every hunk is a pure restructuring. Anything else is split into its own change or reported.

## 5. Report

What was refactored, how behaviour was kept (tests run, outputs compared), what was found and left alone (suspected
bugs, risky spots, code that needs a decision).
