import streamlit as st
import os, sys, json
from google.cloud import storage
import requests, time
import logging
from typing import List
from google.cloud import speech
import google.cloud.dlp
from google.cloud.speech_v2 import SpeechClient
from google.api_core.client_options import ClientOptions
import librosa
import gcsfs
from flask import Flask, request, Response  # Import Flask and request
import vertexai
from vertexai.generative_models import GenerativeModel, Part, SafetySetting

app = Flask(__name__)
project = os.environ["PROJECT_ID"]
info_types = [
    "PERSON_NAME",
    "PHONE_NUMBER",
    "US_SOCIAL_SECURITY_NUMBER",
    "EMAIL_ADDRESS"  # Add other info types as needed
]

vertexai.init(project=project, location="us-central1")

generation_config = {
    "max_output_tokens": 8192,
    "temperature": 1,
    "top_p": 1,
}

safety_settings = [
    SafetySetting(
        category=SafetySetting.HarmCategory.HARM_CATEGORY_HATE_SPEECH,
        threshold=SafetySetting.HarmBlockThreshold.OFF
    ),
    SafetySetting(
        category=SafetySetting.HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
        threshold=SafetySetting.HarmBlockThreshold.OFF
    ),
    SafetySetting(
        category=SafetySetting.HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
        threshold=SafetySetting.HarmBlockThreshold.OFF
    ),
    SafetySetting(
        category=SafetySetting.HarmCategory.HARM_CATEGORY_HARASSMENT,
        threshold=SafetySetting.HarmBlockThreshold.OFF
    ),
]


input_bucket = os.environ["GCS_INPUT_BUCKET"]
output_bucket = os.environ["GCS_OUTPUT_BUCKET"]

# Instantiate clients for Speech, DLP and Cloud Storage
client = speech.SpeechClient()
dlp = google.cloud.dlp_v2.DlpServiceClient()
storage_client = storage.Client()
bucket = storage_client.bucket(input_bucket)

#Helper utilities

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
    
    print("Masked information: ",response.item.value)
    print(f"Redacted file copied to: gs://{output_bucket}/{redacted_file_path}")

    return response.item.value


def generate_transcript(input_file, first_lang):
    """This function is triggered by a change in a storage bucket.

    Args:
        cloud_event: The CloudEvent that triggered this function.
    Returns:
        The event ID, event type, bucket, name, metageneration, and timeCreated.
    """

    try:
        file_name = input_file
        bucket_name = input_bucket
        #first_lang = "en-US"

        print(f"Input File Name: {file_name}")
        print(f"Language detected: {first_lang}")

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
                language_code=first_lang
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
        transcript = deidentify_with_replace_infotype(project, info_types, transcript, file_name)
        print(f"Masked Transcript: {transcript}")

    except ValueError as e:
        print(f"Error: {e}")
    except KeyError as e:
        print(f"Missing key in event data: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}") 

    return transcript


def get_model(textsi_1):
    """Initialises model"""

    model = GenerativeModel(
    "gemini-1.5-flash-002",
    system_instruction=[textsi_1]
)

    return model

def diarizeTranscript(transcript, language):
    textsi_1 = f"""You are an assistant helping me in identifying the speakers in a conversation.
    The text below is a conversation between a Agent and Customer.
    The conversation shared is in {language} language.
    Do not translate the conversation unless you are asked to.
    Perform clear Diarization from the below text by understanding the context.
    Format the output between the speakers clearly based on the context and identify the speakers Agent and Customer.
    The audio might contain some rude conversation.
    Also, mask any sensitive information in the transcription with [REDACTED] keyword.
    Do not hallucinate.
    Try to make sense out of what person is trying to say and modify the sentence 
    to make the conversation understandable. Only modify the sentences which are not correct, keep the rest of conversation as it is."""

    model = get_model(textsi_1)
    
    diarized_content = ""
    
    responses = model.generate_content(
        [transcript],
        generation_config=generation_config,
        safety_settings=safety_settings,
        stream=True,
    )

    for response in responses:
        print(response.text, end="")
        diarized_content += response.text 

    print("Diarized Content: ", diarized_content)

    return diarized_content

def summarize(content):
    textsi_1="""Summarize the conversation between Agent and Customer. Redact any sensitive information.Use format below to display information:
    Summary

    Sentiment Score

    Sentiment Detail
    
    """

    model = get_model(textsi_1)
    
    summarized_content = ""
    
    responses = model.generate_content(
        [content],
        generation_config=generation_config,
        safety_settings=safety_settings,
        stream=True,
    )

    for response in responses:
        print(response.text, end="")
        summarized_content += response.text 

    print("Summarized Content: ", summarized_content)

    return summarized_content


def actionItems(content):
    textsi_1="""Generate list of outstanding action items from the call conversation between customer and agent. Also specify action item is pending on whom. Do not display the actions that are already completed. 
                Return the result in below format:
            1.   Action item:                
                Owner:                     
                Status:
                """
    
    model = get_model(textsi_1)
    
    action_items = ""
    
    responses = model.generate_content(
        [content],
        generation_config=generation_config,
        safety_settings=safety_settings,
        stream=True,
    )

    for response in responses:
        print(response.text, end="")
        action_items += response.text 


    print("Action Items: ", action_items)

    return action_items

# Setup UI Elements 
# Set the page header
st.set_page_config(page_title="Generative AI Powered Operational Insights Dashboard")
# Set the background color to light blue
st.markdown(
    """
    <style>
    body {
        background-color: lightblue;
    }
    </style>
    """,
    unsafe_allow_html=True,
)
# Create two columns with a 1:3 ratio
col1, col2 = st.columns([1, 3])

# Display the "Cymbal" text in the first column
with col1:
    st.markdown(
        "<div style='text-align: left; font-size: 40px; font-weight: bold; color: #007bff;'>"  # Changed color to blue (#007bff)
        "Cymbal"
        "</div>",
        unsafe_allow_html=True,
    )

# Display the "Generative AI..." text in the second column
with col2:
    st.markdown(
        "<div style='text-align: right; font-size: 32px; color: red;'>"
        "Generative AI Powered Operational Insights Dashboard"
        "</div>",
        unsafe_allow_html=True,
    )


# --- Upload File Section  ---
st.header("Upload File")
col1, col2 = st.columns([2, 1])  # Adjust column ratios as needed

with col1:
    uploaded_file = st.file_uploader(
        "Choose file", type=["wav", "mp3", "m4a", "flac"],
         label_visibility="collapsed",
         help="" 
         )
    st.markdown(  # Custom styling for the drag and drop area
        """
        <style>
        .stUploadedFile > div > div {
            border: 2px dashed #ccc;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
        }
        </style>
        """,
        unsafe_allow_html=True,
    )


with col2:
    # Dictionary mapping common language names to BCP-47 codes
    language_map = {
        "English (US)": "en-US",
        "Spanish (Spain)": "es-ES",
        "French (France)": "fr-FR",
        "German (Germany)": "de-DE",
        "Hindi (India)": "hi-IN",
        "Mandarin Chinese (Simplified)": "zh (cmn-Hans)", 
        "Japanese (Japan)": "ja-JP",
        "Portuguese (Brazil)": "pt-BR",
        "Russian (Russia)": "ru-RU",
        "Arabic (Egypt)": "ar-EG"
        # Add more common languages as needed
    }
    selected_language_name = st.selectbox("Select Language", list(language_map.keys()))
    
    if st.button("Process Audio", use_container_width=True):
        process_audio = True
        with st.spinner("Uploading file..."):  # Display a spinner while uploading
                blob = bucket.blob(uploaded_file.name)
                blob.upload_from_file(uploaded_file, content_type=uploaded_file.type)
                print(f"File uploaded to GCS: gs://{input_bucket}/{uploaded_file.name}")
    else:
        process_audio = False
        st.info("Please upload a file first.")
        sys.exit(1)

    st.markdown(  # Custom styling for the drag and drop area
        """
        <style>
        .stUploadedFile > div > div {
            border: 2px dashed #ccc;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
        }
        </style>
        """,
        unsafe_allow_html=True,
    )

#2. Display UI elements

# Display the text boxes outside the processing blocks
st.subheader("Audio Transcript")
with st.container():
    if uploaded_file is not None and process_audio:
        try:
            # Get the BCP-47 code for the selected language
            selected_language_code = language_map[selected_language_name]

            # 3. Call the Cloud Function
            headers = {'Content-Type': 'application/json'}

            with st.spinner("Processing audio..."):  # Display a spinner while processing
                transcript = generate_transcript(uploaded_file.name, selected_language_code)
                # st.success("Transcript generated")

            with st.spinner("Masking sensitive data..."):  # Display a spinner while processing
                masked_transcript = mask(transcript, uploaded_file.name)
                # st.success("Masked sensitive information")

            with st.spinner("Performing Diarization..."):
                diarized_content = diarizeTranscript(masked_transcript, selected_language_name)
                st.text_area("Response:", value=diarized_content, height=200, label_visibility="hidden")


        except Exception as e:
            st.error(f"Error uploading file: {e}")



st.subheader("Gemini AI Summary")
with st.container():
    if uploaded_file is not None and process_audio:
        try:
            with st.spinner("Generating Call Summary"):
                summary = summarize(diarized_content)
                st.text_area("Response:", value=summary, height=200, label_visibility="hidden", key="summary")

        except Exception as e:
            st.error(f"Error uploading file: {e}")

st.subheader("Gemini AI Action Items")
with st.container():
    if uploaded_file is not None and process_audio:
        try:
            with st.spinner("Generating List of Action items"):
                action_items = actionItems(diarized_content)
                st.text_area("Response:", value=action_items, height=200, label_visibility="hidden", key="action_items")

        except Exception as e:
            st.error(f"Error uploading file: {e}")


if __name__ == '__main__':
    server_port = os.environ.get('PORT', '8502')
    app.run(debug=False, port=server_port, host='0.0.0.0')