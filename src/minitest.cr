require "option_parser"
require "./result"
require "./reporter"
require "./runnable"
require "./test"
require "./spec"

module Minitest
  class Options
    property? chaos : Bool
    property? verbose : Bool
    property fibers : Int32
    getter pattern : String | Regex | Nil
    getter seed : UInt32

    def initialize
      @chaos = false
      @verbose = false
      @fibers = 1
      @seed = ENV["SEED"]?.try(&.to_u32) || Random.rand(0_u32..0xFFFF_u32)
    end

    def pattern=(pattern : String)
      if pattern =~ %r(\A/(.+?)/\Z)
        @pattern = Regex.new($1)
      else
        @pattern = pattern
      end
    end

    def seed=(seed : String | UInt32)
      @seed = seed.to_u32
    end

    def to_s(io : IO) : Nil
      io << "Run options: --seed "
      seed.to_s(io)

      if verbose?
        io << " --verbose"
      end

      if chaos?
        io << " --chaos"
      end

      if fibers = @fibers
        io << " --parallel "
        fibers.to_s(io)
      end

      if pattern = @pattern
        io << " --name "
        pattern.inspect(io)
      end

      io << "\n"
    end
  end

  def self.options : Options
    @@options ||= Options.new
  end

  def self.process_args(args : Enumerable(String)) : Nil
    OptionParser.parse(args) do |opts|
      opts.banner = "minitest options"

      opts.on("-h", "--help", "Display this help") do
        puts opts
        exit(0)
      end

      opts.on("-s SEED", "--seed SEED", "Sets random seed. Also via SEED environment variable.") do |seed|
        options.seed = seed.to_u32
      end

      opts.on("-v", "--verbose", "Show progress processing files.") do
        options.verbose = true
      end

      opts.on("-p FIBERS", "--parallel FIBERS", "Parallelize runs.") do |fibers|
        options.fibers = fibers.to_i
      end

      opts.on("-c", "--chaos", "Shuffle all tests from all test suites.") do
        options.chaos = true
      end

      opts.on("-n PATTERN", "--name PATTERN", "Filter run on /pattern/ or string.") do |pattern|
        options.pattern = pattern
      end
    end
  end

  class_property reporter : AbstractReporter do
    CompositeReporter.new(options).tap do |reporter|
      reporter << SummaryReporter.new(options)
      reporter << ProgressReporter.new(options)
    end
  end

  def self.run(args = nil) : Bool
    process_args(args) if args
    puts options

    channel = Channel(Array(Runnable::Data) | Runnable::Data | Nil).new(options.fibers * 4)
    completed = Channel(Nil).new

    # makes sure that reporter is initialized before spawning worker fibers:
    raise "BUG: no minitest reporter" unless self.reporter

    options.fibers.times { spawn_worker(channel, completed) }
    reporter.start
    randomize_and_run_tests(channel)
    options.fibers.times { completed.receive }

    reporter.report
    reporter.passed?
  ensure
    after_run.each(&.call)
    reporter.passed?
  end

  private def self.spawn_worker(channel, completed) : Nil
    spawn do
      loop do
        case value = channel.receive?
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

  private def self.randomize_and_run_tests(channel) : Nil
    random = Random::PCG32.new(options.seed.to_u64)

    if options.chaos?
      # collect & shuffle all tests for all suites:
      Runnable.runnables
        .reduce([] of Runnable::Data) { |tests, suite| tests + suite.collect_tests }
        .shuffle!(random)
        .each { |test| channel.send(test) }
    else
      # shufle each suite, then shuffle tests for each suite:
      Runnable.runnables.shuffle!(random).each do |suite|
        suite
          .collect_tests
          .shuffle!(random)
          .each { |test| channel.send(test) }
      end
    end

    channel.close
  end

  def self.after_run : Array(Proc(Nil))
    @@after_run ||= [] of ->
  end

  def self.after_run(&block : ->) : Nil
    after_run << block
  end

  def self.exit(status : Int32 = 1) : NoReturn
    after_run.each(&.call)
    ::exit status
  end
end
