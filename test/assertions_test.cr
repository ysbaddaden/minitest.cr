require "../src/autorun"

class AssertionsTest < Minitest::Test
  class Failure < Exception; end

  class Foo; end

  class Bar; end

  def test_assert
    assert true
    assert_raises(Minitest::Assertion) { assert false }
  end

  def test_assert_with_block
    assert { true }
    assert_raises(Minitest::Assertion) { assert { false } }
  end

  def test_refute
    refute false
    assert_raises(Minitest::Assertion) { refute true }
  end

  def test_refute_with_block
    refute { false }
    assert_raises(Minitest::Assertion) { refute { true } }
  end

  def test_assert_equal
    assert_equal 1, 1
    assert_equal "abcd", "abcd"
    assert_raises(Minitest::Assertion) { assert_equal 1, 2 }

    ex = assert_raises(Minitest::Assertion) { assert_equal "this is correct", "this is wrong" }
    assert_equal %(Expected "this is correct" but got "this is wrong"), ex.message
  end

  def test_assert_equal_diffs_long_strings
    correct = <<-PLAIN
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
    tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
    quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
    consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
    cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat
    non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    PLAIN

    wrong = <<-PLAIN
    Lorem pisum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
    tempor incididunt ut labore et dolore manga aliqua. Ut enim ad minim veniam,
    quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
    consequat. Duis aute irure dolor ni reprehenderit in voluptate velit esse
    cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat
    non proident, sunt ni culpa qui officia deserunt mollit anim id tse laborum.
    PLAIN

    ex = assert_raises(Minitest::Assertion) { assert_equal correct, wrong }
    assert <<-PLAIN == ex.message
    --- expected
    +++ actual
    -Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
    -tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
    +Lorem pisum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
    +tempor incididunt ut labore et dolore manga aliqua. Ut enim ad minim veniam,
     quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
    -consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
    +consequat. Duis aute irure dolor ni reprehenderit in voluptate velit esse
     cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat
    -non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    +non proident, sunt ni culpa qui officia deserunt mollit anim id tse laborum.
    PLAIN
  end

  def test_assert_equal_diffs_pretty_printed_objects
    a = {code: 1, message: "some long message to force a line break in pretty inspect", status: "failed"}
    b = {code: 3, message: "some long message to force a line break in pretty inspect", status: "failed"}
    ex = assert_raises(Minitest::Assertion) { assert_equal a, b }
    assert <<-PLAIN == ex.message
    --- expected
    +++ actual
    -{code: 1,
    +{code: 3,
      message: "some long message to force a line break in pretty inspect",
      status: "failed"}
    PLAIN
  end

  def test_assert_equal_diffs_pretty_printed_objects_with_swapped_a_and_b
    a = {code: 1, message: "some short message", status: "failed"}
    b = {code: 3, message: "some long message to force a line break in pretty inspect", status: "failed"}

    ex = assert_raises(Minitest::Assertion) { assert_equal a, b }
    assert <<-PLAIN == ex.message
    --- expected
    +++ actual
    -{code: 1, message: "some short message", status: "failed"}
    +{code: 3,
    + message: "some long message to force a line break in pretty inspect",
    + status: "failed"}
    PLAIN

    ex = assert_raises(Minitest::Assertion) { assert_equal b, a }
    assert <<-PLAIN == ex.message
    --- expected
    +++ actual
    -{code: 3,
    - message: "some long message to force a line break in pretty inspect",
    - status: "failed"}
    +{code: 1, message: "some short message", status: "failed"}
    PLAIN
  end

  def test_refute_equal
    refute_equal 1, 2
    refute_equal "abcd", "dcba"
    refute_equal 1, "abcd"
    assert_raises(Minitest::Assertion) { refute_equal 1, 1 }
  end

  def test_assert_same
    foo = Foo.new
    assert_same foo, foo
    assert_raises(Minitest::Assertion) { assert_same Foo.new, foo }
  end

  def test_refute_same
    foo = Foo.new
    refute_same foo, Foo.new
    assert_raises(Minitest::Assertion) { refute_same foo, foo }
  end

  def test_assert_match_with_regex
    assert_match /test/, "this is a test"
    assert_raises(Minitest::Assertion) { assert_match /foo/, "bar baz" }
  end

  def test_assert_match_with_string
    assert_match "this", "this is a test"
    assert_raises(Minitest::Assertion) { assert_match "foo", "bar baz" }
  end

  def test_refute_match_with_regex
    refute_match /foo/, "this is a test"
    assert_raises(Minitest::Assertion) { refute_match /foo/, "foo bar" }
  end

  def test_refute_match_with_string
    refute_match "foo", "this is a test"
    assert_raises(Minitest::Assertion) { refute_match "bar", "foo bar baz" }
  end

  def test_assert_empty
    assert_empty [] of Int32
    assert_empty({} of Int32 => Int32)
    assert_raises(Minitest::Assertion) { assert_empty([1, 2, 3]) }
  end

  def test_refute_empty
    refute_empty [1, 2, 3]
    refute_empty({1 => 2, 3 => 4})
    assert_raises(Minitest::Assertion) { refute_empty([] of Int32) }
    # assert_raises(Minitest::Assertion) { refute_empty({} of Int32 => Int32) }
  end

  def test_assert_nil
    assert_nil nil
    assert_raises(Minitest::Assertion) { assert_nil 1 }
  end

  def test_refute_nil
    refute_nil 1
    assert_raises(Minitest::Assertion) { refute_nil nil }
  end

  def test_assert_in_delta
    assert_in_delta 0, 1, 1
    assert_in_delta 0.0, 1.0 / 1000
    assert_in_delta 0.0, 1.0 / 1000, 0.1
    assert_raises(Minitest::Assertion) { assert_in_delta 0.0, 1.0 / 1000, 0.000001 }
  end

  def test_refute_in_delta
    refute_in_delta 0, 2, 1
    refute_in_delta 0.0, 1.0 / 1000, 0.0001
    assert_raises(Minitest::Assertion) { refute_in_delta 0, 1, 1 }
  end

  def test_assert_in_epsilon
    assert_in_epsilon 10000, 9991
    assert_in_epsilon 9991, 10000
    assert_in_epsilon 1.0, 1.001
    assert_in_epsilon 1.001, 1.0

    assert_in_epsilon 10000, 9999.1, 0.0001
    assert_in_epsilon 9999.1, 10000, 0.0001
    assert_in_epsilon 1.0, 1.0001, 0.0001
    assert_in_epsilon 1.0001, 1.0, 0.0001

    assert_in_epsilon -10000, -9991
    assert_in_epsilon -1, -1

    assert_raises(Minitest::Assertion) { assert_in_epsilon 10000, 9990 }
  end

  def test_refute_in_epsilon
    refute_in_epsilon 10000, 9989
    refute_in_epsilon 9991, 10001
    refute_in_epsilon 1.0, 1.1
    refute_in_epsilon 1.001, 1.003

    assert_raises(Minitest::Assertion) { refute_in_epsilon 10000, 9990 }
  end

  def test_assert_includes
    assert_includes [1, 2, 3], 2
    assert_raises(Minitest::Assertion) { assert_includes [1, 2], 3 }
  end

  def test_refute_includes
    refute_includes [1, 2, 3], 4
    assert_raises(Minitest::Assertion) { refute_includes [1, 2], 2 }
  end

  def test_assert_instance_of
    assert_instance_of Foo, Foo.new
    assert_raises(Minitest::Assertion) { assert_instance_of Bar, Foo.new }
  end

  def test_refute_instance_of
    refute_instance_of Bar, Foo.new
    assert_raises(Minitest::Assertion) { refute_instance_of Foo, Foo.new }
  end

  def test_assert_responds_to
    assert_responds_to Foo.new, :inspect
    assert_raises(Minitest::Assertion) { assert_responds_to Foo.new, :foo }
  end

  def test_refute_responds_to
    refute_responds_to Foo.new, :foo
    assert_raises(Minitest::Assertion) { refute_responds_to Foo.new, :inspect }
  end

  def test_assert_raises
    ex = assert_raises { raise "error message" }
    assert_equal "error message", ex.message

    ex = assert_raises(Failure) { raise Failure.new("error message") }
    assert_equal "error message", ex.message
  end

  def test_assert_raises_no_exception
    ex = assert_raises(Minitest::Assertion) { assert_raises { true } }
    assert_match "nothing was raised", ex.message
  end

  def test_assert_raises_unexpected_exception
    ex = assert_raises(Minitest::Assertion) do
      assert_raises(Failure) { raise "oops" }
    end
    assert_match "AssertionsTest::Failure", ex.message
    assert_match "Exception", ex.message
  end

  def test_capture_io
    # captures io (and flushes):
    output, error = capture_io do
      STDOUT << "hello world"
      STDERR << "failed hello"
    end
    assert_equal "hello world", output
    assert_equal "failed hello", error

    # captures long output without blocking:
    bytes = Bytes.new(2 * 1024 * 1024)
    Random::Secure.random_bytes(bytes)

    output, error = capture_io do
      STDOUT.write bytes
      STDERR.write bytes
    end
    assert_equal bytes, output.to_slice
    assert_equal bytes, error.to_slice
  end

  def test_assert_silent
    assert_silent { }
    assert_raises(Minitest::Assertion) { assert_silent { STDOUT << "hello" } }
    assert_raises(Minitest::Assertion) { assert_silent { STDERR << "world" } }
  end

  def test_assert_output
    assert_output("hello", "world") do
      STDOUT << "hello"
      STDERR << "world"
    end

    assert_output(stdout: "hello") do
      STDOUT << "hello"
      STDERR << "world"
    end

    assert_output(stderr: "world") do
      STDOUT << "hello"
      STDERR << "world"
    end

    assert_output(stdout: /hello/) do
      STDOUT << "hello world"
      STDERR << "failed hello"
    end

    assert_output(stderr: /failed/) do
      STDOUT << "hello world"
      STDERR << "failed hello"
    end

    assert_output(/hello/, /failed/) do
      STDOUT << "hello world"
      STDERR << "failed world"
    end

    assert_output("hello world", /failed/) do
      STDOUT << "hello world"
      STDERR << "failed world"
    end

    assert_output(/hello/, "failed world") do
      STDOUT << "hello world"
      STDERR << "failed world"
    end

    assert_raises(Minitest::Assertion) do
      assert_output(/failed/) { STDOUT << "hello world" }
    end

    assert_raises(Minitest::Assertion) do
      assert_output("hello") { STDOUT << "hello world" }
    end

    assert_raises(Minitest::Assertion) do
      assert_output(stdout: "hello") { }
    end

    assert_raises(Minitest::Assertion) do
      assert_output(stderr: "hello") { }
    end

    assert_raises(Minitest::Assertion) do
      assert_output("world", "hello") do
        STDOUT << "hello world"
        STDERR << "world"
      end
    end

    assert_raises(Minitest::Assertion) do
      assert_output(/world/, /hello/) do
        STDOUT << "hello world"
        STDERR << "world"
      end
    end
  end

  def test_skip
    ex = assert_raises(Minitest::Skip) { skip }
    assert_equal "", ex.message
  end

  def test_skip_with_message
    ex = assert_raises(Minitest::Skip) { skip "todo" }
    assert_equal "todo", ex.message
  end

  def test_flunk
    ex = assert_raises(Minitest::Assertion) { flunk }
    assert_equal "Epic Fail!", ex.message
  end

  def test_flunk_with_message
    ex = assert_raises(Minitest::Assertion) { flunk "broken" }
    assert_equal "broken", ex.message
  end

  def test_message
    assert_equal "default", (message(nil) { "default" }).call
    assert_equal "string\ndefault", (message("string") { "default" }).call
    assert_equal "proc:string\ndefault", (message(-> { "proc:string" }) { "default" }).call
  end
end
