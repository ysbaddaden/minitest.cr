require "../src/autorun"

class FocusTest < Minitest::Test
  BINARY_PATH = File.expand_path("focus_#{Random::Secure.hex(3)}_test", __DIR__)
  SOURCE_PATH = BINARY_PATH + ".cr"

  begin
    File.write(SOURCE_PATH, <<-CRYSTAL)
    require "../src/autorun"
    require "../src/focus"

    class FocusTest < Minitest::Test
      focus def test_will_run
      end

      def test_wont_run
      end

      focus def test_will_also_run
      end

      def test_wont_run_too
      end
    end

    describe "Focus" do
      it "shall run", focus: true do
        assert true
      end

      it "shall not run" do
        refute true
      end
    end
    CRYSTAL

    crystal = ENV.fetch("CRYSTAL", "crystal")
    args = ["build", SOURCE_PATH, "-o", BINARY_PATH]
    stderr = IO::Memory.new

    unless Process.run(crystal, args).success?
      STDERR.puts "Failed to build focus test:"
      STDERR.puts stderr.rewind.to_s
      Minitest.exit(1)
    end
  end

  Minitest.after_run do
    File.delete(BINARY_PATH) if File.exists?(BINARY_PATH)
    File.delete(SOURCE_PATH) if File.exists?(SOURCE_PATH)
  end

  def test_runs_only_focused_tests
    stdout = execute("--verbose", pass: true)

    assert_match /FocusTest#test_will_run = [\d.]+ s = \e\[32m\./, stdout
    assert_match /FocusTest#test_will_also_run = [\d.]+ s = \e\[32m\./, stdout
    refute_match /FocusTest#test_wont_run = [\d.]+ s = \e\[32m\./, stdout
    refute_match /FocusTest#test_wont_run_too = [\d.]+ s = \e\[41m\./, stdout

    assert_match /Focus#test_shall_run = [\d.]+ s = \e\[32m\./, stdout
    refute_match /Focus#test_shall_not_run = [\d.]+ s = \e\[41m\./, stdout

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
