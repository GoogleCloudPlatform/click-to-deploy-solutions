import streamlit as st
import os
import uuid
import moviepy as mp

def save_temp_video(video_bytes: bytes, segment_index: int) -> str:
    """Saves video bytes to a temporary file and returns the path."""
    temp_dir = "temp_video_segments"
    os.makedirs(temp_dir, exist_ok=True)
    temp_filepath = os.path.join(temp_dir, f"segment_{segment_index}_{uuid.uuid4()}.mp4")
    try:
        with open(temp_filepath, "wb") as f:
            f.write(video_bytes)
        return temp_filepath
    except Exception as e:
        st.error(f"Error saving temporary video file: {e}")
        return None

def stitch_videos(video_paths: list[str]) -> bytes | None:
    """Stitches multiple video files into one and returns the bytes of the combined video."""
    if not video_paths:
        return None

    try:
        st.info("Stitching video segments together...")
        clips = [mp.VideoFileClip(path) for path in video_paths]
        final_clip = mp.concatenate_videoclips(clips)

        output_filename = f"final_stitched_video_{uuid.uuid4()}.mp4"
        output_filepath = os.path.join("temp_video_segments", output_filename)
        
        final_clip.write_videofile(output_filepath, codec="libx264", audio_codec="aac", fps=24, preset="ultrafast")

        with open(output_filepath, "rb") as f:
            final_video_bytes = f.read()

        # Clean up temporary files and directory
        for path in video_paths:
            if os.path.exists(path):
                os.remove(path)
        if os.path.exists(output_filepath):
            os.remove(output_filepath)
        # Only remove the directory if it's empty
        if os.path.exists("temp_video_segments") and not os.listdir("temp_video_segments"):
            os.rmdir("temp_video_segments")

        st.success("Videos generated successfully!")
        return final_video_bytes

    except Exception as e:
        st.error(f"Error stitching videos with MoviePy: {e}")
        st.warning("Please ensure FFmpeg is installed and accessible in your environment for MoviePy to function correctly.")
        return None
