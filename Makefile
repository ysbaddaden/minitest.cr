CRYSTAL ?= `which crystal`

.PHONY: test

test:
	$(CRYSTAL) run test/*_test.cr -- --chaos --parallel 4 --verbose

