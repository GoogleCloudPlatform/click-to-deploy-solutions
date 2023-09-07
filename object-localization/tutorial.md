# Identify Objects from Images using AI on Google Cloud

## Let's get started

This solution assumes you already have a project created and set up where you wish to host these resources.

**Time to complete**: About 6 minutes

Click the **Start** button to move to the next step.

## Prerequisites

* Have an [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization) set up in Google cloud.
* Have a [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account) set up.
* Have an existing [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) with [billing enabled](https://cloud.google.com/billing/docs/how-to/modify-project).

### Roles & Permissions

In order to spin up this architecture, you will need to be a user with the “__Project owner__” [IAM](https://cloud.google.com/iam) role on the existing project:

Note: To grant a user a role, take a look at the [Granting and Revoking Access](https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role) documentation.

## Spinning up the architecture

Before we deploy the architecture, you will need the following information:

* The __project ID__

Once the repository is cloned please run the following command to install the prerequisistes:

```bash
sh prereq.sh
```

You will then be prompted to provide the project-id for the destination project.

After this is complete, you can kick off the Cloud Build pipeline with the following command:

```bash
gcloud builds submit . --config cloudbuild.yaml
```

If you encounter errors when running these commands, please attempt to run them again in a clean project.

If you face a problem with the EventArc API during the deployment, please check out the next section

## Known Issues 
You might face the error below while running it for the first time.

```
Step #2 - "tf apply": │ Error: Error creating function: googleapi: Error 400: Cannot create trigger projects/doc-ai-test4/locations/us-central1/triggers/form-parser-868560: Invalid resource state for "": Permission denied while using the Eventarc Service Agent.

If you recently started to use Eventarc, it may take a few minutes before all necessary permissions are propagated to the Service Agent. Otherwise, verify that it has Eventarc Service Agent role.
```

It happens because the Eventarc permissions take some time to propagate. First, make sure you ran the pre-req.sh script. Then, wait some minutes and trigger the deploy job again

## Result

At this point you should have successfully deployed the foundations for a Three Tier Web Application!.

This process may take a while to deploy, please do not close the window when deploying.

Next we are going to test the architecture and finally clean up your environment.

## Testing your architecture
Once you deployed the solution successfully, upload an image to the image bucket using either Cloud Console or gsutil.

For example, you can download this <a href="https://cloud.google.com/static/vision/docs/images/bicycle.jpg"> image </a>, and upload it to GCS using the command below. Note you must to replace the bucket name.

```bash
gsutil cp bicycle.jpg gs://<YOUR PROJECT NAME>-images
```

Then, you can check the object localization results into a JSON file in the output bucket:

The BigQuery Transfer Service Job we create on this example runs every 15-min, and it will upload to BigQuery all image results in the output bucket. After it ran, you can check results on BigQuery.

Alternatively, feel free to trigger the job anytime by clicking on the RUN TRANSFER NOW button.

## Cleaning up your environment

Execute the command below on Cloud Shell to destroy the resources.

``` {shell}
gcloud builds submit . --config cloudbuild_destroy.yaml
```

The above command will delete the associated resources so there will be no billable charges made afterwards.

## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

You’re all set!