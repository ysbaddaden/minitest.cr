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
    getter seed : UInt32

    def initialize
      @verbose = false
      @threads = 1
      @seed = ENV["SEED"]?.try(&.to_u32) || Random.new_seed
    end

    def pattern=(pattern)
      if pattern =~ %r(\A/(.+?)/\Z)
        @pattern = Regex.new($1)
      else
        @pattern = pattern
      end
    end

    def seed=(@seed)
    end

    def to_s(io)
      io << "Run options: --seed "
      seed.to_s(io)

      if verbose
        io << " --verbose"
      end

      if threads = @threads
        io << " --parallel "
        threads.to_s(io)
      end

      if pattern = @pattern
        io << " --name "
        pattern.to_s(io)
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

  private def self.set_random_seed
    seed = options.seed
    static_array = pointerof(seed).as(StaticArray(UInt8, 4)*).value
    Random::DEFAULT.new_seed(static_array)
  end

  def self.after_run
    @@after_run ||= [] of ->
  end

  def self.after_run(&block)
    after_run << block
  end
end
