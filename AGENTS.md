# PHP coding rules for agents

Technical rules for writing PHP: types, classes, control flow, errors, tests, tooling. They say nothing about
architecture (layers, bounded contexts, folders): every project has its own, read it from the code and its own docs.

## Precedence

1. The project's own instructions (a project section below, `CLAUDE.md`, docs) and its tooling configuration
   (`.php-cs-fixer.dist.php`, `pint.json`, `phpstan.neon`, `rector.php`, `phpcs.xml`) win over this file.
2. Then the code already there: before writing, read two or three neighbouring files of the same kind and do as they
   do. A second way of doing the same thing is worse than a suboptimal but consistent one.
3. Then these rules. When one of them conflicts with the existing code, say so; don't settle it alone, and don't
   rewrite the existing code to match unless asked.

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

- No comment saying what the code does: rename, extract a method or a variable until the code says it.
- A comment only for a why the code cannot express (a constraint, a workaround with its reason and link, a non-obvious
  decision). A class or public method may carry a docblock stating its contract when its name cannot. Some projects
  forbid even those: follow the project.
- No commented-out code, no `TODO` without a ticket reference, no change log in comments (git has it).
- No debugging leftovers: `dump()`, `dd()`, `var_dump()`, `print_r()`, `die()`, `error_log()` for tracing.

## Security

- SQL through prepared statements or the query builder only; never concatenate input into SQL, shell commands
  (`escapeshellarg` if a shell is unavoidable), paths or headers.
- Escape output for its context (HTML, attribute, URL, JSON); use the template engine's escaping.
- Never `eval`, never `unserialize` untrusted data (or with `['allowed_classes' => [...]]`), never `extract`.
- Secrets come from the environment or a secret store, never from the code or a committed file.
- `random_bytes()`/`random_int()` for anything secret, `password_hash()`/`password_verify()` for passwords,
  `hash_equals()` to compare tokens.
- Never run or include code of a project you are only analysing.

## Performance

- Measure before optimising; readable first.
- No query, HTTP call or file read inside a loop over records (N+1): load in bulk before the loop.
- Generators or chunked iteration for large data sets instead of loading everything in memory.

## Dependencies

- Add a Composer dependency only when it saves real work; prefer what the project already has.
- Constraints with `^`, the lock file committed for applications, `composer audit` clean.
- Never edit `vendor/`.

## Tests

- Every change of behaviour comes with a test; a bug fix starts with a test that fails without the fix.
- Follow the project's framework and style (PHPUnit or Pest, folder, base classes, helpers). Test classes `final`.
- One behaviour per test, named as a sentence (`testAnExpiredCouponIsRefused`), arranged as given / when / then.
- `assertSame` over `assertEquals`; an assertion message saying why when the failure would be unclear.
- Test through the public API, never private methods. Don't mock value objects or the class under test; prefer real
  objects, then in-memory fakes, then stubs; mocks only to check an interaction that is the behaviour itself.
- Deterministic: no real clock, randomness, network or shared state; inject them.
- Data providers for the same behaviour over several inputs.

## Tooling and verification

- Run the project's checks before handing work back (`composer check`, `composer test`, `make check`, CI scripts):
  formatter, static analysis, tests. Report failures as they are, with their output.
- Static analysis at the project's level (PHPStan or Psalm; aim for the highest level on new code). Never add a
  baseline entry, `@phpstan-ignore` or `@psalm-suppress` to make a check pass: fix the code. A false positive is
  reported, with why.
- Rector and the formatter are run, never fought: if they rewrite your code, keep their version.
- Verify behaviour in the running application (CLI command, HTTP request, worker) when the change can be observed
  there, not only through unit tests.

## Working method

- Read before writing: the files you change, their callers, their tests, and the neighbouring code you will imitate.
- Smallest change that solves the task. No unrelated refactoring, renaming or reformatting in the same change; note
  what you saw instead.
- Never change a public API, a serialised format or a database schema as a side effect: it is a decision to state.
- Don't leave work half done: no stub, no `// implement later`, no skipped test.
- Say what you did not do or could not verify.
