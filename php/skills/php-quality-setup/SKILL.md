---
name: php-quality-setup
description: Set up PHP CS Fixer, PHPStan, Rector and one composer "check" script in a PHP project.
disable-model-invocation: true
---

# Set up PHP quality tooling

Give the project one command that formats, analyses and tests, so agents and CI check the same thing.

## 1. Look first

- Read `composer.json`: PHP minimum (`require.php`, `config.platform.php`), framework, existing `scripts`, existing
  dev dependencies.
- Look for existing configs: `.php-cs-fixer(.dist).php`, `pint.json`, `phpcs.xml`, `ecs.php`, `phpstan.neon(.dist)`,
  `psalm.xml`, `rector.php`, `grumphp.yml`, CI workflows. **Complete what exists; never replace a tool the project
  already uses** (Pint stays Pint on Laravel, ECS stays ECS, Psalm stays Psalm).
- Note the source and test directories (`autoload` and `autoload-dev` in `composer.json`).

## 2. Install what is missing

```
composer require --dev friendsofphp/php-cs-fixer phpstan/phpstan phpstan/phpstan-strict-rules rector/rector
```

Add `phpstan/extension-installer` and the framework extension when relevant (`phpstan/phpstan-symfony`,
`phpstan/phpstan-doctrine`, `phpstan/phpstan-phpunit`, `larastan/larastan`).

## 3. Copy and adapt the templates

The templates next to this file were run together on a sample project: the formatter and Rector converge (a second
run changes nothing) and PHPStan passes on the result.

- `templates/.php-cs-fixer.dist.php`: PER-CS 2.0 with its risky set, plus `declare_strict_types`, `final_class`,
  `strict_comparison`, `date_time_immutable`, `no_useless_else`, blank lines before `return`/`throw`.
- `templates/phpstan.dist.neon`: level `max`, strict rules, uninitialised properties, callable signatures.
- `templates/rector.php`: PHP sets for the project's version (`withPhpSets()` reads `composer.json`), dead code,
  code quality, type declarations, privatisation, early return, PHPUnit quality.

Adapt the `paths`/`in` to the project's directories. When the project has a framework (Symfony, Laravel, Doctrine),
add `withComposerBased(symfony: true, doctrine: true, laravel: true)` in Rector and the matching PHPStan extension.

## 4. One check script

In `composer.json`:

```json
"scripts": {
    "cs": "php-cs-fixer check --diff",
    "cs:fix": "php-cs-fixer fix",
    "stan": "phpstan analyse --no-progress",
    "rector": "rector --dry-run",
    "test": "phpunit",
    "check": ["@cs", "@rector", "@stan", "@test"]
}
```

Make CI run `composer check`.

## 5. Existing code that fails

On an existing project the first run reports a lot. In this order:

1. Formatting first: remove every risky rule from the config (`@PER-CS2x0:risky`, `declare_strict_types`, `final_class`,
   `strict_comparison`, `strict_param`, `date_time_immutable`, `modernize_types_casting`, `protected_to_private`), set
   `setRiskyAllowed(false)`, run `composer cs:fix`, and commit that alone.
2. Risky rules change behaviour (`==` becomes `===`, strict types raise `TypeError`, `final` breaks mocks and
   subclasses). Add them back one at a time, only where tests cover the code, one commit each. Values read from a
   database are often strings: check them before enabling strict comparison.
3. `vendor/bin/rector`: read the diff, run the tests, commit it alone.
4. PHPStan: start at the level where the project passes, then raise it one level per change, fixing the code.
   A baseline (`--generate-baseline`) is acceptable only to adopt PHPStan on a large legacy code base, decided by
   the user, and it only ever shrinks: new code never adds to it.
5. Rules the project disagrees with: remove them from the config.

## 6. Verify

Run `composer check` twice: the second run must change nothing and pass. Report the tool versions installed, the
level reached and what is left.
