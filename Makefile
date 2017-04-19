CRYSTAL_BIN ?= = `which crystal`

.PHONY: test

test:
	$(CRYSTAL_BIN) run test/*_test.cr -- --parallel 4 --verbose
	SEED=12345 $(CRYSTAL_BIN) run test/seed_test.cr -- --verbose
