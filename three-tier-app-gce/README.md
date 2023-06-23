[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Three-Tier Web Application using Managed Instance Groups

## Introduction

This architecture uses click-to-deploy to create an  infrastructure to run a three-tier auto scaling web application on GCE  using MIG.

At the core of this architecture is the Three-Tier model. Managed Instance Groups (MIGs) are a critical component of auto scaling because they allow you to create a group of identical instances that can be scaled horizontally based on demand. MIGs can directly host monolithic applications without the need for containerization, making them a good option for a lift-and-shift migration if you're not ready to change your entire architecture to containers or microservices. This makes the migration process simpler and faster, as organizations can replicate their existing monolithic application directly onto the instances within the Managed Instance Groups. This approach allows for a seamless transition, minimizing the need for code refactoring or redesigning the application architecture.

To enhance security, this architecture incorporates several Google Cloud services. Cloud NAT enables secure outbound connectivity for instances within the Managed Instance Group, reducing exposure to the public internet and providing additional protection for the application and data. Cloud Armor provides web application firewall (WAF) capabilities, protecting against common web-based threats and ensuring the integrity and availability of the web application.

The combination of auto scaling and security measures makes this architecture ideal for web applications with fluctuating traffic patterns and the need for protection against potential cyber threats. It ensures that the web application remains highly available, even during peak usage periods, while safeguarding sensitive data and maintaining a secure environment.

:clock1: Estimated deployment time: 8 min

## Architecture
![architecture](architecture.png)

## Deploy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=three-tier-app-gce" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script and follow the instructions
```
sh cloudbuild.sh
```

## Destroy
1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=three-tier-app-gce" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script with the `destroy` argument
```
sh cloudbuild.sh destroy
```
