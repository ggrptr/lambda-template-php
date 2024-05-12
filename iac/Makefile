# To run any command in a subdirectory, use the -e WORKDIR=<subdir> option, for example:
# make -e WORKDIR=examples init

TERRAFORM_IMAGE:=hashicorp/terraform:1.8.1
TFLINT_IMAGE:=ghcr.io/terraform-linters/tflint:v0.49.0
CHECKOV_IMAGE:=bridgecrew/checkov:3.1.11
TERRAFORM_DOCS_IMAGE:=ggrptr/terraform-docs:latest
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
WORKDIR=$(shell realpath --relative-to=${ROOT_DIR} $(realpath .))
TTY_MODE=-it

define _run_in_container
	@docker run --rm  ${TTY_MODE} \
	-e AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY \
	-e AWS_SESSION_TOKEN \
	-e AWS_REGION \
	-v ${ROOT_DIR}:${ROOT_DIR} -w ${ROOT_DIR}/${WORKDIR} -u $$(id -u):$$(id -g) ${IMAGE} $1

endef

.PHONY: terraform-docs
terraform-docs:
	$(eval IMAGE:=${TERRAFORM_DOCS_IMAGE})
	$(call _run_in_container, markdown --output-file=README.md .)

.PHONY: tflint
tflint:
	$(eval IMAGE:=${TFLINT_IMAGE})
	$(call _run_in_container)

.PHONY: checkov
checkov:
	$(eval IMAGE:=${CHECKOV_IMAGE})
	$(call _run_in_container)

.PHONY: terraform
terraform:
	@$(eval IMAGE:=${TERRAFORM_IMAGE})
	$(call _run_in_container,$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)))

.PHONY: %
%:
	@true
