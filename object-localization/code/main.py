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

    objects = []
    for x in response.localized_object_annotations:
        obj = {"name": x.name, "score": x.score}
        objects.append(obj)
    return objects


def save_results(object_name, objects):
    """
    Parse objects detected to json and save it into the GCS bucket set on GCS_OUTPUT
    """
    print("Process output started.")
    bucket_name = os.getenv("GCS_OUTPUT")
    storage_client = storage.Client()
    destination_bucket = storage_client.bucket(bucket_name)

    print("Saving results...")
    results_json = {
        "file_name": object_name,
        "objects": objects
    }
    results_json = json.dumps(results_json)
    results_json_name = "{}.json".format(object_name)
    results_json_blob = destination_bucket.blob(results_json_name)
    results_json_blob.upload_from_string(results_json)


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
    objects = localize_objects(uri)
    save_results(name, objects)

    print("Object localization completed sucessfully")
