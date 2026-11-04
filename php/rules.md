---
paths:
  - "**/*.php"
---

# PHP rules

Technical rules only: architecture belongs to each project. The project's instructions, its tooling configuration and
the code already there win over this file.

## Standards

- PSR-1 (basic coding standard) and PSR-4 (autoloading: one class per file, namespace = directory).
- PER Coding Style 2.0, the successor of PSR-12, unless the project's formatter says otherwise. Formatting is the
  formatter's job: run it, never format by hand against it.
- Use the PSR interfaces when crossing a boundary: PSR-3 logger, PSR-7/17 HTTP messages and factories, PSR-11
  container, PSR-14 events, PSR-15 middleware, PSR-18 HTTP client, PSR-20 clock. Depend on the interface, not on the
  implementation.
- Target the project's minimum PHP version (`composer.json` `require.php`, `config.platform.php`): no syntax or
  function newer than it.

## Types

- `declare(strict_types=1);` at the top of every PHP file.
- Native types on every parameter, return and property where PHP allows them, `void` and `never` included.
- No `mixed`, no bare `array`, no `array<string, mixed>` when the shape is known: write it in PHPDoc
  (`list<Order>`, `array<string, int>`, `array{id: string, line: int, service?: string}`, `class-string<T>`,
  `non-empty-string`, `positive-int`, generics with `@template`). Open shapes only at the boundaries (decoded JSON,
  request input, CLI arguments), narrowed right there into typed values.
- A structure passed between classes is an object (`final readonly class`), not an array of keys.
- PHPDoc only adds what the native type cannot say. Never repeat a native type in a `@param`/`@return`/`@var`.
- Enums (backed when stored or sent) instead of string or int constants for a closed set of values.
- `null` means "absent", and only where absence is possible: no nullable parameter used as an optional flag.
- Strict comparisons (`===`, `!==`, `in_array(..., true)`); no `==`, no truthiness tests on strings or numbers
  (`if ($count)`, `empty($name)`): compare with the value meant.
- Casts only at the boundary and explicit (`(int)`), never to silence the type checker.

## Classes and objects

- `final` by default. A class is open only when it is designed for extension (abstract base) or a test must extend it.
- Value objects and results are `final readonly class`, built complete and valid by their constructor or a named
  constructor (`Money::fromCents()`), never by setters.
- Every property and method `private` until something outside needs it; `protected` only in a class built for
  inheritance.
- Composition over inheritance; an interface per role, small (one to a few methods), named after the role.
- Dependencies arrive through the constructor (promoted properties). No service locator, no `new` of a service inside
  business code, no static mutable state, no singletons, no global functions holding state.
- Mark overrides with `#[\Override]` on PHP 8.3 and later.
- No magic methods (`__get`, `__call`) unless a framework requires them.
- `DateTimeImmutable` (or a PSR-20 clock injected), never `DateTime` nor `time()` / `new DateTimeImmutable()` deep in
  business code: time comes from a clock so tests control it.
- Money and other exact quantities: integers of the smallest unit or a decimal library, never `float`.

## Functions and control flow

- One expression = one idea. No nested ternary (`a ? b : (c ? d : e)`): successive `if`/`return`, a `match`, or a
  named private method. A single, simple ternary is fine.
- No chain of conditional array unions (`[...] + ($x === null ? [] : ['k' => $x]) + ...`): build the base array, then
  one `if` per optional key.
- An expression that mixes several computations (a string assembled from conditional parts, a sort key, a combined
  condition) is split into named variables or a private method that says what it computes.
- Guard clauses and early returns instead of nested `if`; no `else` after a `return`, `throw`, `continue` or `break`.
- No assignment inside a condition (`if ($x = f())`): assign on its own line, then test.
- `match` instead of `switch` when mapping values; it is strict and exhaustive (`UnhandledMatchError`).
- No boolean flag parameter that changes what a method does: two methods, or an enum. Name literal arguments at the
  call site when their meaning is not obvious (`send(retry: false)`).
- Short methods that do one thing at one level of abstraction; a method whose body needs a comment to explain its
  steps is several methods.
- Prefer `foreach` and plain loops over `array_map`/`array_filter` chains when the chain needs keys, references or
  more than one line of closure.
- Use `mb_*` functions for user-facing text; byte functions (`strlen`, `substr`) only for bytes and ASCII
  identifiers.

## Naming

- Names say intent, in full words: `$unpaidInvoices`, not `$data`, `$arr`, `$tmp`, `$inv2`.
- Booleans read as questions: `isPaid`, `hasItems`, `canRetry`.
- Methods are verbs (`cancel()`, `totalPrice()`); a getter that computes nothing is the property's name or `get*`,
  as the project already does.
- Follow the project's suffix conventions (`*Interface`, `*Exception`, `*Test`, `*Handler`) and invent none.
- Code, identifiers, messages, logs and commits in English unless the project says otherwise.

## Errors

- Throw an exception for a failure; don't return `false`, `null` or an error code from a method whose result is
  otherwise an object. Return `null` only for "not found" when absence is a normal outcome, and type it `?X`.
- Specific exception classes (extending SPL ones: `InvalidArgumentException`, `RuntimeException`, `LogicException`),
  with a message stating what was wrong and the value involved. Keep the cause: `new X('...', previous: $e)`.
- Never catch to ignore. Catch only what you can handle, as narrow a type as possible; never `catch (\Throwable)`
  except at the outermost boundary (entry point, worker loop), where it is logged.
- No `@` error suppression; no `die()`/`exit()` outside an entry script.
- Validate input at the boundary, once, and turn it into typed objects; code behind the boundary trusts its types
  instead of re-checking them.
- Document `@throws` for exceptions a caller is expected to handle.

## Comments

- No comment saying what the code does: rename or extract until the code says it. Some projects forbid even docblocks:
  follow the project.
- No `TODO` without a ticket reference, no change log in comments.
- No `dump()`, `dd()`, `var_dump()`, `print_r()`, `die()`, `error_log()` for tracing.

## Security

- SQL through prepared statements or the query builder only; `escapeshellarg` if a shell is unavoidable.
- Use the template engine's escaping.
- Never `eval`, never `extract`, never `unserialize` untrusted data (or with `['allowed_classes' => [...]]`).
- `random_bytes()`/`random_int()` for secrets, `password_hash()`/`password_verify()`, `hash_equals()` for tokens.

## Dependencies

- Add a Composer dependency only when it saves real work. `^` constraints, lock committed for applications,
  `composer audit` clean. Never edit `vendor/`.

## Tests

- Every change of behaviour comes with a test. Test classes `final`.
- `assertSame` over `assertEquals`. Test through the public API. Don't mock value objects or the class under test.

## Tooling

- Static analysis at the project's level. Never add a baseline entry, `@phpstan-ignore` or `@psalm-suppress` to make a
  check pass: fix the code, or report a false positive with why.
- Rector and the formatter are run, never fought: if they rewrite your code, keep their version.
