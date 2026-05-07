provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "sctp-ce12-tfstate-bucket"
    key    = "3.2/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

resource "aws_s3_bucket" "s3_tf" {
  bucket_prefix = "charissa-"

  # checkov:skip=CKV2_AWS_62: Event notifications are not required for this use case.
  # checkov:skip=CKV_AWS_144: Cross-region replication is not required for this dev/test bucket to minimize costs.
}

resource "aws_s3_bucket_public_access_block" "s3_tf_pab" {
  bucket                  = aws_s3_bucket.s3_tf.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_tf_versioning" {
  bucket = aws_s3_bucket.s3_tf.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_tf_encryption" {
  bucket = aws_s3_bucket.s3_tf.id

  rule {
    apply_server_side_encryption_by_default {
      # This alias points to the default KMS key for S3 in your account
      kms_master_key_id = "alias/aws/s3"
      sse_algorithm     = "aws:kms"
    }
    # This ensures the bucket uses the KMS key for all new objects
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_tf_lifecycle" {
  bucket = aws_s3_bucket.s3_tf.id

  rule {
    id     = "cleanup-and-abort-failed-uploads"
    status = "Enabled"
    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_logging" "s3_tf_logging" {
  bucket = aws_s3_bucket.s3_tf.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket" "log_bucket" {
  bucket_prefix = "charissa-logs-"
}

resource "aws_s3_bucket_ownership_controls" "log_bucket_oc" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}