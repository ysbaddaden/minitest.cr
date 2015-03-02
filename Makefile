ifndef CRYSTAL_BIN
	CRYSTAL_BIN = `which crystal`
endif

.PHONY: test

test:
	$(CRYSTAL_BIN) test/*_test.cr -- --parallel 4 --verbose

