# Streaming Data to Analytics

## Description

This example demonstrates how to stream data from your application to BigQuery using Pub/sub.

Resources created:
- BigQuery dataset and table
- Pub/Sub topic and BQ subscription
- Cloud Run Ingest API

## Pre-req
The ingest API uses private docker image, so before running the terraform, make sure you:
1. Build [this docker image](https://github.com/sylvioneto/gcp-ingest-api) and store it into your project
2. Replace the image URL in [cloud_run.tf](./terraform/variables.tf#L24)


## Deploy

1. Create a new project and select it
2. Open Cloud Shell and ensure the env var below is set, otherwise set it with `gcloud config set project` command
```
echo $GOOGLE_CLOUD_PROJECT
```

3. Create a bucket to store your project's Terraform state
```
gsutil mb gs://$GOOGLE_CLOUD_PROJECT-tf-state
```

4. Enable the necessary APIs
```
gcloud services enable bigquery.googleapis.com \
    bigquerydatatransfer.googleapis.com \
    cloudfunctions.googleapis.com \
    pubsub.googleapis.com \
    run.googleapis.com \
    storage.googleapis.com
```

5. Give permissions to Cloud Build for creating the resources
```
PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format='value(projectNumber)')
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/editor
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role=roles/iam.securityAdmin
```

6. Clone this repo
```
git clone https://github.com/sylvioneto/gcp-streaming-data.git
cd ./gcp-streaming-data
```

7. Execute Terraform using Cloud Build
```
gcloud builds submit . --config cloudbuild.yaml
```

## Destroy
1. Execute Terraform using Cloud Build
```
gcloud builds submit . --config cloudbuild_destroy.yaml
```


## Load Test
If you want to run a load test, please follow the instructions below.

1. Set GCP_TOKEN env var
```
export GCP_TOKEN=$(gcloud auth print-identity-token)
```

2. Create a python virtual env and activate it
```
cd load_test
python3 -m virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
```

3. Run locust with your Cloud Run Service URL as target, for example:
```
locust -f locustfile.py --headless -u 100 -r 10 \
    --run-time 30m \
    -H https://ingest-api-myuq-ue.a.run.app/
```
