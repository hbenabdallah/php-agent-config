# PHP review overlay

## Commands

Use what the project has, on changed files, with `<files>` the changed `.php` paths:

- `vendor/bin/php-cs-fixer check --diff --path-mode=intersection -- <files> | tail -n 40`, or `vendor/bin/pint --test <files>`
- `vendor/bin/phpstan analyse --no-progress --error-format=raw <files> | tail -n 40`, or `vendor/bin/psalm --no-progress <files>`
- `vendor/bin/rector process --dry-run <files> | tail -n 40`
- `vendor/bin/phpunit --no-progress --filter <test> | tail -n 40`

Find callers with phpgraph `impact_of` when available, otherwise a search.

## Checks

- Comparisons: `==`, truthiness tests, `in_array` without `true`.
- Types: missing native types, `mixed` or bare `array` for a known shape, PHPDoc repeating native types, casts silencing
  the checker, new ignores or baseline entries.
- Classes: not `final`, value object with setters or not `readonly`, wide visibility, service created with `new`, static
  state, boolean flag parameter.
- Readability: nested ternary, conditional array unions, assignment in a condition, `else` after `return`.
- Tests: private methods tested, value objects mocked, `assertEquals` where `assertSame` fits.
