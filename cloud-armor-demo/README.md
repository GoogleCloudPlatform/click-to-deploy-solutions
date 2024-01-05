[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)


# Cloud Armor Demo

This example deploys a web application called [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/), and exposes it to the internet by using a Global Load Balancer protected with Cloud Armor.

:clock1: Estimated deployment time: 4 min 23 sec

:heavy_dollar_sign: Estimated solution cost: [USD 86.68 per 1 month](https://cloud.google.com/products/calculator/#id=4690c11f-35e2-4eb1-9565-efb1fdd5faba)

## Architecture
![architecture](assets/architecture.png)

## Deploy the architecture

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=cloud-armor-demo&cloudshell_open_in_editor=infra/terraform.tfvars" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the prerequisites script to enable APIs and set Cloud Build permissions.
```
sh prereq.sh
```

3. Run the Cloud Build Job
```
gcloud builds submit . --config build/cloudbuild.yaml
```
## Testing the architecture

1. Verify that the Juice Shop Application is running
```
PUBLIC_SVC_IP="$(gcloud compute forwarding-rules describe juice-shop-http-lb  --global --format="value(IPAddress)")"
```
```
echo $PUBLIC_SVC_IP
```
Paste the output IP Address into your url bar to see the application

2. Verify that the Cloud Armor policies are blocking malicious attacks

LFI vulnerability

```
curl -Ii http://$PUBLIC_SVC_IP/?a=../
```

RCE Attack

```
curl -Ii http://$PUBLIC_SVC_IP/ftp?doc=/bin/ls
```

Well-known scanner detection
```
curl -Ii http://$PUBLIC_SVC_IP -H "User-Agent: blackwidow"
```

Protocol attack mitigation
```
curl -Ii "http://$PUBLIC_SVC_IP/index.html?foo=advanced%0d%0aContent-Length:%200%0d%0a%0d%0aHTTP/1.1%20200%20OK%0d%0aContent-Type:%20text/html%0d%0aContent-Length:%2035%0d%0a%0d%0a<html>Sorry,%20System%20Down</html>"
```

Session fixation attempt
```
curl -Ii http://$PUBLIC_SVC_IP/?session_id=a
```
3. All the above commands should return
```
HTTP/1.1 403 Forbidden
<..>
```

4. You can view the logs in Cloud Armor policies to verify these.

## Cleaning up your environment
Run the command below on Cloud Shell to destroy the resources.
```
gcloud builds submit . --config build/cloudbuild_destroy.yaml
```
