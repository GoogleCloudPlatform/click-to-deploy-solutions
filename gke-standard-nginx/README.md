[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Leverage NGINX for Load Balancing in a Kubernetes Architecture

## Introduction

_This architecture uses click-to-deploy so you can spin up a GKE cluster with_
[_NGINX_][1] _for load balancing_.

In the fast-paced world of software development, organizations strive to achieve
efficient and automated processes to deliver high-quality applications at a
rapid pace. To accomplish this, companies leverage technologies like Google
Kubernetes Engine (GKE) for container orchestration, Jenkins to implement CI/CD
pipelines, and Prometheus Stack for monitoring.

This architecture enables the company to achieve several key benefits. Firstly,
it automates and streamlines the application deployment process, reducing manual
intervention and improving deployment consistency. Secondly, it ensures
scalability and high availability by leveraging GKE's container orchestration
capabilities, allowing applications to scale dynamically to handle varying
workloads. Thirdly, the integrated monitoring stack provides valuable insights
into the system's performance, allowing the company to proactively address any
issues, optimize resource usage, and ensure a high-quality user experience.

Overall, this architecture offers a robust and efficient solution for modern
application deployment, enabling the company to accelerate their software
development processes, improve scalability and reliability, and gain valuable
insights into application performance.

## Use cases

These are some examples of the use cases you can build on top of this
architecture:

- **Web applications**: This architecture can be used to deploy and manage web
  applications. The Nginx controller can be used to load balance traffic across
  multiple pods or nodes in a cluster, and Jenkins can be used to automate the
  deployment of applications to Kubernetes. Prometheus can be used to collect
  metrics from the web applications and to generate alerts when applications are
  unhealthy or when performance metrics are outside of acceptable ranges.
- **Automated Deployment and Testing**: With GKE and Jenkins, you can set up an
  automated CI/CD pipeline that enables seamless deployment of applications to
  the Kubernetes cluster.Jenkins can be configured to monitor source code
  repositories, trigger build processes, run automated tests, and deploy
  application containers to GKE.Utilize the Prometheus Stack to collect and
  analyze metrics from the deployment pipeline, monitoring the application's
  performance and ensuring its stability.
- **Scalable and Resilient Deployment**: By combining GKE with NGINX, you can
  achieve scalable and resilient application deployments. NGINX acts as a
  reverse proxy and load balancer in front of the GKE cluster, efficiently
  distributing traffic to the application containers. GKE's built-in scalability
  features, combined with NGINX's load balancing capabilities, allow the
  infrastructure to handle increasing user loads and ensure high availability.

## Architecture

![Design Architecture](assets/architecture.png)

The main components that we would be setting up are (to learn more about these
products, click on the hyperlinks)

- [VPC][2] with Private Service Access to deploy the instances and
  VM
- [Google Kubernetes Engine cluster][3]: The most scalable and
  fully automated Kubernetes service
- [Load Balancers][4]: When your app usage spikes, it is important
  to scale, optimize and secure the app. Cloud Load Balancing is a fully
  distributed solution that balances user traffic to multiple backends to avoid
  congestion, reduce latency and increase security.

**Applications Deployed**

- The [Prometheus Stack][5] including Prometheus, Grafana, and Alert
  Manager.
- A [Jenkins][6] instance which is an open-source automation
  server that lets you flexibly orchestrate your build, test, and deployment
  pipelines.

## Costs

Pricing Estimates - We have created a sample estimate based on some usage we see
from new startups looking to scale. This estimate would give you an idea of how
much this deployment would essentially cost per month at this scale and you
extend it to the scale you further prefer. Here's the [link][7].

## Setup

This solution assumes you already have a project created and set up where you
wish to host these resources. If you haven't created a project yet or want to create a new one, please follow the instructions in this [guide][8].
### Prerequisites

- Have an [organization][9] set up in Google cloud.
- Have a [billing account][10] set up.
- Have an existing [project][11] with [billing
  enabled][12], we'll call this the **service project**.

### Roles & Permissions

In order to spin up this architecture, you will need to be a user with the **Project owner** [IAM][13] role on the existing project:

> __Note__: To grant a user a role, take a look at the [Granting and Revoking Access][14] documentation.

### Deploy the architecture

:clock1: Estimated deployment time: 13 min

1. Click on Open in Google Cloud Shell button below.

<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=gke-standard-nginx&cloudshell_open_in_editor=terraform/terraform.tfvars&cloudshell_tutorial=tutorial.md" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the prerequisites script to enable APIs and set Cloud Build permissions.

```bash
sh prereq.sh
```

3. Run the Cloud Build Job

```bash
gcloud builds submit . --config build/cloudbuild.yaml
```

### Testing your architecture

In this example, we demonstrate the usage of a sample domain (example.com). To access the applications, you should set the NGINX IP in your /etc/hosts file.


Go to the [GKE Services][15] and copy the external IP assigned to `ingress-nginx-controller`, then add it to your machine's `/etc/hosts` alongside `<app>.example.com`, for example:

```txt
##
# Host Database
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost
34.95.133.118   jenkins.example.com
34.95.133.118   grafana.example.com
34.95.133.118   prometheus.example.com
```

> __Note__: In your environment, please use a proper domain and set DNS records.

Looking at the grafana.example.com should look like this:
![grafana login][16]

## Cleaning up your environment

Run the command below on Cloud Shell to delete the resources.

```bash
gcloud builds submit . --config build/cloudbuild_destroy.yaml
```

<!-- BEGIN TFDOC -->

## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [project_id](variables.tf#L50) | Project id, references existing project if `project_create` is null. | <code>string</code> | ✓ |  |

<!-- END TFDOC -->

[1]: https://www.nginx.com/
[2]: https://cloud.google.com/vpc
[3]: https://cloud.google.com/kubernetes-engine
[4]: https://cloud.google.com/load-balancing
[5]: https://cloud.google.com/stackdriver/docs/managed-prometheus
[6]: https://cloud.google.com/kubernetes-engine/docs/archive/jenkins-on-kubernetes-engine
[7]: https://cloud.google.com/products/calculator/#id=d03e562e-8f7b-41a8-9aed-bb064efa2b3c
[8]: https://github.com/GoogleCloudPlatform/click-to-deploy-solutions/tree/main/gke-standard-nginx
[9]: https://cloud.google.com/resource-manager/docs/creating-managing-organization
[10]: https://cloud.google.com/billing/docs/how-to/manage-billing-account
[11]: https://cloud.google.com/resource-manager/docs/creating-managing-projects
[12]: https://cloud.google.com/billing/docs/how-to/modify-project
[13]: https://cloud.google.com/iam
[14]: https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role
[15]: https://console.cloud.google.com/kubernetes/discovery
[16]: https://github.com/GoogleCloudPlatform/click-to-deploy-solutions/raw/main/gke-standard-nginx/assets/grafana.png
