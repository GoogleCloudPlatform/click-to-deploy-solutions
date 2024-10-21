FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirement.txt
COPY . .
EXPOSE 8501
CMD ["streamlit", "run", "app.py"]