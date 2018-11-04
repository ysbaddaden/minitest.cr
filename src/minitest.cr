require "option_parser"
require "./result"
require "./reporter"
require "./runnable"
require "./test"
require "./spec"

module Minitest
  class Options
    property chaos
    property verbose
    property threads
    getter pattern : String | Regex | Nil
    getter seed : UInt32

    def initialize
      @chaos = false
      @verbose = false
      @threads = 1
      @seed = (ENV["SEED"]?.try(&.to_u32) || Random::Secure.rand(UInt32::MIN..UInt32::MAX)) & 0xFFFF
    end

    def pattern=(pattern)
      if pattern =~ %r(\A/(.+?)/\Z)
        @pattern = Regex.new($1)
      else
        @pattern = pattern
      end
    end

    def seed=(seed)
      @seed = seed.to_u32 & 0xFFFF
    end

    def to_s(io)
      io << "Run options: --seed "
      seed.to_s(io)

      if verbose
        io << " --verbose"
      end

      if chaos
        io << " --chaos"
      end

      if threads = @threads
        io << " --parallel "
        threads.to_s(io)
      end

      if pattern = @pattern
        io << " --name "
        pattern.inspect(io)
      end

      io << "\n"
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

      opts.on("-s SEED", "--seed SEED", "Sets random seed. Also via SEED environment variable.") do |seed|
        options.seed = seed.to_u32
      end

      opts.on("-v", "--verbose", "Show progress processing files.") do
        options.verbose = true
      end

      opts.on("-p THREADS", "--parallel THREADS", "Parallelize runs.") do |threads|
        options.threads = threads.to_i
      end

      opts.on("-c", "--chaos", "Shuffle all tests from all test suites.") do
        options.chaos = true
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
    puts options

    random = Random::PCG32.new(options.seed.to_u64)
    channel = Channel::Buffered(Array(Runnable::Data) | Runnable::Data | Nil).new
    completed = Channel(Nil).new

    options.threads.times do
      spawn do
        loop do
          value = channel.receive
          case value
          when Array
            value.each do |test|
              suite, name, proc = test
              suite.new(reporter).run_one(name, proc)
            end
          when Runnable::Data
            suite, name, proc = value
            suite.new(reporter).run_one(name, proc)
          else
            completed.send(nil)
            break
          end
        end
      end
    end

    reporter.start

    if options.chaos
      # collect & shuffle all tests for all suites:
      tests = [] of Runnable::Data
      Runnable.runnables.each do |suite|
        tests += suite.collect_tests
      end
      tests.shuffle!(random)
      tests.each { |test| channel.send(test) }
    else
      # shufle each suite, then shuffle tests for each suite:
      Runnable.runnables.shuffle!(random)
      Runnable.runnables.each do |suite|
        tests = suite.collect_tests
        tests.shuffle!(random)
        tests.each { |test| channel.send(test) }
      end
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

  def self.exit(status = 1)
    after_run.each(&.call)
    exit status
  end
end
