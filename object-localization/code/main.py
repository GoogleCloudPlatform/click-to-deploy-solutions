from google.cloud import bigquery, vision, storage
import functions_framework
import os
import json


def localize_objects(uri):
    """Localize objects in the image on Google Cloud Storage

    Args:
    uri: The path to the file in Google Cloud Storage (gs://...)
    """
    client = vision.ImageAnnotatorClient()
    response = client.annotate_image({
    'image': {'source': {'image_uri': uri}},
    'features': [{'type_': vision.Feature.Type.OBJECT_LOCALIZATION}]
    })

    print(response)


# Download file from GCS
def download_file(bucket_name, object_name):
    file_path = "/tmp/{}".format(object_name)
    print("download file to..."+file_path)
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(object_name)
    blob.download_to_filename(file_path)
    return file_path


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

    uri = "gs://{}/{}".format(bucket, name)
    localize_objects(uri)
