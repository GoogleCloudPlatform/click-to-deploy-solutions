# Build a GenAI for Marketing tool

## Let's get started 

This solution assumes you already have a project created and set up where you wish to host these resources.

**Time to complete**: About 15 minutes

Click the **Start** button to move to the next step.

## Prerequisites 

- Have an [organization][2] set up in Google cloud.
- Have a [billing account][3] set up.
- Have an existing [project][4] with [billing
  enabled][5], we'll call this the **service project**.

### Roles & Permissions 

In order to spin up this architecture, you will need to be a user with the
**Project Owner** [IAM][6] role on the existing project.

> __Note__: To grant a user a role, take a look at the [Granting and Revoking Access][7] documentation.

## Deploy the architecture 

1. Before we deploy the architecture, you will need to set the **Project ID**.

```bash
gcloud config set project PROJECT_ID
```

2. Once the repository is cloned please run the prerequisites script to enable APIs and set Cloud Build permissions.

```bash
sh prereq.sh
```


Next, you'll be asked to enter the project ID of the destination project. Please provide the project ID when prompted.

## Result

Congratulations! The GenAI for marketing project deployment should now be underway. Please be patient as this process might take some time. Kindly keep this window open during the deployment. Once completed, we'll proceed to test the architecture and then guide you through cleaning up your environment.

## Cleaning up your environment

The below command will delete the associated resources so there will be no billable charges made afterwards.

```sh
terraform destroy -auto-approve
```

## Congratulations 

You have completed the **Build a GenAI for marketing tool** tutorial!

[1]: https://github.com/googlestaging/deploystack-gcs-to-bq-with-least-privileges
[2]: https://cloud.google.com/resource-manager/docs/creating-managing-organization
[3]: https://cloud.google.com/billing/docs/how-to/manage-billing-account
[4]: https://cloud.google.com/resource-manager/docs/creating-managing-projects
[5]: https://cloud.google.com/billing/docs/how-to/modify-project
[6]: https://cloud.google.com/iam
[7]: https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role

