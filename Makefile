COMPOSE = .bin/docker-compose-$(COMPOSE_VERSION)
COMPOSE_CI = $(COMPOSE) -f docker-compose-ci.yml
COMPOSE_DEV = $(COMPOSE) -f docker-compose-dev.yml
COMPOSE_VERSION = 1.4.0

.PHONY: test

all: clean build test

test: compose
	$(COMPOSE_CI) run --rm -e COVERAGE=$(COVERAGE) test

bash: compose
	$(COMPOSE_DEV) run --rm test bash

build: compose
	$(COMPOSE_CI) build

clean: compose
	- $(COMPOSE_CI) stop
	- $(COMPOSE_CI) rm -f -v

.bin:
	mkdir -p .bin

compose: $(COMPOSE)

$(COMPOSE): .bin
	curl -L https://github.com/docker/compose/releases/download/$(COMPOSE_VERSION)/docker-compose-`uname -s`-`uname -m` > $@
	chmod +x $@
