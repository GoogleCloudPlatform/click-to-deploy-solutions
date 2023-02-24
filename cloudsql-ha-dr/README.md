# Cloud SQL with High Availability and Disaster Recovery  

## Description

This example demonstrates how to deploy a CloudSQL instance with high-availability and cross-region replica.

Resources created:
- VPC
- CloudSQL for Postgres instance with [high-availability](https://cloud.google.com/sql/docs/postgres/high-availability)
- CloudSQL [cross-region read replica](https://cloud.google.com/sql/docs/postgres/intro-to-cloud-sql-disaster-recovery) instance

## Architecture
Please find below a reference architecture.
![architecture](architecture.png)


## Deploy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=cloudsql-ha-dr" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script and follow the instructions
```
sh cloudbuild.sh
```


## Destroy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=cloudsql-ha-dr" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script with `destroy` argument
```
sh cloudbuild.sh destroy
```
