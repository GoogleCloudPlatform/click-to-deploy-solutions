import os
import vertexai
from google.cloud import storage
from google import genai
import streamlit as st

# --- Configuration ---
region = os.environ.get('GCP_REGION', 'us-central1')
project_id = os.environ.get('PROJECT_ID')
gcs_bucket_name = os.environ.get('GCS_BUCKET')

vertexai.init(project=project_id, location=region)
client = genai.Client(vertexai=True, project=project_id, location=region)
storage_client = storage.Client(project=project_id)
