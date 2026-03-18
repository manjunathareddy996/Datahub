from datetime import datetime

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator


def prepare_metrics_payload() -> None:
    metrics = {
        "pipeline": "sample_weekly_metrics_dag",
        "status": "ready",
        "generated_at": datetime.utcnow().isoformat(),
    }
    print(f"Prepared metrics payload: {metrics}")


with DAG(
    dag_id="sample_weekly_metrics_dag",
    description="Weekly sample DAG for Airflow S3 deployment testing.",
    start_date=datetime(2024, 1, 1),
    schedule="0 9 * * 1",
    catchup=False,
    tags=["sample", "metrics"],
) as dag:
    start = EmptyOperator(task_id="start")

    prepare_metrics = PythonOperator(
        task_id="prepare_metrics",
        python_callable=prepare_metrics_payload,
    )

    finish = EmptyOperator(task_id="finish")

    start >> prepare_metrics >> finish
 
