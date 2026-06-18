from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.exceptions import AirflowFailException
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from datetime import datetime, timedelta
import logging as logs
import re
import json

# Default arguments for the DAG
default_args = {
    'owner': 'empower',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email': ['empower@lumiq.ai'],
    'email_on_failure': False,
    'email_on_retry': False
}
 

# Snowflake connection
SNOWFLAKE_CONN_ID = 'copy_cmd_snowflake'
WAREHOUSE = 'BAGIC_DPM_MAXI_RAW_WH'


def execute_mirror_procedure(**context):
    """
    Execute the Snowflake mirror procedure with parameters from DAG run configuration
    """
    # Get parameters from dag_run.conf (event trigger parameters)
    dag_run = context.get('dag_run')
    conf = dag_run.conf if dag_run and dag_run.conf else {}
    
    # Extract parameters with validation
    try:
        src_db = conf.get('src_db') or conf.get('SRC_DB')
        src_schema = conf.get('src_schema') or conf.get('SRC_SCHEMA')
        src_table = conf.get('src_table') or conf.get('SRC_TABLE')
        target_db = conf.get('target_db') or conf.get('TARGET_DB')
        target_schema = conf.get('target_schema') or conf.get('TARGET_SCHEMA')
        variant_column = conf.get('variant_column') or conf.get('VARIANT_COLUMN', 'DATA')
        variant_keys = conf.get('variant_keys') or conf.get('VARIANT_KEYS', '')
        relation_columns = conf.get('relation_columns') or conf.get('RELATION_COLUMNS', '')
        foreign_key_path = conf.get('foreign_key_path') or conf.get('FOREIGN_KEY_PATH', '')
        metadata_flag = conf.get('metadata_flag') or conf.get('METADATA_FLAG', True)
        sync_mode = conf.get('sync_mode') or conf.get('SYNC_MODE', 'FRO')
        
        # Validate required parameters
        required_params = {
            'src_db': src_db,
            'src_schema': src_schema,
            'src_table': src_table,
            'target_db': target_db,
            'target_schema': target_schema,
            'foreign_key_path': foreign_key_path,
            'metadata_flag' : metadata_flag,
            'sync_mode' : sync_mode,
            'variant_column' : variant_column,
            'relation_columns' : relation_columns
        }
        
        missing_params = [k for k, v in required_params.items() if not v]
        if missing_params:
            raise ValueError(f"Missing required parameters: {', '.join(missing_params)}")
            
    except Exception as e:
        error_msg = f"Error extracting parameters from DAG run configuration: {e}"
        logs.error(error_msg)
        raise AirflowFailException(error_msg)
    
    # Generate job metadata
    job_id = f"job_id_{datetime.now().strftime('%Y%m%d_%H%M%S%f')}"
    start_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    # Log job details
    logs.info(f"""
    ================================================================================
    SNOWFLAKE MIRROR JOB - EXECUTION DETAILS
    ================================================================================
    Job ID              : {job_id}
    Start Time          : {start_time}
    DAG Run ID          : {dag_run.run_id if dag_run else 'N/A'}
    
    SOURCE CONFIGURATION:
    ---------------------
    Source Database     : {src_db}
    Source Schema       : {src_schema}
    Source Table        : {src_table}
    
    TARGET CONFIGURATION:
    ---------------------
    Target Database     : {target_db}
    Target Schema       : {target_schema}
    
    PROCEDURE PARAMETERS:
    ---------------------
    Variant Column      : {variant_column}
    Variant Keys        : {variant_keys[:100]}{'...' if len(variant_keys) > 100 else ''}
    Relation Columns    : {relation_columns}
    Foreign Key Path    : {foreign_key_path}
    Metadata Flag       : {metadata_flag}
    Sync Mode           : {sync_mode}
    
    SNOWFLAKE CONFIG:
    -----------------
    Connection ID       : {SNOWFLAKE_CONN_ID}
    Warehouse           : {WAREHOUSE}
    ================================================================================
    """)
    
    # Initialize Snowflake hook
    snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)
    
    # Set query tag for tracking
    query_tag = (
        f"ALTER SESSION SET QUERY_TAG = "
        f"'INGESTION,MIRROR,SNOWFLAKE,{src_db}.{src_schema}.{src_table},"
        f"{sync_mode},JOB_ID:{job_id}';"
    )
    
    # Build the mirror procedure call
    mirror_query = f"""
    CALL BAGIC_PREPROD_CURATED_DB.UTILS.WRAPPER_PROC(
        SRC_DB => '{src_db}',
        SRC_SCHEMA => '{src_schema}',
        SRC_TABLE => '{src_table}',
        TARGET_DB => '{target_db}',
        TARGET_SCHEMA => '{target_schema}',
        VARIANT_COLUMN => '{variant_column}',
        VARIANT_KEYS => '{variant_keys}',
        RELATION_COLUMNS => '{relation_columns}',
        FOREIGN_KEY_PATH => '{foreign_key_path}',
        METADATA_FLAG => {metadata_flag},
        SYNC_MODE => '{sync_mode}'
    );
    """
    
    conn = None
    cur = None
    status = 'FAILED'
    drift_path = None
    error_message = None
    
    try:
        # Establish connection
        logs.info("Establishing Snowflake connection...")
        conn = snowflake_hook.get_conn()
        cur = conn.cursor()
        logs.info("✓ Connection established successfully")
        
        # Set warehouse
        logs.info(f"Setting warehouse to {WAREHOUSE}...")
        cur.execute(f"USE WAREHOUSE {WAREHOUSE};")
        logs.info("✓ Warehouse set successfully")
        
        # Set query tag
        logs.info("Setting query tag for tracking...")
        cur.execute(query_tag)
        logs.info("✓ Query tag set successfully")
        
        # Execute mirror procedure
        logs.info("Executing mirror procedure...")
        logs.info(f"Query: {mirror_query}")
        cur.execute(mirror_query)
        result = cur.fetchall()
        logs.info(f"✓ Mirror procedure executed successfully")
        
        # Parse result
        raw_result = result[0][0] if result and len(result) > 0 else None
        logs.info(f"Procedure output: {raw_result}")
        
        # Check for type drift
        if raw_result:
            match = re.search(r"Type drift detected: path '([^']+)'", str(raw_result))
            if match:
                drift_path = match.group(1)
                error_message = f"Type drift detected at path: {drift_path}"
                logs.warning(f"⚠️ {error_message}")
                status = 'FAILED_TYPE_DRIFT'
            else:
                status = 'SUCCESS'
                logs.info("✓ Mirror procedure completed successfully")

        # Push results to XCom for downstream tasks
        context['ti'].xcom_push(key='mirror_status', value=status)
        context['ti'].xcom_push(key='job_id', value=job_id)
        context['ti'].xcom_push(key='drift_path', value=drift_path)
        
        end_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        logs.info(f"""
        ================================================================================
        JOB COMPLETED
        ================================================================================
        Job ID              : {job_id}
        Status              : {status}
        Start Time          : {start_time}
        End Time            : {end_time}
        Drift Path          : {drift_path if drift_path else 'None'}
        ================================================================================
        """)
        
        # Raise exception if type drift detected
        if status == 'FAILED_TYPE_DRIFT':
            raise AirflowFailException(error_message)
            
    except Exception as e:
        error_msg = f"Error executing mirror procedure for {src_db}.{src_schema}.{src_table}: {str(e)}"
        logs.error(error_msg, exc_info=True)
        
        # Push error to XCom
        context['ti'].xcom_push(key='mirror_status', value='FAILED')
        context['ti'].xcom_push(key='error_message', value=error_msg)
        
        raise AirflowFailException(error_msg)
        
    finally:
        # Clean up resources
        if cur:
            logs.info("Closing cursor...")
            cur.close()
        if conn:
            logs.info("Closing Snowflake connection...")
            conn.close()
        logs.info("Mirror job process completed")


def validate_parameters(**context):
    """
    Validate input parameters before execution
    """
    dag_run = context.get('dag_run')
    conf = dag_run.conf if dag_run and dag_run.conf else {}
    
    logs.info(f"Received configuration: {json.dumps(conf, indent=2)}")
    
    if not conf:
        raise AirflowFailException(
            "No configuration provided. Please trigger the DAG with required parameters."
        )
    
    logs.info("✓ Parameter validation passed")


# Create the DAG
with DAG(
    dag_id='MAXI_RAW_WRAPPER_PROC_DAG',
    default_args=default_args,
    description='Execute Snowflake mirror procedure with event-triggered parameters',
    schedule_interval=None,  # Only triggered manually or via API
    catchup=False,
    tags=['snowflake', 'mirror', 'ingestion', 'maxi_raw'],
    params={
        'src_db': '',
        'src_schema': '',
        'src_table': '',
        'target_db': '',
        'target_schema': '',
        'variant_column': '',
        'variant_keys': '',
        'relation_columns': '',
        'foreign_key_path': '',
        'metadata_flag': '',
        'sync_mode': ''
    }
) as dag:
    
    # Task 1: Validate parameters
    validate_task = PythonOperator(
        task_id='validate_parameters',
        python_callable=validate_parameters,
        provide_context=True
    )
    
    # Task 2: Execute mirror procedure
    mirror_task = PythonOperator(
        task_id='execute_mirror_procedure',
        python_callable=execute_mirror_procedure,
        provide_context=True
    )
    
    # Set task dependencies
    validate_task >> mirror_task