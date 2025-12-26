# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

add_iam_member()
{
  gcloud projects add-iam-policy-binding $PROJECT_ID --member=$1 --role=$2
}

add_secret_accessor()
{
  echo "Granting Secret Accessor role for secret '$1' to '$2'..."
  gcloud secrets add-iam-policy-binding "$1" \
    --project="$PROJECT_ID" \
    --member="$2" \
    --role="roles/secretmanager.secretAccessor" \
    --condition=None >/dev/null
}

if [ -z "$GOOGLE_CLOUD_PROJECT" ]
then
   echo Project not set!
   echo What Project Id do you want to deploy the solution to?
   read var_project_id
   gcloud config set project $var_project_id
   export PROJECT_ID=$var_project_id
else
   export PROJECT_ID=$GOOGLE_CLOUD_PROJECT
fi

# Determine region dynamically from gcloud config (must be set by user)
REGION=$(gcloud config get-value compute/region 2>/dev/null)
if [ -z "$REGION" ]; then
  echo "No default compute/region set. Please set one with:"
  echo "  gcloud config set compute/region REGION"
  exit 1
fi

echo Running prerequisites on project $PROJECT_ID
BUCKET_NAME=gs://$PROJECT_ID-tf-state
if gcloud storage ls $BUCKET_NAME; then
    echo Terraform bucket already created!
else
    echo Creating Terraform state bucket...
    gcloud storage buckets create $BUCKET_NAME
fi

echo Enabling required APIs...
gcloud services enable cloudbuild.googleapis.com \
    artifactregistry.googleapis.com \
    aiplatform.googleapis.com \
    cloudresourcemanager.googleapis.com \
    compute.googleapis.com \
    iam.googleapis.com \
    logging.googleapis.com \
    pubsub.googleapis.com \
    run.googleapis.com \
    storage.googleapis.com \
    storage-component.googleapis.com \
    secretmanager.googleapis.com \
    dialogflow.googleapis.com \
    geminidataanalytics.googleapis.com \
    secretmanager.googleapis.com\
    cloudaicompanion.googleapis.com

LOOKER_AGENT_CONFIG="LOOKER_AGENT_CONFIG"


if ! gcloud secrets describe "$LOOKER_AGENT_CONFIG" --project="$PROJECT_ID" &> /dev/null; then
  # If the command fails (prefixed with '!'), this block is executed.
  echo "--------------------------------------------------" >&2
  echo "ERROR: Secret not found!" >&2
  echo "The required secret '$LOOKER_AGENT_CONFIG' does not exist in the project '$PROJECT_ID'." >&2
  echo "Please create the secret before running this script." >&2
  echo "--------------------------------------------------" >&2
  exit 1 # Exit the script with a non-zero status code to indicate failure.
fi

echo 60 seconds wait...
sleep 60


echo "Secret '$LOOKER_AGENT_CONFIG' found. Proceeding with the script..."

echo "Granting Cloud Build's and Compute Service Accounts IAM roles to deploy the resources..."
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
COMPUTEMEMBER=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com

# --- Create a dedicated service account if it doesn't exist ---
CUSTOM_SA_NAME="looker-agent-runner"
CUSTOM_SA_EMAIL="${CUSTOM_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
CUSTOMSAMEMBER=serviceAccount:$CUSTOM_SA_EMAIL

if gcloud iam service-accounts describe "$CUSTOM_SA_EMAIL" --project="$PROJECT_ID" &> /dev/null; then
  echo "Service account '$CUSTOM_SA_NAME' already exists."
else
  echo "Creating service account '$CUSTOM_SA_NAME'..."
  gcloud iam service-accounts create "$CUSTOM_SA_NAME" \
    --display-name="Looker Agent Runner" \
    --project="$PROJECT_ID"
fi


# Service usage admin
add_iam_member $CUSTOMSAMEMBER roles/artifactregistry.admin
add_iam_member $CUSTOMSAMEMBER roles/storage.objectUser
add_iam_member $CUSTOMSAMEMBER roles/logging.logWriter
add_iam_member $CUSTOMSAMEMBER roles/aiplatform.user
add_iam_member $CUSTOMSAMEMBER roles/iam.serviceAccountUser
add_iam_member $CUSTOMSAMEMBER roles/cloudbuild.builds.builder
add_iam_member $CUSTOMSAMEMBER roles/storage.admin
add_iam_member $CUSTOMSAMEMBER roles/run.admin
add_iam_member $CUSTOMSAMEMBER roles/secretmanager.secretVersionManager
add_iam_member $CUSTOMSAMEMBER roles/cloudaicompanion.user
add_iam_member $CUSTOMSAMEMBER roles/resourcemanager.projectIamAdmin
add_iam_member $CUSTOMSAMEMBER roles/dialogflow.consoleAgentEditor


# # Service usage admin
add_iam_member $COMPUTEMEMBER roles/storage.objectUser 
add_iam_member $COMPUTEMEMBER roles/aiplatform.user 
add_iam_member $COMPUTEMEMBER roles/secretmanager.secretVersionManager
add_iam_member $COMPUTEMEMBER roles/cloudaicompanion.user
add_iam_member $COMPUTEMEMBER roles/geminidataanalytics.dataAgentUser
add_iam_member $COMPUTEMEMBER roles/geminidataanalytics.dataAgentStatelessUser

# --- GRANT SECRET ACCESSOR ROLE TO COMPUTE MEMBER ON SPECIFIC SECRET ---
add_secret_accessor "$LOOKER_AGENT_CONFIG" "$COMPUTEMEMBER"
add_secret_accessor "$LOOKER_AGENT_CONFIG" "$CUSTOMSAMEMBER"
# ---------------------------------------------------

echo "Creating artifact registry repository"
if gcloud artifacts repositories describe cloud-run-source-deploy --location="$REGION" --project="$PROJECT_ID" &> /dev/null; then
    echo "Repository 'cloud-run-source-deploy' already exists."
else
    echo "Creating Artifact Registry repository 'cloud-run-source-deploy'..."
    gcloud artifacts repositories create cloud-run-source-deploy --repository-format=docker --location="$REGION" --async
fi

gcloud builds submit --config ./build/cloudbuild.yaml --region "$REGION"

echo Script completed successfully!
