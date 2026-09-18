output "raw_bucket_name" {
  value = aws_s3_bucket.raw.bucket
}

output "processed_bucket_name" {
  value = aws_s3_bucket.processed.bucket
}

output "lambda_resize_name" {
  value = aws_lambda_function.lambda_resize.function_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}