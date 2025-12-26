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
    aiplatform.googleapis.com \
    artifactregistry.googleapis.com \
    bigquery.googleapis.com \
    cloudfunctions.googleapis.com \
    cloudresourcemanager.googleapis.com \
    compute.googleapis.com \
    documentai.googleapis.com \
    iam.googleapis.com \
    logging.googleapis.com \
    pubsub.googleapis.com \
    run.googleapis.com \
    storage.googleapis.com \
    storage-component.googleapis.com \
    eventarc.googleapis.com \
    eventarcpublishing.googleapis.com 

gcloud services enable drive.googleapis.com \
    discoveryengine.googleapis.com \
    datacatalog.googleapis.com \
    firestore.googleapis.com \
    firebase.googleapis.com \
    secretmanager.googleapis.com \
    dialogflow.googleapis.com

echo "Granting Cloud Build's Service Account IAM roles to deploy the resources..."
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
MEMBER=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com
add_iam_member $MEMBER roles/editor
add_iam_member $MEMBER roles/viewer
add_iam_member $MEMBER roles/iam.securityAdmin
add_iam_member $MEMBER roles/documentai.admin
add_iam_member $MEMBER roles/eventarc.admin
add_iam_member $MEMBER roles/storage.admin

echo "Granting Compute's Service Account IAM roles to deploy the resources..."
MEMBER2=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com
add_iam_member $MEMBER2 roles/artifactregistry.admin
add_iam_member $MEMBER2 roles/storage.admin

# Terraform Setup
cd infra
echo "Initializing Terraform..."
terraform init -reconfigure -backend-config="bucket=$PROJECT_ID-tf-state"

echo "Applying Terraform configuration..."
terraform apply -auto-approve

echo Script completed successfully!

echo Script completed successfully!
