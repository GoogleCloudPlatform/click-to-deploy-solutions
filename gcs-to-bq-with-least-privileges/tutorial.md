# Foundation Data Pipeline with Google Cloud

## Let's get started

This solution assumes you already have a project created and set up where you
wish to host these resources. If not, and you would like for the project to
create a new project as well, please refer to the [github
repository][1] for instructions.

**Time to complete**: About 10 minutes

Click the **Start** button to move to the next step.

## Prerequisites

- Have an [organization][2] set up in Google cloud.
- Have a [billing account][3] set up.
- Have an existing [project][4] with [billing
  enabled][5], we'll call this the **service project**.

### Roles & Permissions

In order to spin up this architecture, you will need to be a user with the
**Project Owner** [IAM][6] role on the existing project.

>__Note__: To grant a user a role, take a look at the [Granting and Revoking Access][7] documentation.

## Spinning up the architecture

1. Before we deploy the architecture, you will need to set the **Project ID**.

```bash
export PROJECT_ID=[PROJECT_ID]
```

2. Run the prerequisites script to enable APIs and set Cloud Build permissions.

```bash
sh prereq.sh
```

3. Run the Cloud Build Job

```bash
gcloud builds submit . --config ./build/cloudbuild.yaml
```

Next we are going to test the architecture and finally clean up your environment.

## Testing your architecture

For the purpose of the example we will import a CSV file from GCS to BigQuery.
You can copy the example files from .`/app/demo-data` into the GCS bucket by
running:

```bash
gcloud storage cp --recursive ./app/demo-data/* gs://$PROJECT_ID-data/
```

After completion, the three essential files required to execute the Dataflow Job
will be copied to the GCS bucket created alongside the resources.

Run the following command to start the dataflow job:

```bash
gcloud dataflow jobs run test_batch_01 \
    --gcs-location gs://dataflow-templates/latest/GCS_Text_to_BigQuery \
    --project $PROJECT_ID \
    --region europe-west1 \
    --disable-public-ips \
    --subnetwork https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/regions/europe-west1/subnetworks/subnet \
    --staging-location gs://$PROJECT_ID-df-tmp \
    --service-account-email df-loading@$PROJECT_ID.iam.gserviceaccount.com \
    --parameters \
javascriptTextTransformFunctionName=transform,\
JSONPath=gs://$PROJECT_ID-data/person_schema.json,\
javascriptTextTransformGcsPath=gs://$PROJECT_ID-data/person_udf.js,\
inputFilePattern=gs://$PROJECT_ID-data/person.csv,\
outputTable=$PROJECT_ID:datalake.person,\
bigQueryLoadingTemporaryDirectory=gs://$PROJECT_ID-df-tmp

```

Once the job completes, you can navigate to BigQuery in the console and under
**PROJECT_ID** → datalake → person, you can see the data that was successfully
imported into BigQuery through the Dataflow job.

## Cleaning up your environment

The easiest way to remove all the deployed resources is to run the following
command in Cloud Shell:

```bash
gcloud builds submit . --config ./build/cloudbuild_destroy.yaml
```

The above command will delete the associated resources so there will be no
billable charges made afterwards.

## Congratulations

You have completed the **Foundation Data Pipeline with Google Cloud** tutorial!

[1]: https://github.com/GoogleCloudPlatform/click-to-deploy-solutions/tree/main/gke-autopilot-hpa
[2]: https://cloud.google.com/resource-manager/docs/creating-managing-organization
[3]: https://cloud.google.com/billing/docs/how-to/manage-billing-account
[4]: https://cloud.google.com/resource-manager/docs/creating-managing-projects
[5]: https://cloud.google.com/billing/docs/how-to/modify-project
[6]: https://cloud.google.com/iam
[7]: https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role
