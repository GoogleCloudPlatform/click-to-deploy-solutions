[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Foundation Data Pipeline with Google Cloud

## Introduction

_This architecture uses click-to-deploy so you can spin up infrastructure in
minutes using Terraform!_

In today's world, data matters more than ever. It can be used to make better
decisions, improve efficiency, and gain a competitive edge. However, data
management can be challenging. It can be difficult to keep data organized,
secure, and accessible.

That's where data pipelines come in. Data pipelines are a set of processes that
move data from one place to another. They can be used to collect data from
different sources, transform it, and load it into a data warehouse or data lake.

The following **click-to-deploy** architecture deploys a secure and scalable
data pipeline that can help you to achieve data agility with **Google Cloud
Storage, Dataflow and BigQuery**. It uses the least privilege principles to
ensure that only the minimum amount of permissions are required to transfer
data.

You can learn more about cloud-based ETL [here][1].

This repo is based on the Cloud Foundation Fabric blueprint available
[here][2].

## Use cases

Whether you're transferring from another Cloud Service Provider or you're taking
your first steps into the cloud with Google Cloud, building a data pipeline sets
a good foundation to begin deriving insights for your business.

These are some examples of the use cases you can build on top of this
architecture:

- **Any application that requires some kind of transformation to data to be able
  to analyze it**
- **Data Privacy**: Dataflow allows you to call the Data Loss Prevention API to
  identify PII that you might not want to have in a readable format and
  de-identify it.
- **Anomaly Detection**: building data pipelines to identify cyber security
  threats or fraudulent transactions using machine learning (ML) models.
- **Interactive Data Analysis**: carry out interactive data analysis with
  BigQuery BI Engine that enables you to analyze large and complex datasets
  interactively with sub-second query response time and high concurrency.
- **Predictive Forecasting**: building solid pipelines to capture real-time data
  for ML modeling and using it as a forecasting engine for situations ranging
  from weather predictions to market forecasting.
- **Create Machine Learning models**: using BigQuery ML you can create and
  execute machine learning models in BigQuery using standard SQL queries. Create
  a variety of models pre-built into BigQuery that you train with your data.

## Architecture

<figure id = "image-1">
  <img src = "./assets/diagram.png"
  width = "100%"
  alt = "GCS to BigQuery High-level diagram">
</figure>

The main components that we would be setting up are (to learn more about these
products, click on the hyperlinks):

- [Cloud Storage (GCS) bucket][3]: data lake solution to store
  extracted raw data that must undergo some kind of transformation.
- [Cloud Dataflow pipeline][4]: to build fully managed batch and
  streaming pipelines to transform data stored in GCS buckets ready for
  processing in the Data Warehouse using Apache Beam.
- [BigQuery datasets and tables][5]: to store the transformed data
  in and query it using SQL, use it to make reports or begin training [machine
  learning][6] models without having to take your data out.
- [Service accounts][7] (**created with least privilege on each
  resource**): one for uploading data into the GCS bucket, one for
  Orchestration, one for Dataflow instances and one for the BigQuery tables. You
  can also configure users or groups of users to assign them a viewer role on
  the created resources and the ability to impersonate service accounts to test
  the Dataflow pipelines before automating them with a tool like Cloud
  [Composer][8].

For a full list of the resources that will be created, please refer to the
[github repository][9] for this project. If you're migrating from
another Cloud Provider, refer to [this][10] documentation to see
equivalent services and comparisons in Microsoft Azure and Amazon Web Services

## Costs

Pricing Estimates - We have created a sample estimate based on some usage we see
from new startups looking to scale. This estimate would give you an idea of how
much this deployment would essentially cost per month at this scale and you
extend it to the scale you further prefer. Here's the [link][11].

## Setup

This solution assumes you already have a project created and set up where you
wish to host these resources. If not, and you want the system to create a new
project for you, please refer to the [GitHub repository][9] for
detailed instructions.

### Prerequisites

- Have an [organization][12] set up in Google cloud.
- Have a [billing account][13] set up.
- Have an existing [project][14] with [billing
  enabled][15], we'll call this the **service project**.

### Roles & Permissions

In order to spin up this architecture, you will need to be a user with the "
**Project owner** " [IAM][16] role on the existing project:

>__Note__: To grant a user a role, take a look at the [Granting and Revoking Access][17] documentation.

### Spinning up the architecture

Before we deploy the architecture, you will need the following information:

- The **service project ID**
1. Click on the Open in Google Cloud Shell button below.

<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=gcs-to-bq-with-least-privileges&cloudshell_open_in_editor=infra/main.tf&cloudshell_tutorial=tutorial.md" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the prerequisites script to enable APIs and set Cloud Build permissions.

```bash
sh prereq.sh
```

3. Run the Cloud Build Job

```bash
gcloud builds submit . --config ./build/cloudbuild.yaml
```

### Testing your architecture

For the purpose of demonstrating how the ETL pipeline flow works, we've set up
an example pipeline for you to run. First of all, we assume all the steps are
run using a user listed on the **data_eng_principles** variable (or a user that
belongs to one of the groups you specified). Authenticate the user using the
following command and make sure your active cloudshell session is set to the
**service project**:

```bash
gcloud auth application-default login
```

Follow the instructions in the cloudshell to authenticate the user.

To make the next steps easier, create two environment variables with the service
project id:

```bash
export PROJECT_ID=[PROJECT_ID]
```

For the purpose of the example we will import a CSV file from GCS to BigQuery.
This has the following structure: `name,surname,timestamp`.

We need to create 3 files:

- **person.csv** This file should contain your data in the format: name,
  surname, timestamp. For instance: `Eva,Rivarola,1637771951`
- **person_udf.js** This file should contain the [User-Defined Function (UDF)
  JavaScript code][18] used by the Dataflow template.
- **person_schema.json** This file should contain the table schema used to
  import the CSV data.

An example of those files can be found in the folder `./app/demo-data` inside the same repository you're currently in.

You can copy the example files into the GCS bucket by running:

```bash
gsutil cp -r ./app/demo-data/* gs://$PROJECT_ID-data/
```

After completion, the three essential files required to execute the Dataflow Job
will be copied to the GCS bucket created alongside the resources.

Run the following command to start the dataflow job:

```bash
gcloud dataflow jobs run test_batch_01 \
    --gcs-location gs://dataflow-templates/latest/GCS_Text_to_BigQuery \
    --project $PROJECT_ID \
    --region europe-west1 \
    --disable-public-ips \
    --subnetwork https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/regions/europe-west1/subnetworks/subnet \
    --staging-location gs://$PROJECT_ID-df-tmp \
    --service-account-email df-loading@$PROJECT_ID.iam.gserviceaccount.com \
    --parameters \
javascriptTextTransformFunctionName=transform,\
JSONPath=gs://$PROJECT_ID-data/person_schema.json,\
javascriptTextTransformGcsPath=gs://$PROJECT_ID-data/person_udf.js,\
inputFilePattern=gs://$PROJECT_ID-data/person.csv,\
outputTable=$PROJECT_ID:datalake.person,\
bigQueryLoadingTemporaryDirectory=gs://$PROJECT_ID-df-tmp

```

This command will start a Dataflow job called `test_batch_01` that uses a Dataflow
transformation script stored in the public GCS bucket `gs://dataflow-templates/latest/GCS_Text_to_BigQuery`.

The expected output is the following:

<figure id = "image-2">
  <img src = "./assets/second_output.png"
  width = "100%"
  alt = "second_output">
</figure>

Then, if you navigate to Dataflow on the console, you will see the following:

<figure id = "image-3">
  <img src = "./assets/dataflow_console.png"
  width = "100%"
  alt = "dataflow_console">
</figure>

This shows the job you started from the cloudshell is currently running in
Dataflow. If you click on the job name, you can see the job graph created and
how every step of the Dataflow pipeline is moving along:

<figure id = "image-4">
  <img src = "./assets/dataflow_execution.png"
  width = "100%"
  alt = "dataflow_execution">
</figure>

Once the job completes, you can navigate to BigQuery in the console and under
**PROJECT_ID** → datalake → person, you can see the data that was successfully
imported into BigQuery through the Dataflow job.

## Cleaning up your environment

The easiest way to remove all the deployed resources is to run the following
command in Cloud Shell:

```bash
gcloud builds submit . --config ./build/cloudbuild_destroy.yaml
```

The above command will remove the associated resources so there will be no
billable charges made afterwards.

>__Note__: This will also terminate the BigQuery dataset as the following option in
`main.tf` is set to `true: delete_contents_on_destroy`.

## Variables

<table>
  <tr>
    <td><p>name</p></td>
    <td><p>description</p></td>
    <td><p>type</p></td>
    <td><p>required</p></td>
    <td><p>default</p></td>
  </tr>
  <tr>
    <td><p>PROJECT_ID</p></td>
    <td><p>Project ID for the project where resources are deployed.</p></td>
    <td><p><code>string</code></p></td>
    <td><p>✓</p></td>
    <td></td>
  </tr>
</table>

## Outputs

<table>
  <tr>
    <td><p>name</p></td>
    <td><p>description</p></td>
    <td><p>sensitive</p></td>
  </tr>
  <tr>
    <td><p>bq_tables</p></td>
    <td><p>Bigquery Tables.</p></td>
    <td></td>
  </tr>
</table>

[1]: https://cloud.google.com/learn/what-is-etl
[2]: https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/blueprints/data-solutions/gcs-to-bq-with-least-privileges
[3]: https://cloud.google.com/storage/
[4]: https://cloud.google.com/dataflow
[5]: https://cloud.google.com/bigquery
[6]: https://cloud.google.com/bigquery-ml/docs/introduction
[7]: https://cloud.google.com/iam/docs/service-accounts
[8]: https://cloud.google.com/composer
[9]: https://github.com/googlestaging/deploystack-gcs-to-bq-with-least-privileges
[10]: https://cloud.google.com/free/docs/aws-azure-gcp-service-comparison
[11]: https://cloud.google.com/products/calculator/estimate-preview/6b8d1736-2544-4877-8f8d-22f1f287472a?hl=en
[12]: https://cloud.google.com/resource-manager/docs/creating-managing-organization
[13]: https://cloud.google.com/billing/docs/how-to/manage-billing-account
[14]: https://cloud.google.com/resource-manager/docs/creating-managing-projects
[15]: https://cloud.google.com/billing/docs/how-to/modify-project
[16]: https://cloud.google.com/iam
[17]: https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-s
[18]: https://cloud.google.com/bigquery/docs/reference/standard-sql/user-defined-functions
