---
name: write-tests
description: Write or fix tests following the project's conventions, failing first for a bug. Use when asked to add, fix or improve tests, cover a change, or reproduce a bug.
---

# Write tests

If `.agents/overlays/test.md` exists, read it first.

## 1. Learn the project's way

Find the framework, where tests live and how they are split. Open two tests of the same kind and copy their structure,
naming and assertion style.

## 2. Decide what to test

- A behaviour seen from the public API or entry point, not the implementation.
- A bug: first a test that fails for the reason of the bug. A test passing before the fix doesn't reproduce it.
- A feature: the normal case, then each edge (empty, null, limits, invalid input, the error path).

## 3. Write it

- One behaviour per test, named as a sentence, arranged as given / when / then, with no logic in the test body.
- Doubles in this order: real objects, in-memory fakes, stubs, then mocks only when the interaction is the behaviour.
- Deterministic: inject clock, randomness and network. No `sleep`, no order dependence. Clean what you create.

## 4. Run

Run the new tests alone, then the file, then the suite, with limited output. Report the commands and results; never
skip a test to make the run pass.
