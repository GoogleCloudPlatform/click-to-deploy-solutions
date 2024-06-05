

1 - Disable the domain sharing restrictions

2 - Run the pre-requirements

3 - Push the cloudbuild gcloud builds submit --config build/cloudbuild.yaml --region us-central1

4 - Post a few tests by running ./populate.sh


5 - https://lookerstudio.google.com/c/u/0/reporting/create?c.mode=edit&ds.connector=BIG_QUERY&ds.type=TABLE&ds.projectId=[YOUR PROJECT ID]&ds.datasetId=classified_messages&ds.tableId=classified_messages