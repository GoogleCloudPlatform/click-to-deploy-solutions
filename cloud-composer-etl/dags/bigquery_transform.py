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
This example shows how to denormalize your data with a BigQuery job.
"""
import os
from datetime import datetime
from airflow import models
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator


PROJECT_ID = os.environ.get("GCP_PROJECT")

with models.DAG(
    dag_id='bigquery_transform',
    schedule_interval="@once",
    start_date=datetime(2022, 1, 1),
    catchup=False,
    tags=["example", "bigquery"],
) as dag:

    BIKE_TRIPS = (
    '''SELECT
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
    '''.format(PROJECT_ID)
    )

    create_bike_trips_table = BigQueryInsertJobOperator(
        task_id="create_bike_trips_table",
        configuration={
            "query": {
                "query": BIKE_TRIPS,
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
