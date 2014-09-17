PROJECT := $(subst @,,$(notdir $(shell pwd)))
RUN = docker run --rm
NAME = $(PROJECT)-build

.PHONY: test

all: clean build test

test:
	$(RUN) --name $(NAME) $(PROJECT)
pull:
	- docker pull 3scale/ruby:2.1

bash:
	$(RUN) -t -i $(PROJECT) bash

build: pull
	docker build -t $(PROJECT) .

clean:
	- docker rm --force $(NAME)
