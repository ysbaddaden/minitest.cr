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
    property? junit : String?
    property? color : Bool = Colorize.enabled?

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

      opts.on("-j PATH", "--junit PATH", "Generate junit report") do |path|
        options.junit = path
      end

      opts.on("--color", "Enable ANSI colored output") do
        options.color = true
      end

      opts.on("--no-color", "Disable ANSI colored output") do
        options.color = false
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
      if path = options.junit?
        reporter << JunitReporter.new(path, options)
      end
    end
  end

  def self.run(args = nil) : Bool
    process_args(args) if args
    puts options

    Colorize.enabled = options.color?

    channel = Channel(Array(Runnable::Data) | Runnable::Data | Nil).new(options.fibers * 4)
    completed = Channel(Nil).new

    # makes sure that reporter is initialized before spawning worker fibers:
    raise "BUG: no minitest reporter" unless self.reporter

    {% if Fiber.has_constant?(:ExecutionContext) %}
      workers_count = Fiber::ExecutionContext.default_workers_count

        {% if Fiber::ExecutionContext.has_constant?(:Parallel) %}
          if (execution_context = Fiber::ExecutionContext.current).responds_to?(:resize)
            execution_context.resize(workers_count)
          else
            execution_context = Fiber::ExecutionContext::Parallel.new("MINITEST", workers_count)
          end
        {% else %}
          execution_context = Fiber::ExecutionContext::MultiThreaded.new("MINITEST", workers_count)
        {% end %}
    {% end %}

    options.fibers.times do |i|
      {% if Fiber.has_constant?(:ExecutionContext) %}
        execution_context.spawn(name: "minitest:worker-#{i}") do
          worker_loop(channel, completed)
        end
      {% else %}
        spawn(name: "minitest:worker-#{i}") do
          worker_loop(channel, completed)
        end
      {% end %}
    end
    reporter.start
    randomize_and_run_tests(channel)
    options.fibers.times { completed.receive }

    reporter.report
    reporter.passed?
  ensure
    after_run.each(&.call)
    reporter.passed?
  end

  private def self.worker_loop(channel, completed) : Nil
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

  private def self.randomize_and_run_tests(channel) : Nil
    random = Random::PCG32.new(options.seed.to_u64)

    if options.chaos?
      # collect & shuffle all tests for all suites:
      Runnable.runnables
        .reduce([] of Runnable::Data) { |tests, suite| tests + suite.collect_tests }
        .shuffle!(random)
        .each { |test| channel.send(test) }
    else
      # shuffle each suite, then shuffle tests for each suite:
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
