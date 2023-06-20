## How to use this template
This template is a reference, no every section applies to all the architectures. Feel free to use the sections that best apply to your solution. A good solution should have a testing your architecture section and a link to the calculator with estimate prices. We tried to provide examples of each section but if you have questions or comments please reach out to the team. Without further ado here is the template. 


## Solution Title
For the title try to make it more use case focused and less product focused.

[Example Title]: 
**Unifying Cloud Data Fusion and Private Cloud SQL for a Robust Data Pipeline**

## Description
Write a brief description about this architecture. The idea is to mentioned that it uses click-to-deploy to make the end user job easier. 

[Example Brief Description]
_This architecture uses click-to-deploy so you can spin up infrastructure in minutes using terraform!_

For the body think on a catchy description. The following questions might help:

* Why is this architecture relevant?
* What problem or challenge does it solve?
* What can it be used for?
* What best practices does it use?

[Example body]: 

In today's world, data matters more than ever. It can be used to make better decisions, improve efficiency, and gain a competitive edge. However, data management can be challenging. It can be difficult to keep data organized, secure, and accessible.

That's where data pipelines come in. Data pipelines are a set of processes that move data from one place to another. They can be used to collect data from different sources, transform it, and load it into a data warehouse or data lake.

The following click-to-deploy architecture deploys a secure and scalable data pipeline that can help you to achieve data agility with Google Cloud Storage, Dataflow and BigQuery. It uses the least privilege principles to ensure that only the minimum amount of permissions are required to transfer data.


## Use cases

These are some examples of the use cases you can build on top of this architecture:

[Example body]: 

* **Any application that requires some kind of transformation to data to be able to analyze it**
* **Data Privacy:** Data Flow allows you to call the Data Loss Prevention API to identify PII that you might not want to have in a readable format and de-identify it.
* **Anomaly Detection:** building data pipelines to identify cyber security threats or fraudulent transactions using machine learning (ML) models.
* **Interactive Data Analysis:** carry out interactive data analysis with BigQuery BI Engine that enables you to analyze large and complex datasets interactively with sub-second query response time and high concurrency.
* **Predictive Forecasting:** building solid pipelines to capture real-time data for ML modeling and using it as a forecasting engine for situations ranging from weather predictions to market forecasting.
* **Create Machine Learning models**: using BigQueryML you can create and execute machine learning models in BigQuery using standard SQL queries. Create a variety of models pre-built into BigQuery that you train with your data.


## Architecture

[Architecture Diagram, centered]

The main components that we would be setting up are (to learn more about these products, click on the hyperlinks)

 [Example]:

* **[Cloud Storage (GCS) bucket](https://cloud.google.com/storage/):** for storing extracted data that must undergo some kind of transformation.
* **[Cloud Dataflow pipeline](https://cloud.google.com/dataflow)**: to build fully managed batch and streaming pipelines to transform data stored in GCS buckets ready for processing in the Data Warehouse.


## Costs

Pricing Estimates - We have created a sample estimate based on some usage we see from new startups looking to scale. This estimate would give you an idea of how much this deployment would essentially cost per month at this scale and you extend it to the scale you further prefer. Here's the link. 

**Note**: 	Use link to pricing calculator to have the most updated prices dynamically. 


## Setup

Setup description. In this section try to be as descriptive as possible, remember that some end users are not tech savvy so the easier we make the set up process the better. Also, try to include an estimated deployment time. 

[Example Estimate time ]:

🕐 Estimated deployment time: 8 min


### **Prerequisites**



* **[Example]** Have an **[organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization)** set up in Google Cloud.
* **[Example]** Have a **[billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account) **set up.
* **[Example]** Have an existing **[project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)** with[ billing enabled](https://cloud.google.com/billing/docs/how-to/modify-project), we’ll call this the **service project**.


### **Roles & Permissions**

**[Example]** In order to spin up this architecture, you will need to be a user with the **“Project owner”** **[IAM](https://cloud.google.com/iam)** role on the existing project:

**Note**: To grant a user a role, take a look at the **[Granting and Revoking Access](https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role)** documentation.


### **Spinning up the architecture**


##### Step 1: Cloning the repository

Body…


### Testing your architecture

Testing your architecture body. For this section try to provide data, commands or as much information as possible so the end user can test and see the real value of this architecture. 


### **Cleaning up your environment**

Instructions to clean up the environment. (For example: running deploystack uninstall / terraform destroy)


### Where to go from here? Optional next steps


### **_[Delete this] Other format specifications:_**

Shell commands/code must be in the following format of code blocks **[Example]**:


```
gsutil -i gcs-landing@$SERVICE_PROJECT_ID.iam.gserviceaccount.com cp data-demo/* gs://$PREFIX-data

