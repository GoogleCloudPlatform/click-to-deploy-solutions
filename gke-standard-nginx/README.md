[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Automate the deployment of your Kubernetes applications

## Introduction
This architecture uses click-to-deploy so you can spin up an infrastructure in minutes using terraform.

In the fast-paced world of software development, organizations strive to achieve efficient and automated processes to deliver high-quality applications at a rapid pace. To accomplish this, companies leverage technologies like Google Kubernetes Engine (GKE) for container orchestration, Jenkins to implement CI/CD pipelines, and Prometheus Stack for monitoring.. 

This architecture enables the company to achieve several key benefits. Firstly, it automates and streamlines the application deployment process, reducing manual intervention and improving deployment consistency. Secondly, it ensures scalability and high availability by leveraging GKE's container orchestration capabilities, allowing applications to scale dynamically to handle varying workloads. Thirdly, the integrated monitoring stack provides valuable insights into the system's performance, allowing the company to proactively address any issues, optimize resource usage, and ensure a high-quality user experience.

Overall, this architecture offers a robust and efficient solution for modern application deployment, enabling the company to accelerate their software development processes, improve scalability and reliability, and gain valuable insights into application performance. 

Resources created:
- VPC
- Google Kubernetes Engine cluster
- Load Balancers

Applications deployed:
- Jenkins
- Prometheus Stack (Prometheus, Grafana, and Alert Manager)

:clock1: Estimated deployment time: 13 min

## Architecture
![architecture](architecture.png)

## Deploy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=gke-standard-nginx" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script and follow the instructions
```
sh cloudbuild.sh
```


## Testing

In this example, we use an example domain (example.com), so you need to set the NGINX IP it in your `/etc/hosts` file in order to access the appications.

Go to the [GKE Services](https://console.cloud.google.com/kubernetes/discovery) and copy the external IP assigned to `ingress-nginx-controller`, then add it to your machine's `/etc/hosts` alongside `<app>.example.com`, for example:
```
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost

34.95.133.118   jenkins.example.com
34.95.133.118   grafana.example.com
34.95.133.118   prometheus.example.com
```

NOTE: In your environment, please use a proper domain and set DNS records.


Save the file and try to access the application http://grafana.example.com, it should work:
![grafana](./assets/grafana.png)


## Destroy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=gke-standard-nginx" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script with `destroy` argument.
```
sh cloudbuild.sh destroy
```
