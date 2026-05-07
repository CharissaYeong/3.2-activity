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

  # checkov:skip=CKV_AWS_144: Cross-region replication not required for cost reasons
  # checkov:skip=CKV2_AWS_62: Event notifications not required for this use case
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
      kms_master_key_id = "alias/aws/s3"
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

<<<<<<< HEAD
=======
# 4. Lifecycle Configuration (Main)
>>>>>>> 1a76a92e11eb0b690e82a22230413a9dc1f61ee2
resource "aws_s3_bucket_lifecycle_configuration" "s3_tf_lifecycle" {
  bucket = aws_s3_bucket.s3_tf.id

  rule {
    id     = "cleanup-and-finops"
    status = "Enabled"
<<<<<<< HEAD
    filter {}
=======
    filter {} # Fixed: Required to apply to the whole bucket
>>>>>>> 1a76a92e11eb0b690e82a22230413a9dc1f61ee2

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

<<<<<<< HEAD
=======
# 5. Logging (Main) - Link main bucket to the log bucket below
>>>>>>> 1a76a92e11eb0b690e82a22230413a9dc1f61ee2
resource "aws_s3_bucket_logging" "s3_tf_logging" {
  bucket        = aws_s3_bucket.s3_tf.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}


resource "aws_s3_bucket" "log_bucket" {
  bucket_prefix = "charissa-logs-"

  # checkov:skip=CKV_AWS_18: This is the log bucket itself
  # checkov:skip=CKV_AWS_21: Versioning not required for logs
  # checkov:skip=CKV_AWS_144: Replication not required for logs
  # checkov:skip=CKV_AWS_145: SSE-S3 is sufficient for logs
  # checkov:skip=CKV2_AWS_61: Lifecycle not required for this dev activity
  # checkov:skip=CKV2_AWS_62: Notifications not required for logs
}

resource "aws_s3_bucket_public_access_block" "log_bucket_pab" {
  bucket                  = aws_s3_bucket.log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "log_bucket_oc" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
<<<<<<< HEAD
=======
    # Fixes CKV2_AWS_65 by disabling ACLs and using bucket owner enforcement
>>>>>>> 1a76a92e11eb0b690e82a22230413a9dc1f61ee2
    object_ownership = "BucketOwnerEnforced"
  }
}