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

    def must_match_array(array, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_match_array(array, message, file, line)
    end

    def wont_match_array(array, message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).wont_match_array(array, message, file, line)
    end

    def must_be_truthy(message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_be_truthy(message, file, line)
    end

    def must_be_falsey(message = nil, file = __FILE__, line = __LINE__)
      Expectation.new(self).must_be_falsey(message, file, line)
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

    def must_change(message = nil, file = __FILE__, line = __LINE__, **opts)
      if opts.empty?
        assert_changes(@target, message, file, line) { yield }
      elsif opts.has_key?(:by)
        assert_changes(@target, opts[:by]?, message, file, line) { yield }
      elsif opts.has_key?(:from) && opts.has_key?(:from)
        assert_changes(@target, opts[:from]?, opts[:to]?, message, file, line) { yield }
      else
        raise "Unknown change matcher arguments (#{opts.inspect})."
      end
    end

    def must_change_at_least(by, message = nil, file = __FILE__, line = __LINE__, &block)
      assert_changes_at_least(@target, by, message, file, line) { yield }
    end

    def must_change_at_most(by, message = nil, file = __FILE__, line = __LINE__, &block)
      assert_changes_at_most(@target, by, message, file, line) { yield }
    end

    def wont_change(message = nil, file = __FILE__, line = __LINE__, &block)
      refute_changes(@target, message, file, line) { yield }
    end

    def must_match_array(array, message = nil, file = __FILE__, line = __LINE__)
      assert_matches_array(array, @target, message, file, line)
    end

    def wont_match_array(array, message = nil, file = __FILE__, line = __LINE__)
      refute_matches_array(array, @target, message, file, line)
    end

    def must_be_truthy(message = nil, file = __FILE__, line = __LINE__)
      assert_truthy(@target, message, file, line)
    end

    def must_be_falsey(message = nil, file = __FILE__, line = __LINE__)
      assert_falsey(@target, message, file, line)
    end
  end
end

{% if !flag?(:mt_no_expectations) %}
  class Object
    include Minitest::Expectations
  end
{% end %}
