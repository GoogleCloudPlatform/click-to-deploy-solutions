# Python image to use.
FROM python:3.10

# Set the working directory to /app
WORKDIR /ca_api_agent_builder

# copy the requirements file used for dependencies
COPY requirements.txt .
# COPY looker-automation.ini .

# Install any needed packages specified in requirements.txt --no-cache-dir
RUN pip install --no-cache-dir --trusted-host pypi.python.org -r requirements.txt

# Copy the rest of the working directory contents into the container at /app
COPY . .

# Run main.py when the container launches
# CMD uvicorn main:app --host 0.0.0.0 --port $PORT
# ENTRYPOINT ["python3", "main.py"]
ENTRYPOINT ["fastapi", "run", "app.py","--port","8080"]