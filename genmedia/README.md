## Deploy the architecture

1. Click on Open in Google Cloud Shell button below. Sign in if required and when the prompt appears, click on “confirm”. It will walk you through setting up your architecture.

**TODO**: Update Cloud Shell link

<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=genmedi&cloudshell_open_in_editor=infra/variables.tf&cloudshell_tutorial=tutorial.md" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. If you have the [domain restriction org policy](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains) on your organization, you'll will need to make an adjustment. You can remove the [policy inheritance](https://cloud.google.com/resource-manager/docs/organization-policy/creating-managing-policies#inheriting_organization_policy) to allow public access to your Cloud Run instance. Or you can edit the `cloud_run_invoker` variable in [variables.tf](https://github.com/GoogleCloudPlatform/click-to-deploy-solutions/blob/main/genmedia/infra/variables.tf) and give it a value that will be accepted in accordance to your policy.

3. Run the prerequisites script to enable APIs and set Cloud Build permissions.
```
sh prereq.sh
```

4. Run the Cloud Build Job
```
gcloud builds submit . --config build/cloudbuild.yaml
```

## Check your deployment
Once deployment is completed, terraform will output the app URL as: **cloud_run_service_url = "https://genmedia-app-xxxxxxxx.a.run.app"**.

<br>

You can retrieve the url at any time with:
``` bash
terraform output
```

or for the concrete variable:

``` bash
terraform output cloud_run_service_url
```

Alternatively, you can find the app URL under services [Cloud Run](https://console.cloud.google.com/run).


## Cleaning up your environment
Execute the command below on Cloud Shell to delete the resources.
```
gcloud builds submit . --config build/cloudbuild_destroy.yaml
```

This is not an official Google product.
