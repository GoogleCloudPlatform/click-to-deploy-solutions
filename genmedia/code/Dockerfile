# Use the official Python image as the base image
FROM python:3.12-slim

# Install FFmpeg and its dependencies
# apt-get is used for Debian-based images like this one (bookworm)
RUN apt-get update && \
    apt-get install -y ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file to the working directory
COPY requirements.txt .

# # Install system dependencies (including OpenGL)
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     libgl1-mesa-glx \
#     libglib2.0-0 
# # && rm -rf /var/lib/apt/lists/* 

# RUN apt-get install ffmpeg libsm6 libxext6  -y

# Install any dependencies
RUN pip install --no-cache-dir -r requirements.txt


# Copy the content of the local src directory to the working directory
COPY . .

# Streamlit-specific commands for running the app
CMD streamlit run app.py --server.enableXsrfProtection false --server.port $PORT