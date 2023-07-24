[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)


# Cloud Armor Demo

This example deploys a web application called [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/), and exposes it to the internet by using a Global Load Balancer protected with Cloud Armor.

:clock1: Estimated deployment time: 4 min 23 sec

:heavy_dollar_sign: Estimated solution cost: [USD 86.68 per 1 month](https://cloud.google.com/products/calculator/#id=4690c11f-35e2-4eb1-9565-efb1fdd5faba)

## Architecture
![architecture](architecture.png)

## Deploy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=cloud-armor-demo&cloudshell_open_in_editor=terraform/terraform.tfvars" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the script below to execute the pre-reqs required to deploy the solution.
```
sh prereq.sh
```

3. Run the Cloud Build Job
```
gcloud builds submit . --config cloudbuild.yaml
```


## Destroy
Run the command below on Cloud Shell to destroy the resources.
```
gcloud builds submit . --config cloudbuild_destroy.yaml
```
