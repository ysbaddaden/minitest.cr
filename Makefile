CRYSTAL_BIN ?= = `which crystal`

.PHONY: test

test:
	$(CRYSTAL_BIN) test/*_test.cr -- --parallel 4 --verbose

