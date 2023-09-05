from google.cloud import bigquery, vision, storage
import functions_framework
import os
import json


def detect_objects_uri(uri):
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


def save_results(object_name, vision_results):
    """
    Parse objects detected to json and save it into the GCS bucket set on GCS_OUTPUT
    """
    print("Process output started.")
    bucket_name = os.getenv("GCS_OUTPUT")
    storage_client = storage.Client()
    destination_bucket = storage_client.bucket(bucket_name)

    print("Saving results...")
    print(vision_results)
    results_json = json.dumps(vision_results)
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
    vision_results = {
        "object_name": name,
        "objects": detect_objects_uri(uri),
        "labels": detect_labels_uri(uri),
        "logos": detect_logos_uri(uri),
        "safe_search": detect_safe_search_uri(uri)
    }

    save_results(name, vision_results)
    print("Object localization completed sucessfully")


def detect_labels_uri(uri):
    """Provides a quick start example for Cloud Vision."""

    # Instantiates a client
    client = vision.ImageAnnotatorClient()

    image = vision.Image()
    image.source.image_uri = uri

    # Performs label detection on the image file
    response = client.label_detection(image=image)
    labels = response.label_annotations

    label_results = []
    for label in labels:
        label_results.append(
            {"label": label.description, "score": label.score})
    return label_results


def detect_logos_uri(uri):
    """Detects logos in the file located in Google Cloud Storage or on the Web."""
    from google.cloud import vision

    client = vision.ImageAnnotatorClient()
    image = vision.Image()
    image.source.image_uri = uri

    response = client.logo_detection(image=image)
    logos = response.logo_annotations

    logo_results = []
    for logo in logos:
        logo_results.append({"label": logo.description, "score": logo.score})

    if response.error.message:
        raise Exception(
            "{}\nFor more info on error messages, check: "
            "https://cloud.google.com/apis/design/errors".format(
                response.error.message)
        )
    return logo_results


def detect_safe_search_uri(uri):
    """Detects unsafe features in the file located in Google Cloud Storage or
    on the Web."""
    from google.cloud import vision

    client = vision.ImageAnnotatorClient()
    image = vision.Image()
    image.source.image_uri = uri

    response = client.safe_search_detection(image=image)
    safe = response.safe_search_annotation

    # Names of likelihood from google.cloud.vision.enums
    likelihood_name = (
        "UNKNOWN",
        "VERY_UNLIKELY",
        "UNLIKELY",
        "POSSIBLE",
        "LIKELY",
        "VERY_LIKELY",
    )

    if response.error.message:
        raise Exception(
            "{}\nFor more info on error messages, check: "
            "https://cloud.google.com/apis/design/errors".format(
                response.error.message)
        )

    safe_search = {
        "adult": likelihood_name[safe.adult],
        "medical": likelihood_name[safe.medical],
        "spoofed": likelihood_name[safe.spoof],
        "violence": likelihood_name[safe.violence],
        "racy": likelihood_name[safe.racy]
    }

    return safe_search
