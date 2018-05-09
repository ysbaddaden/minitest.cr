.POSIX:

CRYSTAL = crystal

test: .phony
	$(CRYSTAL) run test/*_test.cr -- --chaos --parallel 4 --verbose

.phony:
