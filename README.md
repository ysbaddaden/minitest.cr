# Test Unit for Crystal

An attempt at implementing test units in Crystal, using the fantastic
[minitest](https://github.com/seattlerb/minitest) as reference. It may
eventually implement expectations and specs too, but mocks and stubs may be more
complicated to have.

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
  property! :meme  # to avoid @meme being nilable (not defined in all initialize methods)

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

## TODO

- [x] keep a list of classes inheriting Minitest::Test (test suites)
- [x] shuffle test suites
- [x] run all test suites at exit
- [x] run test suites in parallel
- [x] extract the list of test methods from test suites
- [.] shuffle test methods
- [ ] filter test methods to run
- [x] run the test methods
- [x] run setup / teardown methods before / after each test
- [x] capture exceptions in setup, test or teardown
- [ ] after run hooks
- [.] assertions
- [.] refutations
- [x] skip / flunk
- [x] reporter: composite (dispatches to linked reporters)
- [x] reporter: progress
- [x] reporter: verbose progress
- [x] reporter: summary
- [x] reporter: colors
- [.] command line options (--verbose, -n PATTERN, --parallel THREADS)

## Requirements

This requires Crystal >= 0.6.1. As of March 2, 2015 this is the current master
branch.

## License

Distributed under the MIT License. Please see
[LICENSE](https://github.com/ysbaddaden/minitest.cr/tree/master/LICENSE) for details.

## Credits

- Julien Portalier @ysbaddaden for the Crystal implementation
- Ryan Davis @zenspider and seattle.rb for the original Ruby gem
