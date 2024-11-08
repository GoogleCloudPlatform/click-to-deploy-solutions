import streamlit as st
import os, sys
from google.cloud import storage
import requests, time
import logging
from typing import List
from google.cloud import speech
import google.cloud.dlp
from google.cloud import speech_v1p1beta1 as speech
from google.cloud.speech_v2 import SpeechClient
from google.api_core.client_options import ClientOptions
import librosa
import gcsfs
from flask import Flask, request, Response  # Import Flask and request

app = Flask(__name__)
project = os.environ["PROJECT_ID"]
info_types = [
    "PERSON_NAME",
    "PHONE_NUMBER",
    "US_SOCIAL_SECURITY_NUMBER",
    "EMAIL_ADDRESS"  # Add other info types as needed
]
input_bucket = os.environ["GCS_INPUT_BUCKET"]
output_bucket = os.environ["GCS_OUTPUT_BUCKET"]

st.title("Audio Analysis")

# Instantiate clients for Speech, DLP and Cloud Storage
client = speech.SpeechClient()
dlp = google.cloud.dlp_v2.DlpServiceClient()
storage_client = storage.Client()
bucket = storage_client.bucket(input_bucket)

# Fetch file extension to determine the audio encoding
def audio_encoding_format(speech_file):
    _, ext = os.path.splitext(speech_file)
    ext = ext.lower()  # Convert to lowercase for case-insensitive comparison

    if ext == ".mp3":
        print(f"Audio format is: MP3")
        return speech.RecognitionConfig.AudioEncoding.MP3
    elif ext == ".wav":
        print(f"Audio format is: WAV")
        return speech.RecognitionConfig.AudioEncoding.LINEAR16
    elif ext == ".flac":
        print(f"Audio format is: FLAC")
        return speech.RecognitionConfig.AudioEncoding.FLAC
    else:
        raise ValueError(f"Unsupported audio format: {ext}")

# Calculate the audio duration
def audio_duration(speech_file):
    # Create a GCSFileSystem object
    fs = gcsfs.GCSFileSystem()

    # Open the audio file from GCS
    with fs.open(speech_file, "rb") as f:
        # Load the audio using librosa
        y, sr = librosa.load(f)

    audio_duration_in_seconds = librosa.get_duration(y=y, sr=sr)

    print(f"Audio duration: {audio_duration_in_seconds} seconds")
    return audio_duration_in_seconds

def transcribe_audio(config, audio, audio_duration_in_seconds, audio_encoding_format):
    # Use either 'recognize' (for audio <= 1 minute) or 'long_running_recognize' (for audio > 1 minute)
    if audio_duration_in_seconds <= 60:
        operation = client.recognize(config=config, audio=audio)
    else:
        operation = client.long_running_recognize(config=config, audio=audio)

    print("Waiting for operation to complete...")
    response = operation.result()

    full_transcript = ""
    for result in response.results:
        full_transcript += result.alternatives[0].transcript
    return full_transcript

# DLP masking function
def deidentify_with_replace_infotype(
    project: str, info_types: List[str], file_content: str, file_name: str
) -> None:
    """Uses the Data Loss Prevention API to deidentify sensitive data in a
    file stored in a GCS bucket by replacing it with the info type.

    Args:
        project: The Google Cloud project id to use as a parent resource.
        bucket_name: The name of the GCS bucket where the file is stored.
        file_path: The full path to the file within the GCS bucket.
        info_types: A list of strings representing info types to look for.
            A full list of info type categories can be fetched from the API.
    Returns:
        None; the response from the API is printed to the terminal.
    """

    # Convert the project id into a full resource id.
    parent = f"projects/{project}/locations/global"

    # Construct inspect configuration dictionary
    inspect_config = {"info_types": [{"name": info_type} for info_type in info_types]}

    # Construct deidentify configuration dictionary
    deidentify_config = {
        "info_type_transformations": {
            "transformations": [
                {"primitive_transformation": {"replace_with_info_type_config": {}}}
            ]
        }
    }

    # # Get the file content from GCS using the full path
    # bucket = storage_client.bucket(output_bucket)
    # blob = bucket.blob(file_path)
    # file_content = blob.download_as_string().decode("utf-8")

    # Call the API
    response = dlp.deidentify_content(
        request={
            "parent": parent,
            "deidentify_config": deidentify_config,
            "inspect_config": inspect_config,
            "item": {"value": file_content},
        }
    )


    # 3. Store the transcript (consider using a database or another bucket)
    # Copy the redacted content to a new file in the "redacted_transcripts" folder
    bucket = storage_client.bucket(output_bucket)
    redacted_file_path = f"redacted_transcripts/masked-{file_name}"
    redacted_blob = bucket.blob(redacted_file_path)
    redacted_blob.upload_from_string(response.item.value)

    print(f"Redacted file copied to: gs://{output_bucket}/{redacted_file_path}")

    return response.item.value


def generate_transcript(input_file):
    """This function is triggered by a change in a storage bucket.

    Args:
        cloud_event: The CloudEvent that triggered this function.
    Returns:
        The event ID, event type, bucket, name, metageneration, and timeCreated.
    """

    try:
        file_name = input_file
        bucket_name = input_bucket
        first_lang = "en-US"

        print(f"Input File Name: {file_name}")

        # 1. Transcribe audio using Google Cloud Speech-to-Text
        gcs_uri = f"gs://{bucket_name}/{file_name}"

        try:
            audio = speech.RecognitionAudio(uri=gcs_uri)
            audio_duration_in_seconds = audio_duration(gcs_uri)
            audio_format = audio_encoding_format(gcs_uri)

            config = speech.RecognitionConfig(
                encoding=audio_format,
                sample_rate_hertz=44100,
                audio_channel_count=2,
                language_code=first_lang,
            )

            transcript = transcribe_audio(
                config, audio, audio_duration_in_seconds, audio_format
            )
            print(f"Transcript: {transcript}")

            # Construct the output transcript path
            base_name = os.path.splitext(os.path.basename(file_name))[0]
            output_file_path = f"transcripts/{base_name}-transcript.txt"

            # Store the transcript in Google Cloud Storage
            bucket = storage_client.bucket(output_bucket)
            blob = bucket.blob(output_file_path)
            blob.upload_from_string(transcript)  # Upload 'transcript', not 'final_transcript'
            print(f"Transcript saved to gs://{output_bucket}/{output_file_path}")
        
        except ValueError as e:
            # Catch the ValueError that occurs for unsupported audio formats
            print(f"Error: {e}")  # Log the specific error
            print(f"No supported audio file detected: {file_name}")

    except ValueError as e:
        print(f"Error: {e}")
    except KeyError as e:
        print(f"Missing key in event data: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}") 
    return transcript

def mask(transcript, file_name): 
    """This function is triggered by a change in a storage bucket.

    Args:
        cloud_event: The CloudEvent that triggered this function.
    Returns:
        The event ID, event type, bucket, name, metageneration, and timeCreated.
    """

    try:
        print(f"Transcript: {transcript}")

        # Mask sensitive data using Cloud DLP
        masked_transcript = deidentify_with_replace_infotype(project, info_types, transcript, file_name)
        print(f"Masked Transcript: {masked_transcript}")

    except ValueError as e:
        print(f"Error: {e}")
    except KeyError as e:
        print(f"Missing key in event data: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}") 

    return masked_transcript

uploaded_file = st.file_uploader("Upload an audio file", type=["wav", "mp3", "m4a", "flac"])

if uploaded_file is not None:
    if st.button("Process Audio"):
        try:
            with st.spinner("Uploading file..."):  # Display a spinner while uploading
                blob = bucket.blob(uploaded_file.name)
                blob.upload_from_file(uploaded_file, content_type=uploaded_file.type)
                print(f"File uploaded to GCS: gs://{input_bucket}/{uploaded_file.name}")
                st.success(f"File uploaded successfully")

            # 2. Call the Cloud Function
            headers = {'Content-Type': 'application/json'}

            with st.spinner("Processing audio..."):  # Display a spinner while processing
                transcript = generate_transcript(uploaded_file.name)
                st.success("Transcript generated")


            with st.spinner("Masking sensitive data..."):  # Display a spinner while processing
                masked_transcript = mask(transcript, uploaded_file.name)
                st.success("Masked sensitive information")

            # You can further process the response from the Cloud Function if needed
            # Display the response in a scrollable box
            st.subheader("Transcript Generated")
            with st.container():  # Create a container for the scrollable box
                st.text_area("Response:", value=masked_transcript, height=200)  # Use st.text_area

        except Exception as e:
            st.error(f"Error uploading file: {e}")

if __name__ == '__main__':
    server_port = os.environ.get('PORT', '8501')
    app.run(debug=False, port=server_port, host='0.0.0.0')