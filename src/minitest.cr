require "option_parser"
require "./result"
require "./reporter"
require "./runnable"
require "./test"
require "./spec"

module Minitest
  class Options
    property verbose
    property threads
    getter pattern : String | Regex | Nil

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

  @@reporter : AbstractReporter?

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

    Runnable.runnables.each(&.collect_tests)

    channel = Channel::Buffered(Runnable::Data | Nil).new
    completed = Channel(Nil).new

    options.threads.times do
      spawn do
        loop do
          if test = channel.receive
            suite, name, proc = test
            suite.new(reporter).run_one(name, proc)
          else
            completed.send(nil)
            break
          end
        end
      end
    end

    Runnable.tests.shuffle.each do |test|
      channel.send(test)
    end

    options.threads.times do
      channel.send(nil)
      completed.receive
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
