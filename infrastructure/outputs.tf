output "s3_bucket_name" {
  value = aws_s3_bucket.audio_bucket.bucket
}

output "transcribe_lambda_arn" {
  value = aws_lambda_function.transcribe_lambda.arn
}

output "summarize_lambda_arn" {
  value = aws_lambda_function.summarize_lambda.arn
}
