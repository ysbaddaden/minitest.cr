module Minitest
  class Runnable
    def self.runnables : Array(Runnable.class)
      {% begin %}
        [self, {{ @type.all_subclasses.join(", ").id }}]
      {% end %}
    end

    alias Data = {Test.class, String, Proc(Test, Nil)}

    # Builds, at compile time, an Array with the test class, the test method
    # name, and a proc to call that method. The Array will then be shuffled at
    # runtime.
    def self.collect_tests : Array(Runnable::Data)
      tests = [] of Runnable::Data

      {% begin %}
        {% for name in @type.methods.map(&.name).select(&.starts_with?("test_")) %}
          %proc = ->(test : Test) {
            test.as({{ @type }}).{{ name }}
            nil
          }
          tests << { {{ @type }}, {{ name.stringify }}, %proc }
        {% end %}
      {% end %}

      tests
    end

    getter __reporter : AbstractReporter

    def initialize(@__reporter)
    end

    def should_run?(name : String) : Bool
      matches_pattern?(name)
    end

    def matches_pattern?(name : String) : Bool
      case pattern = __reporter.options.pattern
      when Regex
        !(name =~ pattern).nil?
      when String
        name == pattern
      else
        true
      end
    end
  end
end
