# Host a Serverless Wordpress Site with Cloud Run


## Let's get started!

This example will deploy all its resources into the project defined by the `project_id` variable. Please note that we assume this project already exists. 

However, if you provide the appropriate values to the `project_create` variable, the project will be created as part of the deployment.

If `project_create` is left to null, the identity performing the deployment needs the owner role on the project defined by the project_id variable. 

Otherwise, the identity performing the deployment needs `resourcemanager.projectCreator` on the resource hierarchy node specified by `project_create.parent` and `billing.user` on the billing account specified by `project_create.billing_account_id`.

**Time to complete**: About 10 minutes

Click the **Start** button to move to the next step.


## Information required

Before we deploy the architecture, you will need the following information:

* __The service project ID__.
* A __unique prefix__ that you want all the deployed resources to have (for example: awesomestartup). This must be a string with no spaces or tabs.
* A __Wordpress image__ if you want to use your own, otherwise you can use the provided standard image.
* A __list of Groups or Users__ with Service Account Token creator role on Service Accounts in IAM format, eg 'group:group@domain.com'.


### Notes:

1. If you want to change your admin password later on, please note that you can only do so via the Wordpress user interface.
2. If you have the domain restriction org. policy on your organization, you have to edit the cloud_run_invoker variable and give it a value that will be accepted in accordance to your policy.

## Deploy the architecture
Congratulations! At this point you should have successfully deployed the foundations for running Wordpress using CloudRun on Google Cloud.

### Note: 
*** You might get the following error (or a similar one): ***

```
Error: resource is in failed state "Ready:False", message: Revision '...' is not ready and cannot serve traffic.
```


In case this happens, manually run the following command to run the installation again

```bash
deploystack install
```

## Using the Wordpress Installation

Upon completion, you will see the output with the values for the Cloud Run service and the user and password to access the /admin part of the website. You can also view it later with:

``` bash
terraform output
```

or for the concrete variable:

``` bash
terraform output cloud_run_service
```


When clicking on the Wordpress link, it will immediately prompt you to register as an administrator. 

The password will be pre-filled and can be changed after registration.

## Cleaning Up Your Environment
The easiest way to remove all deployed resources is to run the following command in Cloud Shell:

```bash
deploystack uninstall
```

The above command will delete the associated resources so there will be no billable charges made afterwards.

## Variables & Outputs

For full information on variables and outputs please refer to the [README](https://github.com/GoogleCloudPlatform/deploystack-wordpress-on-cloudrun/blob/main/README.md#variables) file

## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

You’re all set!
