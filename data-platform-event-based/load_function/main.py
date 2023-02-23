from google.cloud import storage
import functions_framework
from google.cloud import bigquery, storage
import os


def load_csv_to_bq(bucket, object):
    # Construct a BigQuery client object.
    client = bigquery.Client()

    project_id = os.environ['DW_PROJECT_ID']
    params = object.split("/")
    table_id = "{}.{}.{}".format(project_id, params[0], params[1])
    print(f"Table ID: {table_id}")

    job_config = bigquery.LoadJobConfig(
        autodetect=True,
        skip_leading_rows=1,
        # The source format defaults to CSV, so the line below is optional.
        source_format=bigquery.SourceFormat.CSV,
    )
    uri = "gs://{}/{}".format(bucket, object)

    load_job = client.load_table_from_uri(
        uri, table_id, job_config=job_config
    )  # Make an API request.

    load_job.result()  # Waits for the job to complete.

    destination_table = client.get_table(table_id)  # Make an API request.
    print("Table has now {} rows.".format(destination_table.num_rows))


def move_blob(bucket_name, blob_name):
    """Moves a blob from one bucket to another with a new name."""
    destination_bucket_name = os.environ['GCS_ARCHIVE_BUCKET']

    storage_client = storage.Client()
    source_bucket = storage_client.bucket(bucket_name)
    source_blob = source_bucket.blob(blob_name)
    destination_bucket = storage_client.bucket(destination_bucket_name)

    blob_copy = source_bucket.copy_blob(source_blob, destination_bucket, blob_name)
    source_bucket.delete_blob(blob_name)

    print(
        "Blob {} in bucket {} moved to blob {} in bucket {}.".format(
            source_blob.name,
            source_bucket.name,
            blob_copy.name,
            destination_bucket.name,
        )
    )


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

    if 'csv' in name:
        load_csv_to_bq(bucket, name)
        move_blob(bucket, name)
