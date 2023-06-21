[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Extract Objects from Images using AI on Google Cloud

## Introduction

This architecture uses click-to-deploy so you can spin up a solution for detecting objects on images with Cloud Vision API

This architecture harnesses the power of Google Cloud Vision API to detect and extract objects from images with precise object localization. This architecture provides a robust and efficient solution for applications that require accurate object recognition and extraction capabilities.

At the core of this architecture is the Cloud Vision API, a powerful machine learning-based service that analyzes images to detect objects and their spatial location within the image. By leveraging state-of-the-art computer vision algorithms, the API can accurately identify and localize objects, providing bounding boxes that outline their exact positions.

In this example, the user uploads images to a bucket. This event triggers the Vision API that analyzes the image and saves the object detection results into a JSON file on Google Cloud Storage. BigQuery Transfer Service loads JSONs from the output bucket to a BigQuery table.

<p align="center"><img src="https://cloud.google.com/static/vision/docs/images/bicycle.jpg"></p>

<p align="center"><b>Image credit: <a href="https://unsplash.com/photos/J9cBJjlpYKU"> Bogdan Dada </a> on <a href="https://unsplash.com/">Unsplash </a>(annotations added).</b> </p>


:clock1: Estimated deployment time: 6 min

## Architecture
![architecture](architecture.png)

## Deploy

1. Click on Open in Google Cloud Shell button below.

<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=object-localization" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script and follow the instructions
```
sh cloudbuild.sh
```

## Testing 

Once you deployed the solution successfully, upload an image to the image bucket using either Cloud Console or `gsutil`.
```
gsutil cp my_image.png gs://<YOUR PROJECT NAME>-images
```

Then, you can check the object localization results into a JSON file in the output bucket:

![gcs_results](gcs_results.png)

The [BigQuery Transfer Service Job](https://console.cloud.google.com/bigquery/transfers) runs every 15-min, after it ran, you can check results on BigQuery.

![bq_results](bq_results.png)

## Destroy
Execute the command below on Cloud Shell to destroy the resources.
```
sh cloudbuild.sh destroy
```

## Known issues

You might face the error below while running it for the first time.

```
Step #2 - "tf apply": │ Error: Error creating function: googleapi: Error 400: Cannot create trigger projects/doc-ai-test4/locations/us-central1/triggers/form-parser-868560: Invalid resource state for "": Permission denied while using the Eventarc Service Agent.

If you recently started to use Eventarc, it may take a few minutes before all necessary permissions are propagated to the Service Agent. Otherwise, verify that it has Eventarc Service Agent role.
```

That happens because the Eventarc permissions take time to propagate. Please wait some minutes and try again.

## Useful links
- [Form Parsing with Object Detection](https://codelabs.developers.google.com/codelabs/docai-form-parser-v1-python#0)
- [Use a Object Detection para processar seus formulários escritos à mão de maneira inteligente (Python)](https://codelabs.developers.google.com/codelabs/docai-form-parser-v3-python?hl=pt-br#0) (Portuguese)

