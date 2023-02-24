import http
import os
import logging
from wsgiref import validate
from flask import Flask, request
from google.cloud import pubsub_v1


PROJECT_ID = os.environ.get("PROJECT_ID")
TOPIC_ID = os.environ.get("TOPIC_ID")

app = Flask(__name__)

@app.route("/", methods=['POST'])
def publish():
    try:
        # Request validation
        args = request.args
        entity = args.get("entity")
        if not entity:
            entity = "unknown"

        # Get the request data
        data = request.get_data()
        
        # TO-DO - If you need to validate the request, add your code here

        # Pub/sub publisher
        publisher = pubsub_v1.PublisherClient()
        topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)
        
        # Publish the message to Pub/sub
        publisher.publish(topic_path, data, entity=entity)
    except Exception as ex:
        logging.error(ex)
        return 'error:{}'.format(ex), http.HTTPStatus.INTERNAL_SERVER_ERROR

    return 'success'


if __name__ == "__main__":
    app.run(debug=False, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
