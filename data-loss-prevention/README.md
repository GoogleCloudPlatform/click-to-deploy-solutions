# Protect you data using Data Loss Prevation

## Introduction

## Use cases

## Architecture

## Costs

## Deploy the architecture

Before we deploy the architecture, you will need the following information:

* The **project ID**

Once the repository is cloned please run the following command to install the prerequisistes:

```sh
sh prereq.sh
```

You will then be prompted to provide the project-id for the destination project.

After this is complete, you can kick off the Cloud Run application Generate Service with the following command:

```sh
gcloud run deploy generate-service --source code/generator/ --region us-central1 --update-env-vars PROJECT_ID=<PROJECT ID>
```

> **_NOTE:_**  When you run this command will need to answer if you want to create a new repository and if you allow unauthenticated invocations. Set `Y` to create the repository and `N` to unauthenticated invocations.

And now the applicaion Redact Service

```sh
gcloud run deploy redact-service --source code/redact/ --region us-central1 --update-env-vars PROJECT_ID=<PROJECT ID>
```

> **_NOTE:_**  When you run this command will need to answer if you allow unauthenticated invocations. Set `N` to unauthenticated invocations.

If you encounter errors when running these commands, please attempt to run them again in a clean project.

Now you need to create a log router that will intercept de generate-service's logs and send them to the Pub/Sub. The Pub/Sub will send every message to redact-service that will be responsible to mask the logs.

You need the redact-service's url, run this command to get it:

```sh
gcloud run services describe redact-service --region us-central1 --format 'value(status.url)'
```

And now you can run the following:

```sh
terraform apply -var project_id=<PROJECT ID>
```

Change the `<PROJECT ID>` for your project id.

## Result

At this point you should have successfully deployed the DLP project! This process may take a while to deploy, please do not close the window when deploying. Next we are going to test the architecture and finally clean up your environment.

## Testing your architecture

Once you deployed the solution successfully, let's test.

```sh
gcloud beta run services logs read redact-service --limit=20 --project <PROJECT ID> --region us-central1
```

Then, check the logs in the output.

Example:

```json
{
  'name': '[SENSITIVE DATA]',
  'email': '[SENSITIVE DATA]',
  'address': '1234 [SENSITIVE DATA]',
  'phone_number': '123456789',
  'ssn': '[SENSITIVE DATA]',
  'credit_card_number': '123456789'
}
```

## Cleaning up your environment

Execute the command below on Cloud Shell to destroy the resources.

```sh
terraform destroy -var project_id=<PROJECT ID>
```

To delete Cloud Run, execute this command:

```sh
gcloud run services delete redact-service --region us-central1
```

```sh
gcloud run services delete generate-service --region us-central1
```

Delete the images that were generated:

```sh
gcloud artifacts docker images delete us-central1-docker.pkg.dev/<PROJECT ID>/cloud-run-source-deploy/generate-service
```

```sh
gcloud artifacts docker images delete us-central1-docker.pkg.dev/<PROJECT ID>/cloud-run-source-deploy/redact-service
```

The above commands will delete the associated resources so there will be no billable charges made afterwards.

## Known issues

## Useful links
