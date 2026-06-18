from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.exceptions import AirflowFailException
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from datetime import datetime, timedelta
import logging as logs
import json

# Default arguments for the DAG
default_args = {
    'owner': 'empower',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email': ['empower@lumiq.ai'],
    'email_on_failure': False,
    'email_on_retry': False
}

# Snowflake connection
SNOWFLAKE_CONN_ID = 'copy_cmd_snowflake'
WAREHOUSE = 'BAGIC_DPM_MAXI_RAW_WH'


def execute_update_meta_procedure(**context):
    # Get parameters from dag_run.conf (event trigger parameters)
    dag_run = context.get('dag_run')
    conf = dag_run.conf if dag_run and dag_run.conf else {}

    try:
        meta_table = conf.get('meta_table') or conf.get('META_TABLE')
        src_db = conf.get('src_db') or conf.get('SRC_DB')
        src_schema = conf.get('src_schema') or conf.get('SRC_SCHEMA')
        src_table = conf.get('src_table') or conf.get('SRC_TABLE')
        path_type_map = conf.get('path_type_map') or conf.get('PATH_TYPE_MAP')
        col_type_map = conf.get('col_type_map') or conf.get('COL_TYPE_MAP')
        
        # Validate required parameters
        required_params = {
            'meta_table': meta_table,
            'src_db': src_db,
            'src_schema': src_schema,
            'src_table': src_table,
            'path_type_map': path_type_map,
            'col_type_map': col_type_map
        }
        
        missing_params = [k for k, v in required_params.items() if not v]
        if missing_params:
            raise ValueError(f"Missing required parameters: {', '.join(missing_params)}")
        
        # Convert dict/string to JSON string if needed
        if isinstance(path_type_map, dict):
            path_type_map_json = json.dumps(path_type_map)
        else:
            path_type_map_json = path_type_map
            
        if isinstance(col_type_map, dict):
            col_type_map_json = json.dumps(col_type_map)
        else:
            col_type_map_json = col_type_map
            
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
    UPDATE META AND CHANGE COLUMN TYPE - EXECUTION DETAILS
    ================================================================================
    Job ID              : {job_id}
    Start Time          : {start_time}
    DAG Run ID          : {dag_run.run_id if dag_run else 'N/A'}
    
    TABLE CONFIGURATION:
    --------------------
    Meta Table          : {meta_table}
    Source Database     : {src_db}
    Source Schema       : {src_schema}
    Source Table        : {src_table}
    
    TYPE MAPPING:
    -------------
    Path Type Map       : {path_type_map_json}
    Column Type Map     : {col_type_map_json}
    
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
        f"'METADATA_UPDATE,TYPE_CHANGE,{src_db}.{src_schema}.{src_table},"
        f"JOB_ID:{job_id}';"
    )
    
    # Build the procedure call
    update_meta_query = f"""
    CALL BAGIC_PREPROD_CURATED_DB.UTILS.UPDATE_META_AND_CHANGE_COLUMN_TYPE(
        META_TABLE => '{meta_table}',
        SRC_DB => '{src_db}',
        SRC_SCHEMA => '{src_schema}',
        SRC_TABLE => '{src_table}',
        PATH_TYPE_MAP => PARSE_JSON('{path_type_map_json}'),
        COL_TYPE_MAP => PARSE_JSON('{col_type_map_json}')
    );
    """
    
    conn = None
    cur = None
    status = 'FAILED'
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
        
        # Execute procedure
        logs.info("Executing UPDATE_META_AND_CHANGE_COLUMN_TYPE procedure...")
        logs.info(f"Query: {update_meta_query}")
        cur.execute(update_meta_query)
        result = cur.fetchall()
        logs.info(f"✓ Procedure executed successfully")
        
        # Parse result
        raw_result = result[0][0] if result and len(result) > 0 else None
        logs.info(f"Procedure output: {raw_result}")
        
        if raw_result and 'SUCCESS' in str(raw_result):
            status = 'SUCCESS'
            logs.info("✓ Metadata updated and table recreated successfully")
        else:
            status = 'FAILED'
            error_message = f"Unexpected result: {raw_result}"
            logs.warning(f"⚠️ {error_message}")

        # Push results to XCom for downstream tasks
        context['ti'].xcom_push(key='update_status', value=status)
        context['ti'].xcom_push(key='job_id', value=job_id)
        context['ti'].xcom_push(key='procedure_result', value=str(raw_result))
        
        end_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        logs.info(f"""
        ================================================================================
        JOB COMPLETED
        ================================================================================
        Job ID              : {job_id}
        Status              : {status}
        Start Time          : {start_time}
        End Time            : {end_time}
        Result              : {raw_result}
        ================================================================================
        """)
        
        # Raise exception if failed
        if status == 'FAILED':
            raise AirflowFailException(error_message)
            
    except Exception as e:
        error_msg = f"Error executing UPDATE_META_AND_CHANGE_COLUMN_TYPE for {src_db}.{src_schema}.{src_table}: {str(e)}"
        logs.error(error_msg, exc_info=True)
        
        # Push error to XCom
        context['ti'].xcom_push(key='update_status', value='FAILED')
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
        logs.info("Update metadata job process completed")


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
    
    # Validate JSON format for type maps
    try:
        path_type_map = conf.get('path_type_map') or conf.get('PATH_TYPE_MAP')
        col_type_map = conf.get('col_type_map') or conf.get('COL_TYPE_MAP')
        
        if isinstance(path_type_map, str):
            json.loads(path_type_map)
        if isinstance(col_type_map, str):
            json.loads(col_type_map)
            
        logs.info("✓ JSON type maps validated successfully")
    except json.JSONDecodeError as e:
        raise AirflowFailException(f"Invalid JSON in type maps: {e}")
    
    logs.info("✓ Parameter validation passed")


# Create the DAG
with DAG(
    dag_id='MAXI_RAW_UPDATE_META_CNG_COL_TYPE_DAG',
    default_args=default_args,
    description='Execute Snowflake procedure to update metadata and change column types',
    schedule_interval=None,  # Only triggered manually or via API
    catchup=False,
    tags=['snowflake', 'metadata', 'type_change', 'schema_evolution'],
    params={
        'meta_table': '',
        'src_db': '',
        'src_schema': '',
        'src_table': '',
        'path_type_map': '{}',
        'col_type_map': '{}'
    }
) as dag:
    
    # Task 1: Validate parameters
    validate_task = PythonOperator(
        task_id='validate_parameters',
        python_callable=validate_parameters,
        provide_context=True
    )
    
    # Task 2: Execute update meta procedure
    update_meta_task = PythonOperator(
        task_id='execute_update_meta_procedure',
        python_callable=execute_update_meta_procedure,
        provide_context=True
    )
    
    # Set task dependencies
    validate_task >> update_meta_task