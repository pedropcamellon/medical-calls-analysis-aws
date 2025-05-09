# Medical Calls Analysis in AWS

This is an event-driven medical call analysis system using AWS services. When patient call recordings are uploaded to an S3 bucket, it automatically triggers a Lambda function that initiates a transcription job. Once the transcript is generated, it is stored in S3, which triggers another Lambda function that uses Amazon Bedrock to summarize the call content. By leveraging Amazon Bedrock as a managed LLM solution, we avoid the complexity of handling LLM deployment and availability. The system uses serverless architecture throughout to efficiently process audio files and generate insights from medical conversations.

## Requirements

To run this application, you need to install the required dependencies. You can do this by running:

```bash
uv sync
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
