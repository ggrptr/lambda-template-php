FROM public.ecr.aws/lambda/provided:al2023
LABEL maintainer="Peter Geiger <mail@geigerpeter.hu>"

# checkov:skip=CKV_DOCKER_2: "Ensure that HEALTHCHECK instructions have been added to container images"
# checkov:skip=CKV_DOCKER_3: "Ensure that a user for the container has been created"

#https://aws.amazon.com/blogs/apn/aws-lambda-custom-runtime-for-php-a-practical-example/
RUN dnf update -y && \
	dnf install -y php8.2-cli composer unzip && \
    dnf clean all && \
    rm -rf /var/cache/yum

COPY bootstrap ${LAMBDA_RUNTIME_DIR}/bootstrap
RUN chmod +x ${LAMBDA_RUNTIME_DIR}/bootstrap

WORKDIR ${LAMBDA_TASK_ROOT}
# The order of the following commands is important,
# because the dependencies are not changing frequently
# so it will be cached between changes
COPY composer.*  phpstan.neon ${LAMBDA_TASK_ROOT}/
RUN composer install --no-dev

COPY src ${LAMBDA_TASK_ROOT}/src

#RUN useradd -m lambdarunner
#USER lambdarunner
CMD [ "index.handler" ]