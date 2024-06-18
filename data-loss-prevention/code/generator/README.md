# Data Generator

This application generates fake personal data and logs it to the console. It's designed to be deployed on Google Cloud Run and uses Artifact Registry for storing the container image.

## Features

- **Generates fake personal data:** Uses the Faker library to generate random names, emails, addresses, phone numbers, SSNs, and credit card numbers.
- **Scheduled execution:** Runs the data generation process every 60 seconds using APScheduler.
- **Cloud Run deployment:** Designed for easy deployment on Google Cloud Run.
- **Artifact Registry integration:** Stores the container image in Artifact Registry for efficient deployment and versioning.

## Deployment

- **Create a Google Cloud Project:** If you don't have one already, create a new Google Cloud project.
- **Enable Cloud Run and Artifact Registry APIs:** Enable the Cloud Run and Artifact Registry APIs in your project.
- **Create an Artifact Registry Repository:** Create a new Artifact Registry repository to store your container image.
- **Build the Container Image:**
  - Build a Dockerfile for your application.
  - Use the `gcloud builds submit` command to build the container image and push it to your Artifact Registry repository.
- **Deploy to Cloud Run:**
  - Use the `gcloud run deploy command` to deploy your application to Cloud Run.
  - Specify the container image location from your Artifact Registry repository.
  - Configure the necessary environment variables, such as the port number.

## Example Deployment Commands

Build the container image and push to Artifact Registry

```sh
gcloud builds submit --tag us-docker.pkg.dev/<PROJECT_ID>/<REGION>/<REPOSITORY_NAME>/<IMAGE_NAME>:<TAG> .
```

Deploy to Cloud Run

```sh
gcloud run deploy <SERVICE_NAME> \
  --image us-docker.pkg.dev/<PROJECT_ID>/<REGION>/<REPOSITORY_NAME>/<IMAGE_NAME>:<TAG> \
  --region <REGION> \
  --platform managed \
  --port 8080
```

## Usage

Once deployed, your Cloud Run service will be accessible via a public URL. The application will generate fake personal data every 60 seconds and log it to the console.

## Notes

- This application is for demonstration purposes only and should not be used to generate real personal data.
- The generated data is logged to the console and is not stored persistently.
- You can customize the data generation process by modifying the `generate_person()` function.
- Consider using a more robust logging solution for production environments.

This README provides a basic overview of the application and its deployment process. For more detailed information on Google Cloud Run, Artifact Registry, and other related services, refer to the official Google Cloud documentation.
