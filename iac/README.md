# Terraform configuration for the PHP lambda example
[![License](https://img.shields.io/badge/license-MIT-%233DA639.svg)](https://opensource.org/licenses/MIT)

---
**NOTE**
This is a PoC for a PHP lambda function that uses a custom runtime, do not use in production
---

## Summary of the configuration 
The module operates in two modes:

* If the create_lambda variable is set to false, it will bypass the creation of the lambda function and its 
dependencies, only creating the ECR repository.
* If the create_lambda variable is set to true, the entire configuration is applied, including all resources.

These two modes are necessary to maintain the Infrastructure as Code (IAC) within a single, straightforward 
module. This is because the lambda function requires the URL of the uploaded image. Therefore, the image must be uploaded to the ECR repository after the ECR repository is created but before the lambda function is created.

## How to use this configuration

There are two requirements to use this configuration:
* An AWS account with the necessary permissions to create the resources
* Docker installed on the machine where the configuration is executed

### Validation 
To validate the configuration, run the following commands.
All of these will run in docker containers, so there is no need to install any dependencies.

```shell
make terraform init
```
This will prepare the module, downloading the necessary providers and modules.

```shell
make terraform validate
```
The built-in terraform tool for validating the configuration syntax and structure.

```shell
make tflint
```
Will run the linter to check for common errors and best practices doesn't covere by the built-in validation.

```shell
make checkov
```
Will run the [checkov(https://www.checkov.io)] tool to check not only for errors and best practices but also for security issues.

```shell
make terraform-docs 
```
Regenerates this documentation file based on the configuration files.

### Applying the configuration
Before applying (or destroying) the configuration it is neccessary to provide the following environment variables:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_SESSION_TOKEN
- AWS_REGION

The docker container that will access the AWS api imports these variables from the host.
The configuration can be applied with the following commands:

```shell
make terraform plan
```
Will make a dry-run of the configuration, showing what resources will be created, updated, or destroyed.

```shell
make terraform apply
```
Will apply the configuration, creating the resources in the AWS account.

```shell
make terraform destroy
```
Will destroy all resources created by the configuration.

---
**NOTE**
For detailed information about these commands, check this project:
https://github.com/ggrptr/terraform-module-template
---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.16.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.26.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | git::https://github.com/cloudposse/terraform-null-label | 488ab91e34a24a86957e397d9f7262ec5925586a |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.lambda](https://registry.terraform.io/providers/hashicorp/aws/5.26.0/docs/resources/ecr_repository) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/5.26.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/5.26.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.php-example](https://registry.terraform.io/providers/hashicorp/aws/5.26.0/docs/resources/lambda_function) | resource |
| [aws_iam_policy_document.lambda-assume-role](https://registry.terraform.io/providers/hashicorp/aws/5.26.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Object wrapper for the context map of the null label module. See the null label module for more information. | <pre>object({<br>    enabled             = optional(bool, true)<br>    namespace           = optional(string, null)<br>    tenant              = optional(string, null)<br>    environment         = optional(string, null)<br>    stage               = optional(string, null)<br>    name                = optional(string, null)<br>    delimiter           = optional(string, null)<br>    attributes          = optional(list(string), [])<br>    tags                = optional(map(string), {})<br>    additional_tag_map  = optional(map(string), {})<br>    regex_replace_chars = optional(string, null)<br>    label_order         = optional(list(string), [])<br>    id_length_limit     = optional(number, null)<br>    label_key_case      = optional(string, null)<br>    label_value_case    = optional(string, null)<br>    descriptor_formats  = optional(map(string), {})<br>    labels_as_tags      = optional(list(string), ["unset"])<br>  })</pre> | n/a | yes |
| <a name="input_create_lambda"></a> [create\_lambda](#input\_create\_lambda) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | n/a |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | n/a |
<!-- END_TF_DOCS -->