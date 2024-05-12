TARGET_IMAGE_NAME=aws-lambda-php
TARGET_IMAGE_TAG=latest

CHECKOV_IMAGE:=bridgecrew/checkov:3.2.74
AWS_CLI_IMAGE:=public.ecr.aws/aws-cli/aws-cli:2.2.47

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
WORKDIR=$(shell realpath --relative-to=${ROOT_DIR} $(realpath .))
TTY_MODE=-it


define _run_in_container
	$(eval IMAGE:=$1)
	$(eval PARAMS:=$2)
	$(eval COMMAND:=$3)
	docker run --rm  ${TTY_MODE} \
	-v ${ROOT_DIR}:${ROOT_DIR} \
	-w ${ROOT_DIR}/${WORKDIR} -u $$(id -u):$$(id -g) \
	${PARAMS} \
	${IMAGE} \
	${COMMAND}
endef

define _run_in_container_with_aws_access
	$(eval IMAGE:=$1)
    $(eval PARAMS:=$2 -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -e AWS_REGION)
    $(eval COMMAND:=$3)
	$(call _run_in_container,${IMAGE},${PARAMS},${COMMAND})
endef

.PHONY: build
build:
	docker build -t ${TARGET_IMAGE_NAME}:${TARGET_IMAGE_TAG}  .

.PHONY: run-local
run-local:
	 docker run --rm -p 9000:8080 ${TARGET_IMAGE_NAME}:${TARGET_IMAGE_TAG}

.PHONY: call-local
call-local:
	curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"name": "Peter"}'

.PHONY: terraform-init
terraform-init:
	cd iac && make terraform init

.PHONY: terraform-ecr
terraform-ecr:
	cd iac && \
	eval make terraform apply

.PHONY: image-upload
image-upload:
	$(eval REPOSITORY_URL:=$(shell cd iac && make terraform output -- ecr_repository_url))
	$(call _run_in_container_with_aws_access,${AWS_CLI_IMAGE},,  ecr get-login-password) \
	| docker login --username AWS --password-stdin ${REPOSITORY_URL}
	docker tag ${TARGET_IMAGE_NAME}:${TARGET_IMAGE_TAG} ${REPOSITORY_URL}:${TARGET_IMAGE_TAG}
	docker push ${REPOSITORY_URL}:${TARGET_IMAGE_TAG}


.PHONY: terraform-lambda
terraform-lambda:
	cd iac && make terraform apply  -- "-var create_lambda=true --var lambda_image_tag=${TARGET_IMAGE_TAG}"

.PHONY: terraform-destroy
terraform-destroy:
	cd iac && make terraform destroy

.PHONY: terraform-deploy
terraform-deploy: build terraform-init terraform-ecr image-upload terraform-lambda

.PHONY: aws-call
aws-call:
	$(eval PAYLOAD:=$(shell echo '{"name":"Peter"}' | base64))
	echo ${PAYLOAD}
	$(call _run_in_container_with_aws_access,\
	${AWS_CLI_IMAGE},,lambda invoke --function-name "ggrptr-php-lambda-example" --payload '${PAYLOAD}' /dev/stdout)

.PHONY: checkov
checkov:
	$(call _run_in_container,${CHECKOV_IMAGE}, )

.PHONY: phpstan
phpstan:
	 $(call _run_in_container,${TARGET_IMAGE_NAME}:${TARGET_IMAGE_TAG},\
 		--entrypoint "/bin/bash", \
 		-c "composer install && vendor/bin/phpstan analyze -v --memory-limit=512M")