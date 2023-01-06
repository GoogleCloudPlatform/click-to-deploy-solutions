PROJECT=$1
SQLNAME=$2

SQLSERVICEACCOUNT=$(gcloud sql instances describe $SQLNAME --project $PROJECT --format="value(serviceAccountEmailAddress)" | xargs)
gsutil mb gs://$PROJECT-temp 
gsutil cp schema.sql gs://$PROJECT-temp/schema.sql
gsutil iam ch serviceAccount:$SQLSERVICEACCOUNT:objectViewer gs://$PROJECT-temp/
gcloud sql import sql $SQLNAME gs://$PROJECT-temp/schema.sql -q
gsutil rm gs://$PROJECT-temp/schema.sql
gsutil rb gs://$PROJECT-temp