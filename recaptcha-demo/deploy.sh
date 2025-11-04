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

# This variable is used to rename files that may otherwise be overwritten 
START=$(date +%s)

#Project selector
select_project () {
    num_projects=0

    while IFS= read -r line; do
        project_list+=( "$line" )
    done < <( gcloud projects list --sort-by=projectId --format="value(PROJECT_ID)")
    num_projects=$(echo ${#project_list[@]})

    while : ; do
        echo "Available projects:"
        count=0
        for i in "${project_list[@]}"; do
            echo "[$count]" ${project_list[$count]};
            count=$(expr $count + 1);
        done
        # Check there are projects available, if none then prompt users to
        # investigate then exit
        if [ "$num_projects" -gt "0" ]; then
            echo -n "Please select a project: "
            read var_project
            # TODO: set the REGION variable based on this answer
            # include logic to make sure the input makes sense
            if [ "$num_projects" -gt "$var_project" ]; then
                export PROJECT_ID="${project_list[$var_project]}"
                gcloud config set project $PROJECT_ID
                export PROJECT_NUMBER=$(gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)")
                break
            else
                echo "Selection out of range."
            fi
        else
            echo -e "\e[0;31mNo projects found. Do you need to authenticate this command line session?\e[0m"
            exit 1
        fi        
    done
}

# Check there is a project set
if [ -z "$GOOGLE_CLOUD_PROJECT" ]
then
    select_project
else
    export PROJECT_ID=$GOOGLE_CLOUD_PROJECT
    export PROJECT_NUMBER=$(gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)")
fi

# Check the set project is the one the user wants to use
while : ; do
    echo -n "Deploy solution to project: "$PROJECT_ID" Y/n: "
    read var_confirm
    case "$var_confirm" in
        [yY][eE][sS]|[yY]|"") 
            echo "Deploying to $PROJECT_ID"
            break
            ;;
        *)
            select_project
            ;;
    esac
done

# get the current default region if set
export REGION=$(gcloud config get-value compute/zone)
regions=()
num_regions=0

#Because there could be multiple calls to select_region, we only want to 
#make a list of regions once (it takes a few seconds to run)
populate_regions () {
    if [ -z "${regions[0]}" ] 
    then
        while IFS= read -r line; do
            regions+=( "$line" )
        done < <( gcloud compute regions list --uri | cut -d'/' -f9 )
        num_regions=$(echo ${#regions[@]})
    fi
}

#region selector
select_region () {
    populate_regions
    while : ; do
        echo "Please select a region."
        count=0
        for i in "${regions[@]}"; do
            echo "[$count]" ${regions[$count]};
            count=$(expr $count + 1);
        done
        echo -n "What region do you want to deploy the reCAPTCHA demo to?: "
        read var_region
        # TODO: set the REGION variable based on this answer
        # include logic to make sure the input makes sense
        if [ "$num_regions" -gt "$var_region" ]; then
            REGION="${regions[$var_region]}"
            break
        else
            echo "Selection out of range."
        fi
    done
    
}

echo -n "Checking region: "

#If the region isn't set, go select one
if [ -z "$REGION" ] 
then
    echo "Region not set"
    select_region
fi

#Check the region selected is the one they want to use
while : ; do
  echo -n "Deploy reCAPTCHA demo to region: "$REGION" Y/n: "
    read var_confirm
    case "$var_confirm" in
        [yY][eE][sS]|[yY]|"") 
            echo "Deploying to $REGION"
            break
            ;;
        *)
            select_region
            ;;
    esac
done

# Enable the required services
echo "Checking and enabling services in project $PROJECT_ID, this could take a minute or two."

#This could be one command, but the time to enable all the services can be in the miniutes,
#so running one at a time gives the user some feedback.
echo " - reCAPTCHA"
gcloud services enable recaptchaenterprise.googleapis.com 

echo " - Compute"
gcloud services enable compute.googleapis.com 

echo " - Storage"
gcloud services enable storage.googleapis.com 

echo " - Artifact Registry"
gcloud services enable artifactregistry.googleapis.com 

echo " - Cloud Build"
gcloud services enable cloudbuild.googleapis.com 

echo " - Cloud Run"
gcloud services enable run.googleapis.com

echo " - Secrets Manager"
gcloud services enable secretmanager.googleapis.com

# check if cleanup.sh already exists from prior run, rename it if it does
# The cleanup script created can be used to nuke everything afterwards
# It's important that cleanup commands are added before a create command
# runs, so that if a create command only partially completes then errors 
# out, then the cleanup will still be there.
[ -f cleanup.sh ] && mv cleanup.sh cleanup-old-$START.sh

#These variables are used in the build process
COMMITID=$(git log --format="%H" -n 1)
SHORTCOMMIT=${COMMITID: -5}

#This service account is used instead of the default compute engine S/A
#This is better practice than adding permissions to the default S/A
SERVICE_ACCOUNT=recaptcha-heroes-compute-${SHORTCOMMIT}@${PROJECT_ID}.iam.gserviceaccount.com

#Add removal of this service account to the cleanup before it's created
echo "gcloud iam service-accounts delete $SERVICE_ACCOUNT --quiet --no-user-output-enabled 2>&1 >/dev/null" >> cleanup.sh

# Create S/A
echo "Creating service account $SERVICE_ACCOUNT"
gcloud iam service-accounts create recaptcha-heroes-compute-$SHORTCOMMIT \
  --display-name "reCAPTCHA Heroes Compute Service Account"

echo "Granting permissions to $SERVICE_ACCOUNT"

# These are the roles needed to run the build and deploy to cloud run
# Least privilege applies here. You may alter these permissions as required.
declare -a roles=(
   "roles/artifactregistry.writer"
   "roles/cloudbuild.builds.builder"
   "roles/cloudbuild.integrations.owner"
   "roles/iam.serviceAccountUser"
   "roles/logging.logWriter"
   "roles/run.developer"
   "roles/storage.objectUser"
)

# The dots provide feedback so the user sees progress. On S/A creation it can take a
# little while for the S/A to be ready for permissions assignments after creation, so
# we wait 10 seconds
echo -n "."
sleep 5
echo -n "."
sleep 5

# Add the roles
for role in "${roles[@]}"
do
    echo -n "."
    # If the adding succeeds then move to the next one. If it fails, retry once then
    # cleanup and quit.
    if gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT --role="$role" --no-user-output-enabled ; then
        echo -n "."
    else
        echo "\nRetrying\n"
        sleep 5
        if gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT --role="$role" --no-user-output-enabled ; then
            echo -n "."
        else
            echo -e "\e[0;31m\nFailed to add required permission to $SERVICE_ACCOUNT: $role\n\e[0m"
            echo "cleaning up"
            bash cleanup.sh
            echo -e "\e[0;31mPlease rerun the script to try again\e[0m"
            exit 1
        fi
    fi
    
    echo -n "."
    sleep 1
done
echo ""

# Create the API key needed by the demo. It should be restricted to the reCAPTCHA service.
# Fetch the key name for the cleanup script
APIKEYNAME=$(gcloud services api-keys create --api-target=service=recaptchaenterprise.googleapis.com --display-name="reCAPTCHA Heroes Demo API key" --format="json" --quiet 2>/dev/null | jq '.response.name' | cut -d'"' -f2)
echo "gcloud services api-keys delete $APIKEYNAME --quiet" >> cleanup.sh
# Then fetch the secret value for use in the script itself
APIKEY=$(gcloud services api-keys get-key-string $APIKEYNAME | cut -d" " -f2)

# Create the reCAPTCHA keys
echo Created an API key for use by reCAPTCHA Enterprise
V3KEY=$(gcloud recaptcha keys create --display-name=heroes-score-site-key --web --allow-all-domains --integration-type=score 2>&1 | grep -Po '\[\K[^]]*')
echo Created score based site-key $V3KEY
echo "gcloud recaptcha keys delete $V3KEY --quiet" >> cleanup.sh
V2KEY=$(gcloud recaptcha keys create --display-name=heroes-checkbox-site-key --web --allow-all-domains --integration-type=checkbox 2>&1 | grep -Po '\[\K[^]]*')
echo Created visual challenge based site-key $V2KEY
echo "gcloud recaptcha keys delete $V2KEY --quiet" >> cleanup.sh
TEST2KEY=$(gcloud recaptcha keys create --display-name=heroes-test2-site-key --testing-score=0.2 --web --allow-all-domains --integration-type=score 2>&1 | grep -Po '\[\K[^]]*')
echo Created test site-key with a score of 0.2 $TEST2KEY
echo "gcloud recaptcha keys delete $TEST2KEY --quiet" >> cleanup.sh
TEST8KEY=$(gcloud recaptcha keys create --display-name=heroes-test8-site-key --testing-score=0.8 --web --allow-all-domains --integration-type=score 2>&1 | grep -Po '\[\K[^]]*')
echo Created test site-key with a score of 0.8 $TEST8KEY
echo "gcloud recaptcha keys delete $TEST8KEY --quiet" >> cleanup.sh
EXPRESSKEY=$(gcloud recaptcha keys create --display-name=heroes-express-site-key --express 2>&1 | grep -Po '\[\K[^]]*')
echo Created express site-key $EXPRESSKEY
echo "gcloud recaptcha keys delete $EXPRESSKEY --quiet" >> cleanup.sh

# Create the logging buckets, use START instead of SHORTCOMMIT because bucket names are global
# so there would be multiple buckets with the same name on SHORTCOMMIT.
LOG_BUCKET=recaptcha-heroes-logs-$START

echo "Creating log bucket gs://$LOG_BUCKET"
gcloud storage buckets create gs://$LOG_BUCKET

echo "gcloud artifacts repositories delete recaptcha-heroes-docker-repo-$SHORTCOMMIT --location=$REGION --quiet" >> cleanup.sh
echo "Creating artifact registry repository recaptcha-heroes-docker-repo-$SHORTCOMMIT"
if ! gcloud artifacts repositories create recaptcha-heroes-docker-repo-$SHORTCOMMIT --repository-format=docker --location=$REGION --description="Docker repository"; then
    echo -e "\e[0;31mFailed to create artifact registry repository\e[0m"
    bash cleanup.sh
    echo -e "\e[0;31mPlease rerun the script to try again\e[0m"
    exit 1
fi

# Add delete service to cleanup
echo "gcloud run services delete recaptcha-demo-service-$SHORTCOMMIT --region=$REGION --quiet" >> cleanup.sh

# Create the cloudbuild.yaml. This replaces variables in the template
echo "Creating cloudbuild.yaml"
sed -e "s/LOG_BUCKET/$LOG_BUCKET/" -e "s/SHORTCOMMIT/$SHORTCOMMIT/" -e "s/SERVICE_ACCOUNT/$SERVICE_ACCOUNT/" -e "s/REGION/$REGION/" -e "s/PROJECT_ID/$PROJECT_ID/" -e "s/PROJECT_NUMBER/$PROJECT_NUMBER/" -e "s/COMMITID/$COMMITID/"  -e "s/V3KEY/$V3KEY/" -e "s/V2KEY/$V2KEY/" -e "s/TEST2KEY/$TEST2KEY/" -e "s/TEST8KEY/$TEST8KEY/" -e "s/EXPRESSKEY/$EXPRESSKEY/" cloudbuild-template.yaml > cloudbuild.yaml

# Add the APIKEY to secrets manager
echo "gcloud secrets delete recaptcha-heroes-apikey-$SHORTCOMMIT --quiet" >> cleanup.sh
echo "Creating secret recaptcha-heroes-apikey-$SHORTCOMMIT"
echo -n $APIKEY | gcloud secrets create recaptcha-heroes-apikey-$SHORTCOMMIT --replication-policy="automatic" --data-file=-
echo "Granting permission to read secret recaptcha-heroes-apikey-$SHORTCOMMIT to $SERVICE_ACCOUNT"
if ! gcloud secrets add-iam-policy-binding projects/$PROJECT_NUMBER/secrets/recaptcha-heroes-apikey-$SHORTCOMMIT --member serviceAccount:$SERVICE_ACCOUNT --role roles/secretmanager.secretAccessor; then
    echo -e "\e[0;31mFailed to grant permission to read secret\e[0m]"
    echo "cleaning up"
    bash cleanup.sh
    exit 1
fi

echo "Starting build"
if ! gcloud builds submit --region=$REGION --config cloudbuild.yaml ; then
    echo -e "\e[0;31mBuild failed \e[0m"
    bash cleanup.sh
    echo -e "\e[0;31mBPlease rerun the script to try again\e[0m"
    exit 1
fi

# Stats for nerds
echo Start $START 
echo End $(date +%s)

# Offer the user the chance to connect to the demo right now
echo -n "Would you like to connect to the demo now? Y/n: "
read var_confirm
case "$var_confirm" in
    [yY][eE][sS]|[yY]|"") 
        gcloud run services proxy recaptcha-demo-service-$SHORTCOMMIT --project $PROJECT_ID --region $REGION
        ;;
    *)
        echo "exiting"
        ;;
esac

# Give the user the command they will need to connect to the demo
echo To connect to the demo use: gcloud run services proxy recaptcha-demo-service-$SHORTCOMMIT --project $PROJECT_ID --region $REGION
# check if run.sh already exists from prior run, rename it if it does
[ -f run.sh ] && mv run.sh run-old-$START.sh

# Make a .sh that will connect in case the user forgets to make note of
# the connect command.
echo "gcloud run services proxy recaptcha-demo-service-$SHORTCOMMIT --project $PROJECT_ID --region $REGION" > run.sh
