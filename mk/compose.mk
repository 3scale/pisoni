ifeq ($(PROJECT_PATH),)
$(error PROJECT_PATH must be defined.)
endif

ifeq ($(COMPOSE_VERSION),)
$(error COMPOSE_VERSION must be defined.)
endif

# DF_VARIANT is used to select a specific Dockerfile
export DF_EXT := $(if $(DF_VARIANT),.$(DF_VARIANT),$(DF_EXT))

VENDORED_COMPOSE_PATH := $(PROJECT_PATH)/.bin/docker-compose-$(COMPOSE_VERSION)

# determine whether we want a system-based docker-compose or a vendored one.
# Make will ensure the COMPOSE variable has the right target and if it's
# a vendored one, it will install it if not available.
ifeq ($(VENDORED_COMPOSE),0)
	COMPOSE_BIN := $(shell which docker-compose 2> /dev/null | tail -n 1)
	ifneq ($(COMPOSE_BIN),)
		ifneq ($(shell $(COMPOSE_BIN) --version | grep -o "version $(COMPOSE_VERSION)"),version $(COMPOSE_VERSION))
$(warning WARNING: $(shell $(COMPOSE_BIN) --version) does not match required version $(COMPOSE_VERSION), use VENDORED_COMPOSE=1 to force usage of a vendored version)
		endif
	endif
endif

ifeq ($(COMPOSE_BIN),)
	COMPOSE_BIN := $(VENDORED_COMPOSE_PATH)
endif

$(PROJECT_PATH)/.bin:
	mkdir -p $(PROJECT_PATH)/.bin

.PHONY: compose
compose: $(COMPOSE_BIN)

$(VENDORED_COMPOSE_PATH): $(PROJECT_PATH)/.bin
	@echo "Vendoring docker-compose $(COMPOSE_VERSION)..."
	curl -f -L https://github.com/docker/compose/releases/download/$(COMPOSE_VERSION)/docker-compose-`uname -s`-`uname -m` > $@
	chmod +x $@
