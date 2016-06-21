COMPOSE = .bin/docker-compose-$(COMPOSE_VERSION)
COMPOSE_CI = $(COMPOSE) -f docker-compose-ci.yml
COMPOSE_DEV = $(COMPOSE) -f docker-compose-dev.yml
COMPOSE_VERSION = 1.7.1

.PHONY: test bash run run_test build pull clean clean_test compose

all: clean_test pull build test

test: run_test clean_test

bash: run clean

run: compose
	$(COMPOSE_DEV) run --rm test bash

run_test: compose
	$(COMPOSE_CI) run --rm -e COVERAGE=$(COVERAGE) test

build: compose
	$(COMPOSE_CI) build

pull: compose
	$(COMPOSE_CI) pull

clean: compose
	- $(COMPOSE_DEV) stop
	- $(COMPOSE_DEV) rm -f -v

clean_test: compose
	- $(COMPOSE_CI) stop
	- $(COMPOSE_CI) rm -f -v

.bin:
	mkdir -p .bin

compose: $(COMPOSE)

$(COMPOSE): .bin
	curl -L https://github.com/docker/compose/releases/download/$(COMPOSE_VERSION)/docker-compose-`uname -s`-`uname -m` > $@
	chmod +x $@
