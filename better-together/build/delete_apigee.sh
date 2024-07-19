apt-get update
apt-get install unzip jq -y

curl -L https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | sh 
export PATH=$PATH:$HOME/.apigeecli/bin

export PROJECT="hero-test-428818"
export REGION="europe-west1"
export APIGEE_ENVIRONMENT=test1

gcloud config set project $PROJECT

apigeecli apis undeploy -n AddressValidation-Service -e $APIGEE_ENVIRONMENT -o $PROJECT -t $(gcloud auth print-access-token)

apigeecli apis delete -n AddressValidation-Service -o $PROJECT -t $(gcloud auth print-access-token)
