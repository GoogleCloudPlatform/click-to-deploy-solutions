[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)


# Host a Highly Available SQL database on Google Cloud

## Introduction

This architecture uses click-to-deploy to demonstrate how to deploy a CloudSQL instance with high-availability and cross-region replica

With data being a vital asset for organizations, the high availability and disaster recovery capabilities offered by Cloud SQL allow businesses to meet stringent data availability and regulatory requirements.

By implementing this solution, organizations gain peace of mind knowing that their critical databases are protected and accessible, even during unforeseen events or outages. This solution ensures business continuity by minimizing downtime, providing robust data protection through automated backups, and enabling seamless failover and disaster recovery processes.

This solution is suitable for a wide range of applications and industries, including e-commerce platforms, financial systems, customer relationship management (CRM) tools, and more.

Resources created:
- VPC
- CloudSQL for Postgres instance with [high-availability](https://cloud.google.com/sql/docs/postgres/high-availability)
- CloudSQL [cross-region read replica](https://cloud.google.com/sql/docs/postgres/intro-to-cloud-sql-disaster-recovery) instance

## Use cases

These are some examples of the use cases you can build on top of this architecture:

* __Any application that requires a highly available database__
* __Financial Systems__ : Financial institutions and organizations dealing with sensitive financial data require robust data protection and uninterrupted access to their databases. Cloud SQL's high availability and disaster recovery solution offers the necessary safeguards to ensure the continuous availability of financial systems.

* __Healthcare and Life Sciences Applications__ : Applications in the healthcare and life sciences domains handle sensitive patient data, research findings, and critical medical information. Cloud SQL's high availability and disaster recovery solution provides the necessary infrastructure to protect and ensure the availability of this data.

* __ECommerce Platforms__ : ECommerce businesses heavily rely on continuous access to their databases to manage product inventory, process transactions, and provide a seamless shopping experience. With Cloud SQL's high availability and disaster recovery solution, ECommerce platforms can ensure uninterrupted database access, protect against data loss, and quickly recover from potential disasters.

:clock1: Estimated deployment time: 16 min 30 sec

:heavy_dollar_sign: Estimated solution cost: [USD 706.44 per 1 month](https://cloud.google.com/products/calculator/#id=358b4a68-4f82-4e88-84f4-1da99a05548b)


## Architecture

<p align="center"><img src="architecture.png"></p>

The main components that we would be setting up are (to learn more about these products, click on the hyperlinks).

* [VPC](https://cloud.google.com/vpc) : Global virtual network that spans all regions. Single VPC for an entire organization, isolated within projects. Increase IP space with no downtime.
* CloudSQL for Postgres instance with [high-availability](https://cloud.google.com/sql/docs/postgres/high-availability) : The purpose of an HA configuration is to reduce downtime when a zone or instance becomes unavailable. 
* CloudSQL [cross-region read replica](https://cloud.google.com/sql/docs/postgres/intro-to-cloud-sql-disaster-recovery) instance : database disaster recovery (DR) is about providing continuity of processing, specifically when a region fails or becomes unavailable.


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
