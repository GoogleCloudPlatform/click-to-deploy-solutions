# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Audio Analysis with Gemini and Chirp2

# Import libraries
import sys
import IPython
import vertexai
from google.cloud.speech_v2 import SpeechClient
from google.cloud.speech_v2.types import cloud_speech
from google.api_core.client_options import ClientOptions
from google.cloud import storage
import urllib.parse
import json
import base64
import vertexai
from vertexai.generative_models import GenerativeModel, Part, FinishReason
import vertexai.preview.generative_models as generative_models
from IPython.display import Markdown, Audio, display
from vertexai.generative_models import (
    GenerationConfig,
    GenerativeModel,
    HarmCategory,
    HarmBlockThreshold,
    Part,
)

# Define project information
PROJECT_ID = 'click-to-deploy-demo' 
LOCATION = 'us-central1'
bucket = 'audio-analysis-001'

# Initialize Vertex AI
vertexai.init(project=PROJECT_ID, location=LOCATION)

""" Load the Gemini 1.5 Pro model
Gemini 1.5 Pro (`gemini-1.5-pro-001`) is a multimodal model that supports multimodal prompts. 
You can include text, image(s), PDFs, audio, and video in your prompt requests and get text or code responses.
"""

model = GenerativeModel("gemini-1.5-pro-001")

generation_config = GenerationConfig(temperature=1, top_p=0.95, max_output_tokens=8192)

safety_settings = {
    HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_NONE,
    HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_NONE,
    HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_NONE,
    HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_NONE,
}

SPEECH_V2_ENDPOINT = "us-central1-speech.googleapis.com" #@param {type:"raw"}

"""Create a Recognizer
Note: if recognizer exists in project, you'll get an error - will make a check for this and set the recognizer object.
"""

# Create a client
client = SpeechClient(client_options=ClientOptions(api_endpoint=SPEECH_V2_ENDPOINT))
try:
  # create a recognizer
  language_code = "en-US"
  recognizer_id = f"chirp-{language_code.lower()}-test"
  request = cloud_speech.CreateRecognizerRequest(
      parent=f"projects/{PROJECT_ID}/locations/{LOCATION}",
      recognizer_id=recognizer_id,
      recognizer=cloud_speech.Recognizer(
          language_codes=[language_code], 
          model="chirp_2"
      ),
  )
  operation = client.create_recognizer(request=request)
  recognizer = operation.result()
except:
  print(f"Recognizer already exists, reusing {recognizer_id}")
  # create a recognizer
  request = cloud_speech.GetRecognizerRequest(
      name=f"projects/{PROJECT_ID}/locations/{LOCATION}/recognizers/{recognizer_id}",
  )
  recognizer = client.get_recognizer(request=request)
  recognizer #= operation.result()

"""Transcribe a file on GCS

A longer audio file, 1 min or greater

Here we'll specify the bucket where our audio file resides, as well as the name of the audio file.
"""
#GCS_AUDIO_FILE = "brooklyn.flac"
#GCS_BUCKET = bucket + "/audio-files"  

GCS_BUCKET = BUCKET + "/audio-files"
GCS_AUDIO_FILE = "vr.wav"
GCS_OP_BUCKET = BUCKET

"""This creates a BatchRecognizeRequest which results in an operation. We're not specifying an output file name, only an output bucket, in this case the same bucket where our origin audio file lives.

This will result in a long running operation for transcription, and when it's complete, will show the location & name of the transcription file.
"""

config = cloud_speech.RecognitionConfig(auto_decoding_config={})

request = cloud_speech.BatchRecognizeRequest(
    recognizer=recognizer.name,
    recognition_output_config={
        "gcs_output_config": {
            "uri": f"gs://{GCS_OP_BUCKET}/transcripts/"
        }
    },
    files=[{
        "config": config,
        "uri": f"gs://{GCS_BUCKET}/{GCS_AUDIO_FILE}"
    }],
)


# Transcribes the audio into text
operation = client.batch_recognize(request=request)

# Wait for the operation to complete.
while not operation.done:
    time.sleep(0.1)
    operation.refresh()

# Get the operation's result.
result = operation.result()

# Print the operation's result.
print("Result ",result)

transcript_output = result.results[f"gs://{GCS_BUCKET}/{GCS_AUDIO_FILE}"].uri
print("transcript_output ", transcript_output)

"""Let's grab the transcription, a JSON file located in the same GCS bucket, and show its contents."""

parsed_uri = urllib.parse.urlparse(transcript_output)
last_part_of_path = parsed_uri.path.split("/")[-1]

storage_client = storage.Client()
bucket = storage_client.get_bucket(GCS_OP_BUCKET)
transcript = bucket.blob("transcripts/" + last_part_of_path)
print("transcript ", transcript)
data = json.loads(transcript.download_as_bytes(client=None))

transcripts = []
for result in data['results']:
    if 'alternatives' in result:
        for alternative in result['alternatives']:
            transcripts.append(alternative['transcript'])

# Join transcripts into a single string
full_transcript = ' '.join(transcripts)

print("full_transcript ", full_transcript)





