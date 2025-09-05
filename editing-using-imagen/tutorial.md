# **Editing Images Using Imagen**

## **Let's get started**

### **Getting Started with Imagen for Image Editing on Vertex AI**

This document provides a comprehensive guide for customers who want to use Imagen to edit pictures, covering both the initial environment setup and the image editing workflow.

---

### **1\. Environment Setup**

These steps are essential for a developer to prepare their Google Cloud project and authenticate their environment to use the Imagen API.

1. **Project Selection/Creation:** In the Google Cloud Console, select or create a new Google Cloud project. It's recommended to create a new project if you don't intend to keep the resources, as it allows for easy deletion of all associated resources later.  
2. **Enable Billing:** Ensure that billing is enabled for your Google Cloud project. This is a prerequisite for using Vertex AI.  
3. **Enable the Vertex AI API:** Navigate to the APIs & Services section and enable the **Vertex AI API** for your project.  
   ---

   ### **2\. Image Editing Workflow**

After your environment is set up, this is the process for using Imagen to edit an existing image.

1. [**Access Image:**](https://console.cloud.google.com/vertex-ai/studio/media/generate%20) On the left hand menu, navigate to Vertex AI \-\> Under Vertex AI Studio select Media Studio  
2. **Upload the Image:** Upload the image you wish to edit to the platform.  
3. **Provide a Clear Prompt:** Write a clear and concise text prompt that describes the specific edits or changes you want to be applied to the image.  
4. **Submit the Request:** Submit both the uploaded image and your text prompt to Imagen through the application interface or API call.  
5. **Review the Output:** The Imagen model will return the edited image. You can review the result and, if needed, refine your prompt and regenerate the image.

## **Test Samples**

Sample Images for you to use: 

1. Bag you want to edit: [Bag.png](https://drive.google.com/file/d/1qYEEzfni_zd5ZE_5AvAFZf_mqc1CVQ65/view?usp=drive_link)  
2. Car you want to edit: [uploaded\_image.png](https://drive.google.com/file/d/1kFukDO_Nv9AUhrfWxU8VR_QPOhNhczGY/view?usp=drive_link)

Sample Prompts:

1. Generate a product shot of the bag suitable for a website catalog, featuring studio lighting and a grey backdrop.([Bag.png](https://drive.google.com/file/d/1qYEEzfni_zd5ZE_5AvAFZf_mqc1CVQ65/view?usp=drive_link))  
2. Generate an image of the car on a snowy mountain road.([uploaded\_image.png](https://drive.google.com/file/d/1kFukDO_Nv9AUhrfWxU8VR_QPOhNhczGY/view?usp=drive_link))

## **Result**

#### **🎉 Congratulations\! 🎉**

You’re all set\!  
