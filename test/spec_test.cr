require "../src/autorun"

describe Minitest::Spec do
  def value
    "value"
  end

  it "passes" do
    assert true
  end

  it("accepts a bracket block") { assert true }

  it "calls an instance method" do
    assert_equal "value", value
  end

  it "musn't pass" do
    assert_raises(Minitest::Assertion) { assert false }
  end
end
