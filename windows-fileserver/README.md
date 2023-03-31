[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Configuration Example - Windows File Server

This is a stack that deploys a Configuration Example of Windows File Server.

This repository contains Terraform sample code to deploy Compute Engine and a Persistent Disk.

Resources created
- VPC
- GCP
- Persistent Disk

![arquitecture](architecture.png)

## Deploy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?shellonly=true&cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=windows-fileserver" target="_new">
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