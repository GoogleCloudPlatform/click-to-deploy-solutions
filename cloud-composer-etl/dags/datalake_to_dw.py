# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
This example shows how to trigger a Datalake dag, and then load the data into BigQuery.
"""
import os
from datetime import datetime
from airflow import models
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryCreateEmptyDatasetOperator


CONN_ID = "pgCitibike"
DATASET_NAME = "citibike"
GCS_DATA_LAKE_BUCKET = os.environ.get("GCS_DATA_LAKE_BUCKET")


with models.DAG(
    dag_id='datalake_to_dw',
    schedule_interval="@once",
    start_date=datetime(2022, 1, 1),
    catchup=False,
    tags=["example", "bigquery"],
) as dag:

    trigger_datalake_dag = TriggerDagRunOperator(
        task_id="trigger_datalake_dag",
        trigger_dag_id="postgres_to_datalake",
        wait_for_completion=True,
        poke_interval=10,  # seconds
        execution_date="{{ execution_date }}"
    )

    create_dataset = BigQueryCreateEmptyDatasetOperator(
        task_id="create_dataset",
        dataset_id=DATASET_NAME,
        location="US"
    )

    load_stations = GCSToBigQueryOperator(
        task_id='bq_load_stations',
        bucket=GCS_DATA_LAKE_BUCKET,
        source_objects=["citibike/stations/dt={{ ds }}/records.csv"],
        skip_leading_rows=1,
        destination_project_dataset_table="{}.{}".format(
            DATASET_NAME, "stations"),
        autodetect=True,
        write_disposition='WRITE_TRUNCATE',
    )

    load_trips = GCSToBigQueryOperator(
        task_id='bq_load_trips',
        bucket=GCS_DATA_LAKE_BUCKET,
        source_objects=["citibike/trips/dt={{ ds }}/records.csv"],
        skip_leading_rows=1,
        destination_project_dataset_table="{}.{}".format(
            DATASET_NAME, "trips"),
        autodetect=True,
        write_disposition='WRITE_TRUNCATE',
    )

trigger_datalake_dag >> create_dataset
create_dataset >> load_stations
create_dataset >> load_trips
