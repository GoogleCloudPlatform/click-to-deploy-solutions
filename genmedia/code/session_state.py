import streamlit as st

def initialize_session_state():
    # Initialize session state variables
    if 'refined_prompt' not in st.session_state:
        st.session_state.refined_prompt = ""
    if 'raw_image_user_prompt' not in st.session_state:
        st.session_state.raw_image_user_prompt = "" 
    if 'image_bytes' not in st.session_state:
        st.session_state.image_bytes = None
    if 'uploaded_image_bytes' not in st.session_state: 
        st.session_state.uploaded_image_bytes = None
    if 'uploaded_image_mime_type' not in st.session_state:
        st.session_state.uploaded_image_mime_type = "image/png"
    if 'video_bytes' not in st.session_state:
        st.session_state.video_bytes = None
    
    if 'raw_veo_user_prompt' not in st.session_state:
        st.session_state.raw_veo_user_prompt = ""
    if 'veo_refined_prompt' not in st.session_state:
        st.session_state.veo_refined_prompt = "" 
    
    if 'raw_text_to_video_user_prompt' not in st.session_state:
        st.session_state.raw_text_to_video_user_prompt = ""
    if 'text_to_video_refined_prompt' not in st.session_state:
        st.session_state.text_to_video_refined_prompt = ""
    if 'animate_image_uploaded_bytes' not in st.session_state:
        st.session_state.animate_image_uploaded_bytes = None
    if 'animate_image_uploaded_mime_type' not in st.session_state: 
        st.session_state.animate_image_uploaded_mime_type = "image/png"
    if 'animate_image_prompt_option' not in st.session_state:
        st.session_state.animate_image_prompt_option = "Without prompt"
    
    if 'raw_animate_image_user_prompt' not in st.session_state:
        st.session_state.raw_animate_image_user_prompt = ""
    if 'animate_image_refined_prompt' not in st.session_state:
        st.session_state.animate_image_refined_prompt = ""
    if 'animate_image_video_bytes' not in st.session_state:
        st.session_state.animate_image_video_bytes = None

    # Long Video (Text-Based)
    if 'long_video_segments' not in st.session_state: 
        st.session_state.long_video_segments = []
    if 'long_video_final_video' not in st.session_state: 
        st.session_state.long_video_final_video = None
    if 'long_video_raw_segment_prompts' not in st.session_state: 
        st.session_state.long_video_raw_segment_prompts = [""]
    if 'long_video_refined_segment_prompts' not in st.session_state:
        st.session_state.long_video_refined_segment_prompts = [""]
    if 'long_video_segment_bytes' not in st.session_state:
        st.session_state.long_video_segment_bytes = [None] 


    # Image to Long Video
    if 'img_long_video_uploaded_image_bytes' not in st.session_state:
        st.session_state.img_long_video_uploaded_image_bytes = None
    if 'img_long_video_uploaded_image_mime_type' not in st.session_state:
        st.session_state.img_long_video_uploaded_image_mime_type = "image/png"
    if 'img_long_video_raw_segment_prompts' not in st.session_state:
        st.session_state.img_long_video_raw_segment_prompts = [""]
    if 'img_long_video_refined_segment_prompts' not in st.session_state:
        st.session_state.img_long_video_refined_segment_prompts = [""]
    if 'img_long_video_generated_segments_paths' not in st.session_state:
        st.session_state.img_long_video_generated_segments_paths = []
    if 'img_long_video_final_video' not in st.session_state:
        st.session_state.img_long_video_final_video = None
    if 'img_long_video_segment_bytes' not in st.session_state:
        st.session_state.img_long_video_segment_bytes = [None]
