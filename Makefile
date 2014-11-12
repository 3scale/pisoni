MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))
PROJECT := $(subst @,,$(notdir $(PROJECT_PATH)))
RUN = docker run --rm
NAME = $(PROJECT)-build

.PHONY: test

all: clean build test

test:
	$(PROJECT_PATH)/docker/test $(PROJECT) $(NAME)

pull:
	- docker pull 3scale/ruby:2.1

bash:
	$(RUN) -t -i $(PROJECT) bash

build: pull
	docker build -t $(PROJECT) $(PROJECT_PATH)

clean:
	- docker rm --force $(NAME)

