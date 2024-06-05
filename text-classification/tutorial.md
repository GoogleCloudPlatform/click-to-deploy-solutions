

1 - Disable the domain sharing restrictions

2 - Run the pre-requirements

3 - Push the cloudbuild gcloud builds submit --config build/cloudbuild.yaml --region us-central1

4 - Post a few tests

curl -X POST -H "Content-Type: application/json" -d '{"text": "The sun is shining, and life is good!"}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "Feeling grateful for simple joys."}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "Just had the best cup of coffee ever!"}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "Things could be worse, I suppose."}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "Just feeling a bit meh today."}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "It's one of those days..."}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "Did you know flamingos are pink because of their diet?"}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "I wonder what's for dinner tonight..."}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "Random thought of the day: clouds are fluffy."}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "Missing someone special today."}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "Heart feels heavy."}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "Just need a hug."}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "Excited for the weekend!"}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "Feeling a bit under the weather."}' [YOUR_CLOUD_RUN_URL]
curl -X POST -H "Content-Type: application/json" -d '{"text": "The sky is a beautiful shade of blue."}' [YOUR_CLOUD_RUN_URL]


5 - 