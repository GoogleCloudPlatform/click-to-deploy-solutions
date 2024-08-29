apt-get update
apt-get install unzip jq -y

curl -L https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | sh 
export PATH=$PATH:$HOME/.apigeecli/bin

json_output=$(gcloud beta services api-keys create --display-name="My MAP API Key" --format=json)

GMAPS_KEY=$(echo $json_output | jq -r '.response.keyString')

gcloud iam service-accounts create addressvalidationsa \
    --description="Address Validation SA" \
    --display-name="Address Validation SA"

export PROJECT=$PROJECT_ID
export REGION="europe-west1"
export APIGEE_ENVIRONMENT=test1

export PRODUCT_NAME="AddressValidation-API-v1"
export DEVELOPER_EMAIL="example-developer@cymbalgroup.com"
export APP_NAME=addressvalidation-app-1
export APIGEE_URL=test.api.example.com

gcloud config set project $PROJECT

apigeecli kvms create -e $APIGEE_ENVIRONMENT -n address-gmap-keys -o $PROJECT -t $(gcloud auth print-access-token)
apigeecli kvms entries create -m address-gmap-keys -k gmaps_key -l $GMAPS_KEY -e $APIGEE_ENVIRONMENT -o $PROJECT -t $(gcloud auth print-access-token)

git clone https://github.com/echarish/ApigeeSamples.git
cd ApigeeSamples/apigee-address-validation/apiproxy

apigeecli apis import -o $PROJECT -f . -t $(gcloud auth print-access-token)

apigeecli apis deploy -n AddressValidation-Service -o $PROJECT -e $APIGEE_ENVIRONMENT -t $(gcloud auth print-access-token) -s addressvalidationsa@$PROJECT.iam.gserviceaccount.com --ovr

apigeecli products create -n "$PRODUCT_NAME" \
  -m "$PRODUCT_NAME" \
  -o "$PROJECT" -e "$APIGEE_ENVIRONMENT" \
  -f auto -p "AddressValidation-Service" -t $(gcloud auth print-access-token) 

apigeecli developers create -n "$DEVELOPER_EMAIL" \
  -f "Example" -s "Developer" \
  -u "$DEVELOPER_EMAIL" -o "$PROJECT" -t $(gcloud auth print-access-token)

#Now let’s create an app subscription using the test developer account.

DEVELOPER_APP=$(apigeecli apps create --name "$APP_NAME" \
  --email "$DEVELOPER_EMAIL" \
  --prods "$PRODUCT_NAME" \
  --org "$PROJECT" --token $(gcloud auth print-access-token))#

API_KEY=$(echo $DEVELOPER_APP | jq -r '.credentials[0].consumerKey')

echo $APIGEE_URL
echo $API_KEY

#curl -k --location '$APIGEE_URL/v1/addressvalidation?apikey=$API_KEY' \
#--header 'Content-Type: application/json' \
#--data '{
#    "address": {
#        "regionCode": "US",
#        "locality": "Mountain View",
#        "addressLines": [
#            "1600 Amphitheatre Pkwy"
#        ]
#    }
#}'