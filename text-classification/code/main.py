from flask import Flask, request, jsonify
from google.cloud import aiplatform, bigquery
from datetime import datetime
import vertexai
import os
# from vertexai.preview.language_models import TextGenerationModel
from vertexai.preview.generative_models import GenerativeModel, ChatSession

app = Flask(__name__)

# Vertex AI project and location configuration
PROJECT_ID =  os.environ.get('PROJECT')
LOCATION = os.environ.get('LOCATION')  # Update with your region


vertexai.init(project=PROJECT_ID, location=LOCATION)
# Initialize model
# generation_model = TextGenerationModel.from_pretrained("gemini-1.0-pro")
model = GenerativeModel("gemini-1.0-pro")
chat = model.start_chat()

def get_chat_response(chat: ChatSession, prompt: str):
    response = chat.send_message(prompt)
    return response.text

print("$$$$$$$$$$$$")
# print(available_models)  

def insert_emotion_in_bigquery(emotion, text):
    client = bigquery.Client(project=PROJECT_ID)
    table_id = f'{PROJECT_ID}.classified_messages.classified_messages'

    # Get the current time
    current_time = datetime.now().isoformat()

    # Define the row to insert
    row_to_insert = [
        {"message": text, "emotion": emotion, "timestamp": current_time}
    ]

    # Insert the row
    errors = client.insert_rows_json(table_id, row_to_insert)
    if errors == []:
        return "Hello World successfully written to BigQuery!"
    else:
        return f"Encountered errors while inserting row: {errors}"


@app.route("/", methods=["POST"])
def analyze_sentiment():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()
    if "text" not in data:
        return jsonify({"error": "Missing 'text' in request data"}), 400
    
    text = data["text"]

    # Use the Gemini model to analyze sentiment
    # response = generation_model.predict(
    #     f"""Classify the emotion in this text: "{text}". Give me a simple answer such as happy, sad, angry, doubtful, thoughtful, kind, stressed."""
    # )
    prompt = f"""Classify the emotion in this text: "{text}". Give me a simple answer in only one word nothing else such as happy, sad, angry, doubtful, thoughtful, kind, stressed."""
    

    emotion =  get_chat_response(chat, prompt)    
    return insert_emotion_in_bigquery(emotion, text)
    # return jsonify({"emotion": emotion})

    # return jsonify({"emotion": emotion, "sentiment_score": sentiment_score})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(debug=True, host="0.0.0.0", port=port)


# # main.py
# from flask import Flask
# from google.cloud import bigquery
# from datetime import datetime
# import os

# app = Flask(__name__)

# # Your Google Cloud Project ID
# PROJECT_ID = 'charles-hero'

# @app.route('/')
# def hello_world_to_bigquery():
#     client = bigquery.Client(project=PROJECT_ID)
#     table_id = f'{PROJECT_ID}.classified_messages.classified_messages'

#     # Get the current time
#     current_time = datetime.now().isoformat()

#     # Define the row to insert
#     row_to_insert = [
#         {"message": "Hello World", "timestamp": current_time}
#     ]

#     # Insert the row
#     errors = client.insert_rows_json(table_id, row_to_insert)
#     if errors == []:
#         return "Hello World successfully written to BigQuery!"
#     else:
#         return f"Encountered errors while inserting row: {errors}"

# if __name__ == "__main__":
#     app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
# https://lookerstudio.google.com/c/u/0/reporting/create?c.mode=edit&ds.connector=BIG_QUERY&ds.type=TABLE&ds.projectId=charles-hero&ds.datasetId=classified_messages&ds.tableId=classified_messages