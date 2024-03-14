gcloud dataflow jobs run test_batch_01 \
--gcs-location gs://dataflow-templates/latest/GCS_Text_to_BigQuery \
--project $SERVICE_PROJECT_ID \
--region europe-west1 \
--disable-public-ips \
--subnetwork https://www.googleapis.com/compute/v1/projects/$SERVICE_PROJECT_ID/regions/europe-west1/subnetworks/subnet \
--staging-location gs://$PREFIX-df-tmp \
--service-account-email df-loading@$SERVICE_PROJECT_ID.iam.gserviceaccount.com \
--parameters \
javascriptTextTransformFunctionName=transform,\
JSONPath=gs://$PREFIX-data/person_schema.json,\
javascriptTextTransformGcsPath=gs://$PREFIX-data/person_udf.js,\
inputFilePattern=gs://$PREFIX-data/person.csv,\
outputTable=$SERVICE_PROJECT_ID:datalake.person,\
bigQueryLoadingTemporaryDirectory=gs://$PREFIX-df-tmp
