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
from airflow.providers.google.cloud.operators.bigquery import BigQueryCreateEmptyDatasetOperator,BigQueryInsertJobOperator

CONN_ID = "pgCitibike"
DATASET_NAME = "citibike"
GCS_DATA_LAKE_BUCKET = os.environ.get("GCS_DATA_LAKE_BUCKET")
PROJECT_ID = os.environ.get("GCP_PROJECT")

with models.DAG(
    dag_id='from_data_lake_to_data_warehouse',
    description='Import data from the data lake to the data warehouse in BigQuery',
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

    create_bike_trips_table = BigQueryInsertJobOperator(
        task_id="create_bike_trips_table",
        configuration={
            "query": {
                "query": '''SELECT
                            bikeid,
                            COUNT(*) AS trip_count,
                            MAX(starttime) AS last_start,
                            MAX(stoptime) AS last_stop,
                            ARRAY_AGG( STRUCT( 
                                ss.name AS start_station_name,
                                t.starttime AS start_time,
                                es.name AS end_station_name,
                                t.stoptime AS end_time,
                                tripduration AS trip_duration) ) AS trips
                            FROM
                            `{0}.citibike.trips` t
                            JOIN
                            `{0}.citibike.stations` AS ss ON (t.start_station_id = ss.station_id)
                            JOIN
                            `{0}.citibike.stations` AS es ON (t.end_station_id = es.station_id)
                            GROUP BY
                            bikeid
                        '''.format(PROJECT_ID),
                "useLegacySql": False,
                "destinationTable": {
                    "projectId": PROJECT_ID,
                    "datasetId": "citibike",
                    "tableId": "bike_trips",
                },
                "createDisposition": "CREATE_IF_NEEDED",
                "writeDisposition": "WRITE_TRUNCATE",
            }
        },
    )

# task dependency
trigger_datalake_dag >> create_dataset
create_dataset >> load_stations
create_dataset >> load_trips

load_stations >> create_bike_trips_table
load_trips >> create_bike_trips_table
