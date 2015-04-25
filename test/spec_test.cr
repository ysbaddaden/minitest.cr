require "../src/autorun"

class SpecTest < Minitest::Spec
  before do
    @value = "value"
  end

  it "passes" do
    assert true
  end

  it("accepts a bracket block") { assert true }

  it "calls an instance method" do
    p assert_equal "value", value
  end

  it "musn't pass" do
    assert false
  end

  def value
    @value
  end
end
