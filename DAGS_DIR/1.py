from datetime import datetime

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator


def emit_healthcheck_message() -> None:
    print("Daily healthcheck DAG executed successfully.")


with DAG(
    dag_id="sample_daily_healthcheck_dag",
    description="Minimal daily DAG used for deployment validation.",
    start_date=datetime(2024, 1, 1),
    schedule="0 6 * * *",
    catchup=False,
    tags=["sample", "validation"],
) as dag:
    start = EmptyOperator(task_id="start")

    log_healthcheck = PythonOperator(
        task_id="log_healthcheck",
        python_callable=emit_healthcheck_message,
    )

    finish = EmptyOperator(task_id="finish")

    start >> log_healthcheck >> finish
 
