COMPOSE ?= podman-compose

.PHONY: deps_up
deps_up:
	$(COMPOSE) up -d

.PHONY: deps_down
deps_down:
	- $(COMPOSE) down

.PHONY: run_test
run_test:
	THREESCALE_CORE_INTERNAL_API=http://user:password@localhost:3001 bundle exec rake test

.PHONY: test
test: deps_up run_test deps_down

.PHONY: license_finder
license_finder:
	$(COMPOSE) run --rm -e COVERAGE=$(COVERAGE) pisoni bundle exec rake license_finder:check

.PHONY: stop
stop:
	$(COMPOSE) stop
