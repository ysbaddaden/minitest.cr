require "../src/autorun"

class ExpectationsTest < Minitest::Spec
  class Foo; end

  class Bar; end

  let(:foo) { Foo.new }

  it "must_be_empty" do
    ary = [] of String
    expect(ary).must_be_empty
    assert_raises(Minitest::Assertion) { expect([1, 2, 3]).must_be_empty }
  end

  it "wont_be_empty" do
    expect([1, 2, 3]).wont_be_empty
    assert_raises(Minitest::Assertion) do
      ary = [] of String
      expect(ary).wont_be_empty
    end
  end

  it "must_equal" do
    expect(1).must_equal(1)
    assert_raises(Minitest::Assertion) { expect(1).must_equal(2) }
  end

  it "wont_equal" do
    expect(1).wont_equal(2)
    assert_raises(Minitest::Assertion) { expect(1).wont_equal(1) }
  end

  it "must_be_same_as" do
    expect(foo).must_be_same_as(foo)
    assert_raises(Minitest::Assertion) { expect(foo).must_be_same_as(Foo.new) }
  end

  it "wont_be_same_as" do
    expect(foo).wont_be_same_as(Foo.new)
    assert_raises(Minitest::Assertion) { expect(foo).wont_be_same_as(foo) }
  end

  it "must_be_close_to" do
    expect(1).must_be_close_to(0.9999)
    expect(1.0).must_be_close_to(0.9, delta: 0.1)
    assert_raises(Minitest::Assertion) { expect(3).must_be_close_to(4) }
  end

  it "wont_be_close_to" do
    expect(1).wont_be_close_to(2.1)
    assert_raises(Minitest::Assertion) { expect(1).wont_be_close_to(0.9999) }
  end

  it "must_be_within_epsilon" do
    expect(10000).must_be_within_epsilon(9991)
    expect(10000.0).must_be_within_epsilon(9999.1, epsilon: 0.0001)
    assert_raises(Minitest::Assertion) { expect(10000).must_be_within_epsilon(9990) }
  end

  it "wont_be_within_epsilon" do
    expect(10000).wont_be_within_epsilon(9989)
    expect(10000.0).wont_be_within_epsilon(9998.1, epsilon: 0.0001)
    assert_raises(Minitest::Assertion) { expect(10000).wont_be_within_epsilon(9999) }
  end

  it "must_include" do
    expect([1, 2, 3]).must_include(1)
    assert_raises(Minitest::Assertion) { expect([3, 4]).must_include(1) }
  end

  it "wont_include" do
    expect([1, 2]).wont_include(3)
    assert_raises(Minitest::Assertion) { expect([1, 2]).wont_include(2) }
  end

  it "must_be_instance_of" do
    foo = Foo.new
    expect(foo).must_be_instance_of(Foo)
    assert_raises(Minitest::Assertion) { expect(foo).must_be_instance_of(Bar) }
  end

  it "wont_be_instance_of" do
    foo = Foo.new
    expect(foo).wont_be_instance_of(Bar)
    assert_raises(Minitest::Assertion) { expect(foo).wont_be_instance_of(Foo) }
  end

  it "must_match" do
    expect("test").must_match(/t/)
    assert_raises(Minitest::Assertion) { expect("test").must_match(/z/) }
  end

  it "wont_match" do
    expect("test").wont_match(/z/)
    assert_raises(Minitest::Assertion) { expect("test").wont_match(/test/) }
  end

  it "must_be_nil" do
    expect(nil).must_be_nil
    assert_raises(Minitest::Assertion) { expect(1).must_be_nil }
  end

  it "wont_be_nil" do
    expect(1).wont_be_nil
    assert_raises(Minitest::Assertion) { expect(nil).wont_be_nil }
  end
end
