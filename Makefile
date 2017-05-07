CRYSTAL_BIN ?= `which crystal`

.PHONY: test

test:
	$(CRYSTAL_BIN) run test/*_test.cr -- --parallel 4 --verbose

