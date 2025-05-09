terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.96"
    }
  }

  required_version = ">= 1.11.4"
}

provider "aws" {
  region = var.aws_region
}

# S3 Bucket for storing audio files and results
resource "aws_s3_bucket" "audio_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "Medical Calls Audio Bucket"
    Environment = var.environment
  }
}

# IAM Role for Lambda with permissions for S3, Transcribe, and Bedrock
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

# IAM Policy for S3, Transcribe, and Bedrock
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda to access S3, Transcribe, and Bedrock"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "${aws_s3_bucket.audio_bucket.arn}",
        "${aws_s3_bucket.audio_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "transcribe:StartTranscriptionJob",
        "transcribe:GetTranscriptionJob",
        "transcribe:ListTranscriptionJobs"
      ],
      "Resource": "arn:aws:transcribe:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:ListModels"
      ],
      "Resource": [
        "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-text-express-v1"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.transcribe_lambda.function_name}:*",
        "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.summarize_lambda.function_name}:*"
      ]
    }
  ]
}
EOF
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda Function for Transcription
resource "aws_lambda_function" "transcribe_lambda" {
  function_name = "transcribe_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_transcribe.lambda_handler"
  runtime       = var.lambda_runtime

  timeout = var.transcribe_lambda_timeout

  # Path to your Lambda deployment package
  filename         = "../lambda_transcribe.zip"
  source_code_hash = filebase64sha256("../lambda_transcribe.zip")
}

# Lambda Function for Summarization
resource "aws_lambda_function" "summarize_lambda" {
  function_name = "summarize_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_summarize.lambda_handler"
  runtime       = var.lambda_runtime

  timeout = var.summarize_lambda_timeout

  # Path to your Lambda deployment package
  filename         = "../lambda_summarize.zip"
  source_code_hash = filebase64sha256("../lambda_summarize.zip")
}

# S3 Bucket Notification for Transcription Lambda
resource "aws_s3_bucket_notification" "audio_bucket_notification" {
  bucket = aws_s3_bucket.audio_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.transcribe_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audios/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.summarize_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "transcripts/"
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke_transcribe, aws_lambda_permission.allow_s3_to_invoke_summarize]
}

# Allow S3 to invoke the Transcription Lambda
resource "aws_lambda_permission" "allow_s3_to_invoke_transcribe" {
  statement_id  = "AllowS3InvokeTranscribe"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transcribe_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.audio_bucket.arn
}

# Allow S3 to invoke the Summarization Lambda
resource "aws_lambda_permission" "allow_s3_to_invoke_summarize" {
  statement_id  = "AllowS3InvokeSummarize"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.summarize_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.audio_bucket.arn
}
