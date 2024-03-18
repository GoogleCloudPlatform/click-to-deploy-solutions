gcloud dataflow jobs run test_batch_01 \ 
    --gcs-location gs://dataflow-templates/latest/GCS_Text_to_BigQuery \ 
    --project $PROJECT_ID \
    --region europe-west1 \
    --disable-public-ips \
    --subnetwork https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/regions/europe-west1/subnetworks/subnet \ 
    --staging-location gs://$PROJECT_ID-df-tmp \ 
    --service-account-email df-loading@$PROJECT_ID.iam.gserviceaccount.com \ 
    --parameters \ 
        javascriptTextTransformFunctionName=transform,\ 
        JSONPath=gs://$PROJECT_ID-data/person_schema.json,\ 
        javascriptTextTransformGcsPath=gs://$PROJECT_ID-data/person_udf.js,\ 
        inputFilePattern=gs://$PROJECT_ID-data/person.csv,\ 
        outputTable=$PROJECT_ID:datalake.person,\ 
        bigQueryLoadingTemporaryDirectory=gs://$PROJECT_ID-df-tmp
