# Foundation Data Pipeline with Google Cloud

## Let's get started

This solution assumes you already have a project created and set up where you wish to host these resources. If not, and you would like for the project to create a new project as well,  please refer to the [github repository](https://github.com/googlestaging/deploystack-gcs-to-bq-with-least-privileges) for instructions.

**Time to complete**: About 10 minutes

Click the **Start** button to move to the next step.

## Prerequisites

* Have an [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization) set up in Google cloud.
* Have a [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account) set up.
* Have an existing [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) with [billing enabled](https://cloud.google.com/billing/docs/how-to/modify-project), we’ll call this the __service project__.

### Roles & Permissions

In order to spin up this architecture, you will need to be a user with the “__Project owner__” [IAM](https://cloud.google.com/iam) role on the existing project:

__Note__: To grant a user a role, take a look at the [Granting and Revoking Access](https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role) documentation.

## Spinning up the architecture

Before we deploy the architecture, you will need the following information:

* The __service project ID__.
* A __unique prefix__ that you want all the deployed resources to have (for example: awesomestartup). This must be a string with no spaces or tabs.
* A __list of Groups or Users__ with Service Account Token creator role on Service Accounts in IAM format, eg 'group:group@domain.com'.

## Result

<center>
<h4>🎉 Congratulations! 🎉 </h4><br/>
At this point you should have successfully deployed the Foundation Data Pipeline with Google Cloud</center>

Next we are going to test the architecture and finally clean up your environment.

## Testing your architecture

For the purpose of demonstrating how the ETL pipeline flow works, we’ve set up an example pipeline for you to run.  First of all, we assume all the steps are run using a user listed on the __data_eng_principles__ variable (or a user that belongs to one of the groups you specified). Authenticate the user using the following command and make sure your active cloudshell session is set to the __service project__:

        gcloud auth application-default login

Follow the instructions in the cloudshell to authenticate the user.

To make the next steps easier, create two environment variables with the service project id and the prefix:

        export SERVICE_PROJECT_ID=[SERVICE_PROJECT_ID]
        export PREFIX=[PREFIX]

Again, make sure you’re in the following directory:

        cloudshell_open/cloud-foundation-fabric/blueprints/data-solutions/gcs-to-bq-with-least-privileges

For the purpose of the example we will import a CSV file from GCS to BigQuery. This has the following structure:

        name,surname,timestamp

We need to create 3 files:

* A person.csv file containing your data in the form name,surname,timestamp.  For example: `Eva,Rivarola,1637771951'.
* A person_udf.js containing the [UDF javascript file](https://cloud.google.com/bigquery/docs/reference/standard-sql/user-defined-functions) used by the Dataflow template.
* A person_schema.json file containing the table schema used to import the CSV.

An example of those files can be found  in the folder ./data-demo inside the same repository you're currently in.

You can copy the example files into the GCS bucket by running:

        gsutil -i gcs-landing@$SERVICE_PROJECT_ID.iam.gserviceaccount.com cp data-demo/* gs://$PREFIX-data

Once this is done, the three files necessary to run the Dataflow Job will have been copied to the GCS bucket that was created along with the resources.

Run the following command to start the dataflow job:

        gcloud --impersonate-service-account=orchestrator@$SERVICE_PROJECT_ID.iam.gserviceaccount.com dataflow jobs run test_batch_01 \
    --gcs-location gs://dataflow-templates/latest/GCS_Text_to_BigQuery \
    --project $SERVICE_PROJECT_ID \
    --region europe-west1 \
    --disable-public-ips \
    --subnetwork https://www.googleapis.com/compute/v1/projects/$SERVICE_PROJECT_ID/regions/europe-west1/subnetworks/subnet \
    --staging-location gs://$PREFIX-df-tmp\
    --service-account-email df-loading@$SERVICE_PROJECT_ID.iam.gserviceaccount.com \
    --parameters \
    javascriptTextTransformFunctionName=transform,\
    JSONPath=gs://$PREFIX-data/person_schema.json,\
    javascriptTextTransformGcsPath=gs://$PREFIX-data/person_udf.js,\
    inputFilePattern=gs://$PREFIX-data/person.csv,\
    outputTable=$SERVICE_PROJECT_ID:datalake.person,\
    bigQueryLoadingTemporaryDirectory=gs://$PREFIX-df-tmp

This command will start a Dataflow job called test_batch_01 that uses a Dataflow transformation script stored in the public GCS bucket:

        gs://dataflow-templates/latest/GCS_Text_to_BigQuery.

The expected output is the following:

![second_output](second_output.png)

Then, if you navigate to Dataflow on the console, you will see the following:

![dataflow_console](dataflow_console.png)

This shows the job you started from the cloudshell is currently running in Dataflow.
If you click on the job name, you can see the job graph created and how every step of the Dataflow pipeline is moving along:

![dataflow_execution](dataflow_execution.png)

Once the job completes, you can navigate to BigQuery in the console and under __SERVICE_PROJECT_ID__ → datalake → person, you can see the data that was successfully imported into BigQuery through the Dataflow job.

## Cleaning up your environment

The easiest way to remove all the deployed resources is to run the following command in Cloud Shell:

``` {shell}
deploystack uninstall
```

The above command will delete the associated resources so there will be no billable charges made afterwards.

Note: This will also destroy the BigQuery dataset as the following option in `main.tf` is set to `true`: `delete_contents_on_destroy`.
<!-- BEGIN TFDOC -->

## Variables & Outputs

For full information on variables and outputs please refer to the [README](https://github.com/GoogleCloudPlatform/deploystack-gcs-to-bq-with-least-privileges/edit/main/README.md#variables) file.

## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

You’re all set!