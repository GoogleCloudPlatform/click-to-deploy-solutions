from google.cloud import storage
import functions_framework
from google.cloud import documentai_v1beta3, storage
import os
import json 


def process_document(bucket_name, object_name):
    """Process a document stored in GCS."""
    print("Document processing started.")
    client = documentai_v1beta3.DocumentProcessorServiceClient()

    # Download file
    file_path = "/tmp/{}".format(object_name)
    print("download document to..."+file_path)
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(object_name)
    blob.download_to_filename(file_path)

    # Read the file into memory
    with open(file_path, "rb") as image:
        image_content = image.read()
    document = {"content": image_content, "mime_type": blob.content_type}
    
    # Configure the process request
    processor_name = os.getenv("OCR_PROCESSOR")
    if not processor_name:
        print("Environment variable OCR_PROCESSOR not set")
        exit(1)
    request = {"name": processor_name, "document": document}

    # Use the Document AI client to process the request
    result = client.process_document(request=request)
    document = result.document
    document_text = document.text

    # Extract key value pairs
    document_pages = document.pages
    document_dict = {}
    for page in document_pages:
        for form_field in page.form_fields:
            fieldName=get_text(form_field.field_name,document)
            fieldValue = get_text(form_field.field_value,document)
            document_dict[f"{fieldName}"] = fieldValue

    print("Document processing complete.")
    process_output(bucket_name, object_name, document_text, document_dict) 


def get_text(doc_element: dict, document: dict):
    """
    Document AI identifies form fields by their offsets
    in document text. This function converts offsets
    to text snippets.
    """
    response = ""
    # If a text segment spans several lines, it will
    # be stored in different text segments.
    for segment in doc_element.text_anchor.text_segments:
        start_index = (
            int(segment.start_index)
            if segment in doc_element.text_anchor.text_segments
            else 0
        )
        end_index = int(segment.end_index)
        response += document.text[start_index:end_index]
    return response


def process_output(bucket_name, object_name, document_text, document_dict):
    """Moves a blob from one bucket to another."""
    print("Process output started.")
    storage_client = storage.Client()
    destination_bucket_name = os.environ['GCS_OUTPUT']
    destination_bucket = storage_client.bucket(destination_bucket_name)

    # Save results
    print("Saving raw results into the output bucket...")
    results_text_name = "{}.text".format(object_name)
    results_text_blob = destination_bucket.blob(results_text_name)
    results_text_blob.upload_from_string(document_text)

    print("Saving json results into the output bucket...")
    document_json = json.dumps(document_dict)
    results_json_name = "{}.json".format(object_name)
    results_json_blob = destination_bucket.blob(results_json_name)
    results_json_blob.upload_from_string(document_json)

    # Move object from input to output bucket
    print("Moving object {} from {} to {}".format(object_name, bucket_name, destination_bucket_name))
    source_bucket = storage_client.bucket(bucket_name)
    source_blob = source_bucket.blob(object_name)
    destination_generation_match_precondition = 0
    blob_copy = source_bucket.copy_blob(
        source_blob, destination_bucket, object_name, if_generation_match=destination_generation_match_precondition,
    )
    source_bucket.delete_blob(object_name)
    
    print("Process output completed.")


# Triggered by a change in a storage bucket
@functions_framework.cloud_event
def trigger_gcs(cloud_event):
    data = cloud_event.data

    event_id = cloud_event["id"]
    event_type = cloud_event["type"]

    bucket = data["bucket"]
    name = data["name"]
    metageneration = data["metageneration"]
    timeCreated = data["timeCreated"]
    updated = data["updated"]

    print(f"Event ID: {event_id}")
    print(f"Event type: {event_type}")
    print(f"Bucket: {bucket}")
    print(f"File: {name}")
    print(f"Metageneration: {metageneration}")
    print(f"Created: {timeCreated}")
    print(f"Updated: {updated}")

    process_document(bucket, name)    
