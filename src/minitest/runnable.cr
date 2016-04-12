module Minitest
  class Runnable
    macro def self.runnables : Array(Runnable.class)
      [self, {{ @type.all_subclasses.join(", ").id }}]
    end

    macro def self.run(reporter) : Nil
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
