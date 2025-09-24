# Looker Data Agent Deployment

This guide provides the steps to deploy the Looker Data Agent application using Google Cloud Build. This solution offers a robust backend for creating conversational agents that can interact with Looker, enabling insights through platforms like Microsoft Teams, Slack, and other conversational interfaces.

---

## Prerequisites

1.  A Google Cloud project. If you don't have one, follow the [Creating and Managing Projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects) guide.
2.  The `gcloud` command-line tool installed and authenticated. See [Installing the gcloud CLI](https://cloud.google.com/sdk/docs/install) for details.

---

## Step 1: Generate Looker API Credentials

Before you can configure the secret, generate API credentials from your Looker instance:

1.  In your Looker instance, navigate to **Admin > Users**.
2.  Select the user you want to generate credentials for and click **Edit**.
3.  Under the **API Credentials** section, click **Edit Keys**.
4.  Click **New API Key**. The UI will display a **Client ID** and a **Client Secret**.

For more detailed instructions, refer to the official Looker documentation on [API Credentials](https://cloud.google.com/looker/docs/api-auth#authentication_with_an_sdk).

---

## Step 2: Create the Secret in Google Cloud

The application requires a secret named `LOOKER_AGENT_CONFIG` stored in Google Cloud Secret Manager.
The expected structure of the secret is a JSON with:

    {
      "LOOKER_CLIENT_ID": "YOUR_LOOKER_CLIENT_ID",
      "LOOKER_CLIENT_SECRET": "YOUR_LOOKER_CLIENT_SECRET",
      "LOOKER_INSTANCE": "YOUR_LOOKER_INSTANCE_URL",
      "LOOKML_MODEL": "your_lookml_model_name",
      "LOOKML_EXPLORE": "your_explore_name"
    }

![Screen Recording 2025-06-30 at 18 12 28](https://github.com/user-attachments/assets/8b160d07-90d6-49e6-bcb8-4f121d50ad1f)



For more information on managing secrets, see [Creating and Accessing Secrets](https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets).

---

## Step 3: Deploy the architecture

From the root directory of your project, execute the `prereq.sh` script. This script automates several setup tasks, including enabling necessary Google Cloud APIs, creating a Cloud Storage bucket for Terraform state, and configuring IAM permissions.

To set the Project ID:

```bash
gcloud config set project PROJECT_ID
```

To run the script:

```bash
./prereq.sh
``` 
**During execution, the script will confirm your active Google Cloud Project ID.** If it\'s not already set in your `gcloud` configuration, the script will prompt you to enter it.

After this is complete, you can kick off the Cloud Build pipeline with the following command:

```bash
gcloud builds submit . --config cloudbuild.yaml
```

If you encounter errors when running these commands, please attempt to run them again in a clean project.

## Step 4: Configure the Dialogflow Playbook

After the Cloud Build deployment, a Dialogflow agent named **looker-ca-agent** and an associated tool named **CATOOL** will be automatically created. Your next step is to define the conversational logic (playbook) for this agent.

The **CATOOL** is designed to interact with your Looker instance for specialized data analytics questions. You will need to write custom instructions within the Dialogflow agent to guide its behavior and integrate with **CATOOL**. This allows you to combine Looker conversational analytics with other tools or even multiple Looker Explores as needed.

Here's an example prompt you can use to start configuring your Dialogflow agent:

```bash
Determine if the user is asking specialized data analytics question to an Ecommerce dataset OR if they are looking for more of a general discussion.

If the question is a specialized data analytics question, use ${TOOL:CATOOL} to interpret the natural language question and fetch the results from the database. Provide a contextual summary back to the user with as much detail as you can gather.

If the question is more general discussion related, converse using your own general knowledge. 
``` 

**To access and configure your Dialogflow agent:**

1.  Navigate to the [Dialogflow Console](https://dialogflow.cloud.google.com/).
2.  Select your Google Cloud project.
3.  Locate the agent named **looker-ca-agent**.
4.  Within the agent settings, you can define your custom instructions and further refine its behavior.

![Screen Recording 2025-07-02 at 10 14 13](https://github.com/user-attachments/assets/e783e021-8a3c-4749-a68b-69bc2f2b0f82)

For comprehensive guidance on configuring Dialogflow agents and playbooks, refer to the [Dialogflow Documentation](https://cloud.google.com/dialogflow/docs).

## Cleaning up your environment

Execute the command below on Cloud Shell to destroy the resources.

``` {shell}
gcloud builds submit . --config cloudbuild_destroy.yaml
```

The above command will delete the associated resources so there will be no billable charges made afterwards.


## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

You’re all set!

