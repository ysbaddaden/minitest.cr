.POSIX:

CRYSTAL = crystal
CRFLAGS =
OPTS = --chaos --verbose

test: .phony
	$(CRYSTAL) run $(CRFLAGS) test/*_test.cr -- $(OPTS)

.phony:
