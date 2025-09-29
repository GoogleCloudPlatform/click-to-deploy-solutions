import streamlit as st
from session_state import initialize_session_state
from ui_components import (
    image_to_video_tab,
    text_to_video_tab,
    animate_image_tab,
    long_video_tab,
    image_to_long_video_tab,
)


def main():
    st.set_page_config(layout="wide", page_title="GenMedia Studio")
    st.title("GenMedia Studio ✨")
    st.markdown("Create stunning visuals and videos with Gemini, Imagen, and Veo.")

    initialize_session_state()

    tab_image_to_video, tab_text_to_video, tab_animate_image, tab_long_video, tab_img_to_long_video = st.tabs([
        "🖼️ Image to Video Generation",
        "📝 Text to Video Generation",
        "✨ Animate Image",
        "🎬 Long Video Generator (Text-Based)",
        "📸 Image to Long Videos"
    ])

    with tab_image_to_video:
        image_to_video_tab()

    with tab_text_to_video:
        text_to_video_tab()

    with tab_animate_image:
        animate_image_tab()

    with tab_long_video:
        long_video_tab()

    with tab_img_to_long_video:
        image_to_long_video_tab()


if __name__ == "__main__":
    main()
