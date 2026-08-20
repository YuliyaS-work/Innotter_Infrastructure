provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  s3_use_path_style           = true

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3       = "http://localstack.app.svc.cluster.local:4566"
    lambda   = "http://localstack.app.svc.cluster.local:4566"
    iam      = "http://localstack.app.svc.cluster.local:4566"
    sts      = "http://localstack.app.svc.cluster.local:4566"
  }
}