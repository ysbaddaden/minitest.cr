.POSIX:

CRYSTAL = crystal
CRFLAGS =
TEST_ARGS = --chaos --parallel 4 --verbose

test: .phony
	$(CRYSTAL) run $(CRFLAGS) test/*_test.cr -- $(TEST_ARGS)

.phony:
