.POSIX:

CRYSTAL = crystal
CRFLAGS =
OPTS = --chaos --parallel 4 --verbose

test: .phony
	$(CRYSTAL) run $(CRFLAGS) test/*_test.cr -- $(OPTS)

.phony:
