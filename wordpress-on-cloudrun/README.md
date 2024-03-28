[![GC Start](assets/gcp_banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)
# Host a Serverless Wordpress Site with Cloud Run

## Introduction

_This architecture uses click-to-deploy so you can spin up infrastructure in minutes using terraform!_

43% of the Web is built on Wordpress. Because of its simplicity and versatility, Wordpress can be used for internal websites and customer facing e-commerce platforms in small to large businesses, while still offering security. **Cloud Run automatically scales your WordPress application to handle any amount of traffic**, without requiring manual intervention. This means that your website can handle large traffic spikes, without worrying about capacity.

Cloud Run allows you to deploy your WordPress application quickly and easily, with a few clicks or commands. You can deploy your application from a container image stored in a container registry or directly from a Git repository. This click-to-deploy architecture leverages the serverless and scalability benefits of using Cloud Run to host a Wordpress Application connected to a PostgreSQL instance.

This repo is based on the Cloud Foundation Fabric blueprint available [here](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/blueprints/third-party-solutions/wordpress/cloudrun).

## Use cases

These are some of the use cases you can build on top of this infrastructure:
* Business websites
* E-commerce websites
* Portfolios
* Non-profit websites
* Educational Websites

## Architecture

![Wordpress on Cloud Run](assets/architecture.png "Wordpress on Cloud Run")

The main components that are deployed in this architecture are the following (you can learn about them by following the hyperlinks):

* [Cloud Run](https://cloud.google.com/run): serverless PaaS offering to host containers for web-oriented applications, while offering security, scalability and easy versioning
* [Cloud SQL](https://cloud.google.com/sql): Managed solution for SQL databases
* [VPC Serverless Connector](https://cloud.google.com/vpc/docs/serverless-vpc-access): Solution to access the CloudSQL VPC from Cloud Run, using only internal IP addresses

## Costs

Pricing Estimates - We have created a sample estimate based on some usage we see from new startups looking to scale. This estimate would give you an idea of how much this deployment would essentially cost per month at this scale and you extend it to the scale you further prefer. Here's the [link](https://cloud.google.com/products/calculator#id=8a7471c9-98df-4b71-97de-6222d22484c8).


## Deploy the architecture

1. Click on Open in Google Cloud Shell button below. Sign in if required and when the prompt appears, click on “confirm”. It will walk you through setting up your architecture.

<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=wordpress-on-cloudrun&cloudshell_open_in_editor=infra/variables.tf&cloudshell_tutorial=tutorial.md" target="_new">
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
<center>
<h4>🎉 Congratulations! 🎉  <br />

You have successfully deployed the foundation for running Wordpress using CloudRun on Google Cloud.</h4></center>

**Notes**:

1. If you want to change your admin password later on, please note that you can only do so via the Wordpress user interface.
2. If you have the [domain restriction org. policy](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains) on your organization, you have to edit the `cloud_run_invoker` variable and give it a value that will be accepted in accordance to your policy.


If you face a problem, please check out the [known issues section](#known-issues).

## Using the Wordpress Installation

Upon completion, you will see the output with the values for the Cloud Run service and the user and password to access the `/admin` part of the website. You can also view it later with:

``` {shell}
terraform output
```

or for the concrete variable:

``` {shell}
terraform output cloud_run_service
```

When clicking on the Wordpress link, it will immediately prompt you to register as an administrator. The password will be pre-filled and can be changed after registration. 

![Wordpress on Cloud Run](assets/wordPress_setup.png "Wordpress on Cloud Run")

## Cleaning Up Your Environment

Execute the command below on Cloud Shell to delete the resources, so there will be no billable charges made afterwards..
```
gcloud builds submit . --config build/cloudbuild_destroy.yaml

```

## Known issues
 
You might get the following error (or a similar one):

``` {shell}
│ Error: resource is in failed state "Ready:False", message: Revision '...' is not ready and cannot serve traffic.│
```

In case this happens, manually run
``` {shell}
    gcloud builds submit . --config build/cloudbuild.yaml
```
to run the installation again.


<!-- BEGIN TFDOC -->

## Special Thanks
A special thank you goes out to Natalia Strelkova (skalolazka) and Grigory Movsesyan, the original developers of this example architecture.

## Variables

| name | description | type | default |
|---|---|:---:|:---:|
| [project_id](variables.tf#L78) | Project id, references existing project if `project_create` is null. | <code>string</code> | |
| [wordpress_image](variables.tf#L89) | Image to run with Cloud Run, starts with \"gcr.io\" | <code>string</code> | mirror.gcr.io/library/wordpress |
| [cloud_run_invoker](variables.tf#L18) | IAM member authorized to access the end-point (for example, 'user:YOUR_IAM_USER' for only you or 'allUsers' for everyone) | <code>string</code> | <code>&#34;allUsers&#34;</code> |
| [cloudsql_password](variables.tf#L24) | CloudSQL password (will be randomly generated by default) | <code>string</code> |  <code>null</code> |
| [connector](variables.tf#L30) | Existing VPC serverless connector to use if not creating a new one | <code>string</code> |  <code>null</code> |
| [create_connector](variables.tf#L36) | Should a VPC serverless connector be created or not | <code>bool</code> |  <code>true</code> |
| [ip_ranges](variables.tf#L43) | CIDR blocks: VPC serverless connector, Private Service Access(PSA) for CloudSQL, CloudSQL VPC | <code title="object&#40;&#123;&#10;  connector &#61; string&#10;  psa       &#61; string&#10;  sql_vpc   &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> | <code title="&#123;&#10;  connector &#61; &#34;10.8.0.0&#47;28&#34;&#10;  psa       &#61; &#34;10.60.0.0&#47;24&#34;&#10;  sql_vpc   &#61; &#34;10.0.0.0&#47;20&#34;&#10;&#125;">&#123;&#8230;&#125;</code> |
| [prefix](variables.tf#L57) | Unique prefix used for resource names. Not used for project if 'project_create' is null. | <code>string</code> |  <code>&#34;&#34;</code> |
| [principals](variables.tf#L63) | List of users to give rights to (CloudSQL admin, client and instanceUser, Logging admin, Service Account User and TokenCreator), eg 'user@domain.com'. | <code>list&#40;string&#41;</code> | <code>&#91;&#93;</code> |
| [project_create](variables.tf#L69) | Provide values if project creation is needed, uses existing project if null. Parent is in 'folders/nnn' or 'organizations/nnn' format. | <code title="object&#40;&#123;&#10;  billing_account_id &#61; string&#10;  parent             &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> | <code>null</code> |
| [region](variables.tf#L83) | Region for the created resources | <code>string</code> |  | <code>&#34;europe-west4&#34;</code> |
| [wordpress_password](variables.tf#L94) | Password for the Wordpress user (will be randomly generated by default) | <code>string</code> | <code>null</code> |
| [wordpress_port](variables.tf#L100) | Port for the Wordpress image | <code>number</code> | <code>8080</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [cloud_run_service](outputs.tf#L17) | CloudRun service URL | ✓ |
| [cloudsql_password](outputs.tf#L23) | CloudSQL password | ✓ |
| [wp_password](outputs.tf#L29) | Wordpress user password | ✓ |
| [wp_user](outputs.tf#L35) | Wordpress username |  |

<!-- END TFDOC -->
