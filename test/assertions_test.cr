require "../src/minitest/autorun"

class AssertionsTest < Minitest::Test
  class Failure < Exception; end

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

  def test_assert_raises
    ex = assert_raises { raise "error message" }
    assert_equal "error message", ex.message

    ex = assert_raises(Failure) { raise Failure.new("error message") }
    assert_equal "error message", ex.message
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
