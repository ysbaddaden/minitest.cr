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
    refute @var.nil?
    assert_equal "something", @var
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

This requires Crystal >= 0.6.1.
