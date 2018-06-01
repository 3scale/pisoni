define _ci_build_target
.PHONY: $(1)
$(1): export COMPOSE=$(COMPOSE_BIN) -f $(PROJECT_PATH)/docker/docker-compose.ci.yml -f $(PROJECT_PATH)/docker/docker-compose.apisonator.yml
$(1): export CI_IMAGE:=$(CI_IMAGE)
$(1):
	$(MAKE) $(2)
endef

# Arguments:
# 1. New target to create with CI settings
# 2. Existing target to be wrapped by the new target.
define ci_build_target
$(eval $(call _ci_build_target,$(1),$(2)))
endef
