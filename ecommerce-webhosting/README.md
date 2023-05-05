[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Configuration Example - ECommerce Website Hosting

This is a stack that deploys a Configuration Example of Ecommerce Webhosting.

This repository contains Terraform sample code to deploy Cloud Storage, Compute Engine, Cloud Sql and LoadBalancing.

Resources created
- VPC
- GCE
- Cloud SQL
- Cloud Storage

:clock1: Estimated deployment time: 20 min

:heavy_dollar_sign: Estimated solution cost: [USD 224.42 per month](https://cloud.google.com/products/calculator/#id=c868657d-f5a4-4a09-8da1-a4d6b24b7862)

![arquitecture](architecture.png)

## Deploy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?shellonly=true&cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=ecommerce-webhosting" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `deploy.sh` script
```
sh cloudbuild.sh
```
## Destroy
Execute the command below on Cloud Shell to destroy the resources.
```
sh cloudbuild.sh destroy
```

This is not an official Google product.