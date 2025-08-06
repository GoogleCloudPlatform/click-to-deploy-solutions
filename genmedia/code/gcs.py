import streamlit as st
from google.cloud import storage
import uuid

from config import storage_client

def upload_bytes_to_gcs(bucket_name: str, blob_name: str, data: bytes, content_type: str = "image/png") -> str:
    """Uploads bytes data to GCS and returns the gs:// URI."""
    try:
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_name)
        blob.upload_from_string(data, content_type=content_type)
        return f"gs://{bucket_name}/{blob_name}"
    except Exception as e:
        st.error(f"Failed to upload image to GCS: {e}")
        return None
