variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to store audio files and results"
  type        = string
  default     = "medical-calls-audio-bucket"
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "Production"
}

variable "lambda_runtime" {
  description = "Runtime for Lambda functions"
  type        = string
  default     = "python3.11"
}

variable "transcribe_lambda_timeout" {
  description = "Timeout in seconds for transcribe Lambda function"
  type        = number
  default     = 10
}

variable "summarize_lambda_timeout" {
  description = "Timeout in seconds for summarize Lambda function"
  type        = number
  default     = 30
}
