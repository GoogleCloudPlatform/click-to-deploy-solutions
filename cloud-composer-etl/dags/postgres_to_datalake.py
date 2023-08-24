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
This dag exports tables from a Postgres instance to Google Cloud Storage
"""
import os
from datetime import datetime
import string

from airflow import models
from airflow.providers.google.cloud.transfers.postgres_to_gcs import PostgresToGCSOperator
from airflow.operators.dummy import DummyOperator


CONN_ID = "pgCitibike"
GCS_DATA_LAKE_BUCKET = os.environ.get("GCS_DATA_LAKE_BUCKET")


with models.DAG(
    dag_id='postgres_to_datalake',
    start_date=datetime(2022, 1, 1),
    schedule_interval="0 1 * * *",
    catchup=False,
    tags=['cloudsql', 'postgres', 'gcs'],
) as dag:

    task_stations = PostgresToGCSOperator(
        task_id="extract_table_stations",
        postgres_conn_id=CONN_ID,
        sql="select * from stations;",
        bucket=GCS_DATA_LAKE_BUCKET,
        filename="citibike/stations/dt={{ ds }}/records.csv",
        export_format='csv',
        gzip=False,
        use_server_side_cursor=True,
    )

    task_trips = PostgresToGCSOperator(
        task_id="extract_table_trips",
        postgres_conn_id=CONN_ID,
        sql="select * from trips;",
        bucket=GCS_DATA_LAKE_BUCKET,
        filename="citibike/trips/dt={{ ds }}/records.csv",
        export_format='csv',
        gzip=False,
        use_server_side_cursor=True,
    )

task_stations >> task_trips
