require "option_parser"
require "thread"
require "./minitest/result"
require "./minitest/reporter"
require "./minitest/runnable"
require "./minitest/test"

module Enumerable(T)
  def each_slice(count)
    count = count.to_i
    result = [] of Array(T)
    ary :: Array(T)

    each_with_index do |e, i|
      if i % count == 0
        ary = [] of T
        result << ary
      end

      ary << e
    end

    result
  end
end

module Minitest
  @@threads = 1

  def self.options
    @@options ||= { verbose: false }
  end

  def self.process_args(args)
    OptionParser.parse(args) do |opts|
      opts.banner = "minitest options"

      opts.on("-h", "--help", "Display this help") do
        puts opts
        exit
      end

      opts.on("-p THREADS", "--parallel THREADS", "Show progress processing files.") do |threads|
        value = threads.to_i
        @@threads = value if value > 0
      end

      opts.on("-v", "--verbose", "Show progress processing files.") do
        options[:verbose] = true
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
    n = suites.size < @@threads ? suites.size : @@threads
    partitions = suites.each_slice((suites.size / n.to_f).ceil)

    threads = partitions.map do |partition|
      Thread.new { partition.each(&.run(reporter)) }
    end

    threads.each(&.join)

    reporter.report
    reporter.passed?
  end
end
