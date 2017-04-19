require "../src/autorun"

class SeedTest < Minitest::Test
  def test_seed_environment_variable
    skip "missing SEED=12345 environment variable" unless ENV["SEED"]? == "12345"
    assert_equal 3900435579, Random::DEFAULT.next_u
  end
end
