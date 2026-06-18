from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.exceptions import AirflowFailException
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from datetime import datetime, timedelta
import logging as logs

# Default arguments for the DAG
default_args = {
    'owner': 'empower',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email': ['empower@lumiq.ai'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

# Snowflake connection
SNOWFLAKE_CONN_ID = 'copy_cmd_snowflake'
WAREHOUSE = 'BAGIC_DPM_MAXI_RAW_WH'


def execute_APPLY_DRIFT_CORRECTIONS_procedure(**context):
    """
    Execute the APPLY_DRIFT_CORRECTIONS stored procedure to fix schema drift issues.
    """
    # Generate job metadata
    job_id = f"job_id_{datetime.now().strftime('%Y%m%d_%H%M%S%f')}"
    start_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    logs.info(f"Starting drift correction job: {job_id}")
    logs.info(f"Start time: {start_time}")
    
    # Initialize Snowflake hook
    snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)
    
    conn = None
    cur = None
    error_message = None
    procedure_result = None
    
    try:
        logs.info("Establishing Snowflake connection...")
        conn = snowflake_hook.get_conn()
        cur = conn.cursor()

        logs.info(f"Setting warehouse to {WAREHOUSE}...")
        cur.execute(f"USE WAREHOUSE {WAREHOUSE};")

        # Set query tag for tracking (fixed - removed extra quote)
        query_tag = f"JOB_ID:{job_id}"
        logs.info(f"Setting query tag: {query_tag}")
        cur.execute(f"ALTER SESSION SET QUERY_TAG = '{query_tag}';")

        # Execute the procedure with fully qualified name
        logs.info("Executing APPLY_DRIFT_CORRECTIONS procedure...")
        procedure_call = "CALL BAGIC_PREPROD_CURATED_DB.UTILS.APPLY_DRIFT_CORRECTIONS();"
        cur.execute(procedure_call)
        
        # Fetch the result
        result = cur.fetchone()
        if result:
            procedure_result = result[0]
            logs.info("="*80)
            logs.info("PROCEDURE EXECUTION RESULT:")
            logs.info("="*80)
            logs.info(f"\n{procedure_result}\n")
            logs.info("="*80)
        else:
            logs.warning("No result returned from procedure")
            procedure_result = "No result returned"

        # Push results to XCom for downstream tasks
        context['ti'].xcom_push(key='job_id', value=job_id)
        context['ti'].xcom_push(key='start_time', value=start_time)
        context['ti'].xcom_push(key='procedure_result', value=procedure_result)
        context['ti'].xcom_push(key='status', value='SUCCESS')

        logs.info(f"✓ Drift correction job {job_id} completed successfully")
        
        return {
            'job_id': job_id,
            'status': 'SUCCESS',
            'result': procedure_result
        }

    except Exception as e:
        error_message = str(e)
        logs.error("="*80)
        logs.error("ERROR DURING PROCEDURE EXECUTION:")
        logs.error("="*80)
        logs.error(f"Error: {error_message}")
        logs.error("="*80)
        
        # Push error info to XCom
        context['ti'].xcom_push(key='job_id', value=job_id)
        context['ti'].xcom_push(key='start_time', value=start_time)
        context['ti'].xcom_push(key='error_message', value=error_message)
        context['ti'].xcom_push(key='status', value='FAILED')
        
        # Re-raise the exception to mark the task as failed
        raise AirflowFailException(f"Drift correction procedure failed: {error_message}")
        
    finally:
        # Ensure resources are cleaned up
        if cur:
            try:
                cur.close()
                logs.info("Cursor closed successfully")
            except Exception as e:
                logs.warning(f"Error closing cursor: {e}")
                
        if conn:
            try:
                conn.close()
                logs.info("Connection closed successfully")
            except Exception as e:
                logs.warning(f"Error closing connection: {e}")


# Create the DAG
with DAG(
    dag_id='MAXI_RAW_APPLY_DRIFT_CORRECTIONS_DAG',
    default_args=default_args,
    description='Execute Snowflake procedure to apply pending schema drift corrections',
    schedule_interval=None,  # Manual trigger only
    catchup=False,
    tags=['snowflake', 'metadata', 'schema_drift', 'drift_correction'],
    max_active_runs=1,  # Prevent concurrent runs
    doc_md="""
    ### MAXI RAW - Apply Drift Corrections DAG
    
    This DAG executes the APPLY_DRIFT_CORRECTIONS stored procedure which:
    1. Reads pending drift corrections from SCHEMA_DRIFT_CORRECTIONS table
    2. Updates metadata tables with new data types
    3. Recreates mirror tables with corrected column types
    4. Updates correction status (SUCCESS/ERROR)
    
    **Important Notes:**
    - This DAG should be run manually after drift corrections are reviewed
    - Creates backup clones before modifying tables
    - Tables are disabled during processing - remember to re-enable schedules after
    - Check procedure output in logs for details on processed tables
    
    **Prerequisites:**
    - Pending corrections exist in BAGIC_PREPROD_CURATED_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS
    - User has permissions to modify target tables and metadata
    """
) as dag:

    # Task to execute drift correction procedure
    apply_drift_corrections = PythonOperator(
        task_id='apply_drift_corrections',
        python_callable=execute_APPLY_DRIFT_CORRECTIONS_procedure,
        provide_context=True,
        execution_timeout=timedelta(hours=2),  # Safety timeout
        doc_md="""
        Executes the APPLY_DRIFT_CORRECTIONS stored procedure.
        
        The procedure will:
        - Process all PENDING drift corrections grouped by table
        - Create backup clones with timestamp
        - Update metadata and recreate tables with correct types
        - Log results for each table processed
        """
    )
    
    # Task dependencies (single task, no dependencies needed)
    apply_drift_corrections