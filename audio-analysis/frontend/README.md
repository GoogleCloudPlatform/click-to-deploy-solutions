##Command to deploy Cloud Run


```sh
gcloud run deploy audio-analysis-frontend   --source .  --region us-central1   --allow-unauthenticated   --platform managed --port 8501 --timeout 600 --set-env-vars  PROJECT_ID=click-to-deploy-demo,GCS_INPUT_BUCKET=click-to-deploy-demo-audio_analysis_input,GCS_OUTPUT_BUCKET=click-to-deploy-demo-audio_analysis_output
```