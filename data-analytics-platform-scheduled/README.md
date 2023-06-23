[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Automate transfer of data between Data Lake and Data Warehouse on Google Cloud

## Introduction

This architecture uses click-to-deploy to load files from your Data Lake on Google Cloud Storage (GCS) to your Data Warehouse on BigQuery using scheduled jobs

At the core of this architecture is Google Cloud Storage (GCS), a highly scalable and durable object storage service, serving as the central repository for storing raw or structured data in the Data Lake.

The data loading process is orchestrated through [scheduled jobs](https://cloud.google.com/bigquery/docs/dts-introduction), which are automated tasks that run at predefined intervals. These jobs are responsible for extracting data from GCS and loading it into BigQuery, a fully managed, serverless data warehouse provided by Google Cloud. BigQuery offers powerful querying and analytics capabilities, enabling organizations to gain valuable insights from their data.

The following are some examples of how this architecture can be used to make processes more efficient and reduce manual labor:

* Automate the process of loading data from GCS into BigQuery on a daily, weekly, or monthly basis.

* Organizations can also use the architecture to load data from GCS into BigQuery in real time. This can be useful for organizations that need to analyze data as it is being generated, such as for fraud detection or customer churn prediction.

* Load data from GCS into BigQuery in parallel. This can be useful for organizations that have large amounts of data to load, as it can significantly reduce the time it takes to load the data.

:clock1: Estimated deployment time: 2 min

:heavy_dollar_sign: Estimated solution cost: it depends on the volume of data inserted, please estimate it using [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator)


## Architecture
Please find below a reference architecture.
![architecture](architecture.png)

## Deploy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=data-analytics-platform-scheduled" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script and follow the instructions
```
sh cloudbuild.sh
```

Once it is finished, you can go to [Cloud Composer](https://console.cloud.google.com/composer/environments) to see the dags' results and explore the Cloud Composers's functionalities.


## Testing
After you deployed the solution, you can test it by loading the sample file from this repository to the Data Lake bucket by running the `gsutil` command below, or using the console.
```
gsutil cp sample_data/order_events_001.csv gs://your-upload-bucket/order-events/
```

Then, check the uploaded data on BigQuery > ecommerce dataset > order_events table.

## Destroy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=data-platform-scheduled" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script with `destroy` argument
```
sh cloudbuild.sh destroy
```
