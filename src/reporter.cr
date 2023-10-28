require "colorize"
require "mutex"

module Minitest
  class AbstractReporter
    getter options : Options

    def initialize(@options)
      @mutex = Mutex.new
    end

    def start : Nil
    end

    def record(result : Result) : Nil
    end

    def report : Nil
    end

    def passed? : Bool
      true
    end

    def pause : Nil
      @mutex.lock
    end

    def resume : Nil
      @mutex.unlock
    end
  end

  class CompositeReporter < AbstractReporter
    getter reporters

    def initialize(@options)
      @reporters = [] of AbstractReporter
      super
    end

    def <<(reporter : AbstractReporter)
      reporters << reporter
    end

    def start : Nil
      reporters.each(&.start)
    end

    def record(result : Result) : Nil
      reporters.each(&.record(result))
    end

    def report : Nil
      reporters.each(&.report)
    end

    def passed? : Bool
      reporters.all?(&.passed?)
    end

    def pause : Nil
      reporters.each(&.pause)
    end

    def resume : Nil
      reporters.each(&.resume)
    end
  end

  class ProgressReporter < AbstractReporter
    def record(result : Result) : Nil
      @mutex.lock

      if options.verbose?
        if time = result.time
          print "%s#%s = %.3f s = " % {result.class_name, result.name, time.to_f}
        else
          print "%s#%s = ? = " % {result.class_name, result.name}
        end
      end

      if result.passed?
        print result.result_code.colorize(:green)
      elsif result.skipped?
        print result.result_code.colorize(:yellow)
      else
        print Colorize::Object.new(result.result_code).back(:red)
      end
      puts if options.verbose?
    rescue ex
      puts ex
      puts ex.backtrace.join("\n")
    ensure
      @mutex.unlock
    end
  end

  class StatisticsReporter < AbstractReporter
    getter :count, :results, :start_time, :total_time, :failures, :errors, :skips

    def initialize(options)
      super

      @results = [] of Minitest::Result
      @count = 0
      @failures = 0
      @errors = 0
      @skips = 0
      @start_time = uninitialized Time::Span # avoid nilable
      @total_time = uninitialized Time::Span # avoid nilable
    end

    def start : Nil
      @start_time = Time.monotonic
    end

    def record(result) : Nil
      @mutex.synchronize do
        @count += 1

        if !result.passed? || result.skipped?
          results << result
        end
      end
    end

    def report : Nil
      @total_time = Time.monotonic - start_time
      @failures = results.count(&.failure.is_a?(Assertion))
      @errors = results.count(&.failure.is_a?(UnexpectedError))
      @skips = results.count(&.failure.is_a?(Skip))
    end

    def passed? : Bool
      results.all?(&.skipped?)
    end
  end

  class SummaryReporter < StatisticsReporter
    def report : Nil
      super

      puts unless options.verbose?
      puts "\nFinished in #{total_time}, #{1.0 / total_time.to_f} runs/s"
      puts

      aggregated_results = options.verbose? ? results : results.reject(&.skipped?)

      aggregated_results.each_with_index do |result, i|
        loc = "#{result.class_name}##{result.name}"

        result.failures.each do |exception|
          case exception
          when Assertion
            puts "  #{i + 1}) Failure:".colorize(:red)
            puts "#{loc} [#{exception.__minitest_location}]:\n#{exception.message}"
          when UnexpectedError
            puts "  #{i + 1}) Error:".colorize(:red)
            puts "#{loc} [#{exception.__minitest_location}]:\n#{exception.message}"
            puts "    #{exception.backtrace.join("\n    ")}"
          when Skip
            puts "  #{i + 1}) Skipped:".colorize(:yellow)
            puts "#{loc} [#{exception.__minitest_location}]:\n#{exception.message}"
          else
            # shut up, crystal (you're wrong)
          end
          puts
        end
      end

      puts "#{count} tests, #{failures} failures, #{errors} errors, #{skips} skips"
        .colorize(passed? ? :green : :red)

      if skips > 0 && !options.verbose?
        puts "\nYou have skipped tests. Run with --verbose for details."
      end
    end
  end
end
