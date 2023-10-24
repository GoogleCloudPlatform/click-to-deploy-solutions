# Build an auto scaling application easily with GKE autopilot

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

> __Note__: To grant a user a role, take a look at the [Granting and Revoking Access][7] documentation.

## Deploy the architecture 

1. Before we deploy the architecture, you will need to set the **Project ID**.

```bash
gcloud config set project PROJECT_ID
```

2. Run the prerequisites script to enable APIs and set Cloud Build permissions.

```bash
sh prereq.sh
```

3. Run the Cloud Build Job

```bash
gcloud builds submit . --config cloudbuild.yaml
```

Next we are going to test the architecture and finally clean up your environment. 

## Testing your architecture 

Once you have deployed the solution, you can run a load test and see the HPA in
action.

Go to the [Workloads][8] page and see the `hpa-example` application
has one replica. After the script is finished you may see that the pods have not
been finished spinning up. It may take an additional few minutes to see the pods
update.

To run the load test and see the HPA working, go back to the Cloud Shell
console, then run the load test script:

```bash
HPA_LB_IP=$(gcloud compute addresses describe hpa-lb-ip --global --format='value(address)')
sh load_test.sh $HPA_LB_IP
```

The script will call the service many times causing the CPU to cross the target
defined in the HPA for scaling out. This can be seen on the
[Workloads][8] page once selecting the `hpa-example`.

## Cleaning up your environment 

The easiest way to remove all the deployed resources is to run the following
command in Cloud Shell:

```bash
gcloud builds submit . --config cloudbuild_destroy.yaml
```

The above command will delete the associated resources so there will be no
billable charges made afterwards.

## Congratulations 

You have completed the **Build an auto scaling application easily with GKE
autopilot** tutorial!

[1]: https://github.com/googlestaging/deploystack-gcs-to-bq-with-least-privileges
[2]: https://cloud.google.com/resource-manager/docs/creating-managing-organization
[3]: https://cloud.google.com/billing/docs/how-to/manage-billing-account
[4]: https://cloud.google.com/resource-manager/docs/creating-managing-projects
[5]: https://cloud.google.com/billing/docs/how-to/modify-project
[6]: https://cloud.google.com/iam
[7]: https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role
[8]: https://console.cloud.google.com/kubernetes/workload/overview
