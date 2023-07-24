[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Three-Tier Web Application using Managed Instance Groups

## Introduction

This architecture uses click-to-deploy to create an  infrastructure to run a three-tier auto scaling web application on GCE  using MIG.

At the core of this architecture is the Three-Tier model. Managed Instance Groups (MIGs) are a critical component of auto scaling because they allow you to create a group of identical instances that can be scaled horizontally based on demand. MIGs can directly host monolithic applications without the need for containerization, making them a good option for a lift-and-shift migration if you're not ready to change your entire architecture to containers or microservices. This makes the migration process simpler and faster, as organizations can replicate their existing monolithic application directly onto the instances within the Managed Instance Groups. This approach allows for a seamless transition, minimizing the need for code refactoring or redesigning the application architecture.

To enhance security, this architecture incorporates several Google Cloud services. Cloud NAT enables secure outbound connectivity for instances within the Managed Instance Group, reducing exposure to the public internet and providing additional protection for the application and data. Cloud Armor provides web application firewall (WAF) capabilities, protecting against common web-based threats and ensuring the integrity and availability of the web application.

The combination of auto scaling and security measures makes this architecture ideal for web applications with fluctuating traffic patterns and the need for protection against potential cyber threats. It ensures that the web application remains highly available, even during peak usage periods, while safeguarding sensitive data and maintaining a secure environment.

## Use cases

These are some examples of the use cases you can build on top of this architecture:

* __E-commerce Websites__ : The architecture is well-suited for e-commerce websites that experience fluctuating traffic patterns. During peak shopping seasons or promotional events, the auto scaling feature of the Managed Instance Group ensures that the web application can handle the increased user load without performance degradation.
* __Content Management Systems (CMS)__ : Content-heavy websites or applications that rely on a CMS can benefit from this architecture. The auto scaling capability allows the application to handle varying content creation and publishing demands efficiently.
* __Media and Entertainment Websites__ : Websites or applications that deliver media-rich content, such as streaming platforms, can benefit from this architecture. The auto scaling capability ensures that the platform can handle high traffic volumes during popular events, show releases, or live streaming sessions.
* __Lift-and-shift  migration__ : The lift-and-shift strategy is a good option for companies that want to migrate monolithic applications to the cloud without making significant changes to the code or architecture. The strategy is simple, cost-effective and minimizes migration risk.

## Architecture

<p align="center"><img src="architecture.png"></p>

The main components that we would be setting up are (to learn more about these products, click on the hyperlinks)

* [Cloud CDN](https://cloud.google.com/cdn) : Google's content delivery networks—Cloud CDN and Media CDN—scale to bring content closer to a global audience.
* [Compute Engine MIG](https://cloud.google.com/compute/docs/instance-groups) : An instance group is a collection of virtual machine (VM) instances that you can manage as a single entity.
* [MemoryStore](https://cloud.google.com/memorystore) : Reduce latency with scalable, secure, and highly available in-memory service for Redis and Memcached.
* [Cloud SQL](https://cloud.google.com/sql) : Fully managed relational database service for MySQL, PostgreSQL, and SQL Server with rich extension collections, configuration flags, and developer ecosystems.
* [Cloud NAT](https://cloud.google.com/nat/docs/overview) : Lets certain resources without external IP addresses create outbound connections to the internet.
* [Cloud Armor](https://cloud.google.com/armor?hl=en) : Help protect your applications and websites against denial of service and web attacks.
* [Service Account](https://cloud.google.com/iam/docs/service-account-overview) : A service account is a special kind of account typically used by an application or compute workload, such as a Compute Engine instance, rather than a person.
* [Load Balancer: ](https://cloud.google.com/load-balancing?hl=en) : High performance, scalable load balancing on Google Cloud.
* [VPC](https://cloud.google.com/vpc) : Global virtual network that spans all regions. Single VPC for an entire organization, isolated within projects. Increase IP space with no downtime.

## Costs

Pricing Estimates - We have created a sample estimate based on some usage we see from new startups looking to scale. This estimate would give you an idea of how much this deployment would essentially cost per month at this scale and you extend it to the scale you further prefer. Here's the [link](https://cloud.google.com/products/calculator/#id=bfa6c5e2-8801-4a2a-8075-2d6588d06f13).

## Deploy

:clock1: Estimated deployment time: 8 min

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=three-tier-app-gce&cloudshell_open_in_editor=terraform/terraform.tfvars" target="_new">
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

## Destroy
1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=three-tier-app-gce" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the command below on Cloud Shell to destroy the resources.
```
gcloud builds submit . --config cloudbuild_destroy.yaml
```
