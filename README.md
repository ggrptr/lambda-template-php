# AWS Lambda container template for a PHP 8.3 environment, based on the official al2023 image.
## This is a PoC at the moment, not recommended for production use in its current form.

### Overview
This project aims to provide a simple PoC for a PHP lambda function that uses a docker image as runtime.
For the sake of simplicity, and mainly for ease of testing, the infrastructure and application code 
are not separated to separate repositories, allowing the entire solution to be installed and tested 
with a single make command.

There are only two requirements for testing this project: 
* docker support on your computer 
* an AWS account.

### Building and testing 

#### Building the Docker image

The project takes advantage of the fact that AWS lambda supports custom Docker images as a runtime environment, 
and provides a base image that can be used as a starting point for that.
The Dockerfile in this project extends the public.ecr.aws/lambda/provided:al2023 image with PHP 8.2 runtime and
copies the bootstrap file, and source code to the folders where the lambda runtime expects them.
The command to build the image is:
```shell
make build
```

#### Testing locally
After building the image, you can test it locally by running the container and sending a POST request to the 9000 port.
Both of these steps can be done with make targets:
```shell
make run-local
```
and in another terminal:
```shell
make call-local
```
After the call, you should see the output of the lambda function in the terminal where the container 
is running, and the response in the output of the caller target will be displayed.

If the AWS_LAMBDA_RUNTIME_API environment variable is not set, the container will run the
[AWS Lambda Runtime Interface Emulator](https://github.com/aws/aws-lambda-runtime-interface-emulator).
This emulator starts a lightweight HTTP server that listens for invocation requests from the AWS Lambda service 
and invokes the function handler.
So, in this environment, you can test the lambda function itself, without the bootstrap and polling logic.

#### Upload, testing in  aws

---
**Note:**

If you are not familiar with terraform: is it important to know that when the resources are created, 
the identifiers and parameters of the resources (in this simple configuration) are stored in a terraform.state 
file under the iac folder. 

**Complete teardown of all created resources is only possible if this file is available and matches the online state.**

So, it is important not to edit or delete this file manually, and not to modify the resources on the AWS console.

---

To deploy the lambda function to the cloud, you have to proceed with the following steps:
1. Build the image
2. Upload the image to a container registry
3. Create a lambda function that uses the uploaded image

The first step is already done in the previous section, so we can proceed with next.
In the iac folder, there's a terraform configuration that creates an ECR repository, and a lambda function.
I want to keep it a simple terraform module with one state file, so the same configuration handles both resources.
The complicated part is that the lambda function have to download the image at creation time,
so we have to break up the infrastructure creation into two steps, and upload the image between them:

1. Create the ECR repository with applying the terraform configuration without the create_lambda variable set.
2. Upload the previously built image to this repository.
3. Apply the terraform configuration again, but now with the create_lambda variable set to true, so the lambda function will be created.

**A more detailed documentation of the terraform workflow can be found in the iac folder.**

##### Providing access to the AWS account
In the next steps, we have to modify the resources in your AWS account, so you have to provide the necessary configuration 
by setting the following environment variables on the host where the make targets will be executed:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_SESSION_TOKEN
- AWS_REGION

You can find help on how to get these values in the [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html).

##### Creating the infrastructure
###### You can do the whole deployment with a single make command:
```shell
make terraform-deploy
```

###### Or run the steps separately:

Initializing the Terraform configuration
```shell
make terraform-init
```

Preparing the ECR repository
```shell
make terraform-ecr
```

Uploading the image to the ECR repository
```shell
make upload-image
```
Creating the lambda function
```shell
make terraform-lambda
```

##### Testing the uploaded function
After the lambda function is created, you can test it by invoking it with the following command:
```shell
make aws-call
```
This will invoke the function with the aws cli and print the response to the terminal.

#### Destroying the infrastructure
When you are done with the testing, you can destroy the resources with the following command:
```shell
make terraform-destroy
```

This will use the terraform state file to identify and delete all resources created by the configuration.

#### Utilities
There are two additional make targets that can be used to check the code (and iac) against best practices:

Checkov is a static code analysis tool for infrastructure as code that can be used to find security and compliance 
issues in the terraform configuration, and the Dockerfile.
```shell
make checkov 
```

PHPStan is for PHP, it can find bugs and risky code.
```shell
make phpstan
```