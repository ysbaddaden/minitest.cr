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

    getter reporter : AbstractReporter

    def initialize(@reporter)
    end
  end
end
