[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Build an auto scaling application easily with GKE autopilot

## Introduction

This architecture uses click-to-deploy to demonstrate how to use Horizontal Pod Autoscaling (HPA) to scale the number of pods based on CPU utilization.

Businesses need highly available applications to provide uninterrupted service to customers and ensure a seamless user experience. However, achieving high availability can be difficult and time-consuming, as it requires complex configuration and management of infrastructure components.

GKE Autopilot is a managed Kubernetes environment that automates infrastructure management tasks, including cluster orchestration, scaling, and security updates. This allows businesses to focus on developing their applications rather than worrying about infrastructure management.

Horizontal Pod Autoscaling complements GKE Autopilot by dynamically scaling application pods to match demand. As the workload increases, additional pods are automatically provisioned to distribute the load and maintain optimal performance. Conversely, during periods of low demand, the number of pods can be scaled down, optimizing resource utilization and cost-efficiency.

This solution offers several benefits for businesses. It allows them to focus on developing their applications and delivering value to customers, rather than dealing with infrastructure complexities. By leveraging GKE Autopilot and Horizontal Pod Autoscaling, businesses can achieve high availability without the need for extensive manual configuration or ongoing maintenance.

## Use Cases

* Any web page or application that might require the following:
  * __Handling Variable Workloads__: During peak periods, HPA scales up the number of pods to accommodate increased traffic, ensuring optimal performance and responsiveness. Conversely, during periods of low utilization, HPA scales down the pods, optimizing resource utilization and reducing costs.

  * __Optimizing Resource Allocation__: As CPU utilization increases, HPA scales up the number of pods, preventing resource bottlenecks and ensuring that the application has enough compute capacity to handle the load effectively.By scaling down pods during low utilization, HPA frees up resources, enabling other applications or services to use them efficiently.

  * __Improve Performance and User Experience__: GKE HPA enables organizations to maintain optimal application performance and deliver an enhanced user experience. This results in a responsive and reliable application experience for end-users.

## Architecture
<p align="center"><img src="architecture.png"></p>

The main components that we would be setting up are (to learn more about these products, click on the hyperlinks)

* [VPC](https://cloud.google.com/vpc) : Global virtual network that spans all regions. Single VPC for an entire organization, isolated within projects. Increase IP space with no downtime
* [Subnet](https://cloud.google.com/vpc/docs/subnets) : Subnets are regional resources, and have IP address ranges associated with them.
* [NAT](https://cloud.google.com/nat/docs/overview) : Provides fully managed, software-defined network address translation support for Google Cloud.
* [GKE Autopilot](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview) : GKE Autopilot is a mode of operation in GKE in which Google manages your cluster   configuration, including your nodes, scaling, security, and other preconfigured settings.

## Deploy

:clock1: Estimated deployment time: 10 min

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=gke-autopilot-hpa&cloudshell_open_in_editor=terraform/terraform.tfvars" target="_new">
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

## Executing a load test
Once you deployed the solution, you can run a load test and see the HPA in action.

Go to [Workloads](https://console.cloud.google.com/kubernetes/workload/overview) page and see the `hpa-example` application has one replica.

- ![replicas](./assets/hpa-example-replicas.png)

To run the load test and see the HPA working, go back to the Cloud Shell console, go to this repo dir you cloned earlier, then run the load test script. For example:

```
HPA_LB_IP=$(gcloud compute addresses describe hpa-lb-ip --global --format='value(address)')
sh load_test.sh $HPA_LB_IP
```

The script will call the service many times causing the CPU to cross the target defined in the HPA for scaling out.

- ![events](./assets/hpa-scale-events.png)

## Destroy
Execute the command below on Cloud Shell to destroy the resources.
```
gcloud builds submit . --config cloudbuild_destroy.yaml
```
