from botocore.exceptions import NoCredentialsError
import boto3
import streamlit as st

# S3 bucket name (output from Terraform)
S3_BUCKET_NAME = "medical-calls-audio-bucket"

# Initialize the S3 client
s3_client = boto3.client("s3", region_name="us-east-1")


def main():
    st.title("Medical Calls Analysis")

    tab1, tab2, tab3, tab4 = st.tabs(
        ["Upload", "Audio Files", "Transcripts", "Summaries"]
    )

    with tab1:
        uploaded_file = st.file_uploader(
            label="Upload an audio file smaller than 500KB to process",
            type=["mp3"],
            accept_multiple_files=False,
        )

        if uploaded_file is not None:
            if uploaded_file.size > 500 * 1024:
                st.error("File size should not be bigger than 500KB")
            else:
                st.audio(uploaded_file, format="audio/wav")
                st.write("File name:", uploaded_file.name)
                st.write(f"File size: {uploaded_file.size / 1024:.0f} KB")
                st.button(
                    "Process Audio", on_click=process_audio, args=(uploaded_file,)
                )

    with tab2:
        st.header("Uploaded Audio Files")

        files = list_bucket_objects("audios/")

        for file in files:
            filename = file.split("/")[-1]
            st.write(f"- {filename}")

    with tab3:
        st.header("Transcripts")

        files = list_bucket_objects("transcripts/", ".json")

        for file in files:
            filename = file.split("/")[-1]
            with st.expander(f"{filename}"):
                content = get_object_content(file)
                if content:
                    st.text(content)

    with tab4:
        st.header("Summaries")

        files = list_bucket_objects("summaries/")

        for file in files:
            filename = file.split("/")[-1]
            with st.expander(f"{filename}"):
                content = get_object_content(file)
                if content:
                    st.text(content)


def process_audio(uploaded_file):
    try:
        with st.spinner("Uploading file to S3..."):
            # Upload the file to S3
            s3_client.upload_fileobj(
                Fileobj=uploaded_file,
                Bucket=S3_BUCKET_NAME,
                Key=f"audios/{uploaded_file.name}",
            )
        st.success(
            f"File '{uploaded_file.name}' uploaded successfully to S3 bucket '{S3_BUCKET_NAME}'!"
        )
    except NoCredentialsError:
        st.error("AWS credentials not found. Please configure your credentials.")
    except Exception as e:
        st.error(f"An error occurred: {e}")


def list_bucket_objects(prefix="", file_extension=None):
    try:
        response = s3_client.list_objects_v2(Bucket=S3_BUCKET_NAME, Prefix=prefix)

        if not "Contents" in response:
            return []

        objects = [obj["Key"] for obj in response.get("Contents", [])]

        if file_extension:
            objects = [obj for obj in objects if obj.endswith(file_extension)]

        return objects
    except Exception as e:
        st.error(f"Error listing objects: {e}")
        return []


def get_object_content(key):
    try:
        response = s3_client.get_object(Bucket=S3_BUCKET_NAME, Key=key)
        return response["Body"].read().decode("utf-8")
    except Exception as e:
        st.error(f"Error reading object: {e}")
        return None


if __name__ == "__main__":
    main()
