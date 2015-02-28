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
      false
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
      reporters.each do |reporter|
        reporter.record(result)
      end
    end

    def report
      reporters.each(&.report)
    end

    def passed?
      reporters.all?(&.passed?)
    end
  end

  # TODO: colorize
  class ProgressReporter < AbstractReporter
    def record(result)
      if options[:verbose]
        if time = result.time
          LibC.printf "%s#%s = %.03f s = ", result.class_name, result.name, result.time.to_f
        else
          LibC.printf "%s#%s = ? = ", result.class_name, result.name
        end
      end

      print result.result_code
      puts if options[:verbose]
    end
  end

  # TODO: colorize
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
      failures + errors == 0
    end
  end

  # TODO: report origin of failures/errors (file, line, class, method)
  class SummaryReporter < StatisticsReporter
    def report
      super

      print "\n\nFinished in #{total_time}\n"
      print "#{count} tests, #{failures} failures, #{errors} errors"

      if skips > 0
        print ", #{skips} skips\n\n"
      else
        print "\n\n"
      end

      results.each_with_index do |result, i|
        result.failures.each do |exception|
          if exception.is_a?(Assertion)
            print "  #{i + 1}) Failure: #{exception.message}\n"
          elsif exception.is_a?(UnexpectedError)
            print "  #{i + 1}) #{exception.class}: exception.message}\n"
            print "      #{exception.backtrace.join("\n      ")}\n\n"
          end
        end
      end

      if skips > 0
        print "\nThere are skipped tests.\n"
      end
    end
  end
end
