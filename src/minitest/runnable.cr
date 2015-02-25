module Minitest
  class Runnable
    @@runnables = [Runnable]
    @@runnables.clear

    def self.runnables
      @@runnables
    end

    macro inherited
      Minitest::Runnable.runnables << self
    end

    macro def self.run : Nil
      klass = {{ (@class_name.ends_with?(":Class") ? @class_name[0..-7].id : @class_name).id }}
      klass.new.run_tests
      nil
    end

    def run_tests
    end
  end
end
