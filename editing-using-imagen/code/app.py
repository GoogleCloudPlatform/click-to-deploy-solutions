import streamlit as st
import numpy as np
from PIL import Image, ImageOps
from streamlit_drawable_canvas import st_canvas
from imagen_api_call import imagen_call  # Import the imagen_call function
import auth_token

def app():

    # Initialize session state variables
    if 'image_generated' not in st.session_state:
        st.session_state.image_generated = False
    if 'retry_clicked' not in st.session_state:
        st.session_state.retry_clicked = False


    # Streamlit app layout
    st.title("Edit images with Google Imagen")

    st.write("Upload an image, mark a region, and then generate a new image.")

    uploaded_file = st.file_uploader("Choose an image...", type=["jpg", "png", "jpeg"], key="file_uploader")

    if uploaded_file is not None:
        # Reset session state variables when a new file is uploaded or cleared
        # st.session_state.image_generated = False
        # st.session_state.retry_clicked = False
        image = Image.open(uploaded_file)

        # Display Original Image with Dynamic Scaling
        st.image(image, caption="Original Image")

        prompt = st.text_input("Enter the prompt for the image generation:")

        
        if st.button("Generate Image", type="primary"): 
                
                st.session_state.image_generated = False
                st.session_state.retry_clicked = False
                with st.spinner("Generating image..."): 
                    image_path = "./uploaded_image.png"
                    image.save(image_path) 

                    try:
                            imagen_call(prompt=prompt, input_file=image_path)
                            st.session_state.image_generated = True  # Mark image as generated
                                # Display Generated Image with Dynamic Scaling
                            st.write("Generated Image:")
                            generated_image = Image.open("./generated_image.png")
                            st.image(generated_image, caption="Generated Image")
                    except Exception as e:
                            st.error(f"An error occurred during image generation: {e}")

        if st.session_state.image_generated:
            if st.button("Retry", type="secondary"):
                st.session_state.retry_clicked = True

        if st.session_state.retry_clicked:
                with st.spinner("Generating new image..."): 
                    image_path = "./uploaded_image.png"
                    image.save(image_path) 

                    try:
                            imagen_call(prompt=prompt, input_file=image_path)

                                # Display Generated Image with Dynamic Scaling
                            st.write("Generated Image:")
                            generated_image = Image.open("./generated_image.png")
                            st.image(generated_image, caption="Generated Image")
                    except Exception as e:
                            st.error(f"An error occurred during image generation: {e}")

if __name__ == "__main__":
        #auth_token.authentication();
        app();