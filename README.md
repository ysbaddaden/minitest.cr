# Minitest for Crystal

Unit tests and assertions for the Crystal programming language, using the
fantastic [minitest](https://github.com/seattlerb/minitest) as reference.

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
  def meme
    @meme ||= Meme.new
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
as the original Minitest: `describe` generates classes that inherit from
Minitest::Spec, and `it` generates test methods.

```crystal
require "minitest/autorun"

describe Meme do
  let(:meme) { Meme.new }

  describe "when asked about cheeseburgers" do
    it "must respond positively" do
      meme.i_can_has_cheezburger?.must_equal("OHAI!")
    end
  end

  describe "when asked about blending possibilities" do
    it "won't say no" do
      meme.will_it_blend?.wont_match(/^no/i)
    end
  end
end
```

You may use assertions in your specs (they'll work the same) or you may prefer the `expect` syntax:

```crystal
expect(meme.i_can_haz_cheezeburger?).must_equal("OHAI!")
expect(meme.will_it_blend?).wont_match(/^no/i)
```

### Run Tests

Eventually run the tests:

```
$ crystal run test/meme_test.cr spec/meme_spec.cr -- --verbose
```

You may filter your tests using an exact test name, or a regexp:

```
$ crystal run test/meme_test.cr -- -n test_that_kitty_can_eat
$ crystal run test/meme_test.cr -- -n /will/
```

When using Minitest::Spec with assertions or the `expect` syntax, you can avoid to taint Object with all the `#must_` and `#wont_` expectations:

```
$ crystal run -Dmt_no_expectations spec/meme_spec.cr
```

## License

Distributed under the MIT License. Please see
[LICENSE](https://github.com/ysbaddaden/minitest.cr/tree/master/LICENSE) for details.

## Credits

- Julien Portalier @ysbaddaden for the Crystal implementation
- Ryan Davis @zenspider and seattle.rb for the original Ruby gem
