import streamlit as st
import numpy as np
import cv2
from google.cloud import documentai_v1 as documentai
import os
import random
import json

project_id = "docai-428805"
location = "us"

client = documentai.DocumentProcessorServiceClient()
name = f"projects/427625783791/locations/us/processors/1875d368769573dc"
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = 'path/to/json file'
os.environ['GOOGLE_CLOUD_PROJECT'] = 'docai-428805'

st.title("Invoice Parsing using DocAI")

uploaded_file = st.file_uploader("Upload a document", type=["pdf", "jpg", "png"])


if uploaded_file is not None:
    # Create a button that triggers document processing
    if st.button("Process Document"):
        with st.spinner("Processing document..."):
            # Read the file content
            raw_document = documentai.RawDocument(
                content=uploaded_file.read(), mime_type=uploaded_file.type
            )

            # Configure the process request
            request = documentai.ProcessRequest(name=name, raw_document=raw_document)

           
            result = client.process_document(request=request)
            document = result.document

        # Display the extracted entities in a table
        st.header("Extracted Entities")
        entities = []
        for entity in document.entities:
            entities.append([entity.type_, entity.mention_text])
        st.table(entities)



         # --- Download extracted data as JSON ---
        extracted_data = {}  # Initialize an empty dictionary
        for entity in document.entities:
            extracted_data[entity.type_] = entity.mention_text

        # Create a JSON download button
        st.download_button(
            label="Download JSON",
            data=json.dumps(extracted_data, indent=2),
            file_name="extracted_data.json",
            mime="application/json",
        )
