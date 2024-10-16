# Copyright 2024 Google LLC
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

from datetime import datetime, timedelta
from airflow import models
from airflow.operators.bash_operator import BashOperator

with models.DAG(
    dag_id='dag_with_sla',
    description='This dag shows how to set up SLA for each task',
    schedule_interval="*/5 * * * *",
    start_date=datetime(2022, 1, 1),
    catchup=False,
    tags=["example", "has_sla"],
) as dag:

    task1 = BashOperator(
        task_id='task1',
        bash_command='sleep 15',
        dag=dag,
        sla=timedelta(seconds=10))

    task2 = BashOperator(
        task_id='task2',
        bash_command='sleep 5',
        dag=dag,
        sla=timedelta(seconds=10))
