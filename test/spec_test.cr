require "../src/autorun"

describe Minitest::Spec do
  class Foo
    property :bar
  end

  def add(a, b)
    a + b
  end

  let(:data) { "data value" }

  it "accepts a block" do
    assert true
  end

  it("accepts a block with brackets") { assert true }

  it("reports the original failure location") do
    ex = assert_raises(Minitest::Assertion) { assert false }
    assert_equal("test/spec_test.cr:21", ex.location)
  end

  it "calls an instance method" do
    assert_equal 3, add(1, 2)
  end

  describe("nested describes") do
    let(:more) { "more " + data }

    it "accesses parent methods" do
      assert_equal 4, add(2, 2)
    end

    it "accesses let methods" do
      assert_equal "data value", data
      assert_equal "more data value", more
    end
  end

  describe(". starting with special chars") {}
  describe("ending with special chars #") {}
  it(". has leading and ending special chars .") {}

  describe "let" do
    let(:foo) { Foo.new }

    it "memoizes the object for the duration of the test" do
      foo.bar = "baz"
      assert_equal "baz", foo.bar
    end

    it "regenerates the object on each teardown" do
      assert_nil foo.bar
    end
  end

  describe "expect" do
    it "wraps value" do
      expect(1).must_equal(1)
      expect(Foo.new).wont_be_same_as(Foo.new)
    end
  end
end
