resource "aws_iam_role" "lambda_presign_role" {
  name = "lambda-presign-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "null_resource" "zip_lambda_presign" {
  provisioner "local-exec" {
    command = <<EOT
      cd ${path.module}/lambda && \
      pip install -r requirements.txt -t . && \
      zip -r ../lambda_presign.zip lambda_presign.py .
    EOT
  }
}

resource "aws_lambda_function" "lambda_presign" {
  function_name = "lambda-presign-avatar"
  role          = aws_iam_role.lambda_presign_role.arn
  handler       = "lambda_presign.lambda_handler"
  runtime       = "python3.12"

  filename      = "${path.module}/lambda_presign.zip"

  environment {
    variables = {
      RAW_BUCKET = "avatars-raw"
    }
  }

  depends_on = [
    null_resource.zip_lambda_presign
  ]
}