# Test Unit

An attempt at implementing test units in Crystal, using the fantastic
[minitest](https://github.com/seattlerb/minitest) as reference.

```crystal
require "minitest/autorun"

class MyTest < Minitest::Test
  def setup
    @var = "something"
  end

  def teardown
    @var = nil
  end

  def test_something
    p @var # => "something"
  end
end
```

## TODO

- [x] keep a list of classes inheriting Minitest::Test (test suites)
- [x] shuffle test suites
- [x] run all test suites at exit
- [x] extract the list of test methods from test suites
- [ ] shuffle test methods
- [x] run the test methods
- [x] run setup / teardown methods before / after each test
- [x] capture exceptions in setup, test or teardown
- [ ] after run hooks
- [ ] assertions
- [ ] refutations
- [ ] skip / flunk
- [ ] reporter: composite (dispatches to linked reporters)
- [ ] reporter: progress
- [ ] reporter: verbose progress
- [ ] reporter: summary

## Requirements

This requires Crystal >= 0.6.1.
