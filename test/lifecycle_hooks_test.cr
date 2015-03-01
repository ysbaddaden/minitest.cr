require "../src/minitest/autorun"

class LifecycleHooksTest < Minitest::Test
  getter :state_was

  def before_setup
    assert state_was.nil?
    super
    @state_was = "before_setup"
  end

  def setup
    assert_equal "before_setup", state_was
    @state_was = "setup"
  end

  def after_setup
    super
    assert_equal "setup", state_was
    @state_was = "after_setup"
  end

  def before_teardown
    super
    @state_was = "before_teardown"
  end

  def teardown
    assert_equal "before_teardown", state_was
    @state_was = "teardown"
  end

  def after_teardown
    super
    assert_equal "teardown", state_was
    @state_was = nil
  end

  def test_state
    assert_equal "after_setup", state_was
  end

  def test_state_again
    assert_equal "after_setup", state_was
  end
end
