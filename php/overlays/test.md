# PHP test overlay

- Find the setup in `phpunit.xml(.dist)`, `tests/Pest.php` and the `composer.json` scripts.
- Names: `testAnExpiredCouponIsRefused`, or `it refuses an expired coupon` with Pest.
- Test classes `final`, with `declare(strict_types=1)`.
- `assertSame` over `assertEquals`; the narrowest assertion (`assertCount`, `assertInstanceOf`, `expectException`).
- Data providers or Pest datasets for one behaviour over several inputs, each case named.
- `createStub` for return values, `createMock` with `expects` only for an interaction. Never double a value object or
  the class under test.
- Run with `vendor/bin/phpunit --no-progress --filter <test> | tail -n 40`.
