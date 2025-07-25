## Deploy the architecture

1. Click on Open in Google Cloud Shell button below. Sign in if required and when the prompt appears, click on “confirm”. It will walk you through setting up your architecture.

**TODO**: Update Cloud Shell link

<a href=""/>
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the prerequisites script to enable APIs and set Cloud Build permissions.
```
sh prereq.sh
```

Please note - New organizations have the 'Enforce Domain Restricted Sharing' policy enforced by default. You may have to edit the policy to allow public access to your Cloud Run instance. Please refer to this [page](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#setting_the_organization_policy) for more information.

3. Run the Cloud Build Job
```
gcloud builds submit . --config build/cloudbuild.yaml
```

## Check your deployment
Once deployment is completed, terraform will output the app URL.

```sh
cloud_run_service_url = "https://genmedia-app-xxxxxxxx.a.run.app"
```

Alternatively, you can find the app URL under services [Cloud Run](https://console.cloud.google.com/run).



**Notes**:

If you have the [domain restriction org policy](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains) on your organization, you have to edit the `cloud_run_invoker` variable and give it a value that will be accepted in accordance to your policy.

## Cleaning up your environment
Execute the command below on Cloud Shell to delete the resources.
```
gcloud builds submit . --config build/cloudbuild_destroy.yaml
```

This is not an official Google product.
