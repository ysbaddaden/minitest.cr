module Minitest
  class Runnable
    @@runnables = [] of Runnable.class

    def self.runnables
      @@runnables
    end

    macro inherited
      Minitest::Runnable.runnables << self
    end

    macro def self.run(reporter) : Nil
      klass = {{
        if @type.name.ends_with?(":Class")
          @type.name[0..-7].id
        else
          @type.name
        end.id
      }}
      klass.new(reporter).run_tests
      nil
    end

    getter :reporter

    def initialize(@reporter)
    end

    def run_tests
    end
  end
end
