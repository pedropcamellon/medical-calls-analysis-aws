# Medical Calls Analysis in AWS

This is an event-driven medical call analysis system using AWS services. When patient call recordings are uploaded to an S3 bucket, it automatically triggers a Lambda function that initiates a transcription job. Once the transcript is generated, it is stored in S3, which triggers another Lambda function that uses Amazon Bedrock to summarize the call content. By leveraging Amazon Bedrock as a managed LLM solution, we avoid the complexity of handling LLM deployment and availability. The system uses serverless architecture throughout to efficiently process audio files and generate insights from medical conversations.

## Requirements

To run this application, you need to install the required dependencies. You can do this by running:

```bash
uv sync
```

## Deploying to AWS

To deploy this application to AWS, follow these steps:

1. Zip the contents of the `lambda_summarize` and `lambda_transcribe` directories using the following commands:

    ```bash
    zip -r lambda_summarize.zip lambda_summarize
    zip -r lambda_transcribe.zip lambda_transcribe
    ```

2. Upload the zip files to an S3 bucket.

3. Create an AWS Lambda function for each zip file.

4. Configure the Lambda functions to use the uploaded zip files.

## Deploying to AWS using Terraform

After creating the zip files, run the following commands from the `infrastructure` directory:

```bash
terraform init
terraform apply
```

## Streamlit Audio Uploader

An Streamlit application allows users to upload audio files for processing. The application provides a simple interface for users to interact with and manage their audio files.

## Project Structure

```plaintext
src
├── app.py                # Main entry point of the Streamlit application
```

## Running the Application

To start the Streamlit application, navigate to the `src` directory and run:

```bash
streamlit run src/app.py
```

This will launch the application in your default web browser.

## Features

- Upload audio files in MP3 format.
- User-friendly interface for audio file management.
