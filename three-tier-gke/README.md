[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Three-tier web application with Google Kubernetes Engine (GKE)

## Introduction

This architecture uses click-to-deploy so you can spin up infrastructure in minutes using terraform!

In the world of modern web development, it is essential to create scalable and reliable applications. To achieve this, a three-tier architecture has become a popular approach. This architectural pattern divides an application into three distinct layers: presentation, business logic, and data storage. Each layer has its own set of responsibilities, allowing for flexibility, maintainability, and efficient resource utilization. 

This solution focuses on the combination of GKE clusters, which allows for automatic scaling as needed, Cloud SQL as a relational database, Cloud Storage for unstructured data, and Memorystore for caching, which reduces database access on frequent queries. This solution provides a powerful and robust infrastructure for hosting a three-tier web application.

## Use cases

These are some examples of the use cases you can build on top of this architecture:

* __E-commerce Platform__ : Build a robust e-commerce platform where the presentation layer handles the user interface and shopping cart functionality. The business logic layer manages inventory, order processing, and payment integration. 

* __Content Management System (CMS)__ : Create a scalable CMS where the presentation layer handles content creation, editing, and publishing. The business logic layer manages user authentication, access controls, and content organization. Cloud SQL for MySQL stores content metadata, user profiles, and settings, while Cloud Storage stores media files, such as images and videos.

* __Analytics Dashboard__ : Develop an analytics dashboard where users can visualize and explore data insights. The presentation layer provides interactive data visualizations and filtering options. The business logic layer handles data processing, aggregation, and query optimization. 

Some common use examples include Cloud SQL for MySQL storing product catalogs, customer profiles, and transactional data, while Cloud Storage securely stores product images and other media assets.

## Architecture

<p align="center"><img src="architecture.png"></p>

The main components that we would be setting up are (to learn more about these products, click on the hyperlinks)

* [VPC](https://cloud.google.com/vpc) : Global virtual network that spans all regions. Single VPC for an entire organization, isolated within projects. Increase IP space with no downtime.
* [GKE](https://cloud.google.com/kubernetes-engine) : The most scalable and fully automated Kubernetes service
* [Cloud SQL for MySQL](https://cloud.google.com/sql) : Fully managed relational database service for MySQL, PostgreSQL, and SQL Server with rich extension collections, configuration flags, and developer ecosystems.
* [Cloud Storage (GCS) bucket](https://cloud.google.com/storage/) : Cloud Storage is a managed service for storing unstructured data. Store any amount of data and retrieve it as often as you like.

## Costs

Pricing Estimates - We have created a sample estimate based on some usage we see from new startups looking to scale. This estimate would give you an idea of how much this deployment would essentially cost per month at this scale and you extend it to the scale you further prefer. Here's the [link](https://cloud.google.com/products/calculator#id=3d137920-0e41-4c81-882f-7fdac7482776).

## Deploy the architecture

:clock1: Estimated deployment time: 12 min

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?shellonly=true&cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=three-tier-gke&cloudshell_open_in_editor=terraform/terraform.tfvars&cloudshell_tutorial=tutorial.md" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the prerequisites script to enable APIs and set Cloud Build permissions.
```
sh prereq.sh
```

3. Run the Cloud Build Job
```
gcloud builds submit . --config cloudbuild.yaml
```

## Testing the architecture 

After you deployed the solution, you can check the resources created and see how they work together.

First, go to [Google Kubernetes Engine](https://console.cloud.google.com/kubernetes) and click on the created Cluster.

![GKE](assets/gke.png)

You can see all the details of you applications in Worloads menu

![Workloads](assets/workloads.png)

Lastly,go to [Cloud LoadBalancing](https://console.cloud.google.com/net-services/loadbalancing/list/loadBalancers) and click on the frontend Load Balancer

![loadbalancer](assets/loadbalancer.png)

You can see all the details of the Load Balancer, and you can copy the Frontend IP section to access the application.

![details](assets/details.png)

Finally, if you paste the ip and enter in your browser, you see the example application

![template](assets/application.png)

## Cleaning up your environment
Execute the command below on Cloud Shell to delete the resources.
```
gcloud builds submit . --config cloudbuild_destroy.yaml
```

This is not an official Google product.
