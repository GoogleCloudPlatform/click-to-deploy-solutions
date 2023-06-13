[![banner](../banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Unifying Cloud Data Fusion and Private Cloud SQL for a Robust Data Pipeline

## Introduction
This example deploys Cloud Data Fusion and Cloud SQL private instances, and establishes communication between them.

In today's data-driven world, businesses are challenged with efficiently ingesting, transforming, and analyzing large volumes of data from various sources. By combining the capabilities of Data Fusion and a Cloud SQL Private Instance, businesses can achieve their data processing and storage objectives while maintaining a high level of security and compliance.

Data Fusion offers a visual interface and a wide range of connectors and transformations, simplifying the data integration process. With Data Fusion, businesses can efficiently ingest and process data in real-time, ensuring up-to-date insights for their analytical workflows.

Cloud SQL Private Instance provides a dedicated, isolated environment for their database, protected by Google Cloud's robust security measures. It allows for fine-grained access control, encryption at rest, and network isolation, providing an added layer of protection for sensitive data.

In short, Data Fusion and Cloud SQL Private Instance can help businesses to:

* Efficiently ingest, transform, and analyze large volumes of data from various sources.
* Achieve their data processing and storage objectives.
* Maintain a high level of security and compliance.
* Provide a dedicated, isolated environment for their database.
* Protect their data with robust security measures.


:clock1: Estimated deployment time: 18 min 49 sec


## Architecture
![architecture](architecture.png)

## Deploy

1. Click on Open in Google Cloud Shell button below.
<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy-solutions&cloudshell_workspace=private-cloud-data-fusion" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the `cloudbuild.sh` script and follow the instructions
```
sh cloudbuild.sh
```

After you created the resources, you can use the Cloud SQL Proxy VM's internal IP to connect from Cloud Data Fusion to Cloud SQL. Before you can connect to the MySQL instance from the Cloud Data Fusion instance, install the MySQL JDBC driver from the Cloud Data Fusion Hub.

For more information on how to setup this connection, please refer to [this link](https://cloud.google.com/data-fusion/docs/how-to/connect-to-cloud-sql-source).

## Destroy
Execute the command below on Cloud Shell to destroy the resources.
```
sh cloudbuild.sh destroy
```

## Useful links
- [Cloud Data Fusion How-to guides](https://cloud.google.com/data-fusion/docs/how-to)
- [Cloud SQL](https://cloud.google.com/sql)
