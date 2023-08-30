[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)


# Host a Highly Available SQL database on Google Cloud

## Introduction

This architecture uses click-to-deploy to demonstrate how to deploy a Cloud SQL instance with high-availability and cross-region replica.

With data being a vital asset for organizations, the high availability and disaster recovery capabilities offered by Cloud SQL allow businesses to meet stringent data availability and regulatory requirements.

By implementing this solution, organizations gain peace of mind knowing that their critical databases are protected and accessible, even during unforeseen events or outages. This solution ensures business continuity by minimizing downtime, providing robust data protection through automated backups, and enabling seamless failover and disaster recovery processes.

This solution is suitable for a wide range of applications and industries, including e-commerce platforms, financial systems, customer relationship management (CRM) tools, and more.

## Use cases

These are some examples of the use cases you can build on top of this architecture:

* __Any application that requires a highly available database__
* __Financial Systems__ : Financial institutions and organizations dealing with sensitive financial data require robust data protection and uninterrupted access to their databases. Cloud SQL's high availability and disaster recovery solution offers the necessary safeguards to ensure the continuous availability of financial systems.

* __Healthcare and Life Sciences Applications__ : Applications in the healthcare and life sciences domains handle sensitive patient data, research findings, and critical medical information. Cloud SQL's high availability and disaster recovery solution provides the necessary infrastructure to protect and ensure the availability of this data.

* __ECommerce Platforms__ : ECommerce businesses heavily rely on continuous access to their databases to manage product inventory, process transactions, and provide a seamless shopping experience. With Cloud SQL's high availability and disaster recovery solution, ECommerce platforms can ensure uninterrupted database access, protect against data loss, and quickly recover from potential disasters.


## Architecture

<p align="center"><img src="architecture.png"></p>

The main components that we would be setting up are (to learn more about these products, click on the hyperlinks).

* [VPC](https://cloud.google.com/vpc) : Global virtual network that spans all regions. Single VPC for an entire organization, isolated within projects. Increase IP space with no downtime.
* Cloud SQL for Postgres instance with [high-availability](https://cloud.google.com/sql/docs/postgres/high-availability) : The purpose of an HA configuration is to reduce downtime when a zone or instance becomes unavailable. 
* Cloud SQL [cross-region read replica](https://cloud.google.com/sql/docs/postgres/intro-to-cloud-sql-disaster-recovery) instance : database disaster recovery (DR) is about providing continuity of processing, specifically when a region fails or becomes unavailable.


## Costs

Pricing Estimates - We have created a sample estimate based on some usage we see from new startups looking to scale. This estimate would give you an idea of how much this deployment would essentially cost per month at this scale and you extend it to the scale you further prefer. Here's the [link](https://cloud.google.com/products/calculator/#id=35b50e4b-8292-43b7-b909-d29213b80fea).

## Deploy

:clock1: Estimated deployment time: 16 min 30 sec

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=cloudsql-ha-dr&cloudshell_open_in_editor=terraform/terraform.tfvars" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the prerequisites script to enable APIs and set Cloud Build permissions.
```
sh prereq.sh
```

3. Run the Cloud Build Job
```
gcloud builds submit . --config cloudbuild.yaml
```

## Testing

1. Test the Cloud SQL instance high availability by initiating a failover, causing the instance fails over and unavailable to serve data for a few minutes.
```
gcloud sql instances failover INSTANCE_NAME
```
2. Verify that the Cloud SQL instance has high availability configuration.
```
gcloud sql instances describe INSTANCE_NAME
```
The output should indicate availabilityType as REGIONAL. The gceZone and secondaryGceZone fields should show the current primary and secondary zones of the instance

## Destroy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=cloudsql-ha-dr" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the command below on Cloud Shell to destroy the resources.
```
gcloud builds submit . --config cloudbuild_destroy.yaml
```
