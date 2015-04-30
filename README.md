# Minitest for Crystal

Unit tests and assertions for the Crystal programming language, using the
fantastic [minitest](https://github.com/seattlerb/minitest) as reference.

Unit tests are ready to roll! Preliminary work has begun to implement
minitest/spec too, following the same rationale, which means that calling
describe/it will actually generate unit test classes and methods.

## Getting Started

Given that you'd like to test the following class:

```crystal
class Meme
  def i_can_has_cheezburger?
    "OHAI!"
  end

  def will_it_blend?
    "YES!"
  end
end
```

### Unit Tests

Define your tests as methods beginning with `test_`:

```crystal
require "minitest/autorun"

class MemeTest < Minitest::Test
  property! :meme  # to avoid @meme being nilable

  def setup
    @meme = Meme.new
  end

  def test_that_kitty_can_eat
    assert_equal "OHAI!", meme.i_can_has_cheezburger?
  end

  def test_that_it_will_not_blend?
    refute_match /^no/i, meme.will_it_blend?
  end

  def test_that_will_be_skipped
    skip "test this later"
  end
end
```

### Specs

Specs follow the same
[design rationale](https://github.com/seattlerb/minitest/blob/master/design_rationale.rb)
than the original Minitest: `describe` generates classes that inherit from
Minitest::Spec, and `it` generates test methods.

```crystal
require "minitest/autorun"

describe Meme do
  let(:meme) { @meme = Meme.new }

  describe "when asked about cheeseburgers" do
    it "must respond positively" do
      @meme.i_can_has_cheezburger?.must_equal("OHAI!")
    end
  end

  describe "when asked about blending possibilities" do
    it "won't say no" do
      @meme.will_it_blend?.wont_match(/^no/i)
    end
  end
end
```

### Run Tests

Eventually run the tests:

```
$ crystal test/meme_test.cr spec/meme_spec.cr -- --verbose
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
- [x] specs (describe, before, after, it)
- [x] nested specs (describe, before, after)
- [x] must/wont expectations
- [x] expect ... to ... expectations

## Requirements

Eequires [Crystal](http://crystal-lang.org) >= 0.7.0

## License

Distributed under the MIT License. Please see
[LICENSE](https://github.com/ysbaddaden/minitest.cr/tree/master/LICENSE) for details.

## Credits

- Julien Portalier @ysbaddaden for the Crystal implementation
- Ryan Davis @zenspider and seattle.rb for the original Ruby gem
