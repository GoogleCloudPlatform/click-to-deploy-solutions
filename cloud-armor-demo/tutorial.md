# Protect your High Availability workloads with Load Balancer and Cloud Armor

## Let's get started

This example will deploy all its resources into the project defined by the `project_id` variable. Please note that we assume this project already exists. 

However, if you provide the appropriate values to the `project_create` variable, the project will be created as part of the deployment.

If `project_create` is left to null, the identity performing the deployment needs the owner role on the project defined by the project_id variable. 

Otherwise, the identity performing the deployment needs `resourcemanager.projectCreator` on the resource hierarchy node specified by `project_create.parent` and `billing.user` on the billing account specified by `project_create.billing_account_id`.

**Time to complete**: About 10 minutes

Click the **Start** button to move to the next step.

## Spinning up the architecture

1. Run the prerequisites script to enable APIs and set Cloud Build permissions.

```bash
sh prereq.sh
```

2. Run the Cloud Build Job

```bash
gcloud builds submit . --config ./build/cloudbuild.yaml
```

## Result

<center>
<h4>🎉 Congratulations! 🎉 </h4><br/>
At this point you should have successfully deployed the foundations to protect your High Availability workloads with Load Balancer and Cloud Armor.</center>

Next we are going to test the architecture and finally clean up your environment.

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

The above command will delete the associated resources so there will be no billable charges made afterwards.

<!-- BEGIN TFDOC -->

## Variables & Outputs

For full information on variables and outputs please refer to the [README](https://github.com/GoogleCloudPlatform/deploystack-google-lb-and-armor#variables) file.

## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

You’re all set!
