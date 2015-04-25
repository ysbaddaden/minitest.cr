# Minitest for Crystal

Unit tests and assertions for the Crystal programming language, using the
fantastic [minitest](https://github.com/seattlerb/minitest) as reference.

Unit tests are ready to roll! Some preliminary work has begun to implement
minitest/spec too, but they're still far from prime time.

## Getting Started

Given that you'd like to test the following class:

```crystal
class Meme
  def i_can_haz_cheezburger?
    "OHAI!"
  end

  def will_it_blend?
    "YES!"
  end
end
```

Define your tests as methods beginning with `test_`:

```crystal
require "minitest/autorun"

class MemeTest < Minitest::Test
  property! :meme  # to avoid @meme being nilable

  def setup
    @meme = Meme.new
  end

  def test_that_kitty_can_eat
    assert_equal "OHAI!", meme.i_can_haz_cheezburger?
  end

  def test_that_it_will_not_blend?
    refute_match /^no/i, meme.will_it_blend?
  end

  def test_that_will_be_skipped
    skip "test this later"
  end
end
```

Eventually run it:

```
$ crystal test/meme_test.cr -- --verbose
```

## TODO

- [x] keep a list of classes inheriting Minitest::Test (test suites)
- [x] shuffle test suites
- [x] run all test suites at exit
- [x] run test suites in parallel
- [x] extract the list of test methods from test suites
- [x] shuffle test methods
- [x] filter test methods to run
- [x] run the test methods
- [x] run setup / teardown methods before / after each test
- [x] capture exceptions in setup, test or teardown
- [ ] after run hooks
- [x] assertions
- [x] refutations
- [x] skip / flunk
- [x] reporter: composite (dispatches to linked reporters)
- [x] reporter: progress
- [x] reporter: verbose progress
- [x] reporter: summary
- [x] reporter: colors
- [x] command line options (--verbose, -n PATTERN, --parallel THREADS)
- [ ] specs (describe, context, before, after, it, specify)
- [ ] nested specs (describe, context, before, after)
- [ ] must/wont expectations
- [ ] expect ... to ... expectations

## Requirements

This requires Crystal >= 0.6.1. As of March 2, 2015 this is the current master
branch.

## License

Distributed under the MIT License. Please see
[LICENSE](https://github.com/ysbaddaden/minitest.cr/tree/master/LICENSE) for details.

## Credits

- Julien Portalier @ysbaddaden for the Crystal implementation
- Ryan Davis @zenspider and seattle.rb for the original Ruby gem
