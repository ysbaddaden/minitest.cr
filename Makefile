CRYSTAL ?= `which crystal`

.PHONY: test

test:
	$(CRYSTAL) run test/*_test.cr -- --parallel 4 --verbose

