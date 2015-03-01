require "colorize"

module Minitest
  class AbstractReporter
    getter! :options

    def initialize(@options)
    end

    def start
    end

    def record(result)
    end

    def report
    end

    def passed?
      true
    end
  end

  class CompositeReporter < AbstractReporter
    getter :reporters

    def initialize
      @reporters = [] of AbstractReporter
    end

    def <<(reporter)
      reporters << reporter
    end

    def start
      reporters.each(&.start)
    end

    def record(result)
      reporters.each(&.record(result))
    end

    def report
      reporters.each(&.report)
    end

    def passed?
      reporters.all?(&.passed?)
    end
  end

  class ProgressReporter < AbstractReporter
    def record(result)
      if options[:verbose]
        if time = result.time
          LibC.printf "%s#%s = %.03f s = ", result.class_name, result.name, result.time.to_f
        else
          LibC.printf "%s#%s = ? = ", result.class_name, result.name
        end
      end

      if result.passed?
        print result.result_code.colorize(:green)
      elsif result.skipped?
        print result.result_code.colorize(:yellow)
      else
        print ColorizedObject.new(result.result_code).back(:red)
      end
      puts if options[:verbose]
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
      @start_time :: Time # avoid nilable
      @total_time :: TimeSpan # avoid nilable
    end

    def start
      @start_time = Time.now
    end

    def record(result)
      @count += 1
      results << result if !result.passed? || result.skipped?
    end

    def report
      @total_time = Time.new - start_time

      # NOTE: disabled until crystal fixes compiler bugs with .class (ie. runtime metaprogramming)
      #aggregate = results.group_by { |r| r.failure.class }
      #@failures = aggregate[Assertion].size
      #@errors = aggregate[UnexpectedError].size
      #@skips = aggregate[Skip].size

      @failures = results.select(&.failure.is_a?(Assertion)).size
      @errors = results.select(&.failure.is_a?(UnexpectedError)).size
      @skips = results.select(&.failure.is_a?(Skip)).size
    end

    def passed?
      results.all?(&.skipped?)
    end
  end

  # TODO: report origin of failures (file, line)
  class SummaryReporter < StatisticsReporter
    def report
      super

      puts unless options[:verbose]
      puts "\nFinished in #{total_time}, #{1.0 / total_time.to_f} runs/s"
      puts

      aggregated_results = options[:verbose] ? results : results.reject(&.skipped?)

      aggregated_results.each_with_index do |result, i|
        loc = "#{result.class_name}##{result.name}"

        result.failures.each do |exception|
          case exception
          when Assertion
            puts "  #{i + 1}) Failure:".colorize(:red)
            puts "#{loc}:\n#{exception.message}"
          when UnexpectedError
            puts "  #{i + 1}) Error:".colorize(:red)
            puts "#{loc}:\n#{exception.class}:"
            puts "      #{exception.backtrace.join("\n      ")}"
          when Skip
            puts "  #{i + 1}) Skipped:".colorize(:yellow)
            puts "#{loc}:\n#{exception.message}"
          end
          puts
        end
      end

      puts "#{count} tests, #{failures} failures, #{errors} errors, #{skips} skips"
        .colorize(passed? ? :green : :red)

      if skips > 0 && !options[:verbose]
        puts "\nYou have skipped tests. Run with --verbose for details."
      end
    end
  end
end
