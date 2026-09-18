resource "aws_s3_bucket" "raw" {
  bucket = "avatars-raw"
}

resource "aws_s3_bucket" "processed" {
  bucket = "avatars-processed"
}

resource "aws_s3_bucket_versioning" "raw_versioning" {
  bucket = aws_s3_bucket.raw.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "processed_versioning" {
  bucket = aws_s3_bucket.processed.id

  versioning_configuration {
    status = "Enabled"
  }
}