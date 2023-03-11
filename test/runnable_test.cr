require "../src/autorun"

class RunnableTest < Minitest::Test
  BINARY_PATH = File.expand_path("runnable_#{Random::Secure.hex(3)}_test", __DIR__)
  SOURCE_PATH = BINARY_PATH + ".cr"

  {% if flag?(:interpreted) %}
    def setup
      skip "Process doesn't work in the Crystal interpreter (the VM waits forever for SIGCHLD)"
    end
  {% else %}
    begin
      File.write(SOURCE_PATH, <<-CRYSTAL)
      require "../src/autorun"

      class ABCTest < Minitest::Test
        def test_success
          assert true
        end

        def test_another_success
          refute false
        end

        def test_error
          raise "oopsie"
        end

        def test_skip
          skip
        end

        def test_skip_message
          skip "it doesn't work"
        end

        def test_skip_symbol
          skip :not_implemented
        end

        def test_flunk
          flunk
        end

        def test_flunk_message
          flunk "it crashes randomly"
        end

        def test_flunk_symbol
          flunk :todo
        end
      end

      describe "ABC" do
        it "success" do
          assert true
        end

        it "fails" do
          refute true
        end
      end
      CRYSTAL

      crystal = ENV.fetch("CRYSTAL", "crystal")
      args = ["build", SOURCE_PATH, "-o", BINARY_PATH]
      stderr = IO::Memory.new

      unless Process.run(crystal, args).success?
        STDERR.puts "Failed to build runnable test:"
        STDERR.puts stderr.rewind.to_s
        Minitest.exit(1)
      end
    end

    Minitest.after_run do
      File.delete(BINARY_PATH) if File.exists?(BINARY_PATH)
      File.delete(SOURCE_PATH) if File.exists?(SOURCE_PATH)
    end
  {% end %}

  def test_runs_all_tests
    stdout = execute("--verbose", pass: false)
    assert_match /ABCTest#test_success = [\d.]+ s = \e\[32m\./, stdout
    assert_match /ABCTest#test_another_success = [\d.]+ s = \e\[32m\./, stdout
    assert_match /ABCTest#test_skip = [\d.]+ s = \e\[33mS/, stdout
    assert_match /ABCTest#test_flunk = [\d.]+ s = \e\[41mF/, stdout
    assert_match /ABCTest#test_error = [\d.]+ s = \e\[41mE/, stdout
    assert_match /ABC#test_success = [\d.]+ s = \e\[32m\./, stdout
    assert_match /ABC#test_fails = [\d.]+ s = \e\[41mF/, stdout
    assert_match "11 tests, 4 failures, 1 errors, 3 skips", stdout
  end

  def test_runs_tests_randomly
    a = execute("--verbose", pass: false).split('\n').compact_map { |l| $1 if l =~ /(ABCTest#test_.+?) = / }
    b = execute("--verbose", pass: false).split('\n').compact_map { |l| $1 if l =~ /(ABCTest#test_.+?) = / }
    refute_equal a, b
  end

  def test_runs_tests_in_explicit_order
    a = execute("--seed", "12345", "--verbose", pass: false).split('\n').compact_map { |l| $1 if l =~ /(ABCTest#test_.+?) = / }
    b = execute("--seed", "12345", "--verbose", pass: false).split('\n').compact_map { |l| $1 if l =~ /(ABCTest#test_.+?) = / }
    assert_equal a, b
  end

  def test_reports_exceptions
    stdout = execute("--verbose", pass: false)
    assert_match /ABCTest#test_error = [\d.]+ s = \e\[41mE/, stdout
    assert_match "Exception: oopsie\n", stdout
    assert_match /test\/runnable_.+_test.cr:\d+:\d+ in 'test_error'/, stdout
  end

  def test_skip
    stdout = execute("--name", "/skip/", "--verbose", pass: true)
    assert_match /ABCTest#test_skip = [\d.]+ s = \e\[33mS/, stdout
    assert_match /ABCTest#test_skip_message = [\d.]+ s = \e\[33mS/, stdout
    assert_match /ABCTest#test_skip_symbol = [\d.]+ s = \e\[33mS/, stdout

    assert_match "not_implemented\n", stdout
    assert_match "it doesn't work\n", stdout
  end

  def test_flunk
    stdout = execute("--name", "/flunk/", "--verbose", pass: false)
    assert_match /ABCTest#test_flunk = [\d.]+ s = \e\[41mF/, stdout
    assert_match /ABCTest#test_flunk_message = [\d.]+ s = \e\[41mF/, stdout
    assert_match /ABCTest#test_flunk_symbol = [\d.]+ s = \e\[41mF/, stdout

    assert_match "todo\n", stdout
    assert_match "it crashes randomly\n", stdout
  end

  def test_filters_by_exact_pattern
    stdout = execute("--name", "test_success", "--verbose", pass: true)
    assert_match /ABCTest#test_success = [\d.]+ s = \e\[32m\./, stdout
    refute_match /ABCTest#test_another_success = [\d.]+ s = \e\[32m\./, stdout
    refute_match /ABCTest#test_skip = [\d.]+ s = \e\[33mS/, stdout
    refute_match /ABCTest#test_flunk = [\d.]+ s = \e\[41mF/, stdout
    refute_match /ABCTest#test_error = [\d.]+ s = \e\[41mE/, stdout
    assert_match /ABC#test_success = [\d.]+ s = \e\[32m\./, stdout
    refute_match /ABC#test_fails = [\d.]+ s = \e\[41m\F/, stdout
    assert_match "2 tests, 0 failures, 0 errors, 0 skips", stdout
  end

  def test_filters_by_regex_pattern
    stdout = execute("--name", "/success/", "--verbose", pass: true)
    assert_match /ABCTest#test_success = [\d.]+ s = \e\[32m\./, stdout
    assert_match /ABCTest#test_another_success = [\d.]+ s = \e\[32m\./, stdout
    refute_match /ABCTest#test_skip = [\d.]+ s = \e\[33mS/, stdout
    refute_match /ABCTest#test_flunk = [\d.]+ s = \e\[41mF/, stdout
    refute_match /ABCTest#test_error = [\d.]+ s = \e\[41mE/, stdout
    assert_match /ABC#test_success = [\d.]+ s = \e\[32m\./, stdout
    refute_match /ABC#test_fails = [\d.]+ s = \e\[41m\F/, stdout
    assert_match "3 tests, 0 failures, 0 errors, 0 skips", stdout
  end

  def execute(*args, pass = true)
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    rs = Process.run(BINARY_PATH, args, output: stdout, error: stderr)
    if pass
      assert rs.success?, "expected run to pass, but it failed:\n#{stderr.rewind.to_s}"
    else
      refute rs.success?, "expected run to fail, but it passed"
    end

    stdout.rewind
    stdout.to_s
  end
end
