---
name: php-test
description: Write or fix PHP tests (PHPUnit or Pest) that follow the project's conventions - a failing test first for a bug, one behaviour per test, sentence names, fakes over mocks, deterministic. Use when asked to add, write, fix or improve PHP tests, to cover a change, or to reproduce a bug with a test.
---

# Write PHP tests

## 1. Learn the project's way

- Framework and runner: `phpunit.xml(.dist)`, `tests/Pest.php`, `composer.json` scripts.
- Where tests live and how they are split (unit, integration, functional, acceptance), the base classes, traits and
  helpers they use (factories, fixtures, in-memory doubles, a temporary project or database).
- Open two existing tests of the same kind as the one you'll write, and copy their structure, naming and assertion
  style. Some projects test only some layers: follow what their instructions say.

## 2. Decide what to test

- A behaviour, seen from the public API of the class or the entry point (command, HTTP route, message handler), not
  the implementation. Private methods are tested through the public ones.
- For a bug: first a test that reproduces it and fails for the reason of the bug. Run it, see it fail, then fix.
- For a new feature: the normal case, then each edge (empty, null, limits, invalid input, the error path).

## 3. Write it

- One behaviour per test, named as a sentence: `testAnExpiredCouponIsRefused`, `it refuses an expired coupon`.
- Given / when / then, separated by a blank line; no logic (loops, conditions) in the test body.
- Test classes `final`; `declare(strict_types=1)`.
- `assertSame` over `assertEquals`; the narrowest assertion (`assertCount`, `assertInstanceOf`,
  `expectException` + message). Add an assertion message when the failure alone wouldn't say what broke.
- Data providers (or Pest datasets) for one behaviour over several inputs, each case named.
- Doubles, in this order: real objects, in-memory fakes of the project, stubs (`createStub`) for return values,
  mocks (`createMock` + `expects`) only when the interaction is the behaviour. Never double a value object or the
  class under test.
- Deterministic: inject a clock, a random generator, an HTTP client double; no `sleep`, no network, no dependence on
  test order or on files left by another test. Clean what you create.

## 4. Run

- Run the new tests alone, then the file, then the suite (or the project's `check` script).
- A test that passed before the fix for a bug doesn't reproduce it: rewrite it.
- Report the commands run and their result; never mark a test skipped or incomplete to make the run pass.
