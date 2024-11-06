[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)
# Serverless Address Validation using Apigee and Google Maps

## Introduction
This architecture uses a serverless pipeline to securely process and validate addresses, ensuring data quality while leveraging Google Cloud services for scalability and efficiency. By integrating Apigee with the Address Validation API, it enables organizations to confidently cleanse and store address data without compromising accuracy.

In this architecture, address data is routed from its source to Apigee, a comprehensive API management platform. A Cloud Scheduler triggers periodic cleansing of address data, invoking Apigee to call the Address Validation API for data validation and standardization.

The Address Validation API inspects and validates the address entries, ensuring they conform to postal standards and are accurate. The validated and cleaned addresses are then stored in BigQuery, a fully-managed data warehouse, ready for further analysis and usage.

This architecture allows for seamless integration between address data routing, periodic cleansing, and the Address Validation API, enabling organizations to maintain high-quality address data while leveraging the scalability and efficiency of Google Cloud services. It ensures data accuracy and compliance with postal standards, safeguarding the integrity of customer and internal address information.

## Use cases
These are some examples of the use cases you can build on top of this architecture:

* __Address Standardization for CRM Systems__ : Organizations can use this architecture to ensure their CRM systems have accurate and standardized address data. By periodically cleansing and validating addresses stored in the CRM, the architecture improves data quality, reduces mailing errors, and enhances customer relationship management.

* __E-commerce Address Verification__ : E-commerce platforms can implement this architecture to validate customer shipping addresses at the point of entry. By integrating the Address Validation API through Apigee, the platform ensures that only accurate and deliverable addresses are accepted, reducing shipping errors and improving customer satisfaction.

* __Geospatial Data Analytics__ : Companies dealing with large datasets of geospatial information can leverage this architecture to maintain high-quality address data in their analytical models. By storing cleaned and validated addresses in BigQuery, organizations can perform more accurate geospatial analysis, enabling better decision-making for location-based services, marketing campaigns, and resource allocation.

## Architecture
<p align="center"><img src="assets/architecture.png"></p>
The main components that we would be setting up are (to learn more about these products, click on the hyperlinks)


* [BigQuery](https://cloud.google.com/bigquery) : managed data warehouse solution that offers a powerful scalable SQL engine for analytical workloads
* [Apigee](https://cloud.google.com/apigee) : native API management tool, simplifies the creation, management, and security of APIs across diverse use cases, environments, and scales.
* [Cloud Scheduler](https://cloud.google.com/scheduler) : Cloud Scheduler is a fully managed cron job service that allows you to schedule virtually any job, including batch, big data jobs, cloud infrastructure operations, and more.

## Costs
Pricing Estimates - We have created a sample estimate based on some usage we see from new startups looking to scale. This estimate would give you an idea of how much this deployment would essentially cost per month at this scale and you extend it to the scale you further prefer. Here are the links below:
* [Address Validation API](https://developers.google.com/maps/documentation/address-validation/usage-and-billing#address-validation). - 17 USD/1000 request
* [BigQuery + Apigee](https://cloud.google.com/products/calculator/estimate-preview/bc6ca4af-a62a-4b52-96f4-c661e48b993d?e=48754805&hl=en).

## Deploy the architecture

:clock1: Estimated deployment time: 15 min

1. Click on Open in Google Cloud Shell button below.
   
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=better-together-vertical-efficient-store-operations&cloudshell_open_in_editor=infra/terraform.auto.tfvars&&cloudshell_tutorial=tutorial.md" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the prerequisites script to enable APIs and set Cloud Build permissions.
```
sh prereq.sh
```

3. Run the Cloud Build Job
```
gcloud builds submit . --config build/cloudbuild.yaml
```

Once it is finished, you can go to [Cloud Composer](https://console.cloud.google.com/composer/environments) to see the dags' results and explore the Cloud Composers's functionalities.

## Testing the architecture

Once deployed, you'll need to retrieve two crucial pieces of information to interact with your API: the endpoint URL and your unique app key to start testing the solution.

#### 1. Obtaining the Endpoint URL
The endpoint URL can be found within the DNS hostname of the certificate associated with your load balancer. For instance, it might look something like 34.49.65.0.nip.io

#### 2. Retrieving Your App Key
To access your app key, navigate to the app details section within your application's management interface. There, you'll find the key value readily available.

#### 3. Making API Calls
With the endpoint URL and app key in hand, you can start making requests to the API. Update the placeholders **($APIGEE_URL and $API_KEY)** in the provided curl example with your actual values.

```bash
curl -k --location '$APIGEE_URL/v1/addressvalidation?apikey=$API_KEY' \
--header 'Content-Type: application/json' \
--data '{
    "address": {
        "regionCode": "US",
       "locality": "Mountain View",
        "addressLines": [
            "1600 Amphitheatre Pkwy"
        ]
    }
}'
```

### Expected Response
Once you have completed the steps above you will get a response like this:

![architecture](assets/result.png)

## Cleaning up your environment
1. Click on Open in Google Cloud Shell button below.

<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=better-together-vertical-efficient-store-operations&cloudshell_open_in_editor=infra/terraform.auto.tfvars&&cloudshell_tutorial=tutorial.md" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

1. Run the command below on Cloud Shell to delete the resources.
```
gcloud builds submit . --config build/cloudbuild_destroy.yaml
```
