require "../src/autorun"

class AssertionsTest < Minitest::Test
  class Failure < Exception; end
  class Foo; end

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
    refute_empty({ 1 => 2, 3 => 4 })
    assert_raises(Minitest::Assertion) { refute_empty([] of Int32) }
    #assert_raises(Minitest::Assertion) { refute_empty({} of Int32 => Int32) }
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

  def test_skipped
    skip "testing that this test is skipped"
    raise "should never be raised"
  end

  # def test_flunked
  #   flunk
  # end
end
