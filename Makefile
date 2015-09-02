COMPOSE = docker-compose
COMPOSE_CI = $(COMPOSE) -f docker-compose-ci.yml
COMPOSE_DEV = $(COMPOSE) -f docker-compose-dev.yml

.PHONY: test

all: clean build test

test:
	$(COMPOSE_CI) run --rm -e COVERAGE=$(COVERAGE) test

bash:
	$(COMPOSE_DEV) run --rm test bash

build:
	$(COMPOSE_CI) build

clean:
	- $(COMPOSE_CI) stop
	- $(COMPOSE_CI) rm -f -v
