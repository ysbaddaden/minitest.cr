require "../src/autorun"

class Minitest::TestTest < Minitest::Test
  # NOTE: we verify that tests are run in their own instance of the test suite,
  #       so instance variables aren't stepping on each other.

  def test_one
    assert_equal :a, a
    @a = :b
  end

  def test_two
    assert_equal :a, a
    @a = :c
  end

  def a
    @a ||= :a
  end
end
