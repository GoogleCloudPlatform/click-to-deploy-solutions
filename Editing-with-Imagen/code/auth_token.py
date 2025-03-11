import streamlit as st
import jwt
import os
from dotenv import load_dotenv

load_dotenv()

def authentication():
    SECRET_KEY = os.getenv("SECRET_KEY", "default_secret_key")

    def decode_token(token):
        try:
            # Decode the token with the same secret key
            payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            return payload
        except jwt.ExpiredSignatureError:
            return "Expired"
        except jwt.InvalidTokenError:
            return "Invalid"

    # Get the token from query parameters
    query_params = st.query_params
    token = query_params.get("token", None)

    if not token:
        st.error("Unauthorized access. Token not provided.")
        st.stop()

    # Decode the token
    decoded = decode_token(token)

    if decoded == "Expired":
        st.error("Token has expired. Please login again.")
        st.stop()

    elif decoded == "Invalid":
        st.error("Invalid token. Access denied.")
        st.stop()

    # If token is valid, continue with the app
    # st.success("Authenticated successfully!")
