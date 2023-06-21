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

## Use cases

These are some examples of the use cases you can build on top of this architecture:

* __Extracting data from a variety of sources__: Cloud Composer can be used to extract data from a variety of sources, including CSV files, JSON files, databases, and web APIs.

* __Transforming data__: Cloud Composer can be used to transform data in a variety of ways, including cleaning, filtering, and aggregating data.

* __Data integration from multiple sources__: Businesses often have data stored in various places, such as databases, third-party APIs, or log files. A data pipeline using Cloud Composer and BigQuery can integrate data from these different sources, harmonize it, and transform it into a unified format that is suitable for analysis. This ensures a consistent and reliable data source for decision-making.

* __Data warehousing and reporting__: Businesses often require a central data repository for storing and querying data. BigQuery, a fully managed data warehouse, provides fast and scalable storage and powerful querying capabilities. Businesses can automate the process of loading data into BigQuery by combining Cloud Composer's workflow orchestration capabilities, ensuring timely and accurate data updates for reporting and analysis purposes.
 
* __Data Quality and Governance__: A data pipeline can also be used to ensure data quality and compliance rules are met before loading data into BigQuery. Cloud Composer allows businesses to implement validation checks, data quality controls, and data cleansing processes as part of the data pipeline workflow. This guarantees that only high-quality and reliable data is loaded into BigQuery, enhancing the accuracy and integrity of analytical insights.

## Architecture

<p align="center"><img src="architecture.png"></p>

The main components that we would be setting up are (to learn more about these products, click on the hyperlinks)

* [VPC](https://cloud.google.com/vpc) : Global virtual network that spans all regions. Single VPC for an entire organization, isolated within projects. Increase IP space with no downtime.
* [Cloud Composer v2](https://cloud.google.com/composer) : A fully managed workflow orchestration service built on Apache Airflow.
* [Cloud SQL for Postgres](https://cloud.google.com/sql) :  Fully managed relational database service for MySQL, PostgreSQL, and SQL Server with rich extension collections, configuration flags, and developer ecosystems.
* [Cloud Storage (GCS) bucket](https://cloud.google.com/storage/) : Cloud Storage is a managed service for storing unstructured data. Store any amount of data and retrieve it as often as you like.
* [BigQuery datasets and tables ](https://cloud.google.com/bigquery): BigQuery is a serverless and cost-effective enterprise data warehouse that works across clouds and scales with your data. Use built-in ML/AI and BI for insights at scale. 

Check more operators available in [Airflow Google Operators doc](https://airflow.apache.org/docs/apache-airflow-providers-google/stable/operators/index.html).


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
