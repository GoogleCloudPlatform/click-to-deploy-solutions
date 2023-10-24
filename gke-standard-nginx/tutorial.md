# Leverage NGINX for Load Balancing in a Kubernetes Architecture

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
Next we are going to test the architecture and finally clean up your
environment.

## Testing your architecture 

In this example, we use an example domain (example.com), so you need to set the
NGINX IP in your `/etc/hosts` file in order to access the applications.

Go to the [GKE Services][8] and copy the external IP assigned to
`ingress-nginx-controller`, then add it to your local machine's `/etc/hosts`
alongside `<app>.example.com`, for example:

```txt
##
# Host Database
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost
34.95.133.118   jenkins.example.com
34.95.133.118   grafana.example.com
34.95.133.118   prometheus.example.com
```

Try looking at the grafana.example.com and you should be met with a [login screen][9].

## Cleaning up your environment 

The easiest way to remove all the deployed resources is to run the following
command in Cloud Shell:

```bash
gcloud builds submit . --config cloudbuild_destroy.yaml
```

The above command will delete the associated resources so there will be no
billable charges made afterwards.

## Congratulations 

You have completed the **Leverage NGINX for Load Balancing in a Kubernetes
Architecture** tutorial!

[1]: https://github.com/GoogleCloudPlatform/deploystack-gcs-to-bq-with-least-privileges/tree/main
[2]: https://cloud.google.com/resource-manager/docs/creating-managing-organization
[3]: https://cloud.google.com/billing/docs/how-to/manage-billing-account
[4]: https://cloud.google.com/resource-manager/docs/creating-managing-projects
[5]: https://cloud.google.com/billing/docs/how-to/modify-project
[6]: https://cloud.google.com/iam
[7]: https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role
[8]: https://console.cloud.google.com/kubernetes/discovery
[9]: https://github.com/GoogleCloudPlatform/click-to-deploy-solutions/raw/main/gke-standard-nginx/assets/grafana.png
