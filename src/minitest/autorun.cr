require "../minitest"

def exit(code : Bool)
  exit code ? 0 : -1
end

at_exit do
  exit_code = Minitest.run
  exit exit_code
end
