[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Windows File Server on Google Cloud

## Introduction

This architecture uses click-to-deploy to create an example of building a 2TB capacity Windows file server environment on Google Cloud.

The Windows File Server architecture on Google Cloud provides a robust and reliable environment for efficient data storage and management. This architecture utilizes a 2TB persistent disk, offering ample storage capacity to accommodate your growing file storage needs.

With disk snapshot enabled, you can ensure data protection and quick disaster recovery. The snapshot feature allows you to capture the state of your disk at a specific point in time, creating a backup that can be easily restored in case of data loss or system failures.

By leveraging the power of Google Cloud, this file server environment offers high scalability, performance, and security. You can effortlessly scale up or down your storage capacity as required, ensuring that your file server can adapt to your changing business demands. Additionally, Google Cloud's robust security measures, including encryption and access controls, provide a secure environment for your sensitive data.

Resources created
- VPC
- GCP
- Persistent Disk

:clock1: Estimated deployment time: 1 min 25 seg

## Arquitecture

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