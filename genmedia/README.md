[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)
# GenMedia

## Introduction
The Google genMedia package is a powerful, unified suite of generative AI tools that represents the next evolution of media production, combining Google's most advanced models to create high-quality, multimodal assets from simple prompts. At its core, this package relies on the synergy of three industry-leading technologies: Veo handles state-of-the-art video generation, producing high-fidelity, cinematic clips with native audio from text or existing images; Imagen provides best-in-class image generation, creating detailed, photorealistic static assets and powering precise editing capabilities; and the Gemini foundation model acts as the intelligent orchestrator, applying its multimodal reasoning to manage complex, multi-step creative workflows and ensure consistency across both images and videos. This integration allows creators and developers to move beyond single-asset generation and rapidly produce complete, cohesive campaigns—from product shots to dynamic social media content—all within a single, streamlined process.

## Use cases

* __E-commerce & Advertising at Scale__: Rapidly generate thousands of consistent visual assets from a single product image or text prompt. This includes high-resolution Imagen catalog photos, alongside multiple short Veo video ads for platforms like social media, all orchestrated by Gemini to maintain brand and product consistency across diverse settings and styles.
* __Rapid Creative Prototyping__ :  Accelerate pre-production for film, gaming, and visual effects by instantly transforming a script into a full, animated storyboard. Gemini organizes the narrative, Imagen creates the detailed keyframe visuals, and Veo animates these images with specific camera work and native audio to create a complete, dynamic concept reel in minutes.
* __Global Content Localization__: Quickly localize marketing campaigns for numerous regions. Gemini manages the creative brief and generates localized prompts; Imagen and Veo then automatically produce culturally relevant images and videos (e.g., placing the same product in a Japanese setting versus a European setting), complete with localized on-screen text and voiceover audio.


## Architecture
<p align="center"><img src="app/images/architecture.png"></p>
The main components that we would be setting up are (to learn more about these products, click on the hyperlinks)

1. [Gemini](https://cloud.google.com/looker) :  Gemini acts as the multimodal foundation model that orchestrates the entire genMedia workflow, providing complex reasoning, prompt understanding, and consistency control across the image (Imagen) and video (Veo) generation processes.
2. [Imagen](https://cloud.google.com/vertex-ai/generative-ai/docs/image/overview) : Imagen is the high-fidelity text-to-image and image-editing model responsible for generating stunning, photorealistic, and brand-consistent static visuals that serve as standalone assets or as the high-quality visual basis for Veo video animation.
3. [Veo](https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/veo-video-generation): Veo is Google's state-of-the-art video generation model that converts text and still images (often from Imagen) into high-fidelity, cinematic video clips with exceptional visual consistency, realistic physics, creative controls (like camera angles), and synchronized native audio, effectively acting as the production engine of the genMedia package.


## Costs

[Pricing Estimates](https://cloud.google.com/vertex-ai/generative-ai/pricing#modality-based-pricing)


## Deploy the architecture

1. Click on Open in Google Cloud Shell button below. Sign in if required and when the prompt appears, click on “confirm”. It will walk you through setting up your architecture.

**TODO**: Update Cloud Shell link

<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=genmedia&cloudshell_open_in_editor=infra/variables.tf&cloudshell_tutorial=tutorial.md" target="_new">
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

Alternatively, you can find the app URL under services [Cloud Run](https://console.cloud.google.com/run).


## Cleaning up your environment
Execute the command below on Cloud Shell to delete the resources.
```
gcloud builds submit . --config build/cloudbuild_destroy.yaml
```

This is not an official Google product.
