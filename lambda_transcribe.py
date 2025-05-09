import boto3
import json
import uuid


def lambda_handler(event, context):
    """
    Handles an S3 bucket notification event, extracting the bucket name and object key
    from the event, and then submitting a transcription job to the Transcribe service.

    The job is configured to transcribe the .mp3 file stored in the S3 bucket, and to
    output a JSON-formatted transcript to a file in the same bucket with the same name
    as the job name plus "-transcript.json".

    The function returns a JSON-formatted response with a status code and a message
    indicating success or failure.
    """
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]

    print(f"Processing file {key} from bucket {bucket}.")

    # One of a few different checks to ensure we don't end up in a recursive loop.
    if not key.endswith(".mp3"):
        print("This demo only works with mp3 files.")
        return

    # Create a Boto3 client for the Transcribe service
    transcribe_client = boto3.client("transcribe", region_name="us-east-1")

    try:
        # Needs to be a unique name
        job_name = "transcription-job-" + str(uuid.uuid4())

        print(f"Starting transcription job {job_name}.")

        transcribe_client.start_transcription_job(
            TranscriptionJobName=job_name,
            Media={"MediaFileUri": f"s3://{bucket}/{key}"},
            MediaFormat="mp3",
            LanguageCode="en-US",
            OutputBucketName=bucket,
            OutputKey=f"transcripts/{job_name}.json",
            Settings={"ShowSpeakerLabels": True, "MaxSpeakerLabels": 2},
        )

        print(f"Transcription job {job_name} started successfully.")

    except Exception as e:
        print(f"Error occurred: {e}")
        return {"statusCode": 500, "body": json.dumps(f"Error occurred: {e}")}

    return {
        "statusCode": 200,
        "body": json.dumps(
            f"Submitted transcription job for {key} from bucket {bucket}."
        ),
    }
