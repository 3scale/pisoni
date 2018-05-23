MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))

COMPOSE_VERSION := 1.17.1
VENDORED_COMPOSE_PATH := $(PROJECT_PATH)/.bin/docker-compose-$(COMPOSE_VERSION)

# determine whether we have a system-based docker-compose or a vendored one.
# Make will ensure the COMPOSE variable has the right target and if it's
# a vendored one, it will install it if not available.
ifneq ($(VENDORED_COMPOSE),1)
	COMPOSE := $(shell which docker-compose 2> /dev/null | tail -n 1)
	ifneq ($(COMPOSE),)
		ifneq ($(shell $(COMPOSE) --version | grep -o "version $(COMPOSE_VERSION)"),version $(COMPOSE_VERSION))
$(warning WARNING: $(shell $(COMPOSE) --version) does not match required version $(COMPOSE_VERSION), use VENDORED_COMPOSE=1 to force usage of a vendored version)
		endif
	else
		COMPOSE :=
	endif
endif

ifeq ($(COMPOSE),)
	COMPOSE := $(VENDORED_COMPOSE_PATH)
endif

COMPOSE_CI = $(COMPOSE) -f docker-compose-ci.yml
COMPOSE_DEV = $(COMPOSE) -f docker-compose-dev.yml

.PHONY: test bash run run_test build pull clean clean_test compose

all: clean_test pull build test

test: run_test clean_test

bash: run clean

run: compose
	$(COMPOSE_DEV) run --rm test bash

run_test: compose
	$(COMPOSE_CI) run --rm -e COVERAGE=$(COVERAGE) test

license_finder: compose
	$(COMPOSE_CI) run --rm -e COVERAGE=$(COVERAGE) test bundle exec rake license_finder:check

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

$(PROJECT_PATH)/.bin:
	mkdir -p $(PROJECT_PATH)/.bin

compose: $(COMPOSE)

$(VENDORED_COMPOSE_PATH): $(PROJECT_PATH)/.bin
	@echo "Vendoring docker-compose $(COMPOSE_VERSION)..."
	curl -f -L https://github.com/docker/compose/releases/download/$(COMPOSE_VERSION)/docker-compose-`uname -s`-`uname -m` > $@
	chmod +x $@
