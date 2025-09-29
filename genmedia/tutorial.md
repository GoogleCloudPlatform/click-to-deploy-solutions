# Build a Media Generation tool

## Let's get started

This solution assumes you already have a project created and set up where you wish to host these resources.

**Time to complete**: About 20 minutes

Click the **Start** button to move to the next step.

## Prerequisites

* Have an [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization) set up in Google cloud.
* Have a [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account) set up.
* Have an existing [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) with [billing enabled](https://cloud.google.com/billing/docs/how-to/modify-project).

### Roles & Permissions

In order to spin up this architecture, you will need to be a user with the “__Project owner__” [IAM](https://cloud.google.com/iam) role on the existing project.

**Note**: 
1. To grant a user a role, take a look at the [Granting and Revoking Access](https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role) documentation.
2. If you have the [domain restriction org policy](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains) on your organization, you have to edit the cloud_run_invoker variable to align with the policy. Alternatively, you can remove the policy inheritance to allow public access to your Cloud Run instance.

## Deploy the architecture

1. Run the prerequisites script to enable APIs and set Cloud Build permissions. You may need to re-run scripts if they're not completed successfully the first time.
```bash
sh prereq.sh
```
2. Run the Cloud Build Job
```bash
gcloud builds submit . --config ./build/cloudbuild.yaml
```

## Result

Once deployment is completed, terraform will output the app URL as: **cloud_run_service_url = "https://genmedia-app-xxxxxxxx.a.run.app"**.

Alternatively, you can find the app URL under services [Cloud Run](https://console.cloud.google.com/run).


## Cleaning up your environment

Execute the command below on Cloud Shell to destroy the resources.

``` {shell}
gcloud builds submit . --config ./build/cloudbuild_destroy.yaml
```

The above command will delete the associated resources so there will be no billable charges made afterwards.


## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

You’re all set!
