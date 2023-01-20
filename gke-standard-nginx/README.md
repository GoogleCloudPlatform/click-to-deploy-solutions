# Google Kubernetes Engine with NGINX

This example deploys  a Google Kubernetes Engine (GKE) with NGINX Ingress.

Resources created:
- VPC
- Google Kubernetes Engine cluster
- Load Balancers

Applications deployed:
- Jenkins
- Prometheus Stack (Prometheus, Grafana, and Alert Manager)


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


## Accessing the applications
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

In your environment, please use a proper domain and set DNS records.
Save the file and try to access the application, it should work:
![grafana](./assets/grafana.png)


## Destroy
Execute the command below on Cloud Shell to destroy the resources.
```
sh cloudbuild.sh destroy
```

## Useful links
- TODO
