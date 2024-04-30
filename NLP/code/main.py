from google.cloud import bigquery, documentai_v1beta3, storage
from google.cloud import language_v2
import os
import json

def process_document(bucket_name, object_name):
    """Performs sentiment analysis on a text document stored in GCS."""

    print("Document processing started.")
    language_client = language_v2.LanguageServiceClient()
    storage_client = storage.Client()
    
    file_path = f"/tmp/{object_name}"

    print(f"Downloading document to: {file_path}")
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(object_name)
    blob.download_to_filename(file_path)
    with open(file_path, "r") as text_file:
        document_content = text_file.read()

    print("Performing sentiment analysis...")
    document = language_v2.Document(content=document_content, type_=language_v2.Document.Type.PLAIN_TEXT)
    sentiment = language_client.analyze_sentiment(request={"document": document}).document_sentiment    
    sentiment_score = sentiment.score
    sentiment_magnitude = sentiment.magnitude

    print("Sentiment analysis complete.")
    process_output(bucket_name, object_name, document_content, sentiment_score, sentiment_magnitude)  



def process_output(bucket_name, object_name, document_content, sentiment_score, sentiment_magnitude):
    """Moves a blob from one bucket to another."""
    print("Process output started.")
    storage_client = storage.Client()
    destination_bucket_name = os.environ['GCS_OUTPUT']
    destination_bucket = storage_client.bucket(destination_bucket_name)

    print("Saving json results into the output bucket...")
    results_json = {
        "document_file_name": object_name,
        "document_content": sentiment_score,
        "document_summary": sentiment_magnitude       
    }
    results_json = json.dumps(results_json)
    results_json_name = "{}.json".format(object_name)
    results_json_blob = destination_bucket.blob(results_json_name)
    results_json_blob.upload_from_string(results_json)

    # Move object from input to output bucket
    print("Moving object {} from {} to {}".format(object_name, bucket_name, destination_bucket_name))
    source_bucket = storage_client.bucket(bucket_name)
    source_blob = source_bucket.blob(object_name)
    blob_copy = source_bucket.copy_blob(source_blob, destination_bucket, object_name)
    source_bucket.delete_blob(object_name)

    # Persist results into BigQuery
    print("Persisting data to BigQuery...")
    bq_client = bigquery.Client()
    table_id = os.getenv("BQ_TABLE_ID")
    job_config = bigquery.LoadJobConfig(
        schema=[
            bigquery.SchemaField("document_file_name", "STRING"),
            bigquery.SchemaField("document_content", "JSON"),
            bigquery.SchemaField("document_summary", "STRING"),
        ],
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
    )
    uri = "gs://{}/{}".format(destination_bucket_name, results_json_name)
    print("Load file {} into BigQuery".format(uri))
    load_job = bq_client.load_table_from_uri(
        uri,
        table_id,
        location=os.getenv("BQ_LOCATION"),  # Must match the destination dataset location.
        job_config=job_config,
    )
    load_job.result()

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