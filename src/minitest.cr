require "option_parser"
require "./minitest/result"
require "./minitest/reporter"
require "./minitest/runnable"
require "./minitest/test"
require "./minitest/spec"

module Minitest
  class Options
    property :verbose, :threads
    getter :pattern

    def initialize
      @verbose = false
      @threads = 1
    end

    def pattern=(pattern)
      if pattern =~ %r(\A/(.+?)/\Z)
        @pattern = Regex.new($1)
      else
        @pattern = pattern
      end
    end
  end

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

      opts.on("-v", "--verbose", "Show progress processing files.") do
        options.verbose = true
      end

      opts.on("-p THREADS", "--parallel THREADS", "Parallelize runs.") do |threads|
        options.threads = threads.to_i
      end

      opts.on("-n PATTERN", "--name PATTERN", "Filter run on /pattern/ or string.") do |pattern|
        options.pattern = pattern
      end
    end
  end

  def self.reporter
    @@reporter ||= CompositeReporter.new(options).tap do |reporter|
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
    completed = 0

    count.times do
      spawn do
        loop do
          if suite = suites.pop?
            suite.run(reporter)
            completed += 1
          else
            break
          end
        end
      end
    end

    loop do
      sleep 0.001
      break if completed >= Runnable.runnables.size
    end

    reporter.report
    reporter.passed?
  ensure
    after_run.each(&.call)
    reporter.passed?
  end

  def self.after_run
    @@after_run ||= [] of ->
  end

  def self.after_run(&block)
    after_run << block
  end
end
