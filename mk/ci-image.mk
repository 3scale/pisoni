ifeq ($(PROJECT_PATH),)
$(error PROJECT_PATH must be defined.)
endif

ifeq ($(MKFILE_PATH),)
$(error MKFILE_PATH must be defined.)
endif

ifeq ($(CI_IMAGE),)
$(error CI_IMAGE must be defined.)
endif

ifeq ($(CI_DOCKERFILE),)
$(error CI_DOCKERFILE must be defined.)
endif

# DF_VARIANT is used to select a specific CI Dockerfile
export DF_CIEXT := $(if $(DF_VARIANT),-$(DF_VARIANT),$(DF_CIEXT))

CI_DOCKERFILE := $(CI_DOCKERFILE)$(DF_CIEXT)

.PHONY: ci-build
ci-build: RELEASE?=v$(shell ruby -r$(PROJECT_PATH)/lib/3scale/core/version -e "puts ThreeScale::Core::VERSION")
ci-build: CI_REL?=$(RELEASE)$(DF_CIEXT)
ci-build: $(CI_DOCKERFILE)
	docker build -t $(CI_IMAGE):$(CI_REL)-layered $(DOCKER_BUILD_ARGS) -f $(CI_DOCKERFILE) $(PROJECT_PATH)

.PHONY: ci-flatten
ci-flatten: RELEASE?=v$(shell ruby -r$(PROJECT_PATH)/lib/3scale/core/version -e "puts ThreeScale::Core::VERSION")
ci-flatten: CI_REL?=$(RELEASE)$(DF_CIEXT)
ci-flatten: CI_CONTAINER_NAME?=$(shell echo $(CI_IMAGE) | sed -E -e 's/\//_/g')
ci-flatten: CI_USER?=$(shell docker run --rm $(CI_IMAGE):$(CI_REL)-layered whoami)
ci-flatten: CI_PATH?=$(shell docker run --rm $(CI_IMAGE):$(CI_REL)-layered /bin/bash -c "echo \$${PATH}")
ci-flatten: CI_DF_EXTRA_CMDS=$(shell cat $(CI_DOCKERFILE) | grep -E "^(CMD|ENTRYPOINT)\s+" | sed -E -e "s/^(.*)$$/-c '\1'/g")
ci-flatten:
	-docker rm dummy-export-$(CI_CONTAINER_NAME)-$(CI_REL)-layered
	docker run --name dummy-export-$(CI_CONTAINER_NAME)-$(CI_REL)-layered \
		$(CI_IMAGE):$(CI_REL)-layered echo
	(docker export dummy-export-$(CI_CONTAINER_NAME)-$(CI_REL)-layered | \
		docker import -c "USER $(CI_USER)" -c "ENV PATH $(CI_PATH)" \
		$(CI_DF_EXTRA_CMDS) - $(CI_IMAGE):$(CI_REL)) || \
		(echo Failed to flatten image && \
		docker rm dummy-export-$(CI_CONTAINER_NAME)-$(CI_REL)-layered && false)
	-docker rm dummy-export-$(CI_CONTAINER_NAME)-$(CI_REL)-layered

.PHONY: ci-tag
ci-tag: RELEASE?=v$(shell ruby -r$(PROJECT_PATH)/lib/3scale/core/version -e "puts ThreeScale::Core::VERSION")
ci-tag: CI_REL?=$(RELEASE)$(DF_CIEXT)
ci-tag: LATEST?=latest
ci-tag: LATEST:=$(LATEST)$(DF_CIEXT)
ci-tag:
	docker tag $(CI_IMAGE):$(CI_REL)-layered $(CI_IMAGE):$(LATEST)-layered
	docker tag $(CI_IMAGE):$(CI_REL) $(CI_IMAGE):$(LATEST)

.PHONY: ci-push
ci-push: RELEASE?=v$(shell ruby -r$(PROJECT_PATH)/lib/3scale/core/version -e "puts ThreeScale::Core::VERSION")
ci-push: CI_REL?=$(RELEASE)$(DF_CIEXT)
ci-push: LATEST?=latest
ci-push: LATEST:=$(LATEST)$(DF_CIEXT)
ci-push:
	docker push $(CI_IMAGE):$(CI_REL)
	docker push $(CI_IMAGE):$(LATEST)

ci-destroy: RELEASE?=v$(shell ruby -r$(PROJECT_PATH)/lib/3scale/core/version -e "puts ThreeScale::Core::VERSION")
ci-destroy: CI_REL?=$(RELEASE)$(DF_CIEXT)
ci-destroy: LATEST?=latest
ci-destroy: LATEST:=$(LATEST)$(DF_CIEXT)
ci-destroy:
	docker rmi $(CI_IMAGE):$(CI_REL) $(CI_IMAGE):$(CI_REL)-layered \
		$(CI_IMAGE):$(LATEST) $(CI_IMAGE):$(LATEST)-layered
