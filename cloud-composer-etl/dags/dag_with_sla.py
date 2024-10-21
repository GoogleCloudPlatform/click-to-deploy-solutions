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
# 
# For more information about SLAs, please check https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/tasks.html#slas

from datetime import datetime, timedelta
from airflow import models
from airflow.operators.bash_operator import BashOperator

def my_sla_miss_callback(dag, task_list, blocking_task_list, slas, blocking_tis):
    # add your code here, for example, it can send a notification to your team chat
    print(f"Dag {dag.dag_id} tasks {task_list} missed SLA")


with models.DAG(
    dag_id='dag_with_sla',
    description='This dag shows how to set up SLA for each task',
    schedule_interval="*/5 * * * *",
    start_date=datetime(2022, 1, 1),
    catchup=False,
    sla_miss_callback=my_sla_miss_callback,
    tags=["example", "has_sla"]
) as dag:

    task_1 = BashOperator(
        task_id='task_1',
        bash_command='sleep 5',
        dag=dag,
        sla=timedelta(seconds=10)) # from dag start time

    task_2 = BashOperator(
        task_id='task_2',
        bash_command='sleep 20',
        dag=dag,
        sla=timedelta(seconds=20)) # from dag start time

task_1 >> task_2
