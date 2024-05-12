resource "aws_ecr_repository" "lambda" {
  #checkov:skip=CKV_AWS_51: "Ensure ECR Image Tags are immutable"
  #checkov:skip=CKV_AWS_136: "Ensure that ECR repositories are encrypted using KMS"
  #checkov:skip=CKV_AWS_163: "Ensure ECR image scanning on push is enabled"
  name    = module.label.id
  force_delete = true
  image_tag_mutability = "MUTABLE"
}



