[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)


# Easily Orchestrate and Manage an ETL Pipeline in Google Cloud 

## Introduction

This architecture uses click-to-deploy so you can spin up infrastructure in minutes using terraform!

The data analytics world relies on ETL and ETL pipelines to derive meaningful insights from data. Data engineers and ETL developers are often required to build dozens of interdependent pipelines as part of their data platform, but orchestrating, managing, and monitoring all these pipelines can be quite a challenge.

Cloud Composer is the answer to this challenge. To guarantee reliability and fault tolerance, Cloud Composer automatically handles task scheduling, monitoring, and retries. It provides built-in support for managing dependencies between tasks, allowing us to easily orchestrate the entire ETL workflow. Additionally, Cloud Composer offers monitoring and alerting capabilities, allowing us to track the progress of our pipeline and take the necessary actions if any problems arise.

In conclusion, our cloud ETL pipeline powered by Cloud Composer is a powerful and scalable solution for extracting, transforming, and loading data. It offers a wide range of features, including data source integration, transformation capabilities, fault tolerance, scalability, and seamless integration with other cloud services.

The following click-to-deploy architecture demonstrates how to use Cloud Composer to:

- [Restore a Postgres backup](./dags/postgres_restore.py)
- [Extract data from Postgres and load to Cloud Storage (Data Lake)](./dags/postgres_to_datalake.py)
- [Load data from Cloud Storage (Data Lake) to BigQuery (Data Warehouse)](./dags/datalake_to_dw.py)
- [Transform data on BigQuery](./dags/bigquery_transform.py)

Resources created:
- VPC with firewall rules
- Cloud Composer v2
- Cloud SQL for Postgres
- Cloud Storage Buckets
- BigQuery datasets and tables


:clock1: Estimated deployment time: 26 min 48 sec

:heavy_dollar_sign: Estimated solution cost: [USD 583.04 per 1 month](https://cloud.google.com/products/calculator/#id=f7caffab-fca3-490e-8654-f406df790929)


## Architecture
Please find below a reference architecture.
![architecture](architecture.png)

## Deploy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=cloud-composer-etl" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script and follow the instructions
```
sh cloudbuild.sh
```

Once it is finished, you can go to [Cloud Composer](https://console.cloud.google.com/composer/environments) to see the dags' results and explore the Cloud Composers's functionalities.


## Destroy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=cloud-composer-etl" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script with `destroy` argument
```
sh cloudbuild.sh destroy
```
