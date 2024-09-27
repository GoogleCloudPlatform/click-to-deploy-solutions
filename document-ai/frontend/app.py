import streamlit as st
import numpy as np
import cv2
from google.cloud import documentai_v1 as documentai
import os
import json
from streamlit_pdf_viewer import pdf_viewer

project_id = "docai-428805"
location = "us"

client = documentai.DocumentProcessorServiceClient()
name = f"projects/427625783791/locations/us/processors/1875d368769573dc"
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = '/Users/diyasini/Desktop/Hero-Project/click-to-deploy-solutions/document-ai/frontend/key/docai-428805-fc8a50a1c2bd.json'
os.environ['GOOGLE_CLOUD_PROJECT'] = 'docai-428805'

st.title("Invoice Parsing using DocAI")

uploaded_file = st.file_uploader("Upload a document", type=["pdf", "jpg", "png"])


if uploaded_file is not None:
    # Create a button that triggers document processing
    if uploaded_file.type == "application/pdf":
        pdf_viewer(uploaded_file.read(), width=400, height=500)
        uploaded_file.seek(0)
    else:
        # Display image using st.image
        st.write(f"Displaying Image: {uploaded_file.name}")
        image = np.array(bytearray(uploaded_file.read()), dtype=np.uint8)
        image = cv2.imdecode(image, 1)
        
        # Set the desired width and height
        width = 400  # Example width in pixels
        height = 500  # Example height in pixels

        # Resize the image
        resized_image = cv2.resize(image, (width, height))

        st.image(resized_image, channels="BGR")
        uploaded_file.seek(0)

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

        # --- Display Extracted Entities in Sidebar ---
        st.sidebar.header("Extracted Entities")
        extracted_data = {entity.type_: entity.mention_text for entity in document.entities}
        st.sidebar.json(extracted_data)  # Display JSON in sidebar

        # --- Download Extracted Data as JSON ---
        st.sidebar.download_button( 
            label="Download JSON",
            data=json.dumps(extracted_data, indent=2),
            file_name="extracted_data.json",
            mime="application/json",
        )

        #  # --- Download extracted data as JSON ---
        # extracted_data = {}  # Initialize an empty dictionary
        # for entity in document.entities:
        #     extracted_data[entity.type_] = entity.mention_text

        # # Create a JSON download button
        # st.download_button(
        #     label="Download JSON",
        #     data=json.dumps(extracted_data, indent=2),
        #     file_name="extracted_data.json",
        #     mime="application/json",
        # )
