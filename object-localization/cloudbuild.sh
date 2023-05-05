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

if [ "$1" = "destroy" ]
then
    echo Destroying solution on project $PROJECT_ID
    gcloud builds submit . --config cloudbuild_destroy.yaml
else
    echo Deploying solution onto project $PROJECT_ID
    BUCKET_NAME=gs://$PROJECT_ID-tf-state
    if gsutil ls $BUCKET_NAME; then
        echo Terraform bucket already created!
    else
        echo Creating Terraform state bucket...
        gsutil mb $BUCKET_NAME
    fi

    echo Enabling required APIs...
    gcloud services enable cloudbuild.googleapis.com \
        aiplatform.googleapis.com \
        artifactregistry.googleapis.com \
        bigquery.googleapis.com \
        cloudfunctions.googleapis.com \
        cloudresourcemanager.googleapis.com \
        compute.googleapis.com \
        vision.googleapis.com \
        iam.googleapis.com \
        logging.googleapis.com \
        pubsub.googleapis.com \
        run.googleapis.com \
        storage.googleapis.com \
        storage-component.googleapis.com \
        eventarc.googleapis.com \
        eventarcpublishing.googleapis.com

    # EventArc takes time to propagate, so sleep here is longer
    echo Waiting for APIs activation...
    sleep 300

    echo "Granting Cloud Build's Service Account IAM roles to deploy the resources..."
    PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
    MEMBER=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com
    add_iam_member $MEMBER roles/editor
    add_iam_member $MEMBER roles/iam.securityAdmin
    add_iam_member $MEMBER roles/documentai.admin

    echo "Granting Cloud Storage's Service Account permissions required by EventArc..."
    GCS_SERVICE_ACCOUNT="$(gsutil kms serviceaccount -p $PROJECT_ID)"
    MEMBER=serviceAccount:$GCS_SERVICE_ACCOUNT
    add_iam_member $MEMBER roles/pubsub.publisher

    echo Waiting for permissions to propagate...
    sleep 120
    
    echo Triggering Cloud Build job...
    gcloud builds submit . --config cloudbuild.yaml

    echo Solution deployed successfully!
fi

echo Script completed successfully!
