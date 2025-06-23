import streamlit as st
import os
from dotenv import load_dotenv
from google.oauth2 import id_token
from google.auth.transport import requests

load_dotenv()

def authentication():
    GOOGLE_CLIENT_ID = ""# Replace with your client ID

    def verify_token(token):
        try:
            # Verify the token with Google's servers
            idinfo = id_token.verify_oauth2_token(token, requests.Request(), GOOGLE_CLIENT_ID)

            # Check if the token is from the correct audience (your client ID)
            if idinfo['aud'] != GOOGLE_CLIENT_ID:
                raise ValueError('Wrong audience.')

            return idinfo
        except ValueError as e:
            print(e)
            return "Invalid"
        except Exception as e:
            print(e)
            return "Error"

    # Get the token from the query parameter
    token = st.query_params.get("token", "")
    if not token:
        st.error("Unauthorized access. Token not provided.")
        st.stop()

    # Verify the token
    decoded = verify_token(token)

    if decoded == "Invalid":
        st.error("Invalid token. Access denied.")
        st.stop()
    elif decoded == "Error":
        st.error("Error in token verification. Access denied.")
        st.stop()
    
        