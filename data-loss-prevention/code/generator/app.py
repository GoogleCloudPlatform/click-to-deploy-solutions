import os
from datetime import date
from flask import Flask, jsonify, request
from flask_apscheduler import APScheduler
from faker import Faker
import logging


# pylint: disable=C0103
app = Flask(__name__)
fake = Faker()
scheduler = APScheduler()
logging.basicConfig(format='%(message)s', level=logging.INFO)


@app.route('/', methods=['GET'])
def hello():
    """Handles GET requests to the root path (`/`).

    This function generates a JSON response containing fake personal
    information and the current date.

    Returns:
        tuple: A tuple containing a JSON response object and a 200 OK
               status code.
    """
    if (request.method == 'GET'):
        response = jsonify(
            data=generate_person(),
            date=date.today()
        ), 200
        return response


def generate_person():
    """Generates a dictionary containing fake personal information.

    This function uses the Faker library to generate random values for
    various personal attributes, including name, email, address, phone
    number, SSN, and credit card number.

    Returns:
        dict: A dictionary containing the generated fake personal
              information.
    """
    person = {}
    person['name'] = fake.name()
    person['email'] = fake.email()
    person['address'] = fake.address()
    person['phone_number'] = fake.phone_number()
    person['ssn'] = fake.ssn()
    person['credit_card_number'] = fake.credit_card_number()
    logging.info(person)
    return person


if __name__ == '__main__':
    scheduler.add_job(
        id='Scheduled Task',
        func=generate_person,
        trigger='interval',
        seconds=60
    )
    scheduler.start()
    server_port = os.environ.get('PORT', '8080')
    app.run(debug=False, port=server_port, host='0.0.0.0')
