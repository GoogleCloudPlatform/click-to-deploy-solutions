[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Stream events in real-time for data analytics on Google Cloud

## Introduction

This architecture uses click-to-deploy so you can spin up infrastructure in minutes using terraform!

Real-time event streaming is a powerful solution that allows companies to capture and analyze data as it happens, providing immediate insights and opportunities for real-time decision-making. There are several reasons why a company would want to stream real-time events:

* To stay proactive and responsive to rapidly changing conditions. By capturing and analyzing data as it happens, companies can quickly detect and react to critical events, emerging trends, or anomalies, enabling them to make data-driven decisions in near-real time.

* To unlock valuable insights that would otherwise be lost or delayed. Traditional batch processing methods often involve analyzing data after it has been stored, which can lead to a time lag between data collection and analysis. By streaming events in real time, companies can gain immediate visibility into customer behaviors, operational performance, and market dynamics, enabling them to make timely adjustments to strategies, campaigns, and operations.

* To simplify the development and deployment process. The seamless integration of Cloud Run API, Pub/Sub, and BigQuery allows organizations to focus on building event-driven applications and analytics workflows without the need for managing complex infrastructure or custom event processing pipelines. This accelerates time-to-market and reduces operational overhead.

## Use cases

These are some examples of the use cases you can build on top of this architecture:

* __Real-time Personalization and Customer Engagement__ : valuable for organizations focused on providing personalized customer experiences and improving customer engagement. By streaming events directly to BigQuery, organizations can analyze customer interactions, preferences, and behaviors in real time. This data can be used to dynamically personalize content, recommendations, and offers, enhancing the customer journey and driving customer satisfaction.

* __IoT Data Processing and Analytics__ : IoT devices generate a massive volume of events and sensor data in real time. By leveraging the Real-time Event Streaming Architecture, organizations can ingest and process IoT events in real time, enabling them to gain valuable insights and take immediate actions based on the data. For example, in a smart home environment, events from various sensors can be streamed to BigQuery for real-time analysis, allowing homeowners to automate tasks, monitor energy consumption, and enhance security in real time.

* __Real-time Monitoring and Alerting__ : Organizations that need to track and respond to events as they happen can leverage this architecture to receive events in near real-time and perform real-time analytics. By streaming events directly to BigQuery, organizations can monitor key metrics, detect anomalies or patterns, and trigger alerts or notifications based on predefined thresholds. This use case is particularly valuable for applications that require proactive monitoring, such as fraud detection, system health monitoring, or real-time performance tracking.

Overall, real-time event streaming is a powerful tool that can help companies stay ahead of the competition and make better decisions.


Resources created:
- BigQuery dataset and table
- Pub/Sub topic and BQ subscription
- Cloud Run Ingest API

:clock1: Estimated deployment time: 2 min

## Architecture
![architecture](architecture.png)

## Deploy

1. Click on Open in Google Cloud Shell button below.

<a href="https://ssh.cloud.google.com/cloudshell/editor?shellonly=true&cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=streaming-data-to-analytics" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `deploy.sh` script
```
sh cloudbuild.sh
```

## Test your solution
If you want to run a load test, please follow the instructions below.

1. Set GCP_TOKEN env var
```
export GCP_TOKEN=$(gcloud auth print-identity-token)
```

2. Create a python virtual env and activate it
```
cd load_test
python3 -m virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
```

3. Run locust with your Cloud Run Service URL as target, for example:
```
locust -f locustfile.py --headless -u 100 -r 10 \
    --run-time 30m \
    -H https://<YOUR CLOUD RUN SERVICE URL>/
```

4. Query the events on [BigQuery](https://console.cloud.google.com/bigquery)
```
SELECT *
FROM `ecommerce_raw.order_event`
WHERE DATE(publish_time) >= CURRENT_DATE()
LIMIT 1000
```


## Destroy
Execute the command below on Cloud Shell to destroy the resources.
```
sh cloudbuild.sh destroy
```

This is not an official Google product.
