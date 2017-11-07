require "../src/autorun"

class ExpectationsTest < Minitest::Spec
  class Foo; end

  let(:foo) { Foo.new }

  it "must_be_empty" do
    ary = [] of String
    ary.must_be_empty
    assert_raises(Minitest::Assertion) { [1, 2, 3].must_be_empty }
  end

  it "wont_be_empty" do
    [1, 2, 3].wont_be_empty
    assert_raises(Minitest::Assertion) do
      ary = [] of String
      ary.wont_be_empty
    end
  end

  it "must_equal" do
    1.must_equal(1)
    assert_raises(Minitest::Assertion) { 1.must_equal(2) }
  end

  it "wont_equal" do
    1.wont_equal(2)
    assert_raises(Minitest::Assertion) { 1.wont_equal(1) }
  end

  it "must_be_same_as" do
    foo.must_be_same_as(foo)
    assert_raises(Minitest::Assertion) { foo.must_be_same_as(Foo.new) }
  end

  it "wont_be_same_as" do
    foo.wont_be_same_as(Foo.new)
    assert_raises(Minitest::Assertion) { foo.wont_be_same_as(foo) }
  end

  it "must_be_close_to" do
    1.must_be_close_to(0.9999)
    1.0.must_be_close_to(0.9, delta: 0.1)
    assert_raises(Minitest::Assertion) { 3.must_be_close_to(4) }
  end

  it "wont_be_close_to" do
    1.wont_be_close_to(2.1)
    assert_raises(Minitest::Assertion) { 1.wont_be_close_to(0.9999) }
  end

  it "must_be_within_epsilon" do
    10000.must_be_within_epsilon(9991)
    10000.0.must_be_within_epsilon(9999.1, epsilon: 0.0001)
    assert_raises(Minitest::Assertion) { 10000.must_be_within_epsilon(9990) }
  end

  it "wont_be_within_epsilon" do
    10000.wont_be_within_epsilon(9989)
    10000.0.wont_be_within_epsilon(9998.1, epsilon: 0.0001)
    assert_raises(Minitest::Assertion) { 10000.wont_be_within_epsilon(9999) }
  end

  it "must_include" do
    [1, 2, 3].must_include(1)
    assert_raises(Minitest::Assertion) { [3, 4].must_include(1) }
  end

  it "wont_include" do
    [1, 2].wont_include(3)
    assert_raises(Minitest::Assertion) { [1, 2].wont_include(2) }
  end

  it "must_match" do
    "test".must_match(/t/)
    assert_raises(Minitest::Assertion) { "test".must_match(/z/) }
  end

  it "wont_match" do
    "test".wont_match(/z/)
    assert_raises(Minitest::Assertion) { "test".wont_match(/test/) }
  end

  it "must_be_nil" do
    nil.must_be_nil
    assert_raises(Minitest::Assertion) { 1.must_be_nil }
  end

  it "wont_be_nil" do
    1.wont_be_nil
    assert_raises(Minitest::Assertion) { nil.wont_be_nil }
  end

  it "must_change" do
    i = 0
    expect { i += 1 }.must_change { i }
    assert_raises(Minitest::Assertion) { expect { i += 2 - 2 }.must_change { i } }
  end

  it "must_change with by" do
    i = 0
    expect { i += 1 }.must_change(by: 1) { i }
    assert_raises(Minitest::Assertion) { expect { i += 2 }.must_change(by: 1) { i } }
  end

  it "must_change_at_least" do
    i = 0
    expect { i += 3 }.must_change_at_least(1) { i }
    expect { i += 1 }.must_change_at_least(1) { i }
    assert_raises(Minitest::Assertion) { expect { i += 2 }.must_change_at_least(3) { i } }
  end

  it "must_change_at_most" do
    i = 0
    expect { i += 1 }.must_change_at_most(1) { i }
    expect { i += 2 }.must_change_at_most(3) { i }
    assert_raises(Minitest::Assertion) { expect { i += 2 }.must_change_at_most(1) { i } }
  end

  it "must_change with from and to args" do
    i = 0
    expect { i += 1 }.must_change(from: 0, to: 1) { i }
    assert_raises(Minitest::Assertion) { expect { i += 2 }.must_change(from: 0, to: 1) { i } }
  end

  it "wont_change" do
    i = 0
    expect { i += 0 }.wont_change { i }
    assert_raises(Minitest::Assertion) { expect { i += 2 }.wont_change { i } }
  end

  it "must_match_array" do
    [1, 2, 3].must_match_array([3, 2, 1])
    assert_raises(Minitest::Assertion) { [1, 2, 3].must_match_array([3, 2]) }
  end

  it "wont_match_array" do
    [1, 2, 3].wont_match_array([3, 2])
    assert_raises(Minitest::Assertion) { [1, 2, 3].wont_match_array([3, 2, 1]) }
  end

  it "must_be_truthy" do
    true.must_be_truthy
    1.must_be_truthy
    "".must_be_truthy
    ([] of String)..must_be_truthy
    ({} of String => String).must_be_truthy
    Foo.new.must_be_truthy
    assert_raises(Minitest::Assertion) { false.must_be_truthy }
    assert_raises(Minitest::Assertion) { nil.must_be_truthy }
  end

  it "must_be_falsey" do
    false.must_be_falsey
    nil.must_be_falsey
    assert_raises(Minitest::Assertion) { true.must_be_falsey }
    assert_raises(Minitest::Assertion) { Foo.new.must_be_falsey }
  end
end
