require "./assertions"

module Minitest
  # TODO: must_raise / must_raise(class_name)
  module Expectations
    def must_be_empty(message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_be_empty(message, file, line)
    end

    def wont_be_empty(message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).wont_be_empty(message, file, line)
    end

    def must_equal(expected, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_equal(expected, message, file, line)
    end

    def wont_equal(expected, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).wont_equal(expected, message, file, line)
    end

    def must_be_close_to(expected, delta = 0.001, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_be_close_to(expected, delta, message, file, line)
    end

    def must_be_within_delta(expected, delta = 0.001, message = nil, file = __FILE__, line = __LINE__)
      must_be_close_to(expected, delta, message, file, line)
    end

    def wont_be_close_to(expected, delta = 0.001, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).wont_be_close_to(expected, delta, message, file, line)
    end

    def wont_be_within_delta(expected, delta = 0.001, message = nil, file = __FILE__, line = __LINE__)
      wont_be_close_to(expected, delta, message, file, line)
    end

    def must_be_within_epsilon(expected, epsilon = 0.001, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_be_within_epsilon(expected, epsilon, message, file, line)
    end

    def wont_be_within_epsilon(expected, epsilon = 0.001, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).wont_be_within_epsilon(expected, epsilon, message, file, line)
    end

    def must_include(obj, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_include(obj, message, file, line)
    end

    def wont_include(obj, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).wont_include(obj, message, file, line)
    end

    def must_be_instance_of(obj, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_be_instance_of(obj, message, file, line)
    end

    def wont_be_instance_of(obj, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).wont_be_instance_of(obj, message, file, line)
    end

    def must_match(pattern, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_match(pattern, message, file, line)
    end

    def wont_match(pattern, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).wont_match(pattern, message, file, line)
    end

    def must_be_nil(message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_be_nil(message, file, line)
    end

    def wont_be_nil(message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).wont_be_nil(message, file, line)
    end

    def must_be_same_as(expected, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_be_same_as(expected, message, file, line)
    end

    def wont_be_same_as(expected, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).wont_be_same_as(expected, message, file, line)
    end
  end

  class Expectation(T)
    include Assertions

    def initialize(@target : T)
    end

    def must_be_empty(message = nil, file = __FILE__, line = __LINE__)
      assert_empty(@target, message, file, line)
    end

    def wont_be_empty(message = nil, file = __FILE__, line = __LINE__)
      refute_empty(@target, message, file, line)
    end

    def must_equal(expected, message = nil, file = __FILE__, line = __LINE__)
      assert_equal(expected, @target, message, file, line)
    end

    def wont_equal(expected, message = nil, file = __FILE__, line = __LINE__)
      refute_equal(expected, @target, message, file, line)
    end

    def must_be_close_to(expected, delta = 0.001, message = nil, file = __FILE__, line = __LINE__)
      assert_in_delta(@target, expected, delta)
    end

    def must_be_within_delta(expected, delta = 0.001, message = nil, file = __FILE__, line = __LINE__)
      must_be_close_to(expected, delta, message, file, line)
    end

    def wont_be_close_to(expected, delta = 0.001, message = nil, file = __FILE__, line = __LINE__)
      refute_in_delta(@target, expected, delta, message, file, line)
    end

    def wont_be_within_delta(expected, delta = 0.001, message = nil, file = __FILE__, line = __LINE__)
      wont_be_close_to(expected, delta, message, file, line)
    end

    def must_be_within_epsilon(expected, epsilon = 0.001, message = nil, file = __FILE__, line = __LINE__)
      assert_in_epsilon(@target, expected, epsilon, message, file, line)
    end

    def wont_be_within_epsilon(expected, epsilon = 0.001, message = nil, file = __FILE__, line = __LINE__)
      refute_in_epsilon(@target, expected, epsilon, message, file, line)
    end

    def must_include(obj, message = nil, file = __FILE__, line = __LINE__)
      assert_includes(@target, obj, message, file, line)
    end

    def wont_include(obj, message = nil, file = __FILE__, line = __LINE__)
      refute_includes(@target, obj, message, file, line)
    end

    def must_be_instance_of(obj, message = nil, file = __FILE__, line = __LINE__)
      assert_instance_of(obj, @target, message, file, line)
    end

    def wont_be_instance_of(obj, message = nil, file = __FILE__, line = __LINE__)
      refute_instance_of(obj, @target, message, file, line)
    end

    def must_match(pattern, message = nil, file = __FILE__, line = __LINE__)
      assert_match(pattern, @target, message, file, line)
    end

    def wont_match(pattern, message = nil, file = __FILE__, line = __LINE__)
      refute_match(pattern, @target, message, file, line)
    end

    def must_be_nil(message = nil, file = __FILE__, line = __LINE__)
      assert_nil(@target, message, file, line)
    end

    def wont_be_nil(message = nil, file = __FILE__, line = __LINE__)
      refute_nil(@target, message, file, line)
    end

    def must_be_same_as(expected, message = nil, file = __FILE__, line = __LINE__)
      assert_same(@target, expected, message, file, line)
    end

    def wont_be_same_as(expected, message = nil, file = __FILE__, line = __LINE__)
      refute_same(@target, expected, message, file, line)
    end
  end
end

{% if !flag?(:mt_no_expectations) %}
  class Object
    include Minitest::Expectations
  end
{% end %}
