import vertexai
from vertexai.preview.vision_models import Image, ImageGenerationModel
import os
import random


os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = 'path/to/JSON/key'
os.environ['GOOGLE_CLOUD_PROJECT'] = 'genail300'

# Function to make an API call to Google Imagen
def imagen_call(prompt, input_file="original_image.png"):
    project_id = "genail300"
    output_file = "./images/generated_image.png"  # Output image file name

    # Initialize Vertex AI with the project ID and location
    vertexai.init(project=project_id, location="us-central1")

    # Load the pretrained ImageGenerationModel
    model = ImageGenerationModel.from_pretrained("imagegeneration@006")
    
    # Load the original image and the mask image
    base_img = Image.load_from_file(location=input_file)
    #mask_img = Image.load_from_file(location=mask_file)

    # Call the model to generate a new image based on the prompt and mask
    images = model.edit_image(
        base_image=base_img,
        # mask=mask_img,
        mask_mode="background",
        prompt=prompt,
        edit_mode="inpainting-insert",
    )

    # Save the generated image
    images[0].save(location=output_file, include_generation_parameters=False)
    print(images)

    print(f"Created output image using {len(images[0]._image_bytes)} bytes")

# Example usage
if __name__ == "__main__":
    prompt = "A futuristic city skyline at sunset"  # Example prompt
    imagen_call(prompt)
