[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)
# Editing Using Imagen

This architecture illustrates a streamlined workflow for editing images using Google's Imagen AI. The process begins with the user uploading an image to the platform.  The user then provides a text prompt describing the desired edits. This prompt, along with the image, is sent to Imagen, which resides within Vertex AI, Google Cloud's machine learning platform. Imagen leverages its powerful generative AI capabilities to interpret the prompt and intelligently apply the edits to the image. This includes automatically masking relevant areas of the image, ensuring that the edits are precise and targeted. The final edited image is then returned to the user. This architecture demonstrates how Imagen simplifies and accelerates image editing, allowing users to easily achieve their desired results with natural language prompts.

## Use cases

* __Product Image Enhancement__: Automatically improve product images for e-commerce websites. Using Imagen, businesses can enhance product images by removing backgrounds, adjusting lighting, or even adding special effects like a "glossy" finish. This can be done in bulk, saving significant time and resources compared to manual editing.
* __Personalized Marketing Collateral__: Create customized marketing materials featuring user-generated images. Imagine a travel agency that encourages customers to submit photos from their trips. Using Imagen, the agency can seamlessly edit these images to incorporate their branding or promotional messages, creating unique and engaging marketing content that resonates with individual customers.
* __Social Media Content Creation__: Quickly generate visually appealing images for social media posts. Social media managers can use Imagen to modify images with filters, add text overlays, or resize them to fit different platform requirements. This streamlines the content creation process and ensures a consistent brand aesthetic across all channels.


## Architecture
<p align="center"><img src="assets/Architecture.png"></p>
The main components that we would be setting up are (to learn more about these products, click on the hyperlinks)

1. [Imagen](https://cloud.google.com/use-cases/text-to-image-ai) : Imagen is a powerful AI model from Google that generates and edits images from text descriptions.
2. [Vertex AI](https://cloud.google.com/vertex-ai) : Fully managed platform streamlining the entire machine learning lifecycle, from development to production, with powerful tools and infrastructure.

## Costs
Pricing Estimates - We have created a sample estimate based on some usage we see from new startups looking to scale. This estimate would give you an idea of how much this deployment would essentially cost per month at this scale and you extend it to the scale you further prefer. Here's the [link](https://cloud.google.com/products/calculator/estimate-preview/15e38d2d-f023-4d94-958f-3688d89f0cdf?e=48754805&hl=en).


## Deploy the architecture

Before we deploy the architecture, you will need the following information:
 * The **project ID**

Estimated deployment time: 15 min

Follow the steps below to deploy the architecture:

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=genai-for-marketing&cloudshell_open_in_editor=infra/variables.tf&&cloudshell_tutorial=tutorial.md" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

1. Run the prerequisites script to enable APIs permissions.

```sh
sh prereq.sh
```
Next, you'll be asked to enter the project ID of the destination project. Please provide the project ID when prompted.  

## Result

Congratulations! The GenAI for marketing project deployment should now be underway. Please be patient as this process might take some time. Kindly keep this window open during the deployment. Once completed, we'll proceed to test the architecture and then guide you through cleaning up your environment.

## Cleaning up your environment

The below command will delete the associated resources so there will be no billable charges made afterwards.

```sh
terraform destroy -auto-approve
```

