# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os

from flask import Flask, request
from google.cloud import dlp_v2
import ast
import base64
import logging
import json


# pylint: disable=C0103
app = Flask(__name__)
logging.basicConfig(format='%(message)s', level=logging.INFO)


def redact_dlp_item(project_id: str, inspect_item: str):
    """Redact sensitive data from a given string using Google Cloud DLP API.

    This function uses the Google Cloud DLP API to identify and redact
    sensitive information within a given string. It supports redacting
    the following data types:

    - PERSON_NAME
    - US_SOCIAL_SECURITY_NUMBER
    - EMAIL_ADDRESS
    - PHONE_NUMBER

    Args:
        project_id (str): The Google Cloud project ID.
        inspect_item (str): The string to be inspected and redacted.

    Returns:
        str: The redacted string with sensitive data
             replaced by "[SENSITIVE DATA]".
    """
    client = dlp_v2.DlpServiceClient()

    parent = f"projects/{project_id}"
    item = {"value": inspect_item}
    inspect_config = {
        "info_types": [
            {"name": "PERSON_NAME"},
            {"name": "US_SOCIAL_SECURITY_NUMBER"},
            {"name": "EMAIL_ADDRESS"},
            {"name": "PHONE_NUMBER"}
        ]
    }
    deidentify_config = {
      "info_type_transformations": {
          "transformations": [
              {
                  "primitive_transformation": {
                      "replace_config": {
                          "new_value": {"string_value": "[SENSITIVE DATA]"}
                      }
                  }
              }
          ]
      }
    }

    response = client.deidentify_content(
        request={
            "parent": parent,
            "deidentify_config": deidentify_config,
            "inspect_config": inspect_config,
            "item": item,
        }
    )

    return response.item.value


@app.route("/", methods=["POST"])
def index():
    """Receive and parse Pub/Sub messages.

    This function handles incoming HTTP POST requests, expecting a Pub/Sub
    message in the request body. It parses the message, extracts the
    `textPayload` from the message data, and redacts sensitive information
    within the payload using the `redact_dlp_item` function.

    Returns:
        tuple: An empty tuple and a 204 status code indicating successful
               processing of the Pub/Sub message.
    """
    recevied_msg = request.get_json()
    if not recevied_msg:
        msg = "no Pub/Sub message received"
        print(f"error: {msg}")
        logging.error(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    if not isinstance(recevied_msg, dict) or "message" not in recevied_msg:
        msg = "invalid Pub/Sub message format"
        print(f"error: {msg}")
        logging.error(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    pubsub_message = recevied_msg["message"]

    if isinstance(pubsub_message, dict) and "data" in pubsub_message:
        msg = json.loads(
            base64.b64decode(pubsub_message["data"]).decode("utf-8").strip()
        )
        payload = msg["textPayload"]
        jsopn_payload = ast.literal_eval(payload)
        if isinstance(jsopn_payload, dict):
            for key, _ in jsopn_payload.items():
                redact_item = redact_dlp_item(
                    project_id=os.environ.get("PROJECT_ID"),
                    inspect_item=jsopn_payload[key]
                )
                jsopn_payload[key] = redact_item
            logging.info(jsopn_payload)
    return ("", 204)


if __name__ == '__main__':
    server_port = os.environ.get('PORT', '8080')
    app.run(debug=False, port=server_port, host='0.0.0.0')
