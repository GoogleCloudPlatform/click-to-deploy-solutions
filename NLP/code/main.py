from google.cloud import bigquery, documentai_v1beta3, storage
from google.cloud import language_v2
import functions_framework
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
    response = language_client.analyze_sentiment(request={"document": document})

    # Get results
    sentiment_score = response.document_sentiment.score
    sentiment_magnitude = response.document_sentiment.magnitude
    sentences = [
        {"text": sentence.text.content, "sentiment": sentence.sentiment.score}
        for sentence in response.sentences
    ]

    process_output(
        bucket_name,
        object_name,
        sentiment_score,
        sentiment_magnitude,
        sentences,
    )  



def process_output(
    bucket_name, object_name, sentiment_score, sentiment_magnitude, sentences
):
    print("Storing results in GCS and BigQuery.")

    # Prepare results JSON
    results_json = {
        "document_file_name": object_name,
        "sentiment_score": sentiment_score,
        "sentiment_magnitude": sentiment_magnitude,
        "sentences": sentences,
    }
    results_json_str = json.dumps(results_json)

    # Load to GCS
    storage_client = storage.Client()
    destination_bucket_name = os.environ["GCS_OUTPUT"]
    destination_bucket = storage_client.bucket(destination_bucket_name)
    results_json_blob = destination_bucket.blob(f"{object_name}.json")
    results_json_blob.upload_from_string(results_json_str)

    # Load to BigQuery (error handling omitted for brevity)
    bq_client = bigquery.Client()
    table_id = os.getenv("BQ_TABLE_ID")
    job_config = bigquery.LoadJobConfig(
        schema=[
            bigquery.SchemaField("document_file_name", "STRING"),
            bigquery.SchemaField("sentiment_score", "FLOAT"),
            bigquery.SchemaField("sentiment_magnitude", "FLOAT"),
            bigquery.SchemaField("sentences", "RECORD", mode="REPEATED", fields=[
                bigquery.SchemaField("text", "STRING"),
                bigquery.SchemaField("sentiment", "FLOAT"),
            ]),
        ],
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
    )
    uri = f"gs://{destination_bucket_name}/{object_name}.json"
    load_job = bq_client.load_table_from_uri(uri, table_id, job_config=job_config)
    load_job.result()


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