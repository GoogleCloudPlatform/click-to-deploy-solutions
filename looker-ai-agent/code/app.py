import asyncio
import aiohttp
import json
import logging
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse # Use JSONResponse for non-streaming JSON output
from pydantic import BaseModel
from typing import Optional
import os # Import os to potentially use environment variables
from google.auth import default
from google.auth.transport.requests import Request as gRequest
import requests

# --- PLACEHOLDERS ---
# You need to replace these with your actual implementations or values
# WARNING: Hardcoding credentials like this is NOT secure for production.
# Use environment variables or a secrets manager (like Google Secret Manager)
# in a real-world application.


# --- Cortado Setup ---
SCOPES = ["https://www.googleapis.com/auth/cloud-platform"]

# CA API System Instructions
sys_instructions = """
- system_description: >-
    You are an expert data analyst and understand how to answer questions about
    various analytics data.
"""

def get_auth_token():
    """Shows basic usage of the Google Auth library in a Colab environment.
    Returns:
      str: The API token.
    """
    credentials, _ = default(scopes=SCOPES)
    auth_req = gRequest()
    credentials.refresh(auth_req)  # refresh token
    if credentials.valid:
        return credentials.token

# Consider fetching system instructions from environment variables or a config file
CORTADO_SYS_INSTRUCTIONS = sys_instructions

# --- END PLACEHOLDERS ---

# Configure basic logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Define the request body model
class QuestionRequest(BaseModel):
    question: str
    # data_part: Optional[str]

app = FastAPI()

# Your original NLQ function adapted to wait for the full response
async def process_nlq_request(question: str):
    """
    Processes the natural language question, waits for the full response
    from the external API, and returns the complete JSON result.
    """
    try:
        token = get_auth_token() # Get your auth token

        # SECURITY RISK: Hardcoded credentials. Move these to environment variables
        # or a secrets manager in production.
        client_id = os.environ.get("LOOKER_CLIENT_ID", "")
        client_secret = os.environ.get("LOOKER_CLIENT_SECRET", "")
        PROJECT = os.environ.get("PROJECT", "")

        payload = {
            "project": PROJECT,
            "messages": [
                {
                    "userMessage": {
                        "text": question
                    }
                }
            ],
            "context": {
                "systemInstruction": f"""{CORTADO_SYS_INSTRUCTIONS}""",
                "datasourceReferences": {
                    "looker": {
                        "exploreReferences": [
                            {
                                "lookerInstanceUri": os.environ.get("LOOKER_INSTANCE",""),
                                "lookmlModel": os.environ.get("LOOKML_MODEL",""),
                                "explore": os.environ.get("LOOKML_EXPLORE",""),
                            }
                        ],
                        "credentials": {
                            "oauth": {
                                "secret": {
                                    "client_id": client_id,
                                    "client_secret": client_secret
                                }
                            }
                        }
                    }
                }
            }
        }
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "Accept": "text/event-stream" # Still request event-stream from upstream
        }
        url = f"https://dataqna.googleapis.com/v1alpha1/projects/{PROJECT}:askQuestion"

        data = []

        async with aiohttp.ClientSession() as session:
            async with session.post(url, json=payload, headers=headers) as resp:
                if resp.status == 200:
                    buffer = ''
                    async for chunk in resp.content.iter_any():
                        if not chunk:
                            continue

                        decoded_chunk = chunk.decode('utf-8').strip()
                        buffer += decoded_chunk
                        logging.debug(f"Received chunk: {decoded_chunk}") # Log the chunk

                        # Try to find complete JSON objects
                        while True:
                            try:
                                start_idx = buffer.find('{')
                                if start_idx == -1:
                                    break

                                # Find matching end brace
                                brace_count = 0
                                end_idx = start_idx

                                for i in range(start_idx, len(buffer)):
                                    char = buffer[i]
                                    if char == '{':
                                        brace_count += 1
                                    elif char == '}':
                                        brace_count -= 1

                                    if brace_count == 0:
                                        end_idx = i + 1
                                        break

                                if brace_count != 0:
                                    break

                                # Extract and yield complete JSON
                                json_str = buffer[start_idx:end_idx].strip()
                                json_str = json_str[:-len("]")] if json_str.endswith("]") else json_str
                                try:
                                    json.loads(json_str) #validate json
                                except json.JSONDecodeError as e:
                                    logging.error(f"JSONDecodeError: {e}, for string: {json_str}")
                                    buffer = buffer[end_idx:]
                                    break # Important: Break after error
                                buffer = buffer[end_idx:]
                                data.append(json.loads(json_str))
                                await asyncio.sleep(0)

                            except Exception as e:
                                logging.error(f"Error processing chunk: {e}, buffer: {buffer}")
                                break # Important: Break on any error

                    # Handle any remaining complete JSON in buffer
                    if buffer.strip() and buffer.strip() != "]":
                       data.append(json.loads(buffer))
                else:
                    # format json object error message that can be parsed in the frontend
                    error_text = await resp.text()
                    logging.error(f"Error from server: {resp.status} - {error_text}")
                    yield str(json.dumps({"error": error_text, "code": resp.status}))
        
        yield data
    except:
        logging.error("some Errror")


@app.post("/ask")
async def ask_endpoint(request: QuestionRequest):
    """
    FastAPI endpoint to receive a natural language question and return
    the complete analytics response as JSON.
    """
    logger.info(f"Received question: {request.question}")
    # Call the function that waits for the full response
    chunks = []
    async for chunk in process_nlq_request(request.question):
        chunks = chunk
    print("Chunks: ", chunks)
    text_resp = chunks[len(chunks) - 1]['systemMessage']['text']['parts'][0]

    return JSONResponse(content=text_resp, status_code=200)


# Optional: Add a root endpoint for health checks
@app.get("/")
async def read_root():
    return {"status": "ok"}
