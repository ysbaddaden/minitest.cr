require "../src/autorun"

class ExpectationsTest < Minitest::Spec
  class Foo; end
  class Bar; end

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

  it "must_be_instance_of" do
    foo = Foo.new
    foo.must_be_instance_of(Foo)
    assert_raises(Minitest::Assertion) { foo.must_be_instance_of(Bar) }
  end

  it "wont_be_instance_of" do
    foo = Foo.new
    foo.wont_be_instance_of(Bar)
    assert_raises(Minitest::Assertion) { foo.wont_be_instance_of(Foo) }
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
end
