MOCHA_OPTS = --check-leaks --compilers coffee:coffee-script --colors
REPORTER = dot
CS_OPT = -c -b -o lib

check: test

build:
	@./node_modules/.bin/coffee \
		$(CS_OPT) \
		src

test: test-unit

test-unit:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--reporter $(REPORTER) \
		$(MOCHA_OPTS)

test-cov: build lib-cov
	@EXPRESS_COV=1 $(MAKE) test REPORTER=html-cov > coverage.html

lib-cov:
	@jscoverage lib lib-cov

clean:
	rm -f coverage.html
	rm -fr lib-cov

.PHONY: build test test-unit clean