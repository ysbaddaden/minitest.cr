# CHANGELOG

## v1.1.0

Fixes:
- Compatibility with Crystal interpreter.
- Runnables aren't shuffled in non chaos mode.

Features:
- Add `message` helper to wrap custom messages for custom assertions on top of
  existing assertions (missing feature from original Ruby Minitest).
- Implements a diff algorithm to remove a dependency on `diff` external tools.

## v1.0.0

Identical to v0.5.1. A mere v1 stable release of Minitest for Crystal v1.

## v0.5.1

Requires:
- Crystal >= 0.34.0 (Errno changes)

## v0.5.0

Requires:
- Crystal >= 0.31.0 (Channel changes)

Fixes:
- MT compatibility

## v0.4.3

Fixes:
- compatibility with recent Crystal releases (Exception initializer hack);

## v0.4.2

Fixes:
- `--name` regression since `focus` was introduced.

## v0.4.1

Features:
- Introduce `minitest/focus` to specify tests/specs to focus. Complements the
  `--name` argument and is easier to use in specs.

Fixes:
- Local variable errors in `responds_to` assertions;
- Compatibility with Crystal 0.27.0

## v0.4.0

Features:
- Add `assert_instance_of`, `refute_instance_of` assertions;
- Add `must_be_instance_of`, `wont_be_instance_of` expectations;
- Add `capture_io`, `assert_silent`, `assert_output` assertions.
- Add `--chaos` to merge & shuffle all tests from all suites,
  instead of shuffling suites then shuffling tests for each suite;
- Add `--seed SEED` for reproducible test runs (can also be set
  with `SEED` environment variable).

## v0.3.6

Changes:
- Measure elapsed time using monotonic clock.

Fixes:
- Compatibility with Crystal 0.24.0

## v0.3.5

Changes:
- dropped artificial src/minitest namespace for files

Fixes:
- Compatibility with Crystal 0.19.0

## v0.3.4

Fixes:
- Compatibility with Crystal 0.17.0

## v0.3.3

Fixes:
- Compatibility with Crystal > 0.15.0

## v0.3.2

Fixes:
- Compatibility with Crystal 0.14.0

## v0.3.1

Fixes:
- Compatibility with Crystal 0.11.0

## v0.3.0

Breaking Change:
- Each test now runs in a single instance of the test class, so instance
  variables don't leak from one test to another.

  This change will have a breaking impact if you rely on instance variables to
  cache or share data between tests. You'll may want to use class variables for
  this purpose instead.

Fixes:
- Allow describes in specs to start with special chars like `.` or `#`
- Allow `skip :symbol` and `flunk :symbol`

## v0.2.0

Feature:
- `Minitest.after_run` hooks

Fixes:
- Crystal > 0.9.1 compatibility

## v0.1.5

Fixes:
- Don't exit until all test suites have completed
- Exception overload with Crystal 0.8.0

## v0.1.4

- Compatibility with Crystal 0.8.0

## v0.1.3

- Compatibility with Crystal 0.7.7 (no more `alias_method`)

## v0.1.2

- Fixes verbose mode

## v0.1.1

- Added shard.yml for shards dependency manager

## v0.1.0

- Initial release: unit tests, specs, runner, ...
