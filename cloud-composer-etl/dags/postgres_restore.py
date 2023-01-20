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
This DAG restores the sql backup to populate the sample database.
"""
import os
from datetime import datetime
from airflow import models
from airflow.providers.google.cloud.operators.cloud_sql import CloudSQLImportInstanceOperator


GCS_SQL_BACKUP_BUCKET=os.environ.get("GCS_SQL_BACKUP_BUCKET")
FILE_NAME="gs://{}/citibike.sql".format(GCS_SQL_BACKUP_BUCKET)
INSTANCE_NAME=os.environ.get("SQL_INSTANCE_NAME")


with models.DAG(
    dag_id='postgres_restore',
    start_date=datetime(2022, 1, 1),
    schedule_interval="@once",
    catchup=False,
    tags=['example'],
) as dag:

    import_body = {"importContext": {"fileType": "sql", "uri": FILE_NAME, "database":"citibike"}}

    sql_import_task = CloudSQLImportInstanceOperator(
        body=import_body, 
        instance=INSTANCE_NAME,
        task_id='sql_import_task'
    )
