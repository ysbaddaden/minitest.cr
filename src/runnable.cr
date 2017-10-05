module Minitest
  class Runnable
    def self.runnables : Array(Runnable.class)
      {% begin %}
        [self, {{ @type.all_subclasses.join(", ").id }}]
      {% end %}
    end

    def self.run(reporter)
      {{ @type }}.run_tests(reporter)
      nil
    end

    getter reporter : AbstractReporter

    def initialize(@reporter)
    end

    def self.run_tests(reporter)
    end
  end
end
