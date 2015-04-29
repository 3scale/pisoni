MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))
PROJECT := $(subst @,,$(notdir $(PROJECT_PATH)))
RUN = docker run --rm
NAME = $(PROJECT)-build

.PHONY: test

all: clean build test

test:
	$(RUN) --name $(NAME) $(PROJECT)

bash:
	$(RUN) -t -i $(PROJECT) bash

build:
	docker build -f Dockerfile.ci -t $(PROJECT) .

clean:
	- docker rm --force $(NAME)
