require "../src/minitest/autorun"

class RunnableTest < Minitest::Test
  def setup
    puts "custom setup"
    @myvar = "instance_val"
  end

  def teardown
    puts "\n"
  end

  def test_truthy
    assert { helper == "help you" }
  end

  def test_something
    puts "something"
    puts "@var = #{@myvar}"
  end

  def test_something_else
    puts "else"
    puts helper
  end

  def helper
    "help me"
  end
end
