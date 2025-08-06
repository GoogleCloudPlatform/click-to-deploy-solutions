import streamlit as st
from vertexai.vision_models import ImageGenerationModel
from vertexai.generative_models import GenerativeModel, Part
from google.genai.types import GenerateVideosConfig, Image
from google.genai import types
import time
import uuid

from config import client, gcs_bucket_name, storage_client
from gcs import upload_bytes_to_gcs


def refine_prompt_with_gemini(user_prompt: str, for_video: bool = False) -> str:
    """Uses Gemini on Vertex AI to refine a user's prompt for image or video generation."""
    model = GenerativeModel("gemini-2.0-flash")
    
    if for_video:
        refinement_prompt = f"""
        You are an expert prompt engineer for text-to-video models.
        Your task is to refine the following user prompt to make it more descriptive, vivid, and detailed for generating a high-quality, engaging video from a static image.
        Focus on adding specific details about camera movements (e.g., pan, zoom, tilt), character actions, environmental changes, and dynamic elements.
        Return only the refined prompt, without any additional text or explanation.

        User Prompt: "{user_prompt}"
        """
    else: # For image generation
        refinement_prompt = f"""
        You are an expert prompt engineer for text-to-image models.
        Your task is to refine the following user prompt to make it more descriptive, vivid, and detailed for generating a high-quality, photorealistic image.
        Add specific details about the subject, environment, lighting, camera angle, and overall style.
        Return only the refined prompt, without any additional text or explanation.

        User Prompt: "{user_prompt}"
        """
    
    try:
        response = model.generate_content(refinement_prompt)
        return response.text.strip()
    except Exception as e:
        st.error(f"An error occurred with Gemini: {e}")
        print(f"Error occurred with prompt refinement, error: {e}")
        return ""
    
def refine_veo_prompt_with_gemini(user_prompt: str, image_bytes: bytes = None, mime_type: str = "image/png") -> str:
    """Uses Gemini on Vertex AI to refine a user's prompt for image or video generation, optionally with an image."""
    model = GenerativeModel("gemini-2.0-flash")
    
    refinement_prompt_text = f"""
    You are an expert prompt engineer for text-to-video models.
    Your task is to refine the following user prompt to make it more descriptive, vivid, and detailed for generating a high-quality, engaging video.
    Focus on adding specific details about camera movements (e.g., pan, zoom, tilt), character actions, environmental changes, and dynamic elements.
    If an image is provided, consider how these elements can interact with or animate the visual content of the image.
    Return only the refined prompt, without any additional text or explanation.

    User Prompt: "{user_prompt}"
    """
    
    contents = [Part.from_text(refinement_prompt_text)]
    if image_bytes:
        contents.append(Part.from_data(image_bytes, mime_type=mime_type))
    
    try:
        response = model.generate_content(contents)
        return response.text.strip()
    except Exception as e:
        st.error(f"An error occurred with Gemini: {e}")
        return ""


def generate_image_with_imagen(prompt: str) -> bytes:
    """Generates an image using Imagen on Vertex AI and returns its bytes."""
    try:
        model = ImageGenerationModel.from_pretrained("imagen-3.0-generate-002")
        response = model.generate_images(
            prompt=prompt,
            number_of_images=1,
            aspect_ratio="16:9",
            safety_filter_level="block_some",
            person_generation="allow_adult"
        )
        
        image_bytes = response.images[0]._image_bytes
        return image_bytes
    except Exception as e:
        st.error(f"An error occurred with Imagen: {e}")
        return None

def generate_video_with_veo(input_type: str, input_content: bytes | str, video_prompt: str) -> bytes | None:
    """
    Generates a video using the Veo model on Vertex AI.
    This function handles the long-running operation and downloads the video from GCS
    for display in Streamlit. It can accept either image bytes or a text prompt as input.
    """
    genai_image = None
    if input_type == "image":
        if not isinstance(input_content, bytes):
            st.error("Input content for image generation must be bytes.")
            return None
            
        unique_image_filename = f"veo_input_image_{uuid.uuid4()}.png"
        input_image_gcs_uri = upload_bytes_to_gcs(gcs_bucket_name, unique_image_filename, input_content, content_type="image/png")
        
        if not input_image_gcs_uri:
            return None

        genai_image = types.Image(
            gcs_uri=input_image_gcs_uri,
            mime_type="image/png",
        )

    timestamp = int(time.time())
    output_video_gcs_uri = f"gs://{gcs_bucket_name}/veo_output_{timestamp}.mp4"

    try:
        if input_type == "image":
            operation = client.models.generate_videos(
                model="veo-2.0-generate-001",
                prompt=video_prompt,
                image=genai_image,
                config=GenerateVideosConfig(
                    aspect_ratio="16:9",
                    number_of_videos=1,
                    duration_seconds=8,
                    output_gcs_uri=output_video_gcs_uri,
                ),
            ) 
        else: # Text to Video
            operation = client.models.generate_videos(
                model="veo-2.0-generate-001",
                prompt=video_prompt,
                config=GenerateVideosConfig(
                    aspect_ratio="16:9",
                    number_of_videos=1,
                    duration_seconds=8,
                    output_gcs_uri=output_video_gcs_uri,
                ),
            ) 

        progress_bar = st.progress(0)
        status_text = st.empty()
        start_time = time.time()

        while not operation.done:
            time.sleep(15)
            operation = client.operations.get(operation) 
            
            elapsed_time = time.time() - start_time
            status_text.text(f"Video generation in progress... Elapsed time: {int(elapsed_time)}s")
            
            progress = min(int(elapsed_time / 120 * 100), 99) 
            progress_bar.progress(progress)
            
        progress_bar.progress(100)
        status_text.text("Video generation complete!")

        if operation.response and operation.result and operation.result.generated_videos:
            video_uri = operation.result.generated_videos[0].video.uri
            try:
                video_blob_name = video_uri.replace(f"gs://{gcs_bucket_name}/", "")
                bucket = storage_client.bucket(gcs_bucket_name)
                blob = bucket.blob(video_blob_name)
                video_bytes = blob.download_as_bytes()
                
                return video_bytes
            except Exception as e:
                st.error(f"Failed to download video from GCS: {e}")
                st.warning("Please ensure the GCS bucket has appropriate permissions for downloading.")
                return None
        else:
            st.error("Veo operation completed but no video URI found in the response.")
            if operation.error:
                st.error(f"Veo API error: {operation.error.message}")
            return None

    except Exception as e:
        st.error(f"An error occurred with Veo: {e}")
        return None