# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_dialogflow_cx_agent" "agent" {
  display_name          = "looker-ca-agent"
  location              = var.region
  default_language_code = "en"
  time_zone             = "America/Chicago"
}

resource "google_dialogflow_cx_tool" "open_api_tool" {
  parent       = google_dialogflow_cx_agent.agent.id
  display_name = "CATOOL"
  description  = "Example Description"

  open_api_spec {
    authentication {
      service_agent_auth_config {
        service_agent_auth = "ID_TOKEN"
      }
    }

    # Use a HEREDOC to provide the OpenAPI schema as a raw string.
    # String interpolation is used to dynamically insert the service URL.
    text_schema = <<EOF
{
  "openapi": "3.0.0",
  "info": {
    "title": "Your API Title",
    "version": "1.0.0",
    "description": "API documentation for the /ask endpoint."
  },
  "servers": [
    {
      "url": "${google_cloud_run_v2_service.default.uri}"
    }
  ],
  "paths": {
    "/ask": {
      "post": {
        "summary": "Ask a question and get an analytics response.",
        "description": "Receives a natural language question and returns the complete analytics response as JSON.\nThe response is extracted from the last chunk of the `process_nlq_request` function.",
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/QuestionRequest"
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "Successful response containing the analytics result.",
            "content": {
              "application/json": {
                "schema": {
                  "type": "string"
                }
              }
            }
          },
          "400": {
            "description": "Bad Request. Indicates that the server could not understand the request.",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ErrorResponse"
                }
              }
            }
          },
          "500": {
            "description": "Internal Server Error.",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ErrorResponse"
                }
              }
            }
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "QuestionRequest": {
        "type": "object",
        "required": ["question"],
        "properties": {
          "question": {
            "type": "string",
            "description": "The natural language question.",
            "example": "What is the total sales for last year?"
          }
        }
      },
      "ErrorResponse": {
        "type": "object",
        "properties": {
          "detail": {
            "type": "string",
            "description": "Error details.",
            "example": "Invalid input."
          }
        }
      }
    }
  }
}
EOF
  }
}
data "google_project" "project" {}
resource "google_project_iam_member" "dialogflow_run_invoker" {
  depends_on = [
    google_dialogflow_cx_agent.agent
  ]
  project = data.google_project.project.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dialogflow.iam.gserviceaccount.com"
}