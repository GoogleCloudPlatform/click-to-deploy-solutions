# Prepare your Database for Disaster Recovery with Cloud SQL

## Let's get started!

This blueprint creates a [Cloud SQL instance](https://cloud.google.com/sql) with multi-region read replicas as described in the [Cloud SQL for PostgreSQL disaster recovery](https://cloud.google.com/architecture/cloud-sql-postgres-disaster-recovery-complete-failover-fallback) article.

The solution is resilient to a regional outage. 

To get familiar with the procedure needed in the unfortunate case of a disaster recovery, please follow steps described in [part two](https://cloud.google.com/architecture/cloud-sql-postgres-disaster-recovery-complete-failover-fallback#phase-2) of the aforementioned article.

This repo is based on the Cloud Foundation Fabric blueprint available [here](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/blueprints/data-solutions/cloudsql-multiregion).

**Time to complete**: About 16 minutes 30 sec.

Click the **Start** button to move to the next step
  
## Spinning up the architecture

1. Run the prerequisites script to enable APIs and set Cloud Build permissions.

```bash
sh prereq.sh
```

2. Run the Cloud Build Job

```bash
gcloud builds submit . --config ./build/cloudbuild.yaml
```

Next we are going to test the architecture and finally clean up your environment.

## Testing the architecture

1. Initiate a failover to test Cloud SQL instance high availability. During this process, the instance will temporarily be unavailable for a few minutes while it switches over.
```
gcloud sql instances failover INSTANCE_NAME
```
2. Verify that the Cloud SQL instance has high availability configuration.
```
gcloud sql instances describe INSTANCE_NAME
```
The output should indicate availability Type as REGIONAL. The GceZone and secondary GceZone fields should show the current primary and secondary zones of the instance


## Cleaning up your environment

The easiest way to remove all the deployed resources is to run the following command in Cloud Shell:

``` bash
gcloud builds submit . --config build/cloudbuild_destroy.yaml
```

The above command will delete the associated resources so there will be no billable charges made afterwards.

## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

You’re all set!
