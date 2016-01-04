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
      klass.run_tests(reporter)
      nil
    end

    getter :reporter

    def initialize(@reporter)
    end

    def self.run_tests(reporter)
    end
  end
end
