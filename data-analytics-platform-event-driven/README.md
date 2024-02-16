[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Implement a data analytics pipeline with an event-driven architecture on Google Cloud

## Introduction

This architecture uses click-to-deploy to demonstrate how to load data from Google Cloud Storage to BigQuery using an event-driven load function.

By adopting an event-driven architecture, companies can harness the power of real-time data processing. Events triggered by various sources, such as user interactions, system events, or data updates, can be seamlessly captured and processed in near real-time. This allows for a highly responsive and agile analytics pipeline, ensuring that data is continuously flowing into the system and insights are promptly generated.

Cloud functions play a pivotal role in this setup. They serve as the bridge between the cloud storage and BigQuery, enabling smooth and automated data ingestion. As new data arrives in the cloud storage, the cloud functions can be configured to trigger automatically, instantly fetching and loading the data into BigQuery. This eliminates the need for manual intervention and guarantees a streamlined and efficient data transfer process.

Utilizing Google Cloud's BigQuery as the data warehousing solution further enhances the value of this architecture. BigQuery offers a powerful and scalable analytics platform capable of handling large volumes of data. Its unique serverless architecture enables elastic scaling, allowing the customer to effortlessly accommodate data growth without worrying about infrastructure management. 

In summary, a data analytics pipeline with an event-driven architecture, empowers the customer with a scalable, efficient, and real-time data processing solution. This architecture streamlines data ingestion, ensures prompt analysis, and leverages Google Cloud's comprehensive suite of analytics tools, ultimately enabling the customer to make data-driven decisions faster and stay ahead in today's competitive landscape.

## Use cases

These are some examples of the use cases you can build on top of this architecture:

* __Real-Time Data Analytics__ : This implementation allows organizations to perform real-time data analytics by loading data from Cloud Storage into BigQuery. This is particularly valuable in scenarios where data freshness is critical for making timely decisions. For example, a marketing team can continuously load customer behavior data from Cloud Storage into BigQuery using the event-driven cloud function. This enables them to analyze the latest customer interactions, identify trends, and personalize marketing campaigns in real-time, resulting in improved customer engagement and conversion rates.

* __Streamlined ETL Pipelines__ : This architecture facilitates by automating the data loading process. Organizations can use the event-driven cloud function to trigger the ingestion of data from Cloud Storage into BigQuery as soon as new files are added or existing files are modified. This eliminates the need for manual intervention or scheduled jobs, reducing the time and effort required for data processing. For instance, a retail company can automatically load sales data from Cloud Storage into BigQuery, allowing them to generate daily sales reports without delay, enabling better inventory management and revenue forecasting.

* __Data Archival and Compliance__ : Another important use case for this architecture is data archival and compliance. Many organizations have regulatory requirements or internal policies that dictate data retention periods. By automatically moving processed files from cloud storage to an archive cloud storage, this data analytics pipeline ensures that data is securely stored for long-term retention. This archival process helps organizations meet compliance requirements, facilitates audits and investigations, and preserves data integrity. Additionally, it optimizes primary storage costs by moving less frequently accessed data to a more cost-effective storage layer.

## Architecture

<p align="center"><img src="assets/architecture.png"></p>

The main components that we would be setting up are (to learn more about these products, click on the hyperlinks)

* [Cloud Storage (GCS) bucket](https://cloud.google.com/storage/): Cloud Storage is a managed service for storing unstructured data. Store any amount of data and retrieve it as often as you like.
* [BigQuery](https://cloud.google.com/bigquery): managed data warehouse solution that offers a powerful scalable SQL engine for analytical workloads
* [Service accounts:](https://cloud.google.com/iam/docs/service-accounts) credentials used by Google Cloud services to interact with other Google Cloud components
* [Cloud Functions](https://cloud.google.com/functions): Run your code in the cloud with no servers or containers to manage with our scalable, pay-as-you-go functions as a service (FaaS) product.
* [Looker Studio](https://support.google.com/looker-studio/answer/6283323?hl=en) : Looker Studio is a free tool that turns your data into informative, easy to read, easy to share, and fully customizable dashboards and reports.

## Costs

Pricing Estimates - We have created a sample estimate based on some usage we see from new startups looking to scale. This estimate would give you an idea of how much this deployment would essentially cost per month at this scale and you extend it to the scale you further prefer. Here's the [link](https://cloud.google.com/products/calculator/#id=662dbaa8-91e2-486f-bd28-2d828692a560).

## Deploy the architecture

:clock1: Estimated deployment time: 8 min

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=data-analytics-platform-event-driven&cloudshell_open_in_editor=infra/terraform.tfvars" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the prerequisites script to enable APIs and set Cloud Build permissions.
```
sh prereq.sh
```

Please note - New organizations have the 'Enforce Domain Restricted Sharing' policy enforced by default. You may have to edit the policy to allow public access to your Cloud Run instance. Please refer to this [page](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#setting_the_organization_policy) for more information.

3. Run the Cloud Build Job
```
gcloud builds submit . --config cloudbuild.yaml
```

If you face a problem with the EventArc API during the deployment, please check out the [known issues section](#known-issues).

Once it is finished, you can go to the next section to test your architecture.


## Testing the architecture
After you deployed the solution, you can test it by loading the sample file on this repository to the upload bucket by running the `gsutil` command below, or uploading using the console.
```
gsutil cp sample_data/order_events_001.csv gs://your-upload-bucket/ecommerce/order_events/
```

Then, check the uploaded data on BigQuery > ecommerce dataset > order_events table.

## Cleaning up your environment

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=data-analytics-platform-event-driven&cloudshell_open_in_editor=terraform/terraform.tfvars" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the command below on Cloud Shell to destroy the resources.
```
gcloud builds submit . --config cloudbuild_destroy.yaml
```

## Known issues

You might face errors related to Eventarc, for example:

```
Error: Error creating function: googleapi: Error 400: Validation failed for trigger projects/obj-localization/locations/us-central1/triggers/object-localization-109804: Invalid resource state for "": Permission denied while using the Eventarc Service Agent. If you recently started to use Eventarc, it may take a few minutes before all necessary permissions are propagated to the Service Agent. Otherwise, verify that it has Eventarc Service Agent role.

If you recently started to use Eventarc, it may take a few minutes before all necessary permissions are propagated to the Service Agent. Otherwise, verify that it has Eventarc Service Agent role.
```

It happens because the Eventarc permissions take some time to propagate. First, make sure you ran the `pre-req.sh` script. Then, wait some minutes and trigger the deploy job again. Please see the [Known issues for Eventarc](https://cloud.google.com/eventarc/docs/issues).
