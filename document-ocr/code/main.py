from google.cloud import storage
import functions_framework
from google.cloud import documentai_v1beta3, storage
import os


def process_document(bucket_name, object_name):
    # Create a client
    print("process_document...")
    client = documentai_v1beta3.DocumentProcessorServiceClient()

    ## Download file
    file_path = "/tmp/{}".format(object_name)
    print("download document..."+file_path)
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(object_name)
    blob.download_to_filename(file_path)

    # Read the file into memory
    with open(file_path, "rb") as image:
        image_content = image.read()
    document = {"content": image_content, "mime_type": "application/pdf"}

    # Configure the process request
    processor_name = os.getenv("OCR_PROCESSOR")
    if not processor_name:
        print("Environment variable OCR_PROCESSOR not set")
        exit(1)
    request = {"name": processor_name, "document": document}

    # Use the Document AI client to process the sample form
    result = client.process_document(request=request)

    document = result.document
    document_text = document.text
    print("Document processing complete.")
    process_output(bucket_name, object_name, document_text)


def process_output(bucket_name, object_name, document_text):
    """Moves a blob from one bucket to another."""
    print("process_output...")
    destination_bucket_name = os.environ['GCS_OUTPUT']
    print(destination_bucket_name)

    storage_client = storage.Client()

    # Move object from input to output bucket
    print("Moving object to the output bucket...")
    print(bucket_name)
    print(object_name)
    source_bucket = storage_client.bucket(bucket_name)
    source_blob = source_bucket.blob(object_name)
    destination_bucket = storage_client.bucket(destination_bucket_name)
    destination_generation_match_precondition = 0
    blob_copy = source_bucket.copy_blob(
        source_blob, destination_bucket, object_name, if_generation_match=destination_generation_match_precondition,
    )
    source_bucket.delete_blob(object_name)

    # Save OCR results
    print("Saving results into the output bucket...")
    results_obj_name = "{}.results".format(object_name)
    results_blob = destination_bucket.blob(results_obj_name)
    results_blob.upload_from_string(document_text)
    
    print("process_output completed")



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
