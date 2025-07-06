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
      @failures = results.count(&.failures.first?.is_a?(Assertion))
      @errors = results.count(&.failures.first?.is_a?(UnexpectedError))
      @skips = results.count(&.failures.first?.is_a?(Skip))
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

  class JunitReporter < StatisticsReporter
    def self.new(path : String, options)
      new(File.new(path, "w"), options)
    end

    def initialize(@io : IO, options)
      super(options)
    end

    def record(result) : Nil
      @mutex.synchronize do
        @count += 1
        results << result
      end
    end

    def report : Nil
      super

      @io.puts %(<?xml version="1.0" encoding="UTF-8"?>)
      @io.puts %(<testsuite tests="#{count}" failures="#{failures}" errors="#{errors}" skipped="#{skips}" time="#{total_time.total_seconds}">)
      results.each do |result|
        if result.passed?
          @io.puts %(<testcase classname="#{xml_escape(result.class_name)}" name="#{xml_escape(result.name)}" time="#{result.time.total_seconds}"></testcase>)
        else
          exception = result.failure
          @io.puts %(<testcase classname="#{xml_escape(result.class_name)}" name="#{xml_escape(result.name)}" time="#{result.time.total_seconds}" file="#{xml_escape(exception.__minitest_file)}" line="#{xml_escape(exception.__minitest_line)}">)

          case exception
          when Assertion
            @io.puts %(<failure message="#{xml_escape(exception.message)}"></failure>)
          when Skip
            @io.puts %(<skipped message="#{xml_escape(exception.message)}"/>)
          else
            # UnexpectedError
            @io.puts %(<error message="#{xml_escape(exception.message)}" type="#{xml_escape(exception.class.name)}">)
            if backtrace = exception.backtrace?
              @io.puts xml_escape(backtrace.join('\n'))
            end
            @io.puts %(</error>)
          end
          @io.puts %(</testcase>)
        end
      end
      @io.puts %(</testsuite>)

      @io.close
    end

    private def xml_escape(value : Int32 | Nil) : Nil
      value
    end

    private def xml_escape(value : String) : String
      String.build do |str|
        value.each_char do |char|
          case char
          when '&'
            str << "&amp;"
          when '<'
            str << "&lt;"
          when '>'
            str << "&gt;"
          when '"'
            str << "&quot;"
          when '\''
            str << "&apos;"
          when .control?
            char.to_s.inspect_unquoted(str)
          else
            str << char
          end
        end
      end
    end
  end
end
