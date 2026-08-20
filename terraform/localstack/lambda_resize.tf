# IAM Role for Lambda
resource "aws_iam_role" "lambda_resize_role" {
  name = "lambda-resize-role"

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

# Lambda Function
resource "aws_lambda_function" "lambda_resize" {
  function_name = "lambda-resize-avatar"
  role          = aws_iam_role.lambda_resize_role.arn
  handler       = "lambda_resize.lambda_handler"
  runtime       = "python3.12"

  filename         = "${path.module}/lambda_resize.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_resize.zip")

  environment {
    variables = {
      RAW_BUCKET       = "avatars-raw"
      PROCESSED_BUCKET = "avatars-processed"
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.lambda_subnet_a.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

# Lambda Alias (dev)
resource "aws_lambda_alias" "lambda_resize_dev" {
  name             = "dev"
  function_name    = aws_lambda_function.lambda_resize.function_name
  function_version = aws_lambda_function.lambda_resize.version
}


# Lambda Permission for S3
resource "aws_lambda_permission" "allow_s3_resize" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_resize.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}


# S3 Event Notification → Lambda
resource "aws_s3_bucket_notification" "raw_bucket_notification" {
  bucket = aws_s3_bucket.raw.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_resize.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "users/avatar/"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_resize
  ]
}

# IAM Policy for Lambda S3 Access
resource "aws_iam_role_policy" "lambda_resize_s3_policy" {
  role = aws_iam_role.lambda_resize_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.raw.arn}/*",
          "${aws_s3_bucket.processed.arn}/*",
          aws_s3_bucket.raw.arn,
          aws_s3_bucket.processed.arn
        ]
      }
    ]
  })
}


# Lambda Function
resource "aws_lambda_function" "lambda_resize" {
  function_name = "lambda-resize-avatar"
  role          = aws_iam_role.lambda_resize_role.arn
  handler       = "lambda_resize.lambda_handler"
  runtime       = "python3.12"

  filename         = "${path.module}/lambda_resize.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_resize.zip")

  environment {
    variables = {
      RAW_BUCKET       = "avatars-raw"
      PROCESSED_BUCKET = "avatars-processed"
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.lambda_subnet_a.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

# Lambda Alias (dev)
resource "aws_lambda_alias" "lambda_resize_dev" {
  name             = "dev"
  function_name    = aws_lambda_function.lambda_resize.function_name
  function_version = aws_lambda_function.lambda_resize.version
}


# Lambda Permission for S3
resource "aws_lambda_permission" "allow_s3_resize" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_resize.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}


# S3 Event Notification → Lambda
resource "aws_s3_bucket_notification" "raw_bucket_notification" {
  bucket = aws_s3_bucket.raw.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_resize.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "users/avatar/"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_resize
  ]
}

# IAM Policy for Lambda S3 Access
resource "aws_iam_role_policy" "lambda_resize_s3_policy" {
  role = aws_iam_role.lambda_resize_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.raw.arn}/*",
          "${aws_s3_bucket.processed.arn}/*",
          aws_s3_bucket.raw.arn,
          aws_s3_bucket.processed.arn
        ]
      }
    ]
  })
}