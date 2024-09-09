# Copyright 2024 Google LLC
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
if gsutil ls $BUCKET_NAME; then
    echo Terraform bucket already created!
else
    echo Creating Terraform state bucket...
    gsutil mb $BUCKET_NAME
fi

echo Enabling required APIs...
apis=(
   cloudbuild.googleapis.com 
   bigquery.googleapis.com 
   cloudresourcemanager.googleapis.com 
   compute.googleapis.com 
   composer.googleapis.com 
   container.googleapis.com 
   secretmanager.googleapis.com 
   servicenetworking.googleapis.com 
   sqladmin.googleapis.com 
   storage.googleapis.com 
   cloudfunctions.googleapis.com 
   firestore.googleapis.com 
   aiplatform.googleapis.com 
   run.googleapis.com 
   pubsub.googleapis.com 
   speech.googleapis.com 
   translate.googleapis.com
)

for api in "${apis[@]}"
do
    gcloud services enable "$api" --project "$PROJECT_ID"
done

echo "Granting Cloud Build's Service Account IAM roles to deploy the resources..."
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
MEMBER=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com
add_iam_member $MEMBER roles/editor
add_iam_member $MEMBER roles/iam.securityAdmin
add_iam_member $MEMBER roles/compute.networkAdmin
add_iam_member $MEMBER roles/secretmanager.admin
add_iam_member $MEMBER roles/storage.admin
add_iam_member $MEMBER roles/cloudfunctions.admin
add_iam_member $MEMBER roles/run.admin
add_iam_member $MEMBER roles/pubsub.admin
add_iam_member $MEMBER roles/cloudbuild.builds.editor
add_iam_member $MEMBER roles/artifactregistry.admin
add_iam_member $MEMBER roles/secretmanager.admin
add_iam_member $MEMBER roles/cloudbuild.builds.builder
add_iam_member $MEMBER roles/logging.logWriter

echo "Granting Cloud Speech to text's Service Account IAM roles to perform transcription..."
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
MEMBER=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-speech.iam.gserviceaccount.com
add_iam_member $MEMBER roles/storage.objectUser

echo "Granting default Compute engine service account account IAM roles to deploy the resources..."
#SA change as per https://cloud.google.com/build/docs/cloud-build-service-account-updates
#TODO: Change it to generic SA
MEMBER="serviceAccount:1059281389037-compute@developer.gserviceaccount.com"
add_iam_member $MEMBER roles/storage.admin
add_iam_member $MEMBER roles/cloudfunctions.admin
add_iam_member $MEMBER roles/run.admin
add_iam_member $MEMBER roles/pubsub.admin
add_iam_member $MEMBER roles/cloudbuild.builds.editor
add_iam_member $MEMBER roles/artifactregistry.admin
add_iam_member $MEMBER roles/logging.logWriter
add_iam_member $MEMBER roles/secretmanager.admin


echo Script completed successfully!