# Three-tier web application with Google Kubernetes Engine (GKE)

## Let's get started

This solution assumes you already have a project created and set up where you wish to host these resources.

**Time to complete**: About 20 minutes

Click the **Start** button to move to the next step.

## Prerequisites

* Have an [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization) set up in Google cloud.
* Have a [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account) set up.
* Have an existing [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) with [billing enabled](https://cloud.google.com/billing/docs/how-to/modify-project).

### Roles & Permissions

In order to spin up this architecture, you will need to be a user with the “__Project owner__” [IAM](https://cloud.google.com/iam) role on the existing project:

Note: To grant a user a role, take a look at the [Granting and Revoking Access](https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role) documentation.

## Deploy the architecture

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

## Result

At this point you should have successfully deployed the foundations for a Three Tier Web Application!.

This process may take a while to deploy, please do not close the window when deploying.

Next we are going to test the architecture and finally clean up your environment.

## Testing your architecture
After you deployed the solution, you can check the resources created and see how they work together.
 
First, go to <a href="https://console.cloud.google.com/kubernetes"> Google Kubernetes Engine <a> and click on the created Cluster.

You can see all the details of you applications in Workloads menu

Then, go to <a href="https://console.cloud.google.com/net-services/loadbalancing/list/loadBalancers"> Cloud Load Balancing </a> and click on the frontend Load Balancer

You can see all the details of the Load Balancer, and you can copy the Frontend IP section to access the application.

Finally, if you paste the ip and enter in your browser, you see the example application

## Cleaning up your environment

Execute the command below on Cloud Shell to destroy the resources.

``` {shell}
gcloud builds submit . --config cloudbuild_destroy.yaml
```

The above command will delete the associated resources so there will be no billable charges made afterwards.


## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

You’re all set!