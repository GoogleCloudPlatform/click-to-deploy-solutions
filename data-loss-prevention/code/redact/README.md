# Redaction

This repository contains a Python Flask application that utilizes the Google Cloud Data Loss Prevention (DLP) API to redact sensitive information from text data. The application is designed to be deployed on Google Cloud Run and utilizes Artifact Registry for storing the application's container image.

## Functionality

The application receives text data via HTTP POST requests, typically triggered by a Pub/Sub message. It then processes the data using the following steps:

1. Receive Pub/Sub Message: The application listens for incoming HTTP POST requests containing a Pub/Sub message.
2. Extract Text Payload: The application extracts the textPayload from the Pub/Sub message data.
3. Redact Sensitive Data: The redact_dlp_item function uses the Google Cloud DLP API to identify and redact sensitive information within the textPayload. This includes redacting data types like:
   - PERSON_NAME
   - US_SOCIAL_SECURITY_NUMBER
   - EMAIL_ADDRESS
   - PHONE_NUMBER
4. Return Redacted Data: The application returns the redacted data as a JSON object.

## Deployment

### Prerequisites

- Google Cloud Project with necessary permissions.
- Google Cloud SDK installed and configured.
- Artifact Registry repository created.

### Deployment Steps:

Build the Docker image using the provided Dockerfile:

```sh
docker build -t gcr.io/<PROJECT_ID>/dlp-redaction-service .
```

Push the image to Artifact Registry:

```sh
docker push gcr.io/<PROJECT_ID>/dlp-redaction-service
```

Create Cloud Run Service:

```sh
gcloud run deploy dlp-redaction-service \
    --image gcr.io/<PROJECT_ID>/dlp-redaction-service \
    --region <REGION> \
    --platform managed
```

Configure Pub/Sub Trigger:

- Create a Pub/Sub topic and subscription.
- Configure the Cloud Run service to be triggered by the Pub/Sub subscription.

## Notes

- Replace `<PROJECT_ID>` with your Google Cloud project ID.
- Replace `<REGION>` with the desired Cloud Run region.
- Ensure that the Cloud Run service has the necessary permissions to access the Google Cloud DLP API.

## Usage

Once deployed, the Cloud Run service can be invoked by sending HTTP POST requests to its endpoint. The request body should contain a Pub/Sub message with the textPayload field containing the text data to be redacted.

Example Pub/Sub Message

```json
{
  "message": {
    "data": "eyJ0ZXh0UGF5bG9hZCI6Im15QGVtYWlsLmNvbSIsIm5hbWUiOiJNYXR0aGV3IFJvYmluc29uIn0="
  }
}
```

Example Redacted Response

```json
{
  "name": "[SENSITIVE DATA]"
}
```

This README provides a basic overview of the Google Cloud DLP Redaction Service. For more detailed information on Google Cloud DLP, Cloud Run, and Artifact Registry, please refer to the official Google Cloud documentation.
