[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Host your Website on Google Cloud

## Introduction

This architecture uses click-to-deploy so you can spin up a configuration example of an Ecommerce Web Hosting.

This architecture creates a scalable, reliable, and consistent hosting environment. It enables automatic scaling of compute resources, efficient content delivery, robust storage and serving of static assets, and a managed database service for data persistence.

At the core of this architecture is Compute Engine, which provides virtual machines (VMs) to run your website or application. Compute Engine offers scalable and customizable VM instances that can be tailored to meet your specific workload requirements. To optimize content delivery and improve response times, Cloud CDN is integrated into the architecture. Cloud CDN caches static and dynamic content across a global network of edge locations, reducing latency and increasing performance for end-users.

Cloud Storage is used to store and serve static assets, such as images, videos, CSS, and JavaScript files. It provides a highly available and durable storage solution with automatic scalability. And for database needs, Cloud SQL provides a managed relational database service that ensures data consistency, scalability, and reliability. Cloud SQL offers fully managed MySQL and PostgreSQL databases, eliminating the need for manual database administration tasks. 

In summary, this architecture ensures that your website or application can handle high traffic loads, delivers content quickly to users worldwide, and maintains data integrity and availability.

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