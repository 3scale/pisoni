MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))

include $(PROJECT_PATH)/.env

include $(PROJECT_PATH)/mk/compose.mk
COMPOSE := $(COMPOSE_BIN) -f $(PROJECT_PATH)/docker/docker-compose.yml

CI_IMAGE_REPO ?= quay.io/3scale
CI_IMAGE_NAME ?= pisoni-ci
CI_IMAGE ?= $(CI_IMAGE_REPO)/$(CI_IMAGE_NAME)
CI_DOCKERFILE ?= $(PROJECT_PATH)/docker/Dockerfile.ci

include $(PROJECT_PATH)/mk/ci-image.mk

all: clean pull build test

.PHONY: compose-config
compose-config: compose
	$(COMPOSE) config

.PHONY: test
test: run_test clean

.PHONY: bash
bash: run clean

.PHONY: dev
dev: run

.PHONY: run
run: compose
	$(COMPOSE) run --rm test /bin/bash

.PHONY: run_test
run_test: compose
	$(COMPOSE) run --rm -e COVERAGE=$(COVERAGE) test

.PHONY: license_finder
license_finder: compose
	$(COMPOSE) run --rm -e COVERAGE=$(COVERAGE) test bundle exec rake license_finder:check

.PHONY: build
build: compose
	$(COMPOSE) build

.PHONY: pull
pull: compose
	$(COMPOSE) pull

.PHONY: stop
stop: compose
	$(COMPOSE) stop

.PHONY: clean
clean: stop
	- $(COMPOSE) rm -f -v

.PHONY: up
up: compose
	$(COMPOSE) up --abort-on-container-exit --exit-code-from test -t 2 --remove-orphans

.PHONY: down
down: clean
	- $(COMPOSE) down

.PHONY: destroy
destroy: clean
	$(COMPOSE) down -v --remove-orphans --rmi local

.PHONY: destroy-all
destroy-all: clean
	$(COMPOSE) down -v --remove-orphans --rmi all
