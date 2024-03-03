COMPOSE ?= podman-compose

all: clean pull build test

.PHONY: test
test: run_test clean

.PHONY: bash
bash: run clean

.PHONY: dev
dev: run

.PHONY: run
run:
	$(COMPOSE) run --rm test /bin/bash

.PHONY: run_test
run_test:
	$(COMPOSE) run --rm -e COVERAGE=$(COVERAGE) test

.PHONY: license_finder
license_finder:
	$(COMPOSE) run --rm -e COVERAGE=$(COVERAGE) pisoni bundle exec rake license_finder:check

.PHONY: build
build:
	$(COMPOSE) build

.PHONY: pull
pull:
	$(COMPOSE) pull

.PHONY: stop
stop:
	$(COMPOSE) stop

.PHONY: clean
clean:
	- $(COMPOSE) rm -f -v

.PHONY: up
up:
	$(COMPOSE) up --abort-on-container-exit --exit-code-from pisoni -t 2 --remove-orphans

.PHONY: down
down: clean
	- $(COMPOSE) down

.PHONY: destroy
destroy: clean
	$(COMPOSE) down -v --remove-orphans --rmi local

.PHONY: destroy-all
destroy-all: clean
	$(COMPOSE) down -v --remove-orphans --rmi all
