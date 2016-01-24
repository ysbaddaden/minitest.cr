# CHANGELOG

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
