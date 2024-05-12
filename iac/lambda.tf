data "aws_iam_policy_document" "lambda-assume-role" {
  count = var.create_lambda ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  count = var.create_lambda ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role[0].json
  name               = module.label.id
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count = var.create_lambda ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda[0].name
}

resource "aws_lambda_function" "php-example" {
  count = var.create_lambda ? 1 : 0
  timeout = 5
  memory_size = 128
  #reserved_concurrent_executions = 1
  function_name = module.label.id
  role          = aws_iam_role.lambda[0].arn
  image_uri     = "${aws_ecr_repository.lambda.repository_url}:${var.lambda_image_tag}"
  package_type = "Image"
}
