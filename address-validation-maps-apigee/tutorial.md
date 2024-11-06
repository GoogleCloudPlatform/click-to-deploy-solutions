# Build an Address Validation tool using Apigee and Google Maps

## Let's get started 

This solution assumes you already have a project created and set up where you wish to host these resources.

**Time to complete**: About 15 minutes

Click the **Start** button to move to the next step.

## Prerequisites 

- Have an [organization][2] set up in Google cloud.
- Have a [billing account][3] set up.
- Have an existing [project][4] with [billing
  enabled][5], we'll call this the **service project**.

### Roles & Permissions 

In order to spin up this architecture, you will need to be a user with the
**Project Owner** [IAM][6] role on the existing project.

> __Note__: To grant a user a role, take a look at the [Granting and Revoking Access][7] documentation.

## Deploy the architecture 

1. Before we deploy the architecture, you will need to set the **Project ID**.

```bash
gcloud config set project PROJECT_ID
```

2. Once the repository is cloned please run the prerequisites script to enable APIs and set Cloud Build permissions.

```bash
sh prereq.sh
```
Next, you'll be asked to enter the project ID of the destination project. Please provide the project ID when prompted.

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

The below command will delete the associated resources so there will be no billable charges made afterwards.
```
gcloud builds submit . --config build/cloudbuild_destroy.yaml
```

## Congratulations 

You have completed the **Build an Address Validation tool using Apigee and Google Maps** tutorial!

[1]: https://github.com/googlestaging/deploystack-gcs-to-bq-with-least-privileges
[2]: https://cloud.google.com/resource-manager/docs/creating-managing-organization
[3]: https://cloud.google.com/billing/docs/how-to/manage-billing-account
[4]: https://cloud.google.com/resource-manager/docs/creating-managing-projects
[5]: https://cloud.google.com/billing/docs/how-to/modify-project
[6]: https://cloud.google.com/iam
[7]: https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role

