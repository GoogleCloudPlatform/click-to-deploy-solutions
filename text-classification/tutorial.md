# Extract data from your documents using Generative AI on Google Cloud

## Let's get started

This solution assumes you already have a project created and set up where you wish to host these resources.

**Time to complete**: About 5 minutes

Click the **Start** button to move to the next step.

## Prerequisites

* Have an [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization) set up in Google cloud.
* Have a [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account) set up.
* Have an existing [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) with [billing enabled](https://cloud.google.com/billing/docs/how-to/modify-project).
* The project has to be able to share resources outside the domain (i.e. to get public requests), [check the domain restricted sharing policy](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#console).

### Roles & Permissions

In order to spin up this architecture, you will need to be a user with the “__Project owner__” [IAM](https://cloud.google.com/iam) role on the existing project:

Note: To grant a user a role, take a look at the [Granting and Revoking Access](https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role) documentation.

## Deploy the architecture

Before we deploy the architecture, you will need the following information:

* The __project ID__

Once the repository is cloned please run the following command to install the prerequisistes:

```
sh prereq.sh
```

You will then be prompted to provide the project-id for the destination project.

After this is complete, you can kick off the Cloud Build pipeline with the following command:

```
gcloud builds submit . --config build/cloudbuild.yaml --region us-central1
```

The region is the region where the cloudbuild will run as well as the region where the resulting compiled image of the sourcecode will be stored, if you update the region, it is important to also update it in the terraform variables.


## Result

At this point you should have successfully deployed the foundations for a Three Tier Web Application!.

This process may take a while to deploy, please do not close the window when deploying.

Next we are going to test the architecture and finally clean up your environment.

## Getting the endpoint
* Visit Cloud Run list of services (https://console.cloud.google.com/run) 
* Select the service called text-classification	
* The service endpoint will be available right next to the package name

![Image copying the Cloud Run URL](https://services.google.com/fh/files/misc/copy_cloudrun_url.gif)




## Testing your architecture
Once you deployed the solution successfully, update the populate.sh with the endpoint you got from the previous step

```bash
sh populate.sh
```

Then, check the parsed results in the output bucket in text (OCR) and json (Key=value) formats

Finally, check the json results on BigQuery or even better, use the bellow link to check it in a Looker Studio dashboard.

```
https://lookerstudio.google.com/c/u/0/reporting/create?c.mode=edit&ds.connector=BIG_QUERY&ds.type=TABLE&ds.projectId=[YOUR PROJECT ID]&ds.datasetId=classified_messages&ds.tableId=classified_messages
```

## Taking it further to other usecases

Feel free to play around and take this example to new usecases, in code/main.py you have the prompt that is being used to create the emotions, you could alternativelly update that to e.g classify emails for a law firm into court cases: 

```
prompt = f"""You are a lawyer assistant and need to classify a given email of a law case by its content, the process email text is "{text}". Give me a result such as Criminal, Civil, Family, Probate and Corporate. Refrain from explaining your answer"""
```

Then for testing you can update the strings in the populate.sh file:

"I hope this email finds you well. My name is John Doe, and I am seeking legal assistance regarding an employment dispute with my former employer, ABC Corporation. I was terminated last month under circumstances that I believe were unlawful. Could we schedule a consultation to discuss the details of my case? I have attached relevant documents, including my employment contract and termination letter, for your review."

"My name is Michael Johnson, and I am in urgent need of legal representation. I have been charged with assault following an incident that occurred on June 10, 2024. I maintain that I acted in self-defense and believe that the charges against me are unjust. I am currently out on bail and need to appear in court for my first hearing on July 1, 2024. I would like to schedule a meeting with you as soon as possible to discuss my case and prepare my defense. I have attached the police report and bail documents for your review. Please let me know your earliest availability for a consultation. I am very anxious about this situation and am looking for strong legal guidance."

Hint: You can generate those using Gemini :)

![Image updating the populate.sh file](https://services.google.com/fh/files/misc/update_url_populate_file.gif)



## Cleaning up your environment

Execute the command below on Cloud Shell to destroy the resources.

``` {shell}
gcloud builds submit . --config build/cloudbuild_destroy.yaml
```

The above command will delete the associated resources so there will be no billable charges made afterwards.

## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
