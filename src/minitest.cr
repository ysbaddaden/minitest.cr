require "option_parser"
require "thread"
require "./minitest/result"
require "./minitest/reporter"
require "./minitest/runnable"
require "./minitest/test"

module Minitest
  class Options
    property :verbose, :threads

    def initialize
      @verbose = false
      @threads = 1
    end
  end

  @@mutex = Mutex.new

  def self.options
    @@options ||= Options.new
  end

  def self.process_args(args)
    OptionParser.parse(args) do |opts|
      opts.banner = "minitest options"

      opts.on("-h", "--help", "Display this help") do
        puts opts
        exit
      end

      opts.on("-p THREADS", "--parallel THREADS", "Show progress processing files.") do |threads|
        options.threads = threads.to_i
      end

      opts.on("-v", "--verbose", "Show progress processing files.") do
        options.verbose = true
      end
    end
  end

  def self.reporter
    @@reporter ||= CompositeReporter.new.tap do |reporter|
      reporter << SummaryReporter.new(options)
      reporter << ProgressReporter.new(options)
    end
  end

  def self.reporter=(reporter)
    @@reporter = reporter
  end

  def self.run(args = nil)
    process_args(args) if args
    reporter.start

    suites = Runnable.runnables.shuffle
    count = suites.size < options.threads ? suites.size : options.threads

    threads = (0 ... count).map do
      Thread.new do
        loop do
          if suite = @@mutex.synchronize { suites.pop unless suites.empty? }
            suite.run(reporter)
          else
            break
          end
        end
      end
    end
    threads.each(&.join)

    reporter.report
    reporter.passed?
  end
end
