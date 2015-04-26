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
end
