import datetime
import time
from airflow import DAG
from airflow.operators.python_operator import PythonOperator, BranchPythonOperator
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.models import Variable
from datetime import datetime, timedelta
from airflow.models import TaskInstance
import json
import requests
from airflow.operators.python import ShortCircuitOperator
from airflow.exceptions import AirflowFailException
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
import uuid
from airflow.models import Variable
import logging as logs
import re
from utils.dms_snowflake_pipeline_utils import DMSPipelineUtils as du
from airflow.operators.dummy_operator import DummyOperator
import boto3
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import json
import smtplib
# from airflow.utils.email import send_email_smtp
 
# Constants
DAG_ID = f'MAXI_RAW_S3_TO_SF_INU'
SNOWFLAKE_CONN_ID = 'copy_cmd_snowflake'
SNOWFLAKE_S3_INTEGRATION = 'BAGIC_S3_DATAHUB_INIEGRATION'
DEFAULT_ARGS = {
    'owner': 'empower',
    'depends_on_past': False,
    'email': ['empower@lumiq.ai'],
    'email_on_failure': False,
    'email_on_retry': False
}
 
# BufferBatchSize = 
BatchSize = {
    "INU":900
}
# TableSuffix = {
#     "INU": '_INU'
# }
Stage_Suffix = "_STAGE"
 
# Initialize Snowflake Hook
snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)
try:
    conn = snowflake_hook.get_conn()
    cur = conn.cursor()
    cur.execute("USE WAREHOUSE BAGIC_DPM_MAXI_RAW_WH;") 
    conn.close()
except Exception as e:
    logs.error(f"Error setting warehouse: {e}")

def load_config_from_s3():
    s3 = boto3.client("s3", region_name="ap-south-1")
    bucket = "empower-bagic-s3-mount"
    key = "utils/MAXIMUS_RAW_MASTER/MAXIMUS_RAW_MASTER.json"
    obj = s3.get_object(Bucket=bucket, Key=key)
    return json.loads(obj["Body"].read().decode("utf-8"))

def get_checkpoint(table_name, Job_Id):
    # Get last successful batch from checkpoint table
    query = f"""
        SELECT batch_number
        FROM EMPOWER_DB.UTILS.CHECKPOINT_TABLE
        WHERE table_name = '{table_name}' and JOB_ID = '{Job_Id}'
        ORDER BY batch_number DESC
        LIMIT 1
    """
    result = snowflake_hook.get_first(query)
    return result[0] if result else None
 
def getDMSS3Files(Bucket, Path, LastRun, CurrentRun, BatchSize, FileFormat='parquet', Mode='INU', BufferTimeInDays=1):
    """
    Get Dict of S3 files added or modified by DMS after last run. Only applicable for incremental mode
    :param Bucket: Name of the source Bucket.
    :param Path: Path Key.
    :param LastRun -  Date time Local of Last job time run.
    :param CurrentRun - Local Current Date time.
    :param FileFormat - File Format, Default is parquet.
 
    :return Dict of s3 Paths
    """
    try:
        logs.info(f'::The input Path is {Path}')
        Path_Prefix = "s3://" + Bucket + "/"
        logs.info(f'::The s3 Path prefix is {Path_Prefix}')
        Key = Path.replace(Path_Prefix, "")
        path_dict = {}
        date_format = '%Y-%m-%d %H:%M:%S'
 
        last_utc_dt_str = str(LastRun)
        current_utc_dt_str = str(CurrentRun)
        if ((last_utc_dt_str is None) or (str(last_utc_dt_str).upper() == 'NONE')):
            last_utc_dt_str = '2024-01-01 00:00:00'
        last_utc_dt = datetime.strptime(str(last_utc_dt_str), date_format)
        current_utc_dt = datetime.strptime(str(current_utc_dt_str), date_format)
        logs.info(f'Last Run in UTC {last_utc_dt} and Current Run in UTC {current_utc_dt}')
        logs.info(f'Checking Path for Key {Key}')
 
        # Validate Mode
        if Mode.upper() not in BatchSize:
            error_message = f"Invalid Mode: {Mode}. Supported modes are: {list(BatchSize.keys())}"
            logs.error(error_message)
            return f'Failed - {error_message}', {}, {}
 
        if du.s3_File_Exists(Bucket, Key):
            logs.info(f'Path Key {Key} Exists.')
            logs.info(f'The Mode is {Mode}......')
            Prefix = Key + str('/') if not str(Key).endswith('/') else str(Key)
            start_dt = last_utc_dt.strftime("%Y/%m/%d/%H")
            end_dt = current_utc_dt.strftime("%Y/%m/%d/%H")
            lst = du.date_diff(start_dt, end_dt, "%Y/%m/%d/%H", buffer={"days": BufferTimeInDays})
            print(lst)
            s3_obj_dict = {}
            #testing
            # last_utc_dt = datetime.strptime('2025-12-11 08:43:38', date_format)
            for x in lst:
                prefix = Prefix + x
                prefix = prefix + str('/') if not str(prefix).endswith('/') else str(prefix)
                if(not du.s3_File_Exists(Bucket,prefix)):
                    print("invalid path: ", prefix)
                print(last_utc_dt)
                print(current_utc_dt)
                print(prefix)
                temp_dict = du.s3_list_objects_paginator(
                    Bucket=Bucket, 
                    Path=prefix,
                    LastUtcTime=last_utc_dt, 
                    CurrentUtcTime=current_utc_dt
                )
                s3_obj_dict.update(temp_dict)
            
            print(s3_obj_dict)
            # s3_obj_dict = du.s3_list_objects_paginator(Bucket=Bucket, Path=Prefix, LastUtcTime=last_utc_dt, CurrentUtcTime=current_utc_dt)
            # print(s3_obj_dict)
            objDict = {x: y for x, y in s3_obj_dict.items() if x is not None and str(Prefix) != str(x) and str(x).endswith(str(FileFormat).lower())}
            path_dict = {**path_dict, **objDict}
            logs.info(f'''Path extracted are {str(path_dict)}''')              
 
            
            path_dict = {du.removeDoubleSlash(str(x).replace(Key, '')): y for x, y in path_dict.items() if x is not None}
            logs.info(f'Final Source S3 Unsorted Paths are {path_dict}')
            sorted_path_dict = dict(sorted(path_dict.items()))
            logs.info(f'Final Source S3 Sorted Paths are {sorted_path_dict}')
 
            batch_dict = {}
            batch_modified_time = {}
 
            objCount = len(sorted_path_dict)
 
            print("first object count:", objCount)
            if objCount > 0:
                batch_count = round(objCount / BatchSize[Mode.upper()])
                logs.info(f"Total no .of files: {objCount}")
                allRunningObj = list(sorted_path_dict.keys())
                for x in range(batch_count + 1):
                    if len(allRunningObj) > 0:
                        batch_dict[f'Batch_{x + 1}'] = allRunningObj[0:BatchSize[Mode.upper()]]
                        size = len(allRunningObj)
                        allRunningObj = allRunningObj[BatchSize[Mode.upper()]:size]
                        batch_modified_time[f'Batch_{x + 1}'] = str(sorted_path_dict[batch_dict[f'Batch_{x + 1}'][-1]])
                    else:
                        break
                logs.info(f"::::Batch Splits are {batch_dict}")
                logs.info(f"::::Batch max last modified times are {batch_modified_time}")
                return 'Success', batch_dict, batch_modified_time
            else:
                return 'Success', {}, {}
 
            return 'Success', batch_dict, batch_modified_time
    except Exception as e:
        logs.error(e)
        return 'Failed - ' + str(e), {}, {}
  
  
def snowflake_staging_job(**kwargs):
    table_info = kwargs['table_info_dict']
    ti = kwargs['ti']
    Table = table_info['staging_table']
    Job_Id = ti.xcom_pull(task_ids=f"start_ingestion_task_{Table}", key='job_id')
    run_id = ti.xcom_pull(task_ids=f"start_ingestion_task_{Table}", key='run_id')
    pipeline_run_id = f"{DAG_ID}_{run_id}"
    Mode = str(table_info['sync_type']).upper()
    Pipeline = table_info['pipeline_name']
    FileFormat = str(table_info['file_format']).upper()
    stg_db = table_info['staging_db']
    stg_schema = table_info['staging_schema']
    stg_table = f'{Table}'
    stage_name = f'{Table}{Stage_Suffix}'
    src_path = table_info['s3_path']
    start_time = ti.xcom_pull(key=str(f"start_time_{Table}_{Mode}").upper())
    processed_batch_no = 0
    load_history_count = 0
    # input_files = []
    load_files = []
 
    print(f"""
    STAGING Job Details:
    ------------
    Job ID          : {Job_Id}
    Pipeline Run ID : {pipeline_run_id}
    Table           : {Table}
    Mode            : {Mode}
    Pipeline        : {Pipeline}
    File Format     : {FileFormat}
    Stage DB        : {stg_db}
    Stage Schema    : {stg_schema}
    Stage Table     : {stg_table}
    Stage Name      : {stage_name}
    Source Path     : {src_path}
    Start Time      : {start_time}
    """)
 
 
    query_tag = f"ALTER SESSION SET QUERY_TAG = 'INGESTION,STAGING_JOB,{stg_db}.{stg_schema}.{Table},{Pipeline}'; "
 
    # Create stage #removed table mode
    stage_qry = f'''
        CREATE STAGE IF NOT EXISTS {stg_db}.{stg_schema}.{Table}{Stage_Suffix}
        STORAGE_INTEGRATION = {SNOWFLAKE_S3_INTEGRATION}
        FILE_FORMAT = ( TYPE = {FileFormat} )
        URL = '{src_path}';
    '''
    logs.info(f"CREATE STAGE USING Query: {stage_qry}")
    try:
        result = snowflake_hook.run(sql=query_tag + stage_qry)
        logs.info(f"::: Output of CREATE STAGE query: {result}")
    except Exception as e:
        logs.error(f"::: Error running CREATE STAGE query: ")
        logs.error(e)
        raise AirflowFailException(e)
 
    # Pull file batch info from XCom        
    batchDict = ti.xcom_pull(key=f'{Table.title()}_{Mode}_List_of_objects')
    modifiedTs = ti.xcom_pull(key=f'{Table.title()}_{Mode}_Max_Modified_Time')
    objCount = ti.xcom_pull(key=f'{Table.title()}_{Mode}_object_count')

    # input_files = [file for files in batchDict.values() for file in files]
    # print(input_files)
    # SplitMode = True
    # # file_list = [str(x.split('/')[-1].split('.')[0]).upper() for x in batchDict.keys()]
    # # logs.info(f"File list: {file_list}")
 
    # if (objCount <= BatchSize[Mode] + BufferBatchSize) and Mode == 'FRO' and f'LOAD00001.{FileFormat.lower()}' in input_files:
    #     SplitMode = False
 
    # logs.info(f"Split Mode: {SplitMode}")
    totalbatch = len(batchDict)
    logs.info(f"::: Total batches: {totalbatch}")
 
    # foreign_key_str = table_info['foreign_key']
    # foreign_key = ','.join([f"'{str(pk).strip()}'" for pk in foreign_key_str.split(',')])
 
    # print("foreign_key: ",foreign_key)
    # variant_keys = table_info['variant_key']
 
 
    # print("Split Mode: ",SplitMode)
 
    # print(batchDict.keys()) 
        
    # Get the last successful batch
    last_successful_batch = get_checkpoint(Table, Job_Id)
    logs.info(f"Last successful batch for table {Table}: {last_successful_batch}")

    # Sort batchDict keys to ensure correct order
    sorted_batches = sorted(batchDict.keys(), key=lambda x: int(x.split('_')[1]))

    for x in sorted_batches:
        # Skip batches already processed
        if last_successful_batch:
            last_batch_num = int(last_successful_batch.split('_')[1])
            current_batch_num = int(x.split('_')[1])
            if current_batch_num <= last_batch_num:
                logs.info(f"::: Skipping already processed batch: {x}")
                continue

        batch_number = x
        batch_files = batchDict[x]
        # Set warehouse
        try:
            conn = snowflake_hook.get_conn()
            cur = conn.cursor()
            cur.execute("USE WAREHOUSE BAGIC_DPM_MAXI_RAW_WH;")
            cur.close()
            conn.close()
        except Exception as e:
            logs.error(f"::: Error setting warehouse: {e}")

        # Copy query
        copy_qry = f"""CALL EMPOWER_DB.UTILS.SNOWFLAKE_COPY_INA_STAGING_JOB_MAXI_RAW(
                    DB => '{stg_db}',
                    SCHEMANAME => '{stg_schema}',
                    TABLENAME => '{stg_table}',
                    STAGE_NAME => '{stage_name}',
                    FILE_FORMAT => 'PROD_EXTERNAL_DB.PROD.JSON_FORMAT',
                    INC_JOB_ID => '{Job_Id}',
                    FILE_LIST => {batch_files});"""
        
        logs.info(f"::: Running staging query for batch {x}: {copy_qry}")

        try:
            result = snowflake_hook.run(sql=query_tag + copy_qry)
            processed_batch_no += 1
            load_history_count += len(batch_files)
            load_files.append(batch_files)
            
            logs.info(f"[snowflake_staging_job] SUCCESS: Batch {x} completed")
            logs.info(f"[snowflake_staging_job]   Files loaded in this batch: {len(batch_files)}")
            logs.info(f"[snowflake_staging_job]   Total batches processed: {processed_batch_no}/{totalbatch}")
            logs.info(f"[snowflake_staging_job]   Total files loaded so far: {load_history_count}/{objCount}")
            logs.info(f"[snowflake_staging_job]   ::: Progress: {(processed_batch_no/totalbatch)*100:.1f}%")
            
        except Exception as e:
            # CHANGE 23: Enhanced error logging
            logs.error("="*80)
            logs.error(f"[snowflake_staging_job] BATCH PROCESSING FAILED")
            logs.error(f"[snowflake_staging_job]   Table: {Table}")
            logs.error(f"[snowflake_staging_job]   Batch: {x} (Batch {batch_number} of {totalbatch})")
            logs.error(f"[snowflake_staging_job]   Files in batch: {len(batch_files)}")
            logs.error(f"[snowflake_staging_job]   ::: Error: {e}")
            logs.error("="*80)
            raise AirflowFailException(f"Staging job failed at batch {x}: {e}")


        watermark_value = modifiedTs.get(x) or '2025-01-01 00:00:00'
        logs.info(f'::: Commit Batch {x} Max Modified Timestamp: {watermark_value}')

        # ---- Update CHECKPOINT_TABLE after successful batch ----
        upsert_query =f"""
            MERGE INTO EMPOWER_DB.UTILS.CHECKPOINT_TABLE AS target
            USING (
                SELECT 
                    '{Job_Id}' AS job_id,
                    '{pipeline_run_id}' AS pipeline_run_id,
                    '{Table}' AS table_name,
                    '{batch_number}' AS batch_number
            ) AS source
            ON target.table_name = source.table_name
            WHEN MATCHED THEN
                UPDATE SET 
                    job_id = source.job_id,
                    pipeline_run_id = source.pipeline_run_id,
                    batch_number = source.batch_number
            WHEN NOT MATCHED THEN
                INSERT (job_id, pipeline_run_id, table_name, batch_number)
                VALUES (source.job_id, source.pipeline_run_id, source.table_name, source.batch_number);
            """

        try:
            snowflake_hook.run(sql=upsert_query)
            logs.info(f"::: Checkpoint updated successfully: {batch_number}")
        except Exception as e:
            logs.error(f"Error updating CHECKPOINT_TABLE for batch {batch_number}: {e}")
            raise

    # final summary
    log_str = "===== STAGING JOB COMPLETED SUCCESSFULLY ====="
    logs.info(log_str)
    logs.info("[snowflake_staging_job] FINAL STATISTICS:")
    logs.info(f"::: Table: {Table}")
    logs.info(f"::: Total batches processed: {processed_batch_no}/{totalbatch}")
    logs.info(f"::: Total files loaded: {load_history_count}/{objCount}")
    logs.info(f"::: Success rate: {(processed_batch_no/totalbatch)*100:.1f}%")
    logs.info("="*len(log_str))

 
def snowflake_mirror_job(**kwargs):
    table_info = kwargs['table_info_dict']
    ti = kwargs['ti']
    Table = table_info['mirror_table']
    Mode = str(table_info['sync_type']).upper()
    Job_Id = ti.xcom_pull(task_ids=f"start_ingestion_task_{Table}", key='job_id')
    run_id = ti.xcom_pull(task_ids=f"start_ingestion_task_{Table}", key='run_id')
    start_time = ti.xcom_pull(task_ids=f"start_ingestion_task_{Table}", key= f"START_TIME_{Table}_{Mode}")
    pipeline_run_id = f"{DAG_ID}_{run_id}"
    Pipeline = table_info['pipeline_name']
    FileFormat = str(table_info['file_format']).upper()
    stg_db = table_info['staging_db']
    stg_schema = table_info['staging_schema']
    staging_table = table_info["staging_table"]
    stage_name = f'{Table}{Stage_Suffix}'
    src_path = table_info['s3_path']
    mirror_db = table_info["mirror_db"]
    mirror_schema = table_info["mirror_schema"]
    mirror_table = Table

    variant_keys = table_info["variant_key"]
    foreign_key = table_info["foreign_key"]

    VARIANT_COLUMN = 'DATA'
    RELATION_COLUMNS = 'INC_JOB_CREATED_AT,INC_JOB_ID,FILE_NAME,FILE_TIMESTAMP'

 
    print(f"""
    MIRROR Job Details:
    ------------
    Job ID            : {Job_Id}
    Pipeline Run ID   : {pipeline_run_id}
    Mode              : {Mode}
    Pipeline          : {Pipeline}
    File Format       : {FileFormat}
    Stage DB          : {stg_db}
    Stage Schema      : {stg_schema}
    Stage Table       : {staging_table}
    Stage Name        : {stage_name}
    Mirror DB         : {mirror_db}
    Mirror Schema     : {mirror_schema}
    Mirror Table      : {mirror_table}
    Source Path       : {src_path}
    Start Time        : {start_time}
    Variant keys      : {variant_keys}
    Foreign key       : {foreign_key}
    Variant Column    : {VARIANT_COLUMN}
    Relational Column : {RELATION_COLUMNS}
    Metadata Flag     : TRUE
    """)

 
 
    # Mirror job section
    if mirror_db is None or mirror_schema is None or mirror_table is None:
        logs.warning("::: Mirror info not provided; skipping mirror job.")
        return
 
    logs.info(f"::: Preparing to run mirror job for table: {mirror_table} in database: {mirror_db}, schema: {mirror_schema}")
    query_tag = f"ALTER SESSION SET QUERY_TAG = 'INGESTION,STAGING_JOB,{stg_db}.{stg_schema},{mirror_db}.{mirror_schema},{Pipeline}'; "
    try:
        conn = snowflake_hook.get_conn()
        cur = conn.cursor()
        cur.execute("USE WAREHOUSE BAGIC_DPM_MAXI_RAW_WH;")
        cur.close()
        conn.close()
    except Exception as e:
        logs.error(f"::: Error setting warehouse: {e}")

    mirror_query = f"""
    CALL EMPOWER_DB.UTILS.WRAPPER_PROC(
        SRC_DB => '{stg_db}',
        SRC_SCHEMA => '{stg_schema}',
        SRC_TABLE => '{staging_table}',
        TARGET_DB => '{mirror_db}',
        TARGET_SCHEMA => '{mirror_schema}',
        VARIANT_COLUMN => '{VARIANT_COLUMN}',
        VARIANT_KEYS => '{variant_keys}',
        RELATION_COLUMNS => '{RELATION_COLUMNS}',
        FOREIGN_KEY_PATH => '{foreign_key}',
        METADATA_FLAG => TRUE,
        SYNC_MODE => '{Mode}'
    );
    """
 
    logs.info(f"::: Mirror procedure query prepared: {mirror_query}")
 
    try:
        logs.info("Establishing Snowflake connection...")
        conn = snowflake_hook.get_conn()
        cur = conn.cursor()
        logs.info("::: Connection established successfully.")
 
        # Set query tag
        logs.info(f"Setting query tag: {query_tag}")
        cur.execute(query_tag)
        logs.info("::: Query tag set successfully.")
 
        # Execute mirror procedure
        logs.info("Executing mirror procedure...")
        cur.execute(mirror_query)
        result = cur.fetchall()
        logs.info(f"::: Mirror procedure executed. Raw result: {result}")

        ti.xcom_push(key=f"MIRROR_RESULT_{mirror_table}", value=result)
 
        # -----------------------------
        # run duplicate query and push to XCom (per-table key)
        # -----------------------------

        try:
            duplicate_query = f'''
            SELECT 
                DATA, 
                nvl(DATA:{foreign_key}::STRING, 'null') AS fk_col,
                COUNT(FILE_NAME) AS file_count,
                COUNT(DISTINCT FILE_NAME) AS distinct_file_names,
                LISTAGG(FILE_NAME, ', ') AS file_names,
                LISTAGG(FILE_TIMESTAMP, ', ') AS s3_file_timestamp
            FROM {stg_db}.{stg_schema}.{staging_table}
            WHERE DATE(INC_JOB_CREATED_AT) = DATE('{start_time}')
            GROUP BY DATA
            HAVING COUNT(*) > 1;
            '''
            logs.info("Running duplicate-report query for mirror job...", duplicate_query)
            dup_df = cur.execute(duplicate_query).fetch_pandas_all()
            ti.xcom_push(key=f"MIRROR_DUPLICATE_REPORT_{mirror_table}", value=dup_df.to_json())
            logs.info("::: Duplicate report pushed to XCom.")
        except Exception as e:
            logs.error(f"::: Error while running duplicate query: {e}")
            # push empty result to xcom to avoid missing key
            ti.xcom_push(key=f"MIRROR_DUPLICATE_REPORT_{mirror_table}", value=json.dumps({"error": str(e)}))

        # -----------------------------
        # run daily summary query and push to XCom (per-table key)
        # -----------------------------
        try:
            daily_summary_query = f"""
            SELECT  
                COUNT(1) AS total_count,  
                COUNT(DISTINCT data) AS distinct_count,  
                MIN(file_timestamp) AS start_time,  
                MAX(file_timestamp) AS end_time  
            FROM {stg_db}.{stg_schema}.{staging_table}
            WHERE DATE(INC_JOB_CREATED_AT) = DATE('{start_time}');
            """
            logs.info("Running daily summary query for mirror job...",daily_summary_query)
            summary_row = cur.execute(daily_summary_query).fetchone()
            if summary_row:
                summary_json = {
                    "total_count": summary_row[0],
                    "distinct_count": summary_row[1],
                    "start_time": str(summary_row[2]) if summary_row[2] is not None else None,
                    "end_time": str(summary_row[3]) if summary_row[3] is not None else None,
                }
            else:
                summary_json = {"total_count": 0, "distinct_count": 0, "start_time": None, "end_time": None}
            ti.xcom_push(key=f"MIRROR_DAILY_SUMMARY_{mirror_table}", value=json.dumps(summary_json))
            logs.info("::: Daily summary pushed to XCom.")
        except Exception as e:
            logs.error(f"::: Error while running daily summary query: {e}")
            ti.xcom_push(key=f"MIRROR_DAILY_SUMMARY_{mirror_table}", value=json.dumps({"error": str(e)}))
 
    except Exception as e:
        error_msg = f"::: Error occurred while running mirror procedure for table {Table}: {e}"
        logs.error(error_msg, exc_info=True)
        raise AirflowFailException(error_msg)
 
    finally:
        if cur:
            logs.info("::: Closing cursor...")
            cur.close()
        if conn:
            logs.info("::: Closing Snowflake connection...")
            conn.close()
        
        
def get_previous_state(**kwargs):
    table_info = kwargs['table_info_dict']
    table_name = table_info['mirror_table']
    Mode = table_info['sync_type']
    job_id = f"job_id_{du.TimeNow(date_format='%Y%m%d_%H%M%S%f')}"
    run_id = kwargs['dag_run'].run_id
    logs.info(f"::: job id used will be {job_id}")
    logs.info(f"::: run id used will be {run_id}")
    kwargs['ti'].xcom_push(key='job_id', value=job_id)
    kwargs['ti'].xcom_push(key='run_id', value=run_id)
    # Fetch last modified date from Snowflake
    query = f"""
        SELECT LAST_MODIFIED_DATE
        FROM EMPOWER_DB.UTILS.MAXI_RAW_STATE_TABLE
        WHERE TABLE_NAME = '{table_name}'
    """
    try:
        result = snowflake_hook.get_first(query)
        if result:
            state = result[0]
            logs.info(f"Last modified date for table {table_name}: {state}")
            logs.info(f"table mode is {Mode}")
            logs.info(f"::: The Previous State of Table {table_name}_{Mode} is {state}")
            kwargs['ti'].xcom_push(key=str(f'{table_name}_{Mode}_prv_state').upper(), value=state.isoformat() if isinstance(state, datetime) else state)
        else:
            raise ValueError(f"No data found for table: {table_name}")      
    except Exception as e:
        logs.error(f"Error querying Snowflake: {e}")
        raise
 
    # Push current time and log details
    # Current_time = du.UTCDateTimeNow() + timedelta(hours=5, minutes=30)
    # Get UTC time and convert to IST
    Current_time = datetime.strptime(du.UTCDateTimeNow(), '%Y-%m-%dT%H:%M:%S') + timedelta(hours=5, minutes=30)
    # Current_time='2025-11-19 09:16:28'
 
    kwargs['ti'].xcom_push(key=str(f"start_time_{table_name}_{Mode}").upper(), value=Current_time.isoformat() if isinstance(Current_time, datetime) else Current_time)
    logs.info(f"::: The Start Time of {table_name}_{Mode} is {Current_time}")

    # Log pipeline run details
    run_id = kwargs['task_instance'].xcom_pull(task_ids=f"start_ingestion_task_{table_name}", key='run_id')
    # pipeline_run_id = DAG_ID + "_"
    # execution_id = pipeline_run_id.replace(f"{DAG_ID}_", "")
    # du.pipeline_run_detail(DAG_ID, f"Previous_{table_name}{Mode}_State", pipeline_run_id, execution_id, f" job for {table_name}  : TRIGGERED", 'TRIGGERED')
 
 
def get_list_of_files(BufferTimeInDays=1, **kwargs):
    table_info = kwargs['table_info_dict']
    Bucket = table_info['bucket']
    FileFormat = str(table_info['file_format']).lower()
    Table = table_info['mirror_table']
    Mode = table_info['sync_type']
    Path = table_info['s3_path']
 
    objDict = {}
    objModifiedTime = {}
    LastRun = kwargs['ti'].xcom_pull(key=str(f'{Table}_{Mode}_prv_state').upper())
    CurrentRun = kwargs['ti'].xcom_pull(key=str(f"start_time_{Table}_{Mode}").upper())
    objCount=0
    status, objDict, objModifiedTime = getDMSS3Files(Bucket, Path, LastRun, CurrentRun, FileFormat=FileFormat, Mode=Mode, BatchSize=BatchSize, BufferTimeInDays=1)
    
    logs.info(f"[getDMSS3Files] S3 fetch completed with status: {status}")
    
    if status.upper() == 'SUCCESS':
        logs.info(f"::: S3 batch return is {objDict}")
        logs.info(f"::: Batch Modified Time return is {objModifiedTime}")
        objCount = sum(len(v) for v in objDict.values() if isinstance(v, list))
        logs.info(f"::: objcount: {objCount}")
        kwargs['ti'].xcom_push(key=str(Table).title() + "_" + str(Mode) + "_List_of_objects", value=objDict)
        kwargs['ti'].xcom_push(key=str(Table).title() + "_" + str(Mode) + "_Max_Modified_Time", value={k: v.isoformat() if isinstance(v, datetime) else v for k, v in objModifiedTime.items()})
        kwargs['ti'].xcom_push(key=str(Table).title() + "_" + str(Mode) + "_object_count", value=objCount)
    else:
        kwargs['ti'].xcom_push(key=str(Table).title() + "_" + str(Mode) + "_object_count", value=0)
        logs.warning(f"[getDMSS3Files] Get list of files failed with error - {status}")
        # run_id = kwargs['task_instance'].xcom_pull(task_ids=f"start_ingestion_task_{table_name}", key='run_id')
        # pipeline_run_id = DAG_ID + "_"
        # execution_id = pipeline_run_id.replace(f"{DAG_ID}_", "")
        # du.pipeline_run_detail(DAG_ID, f"Previous_{Table}{Mode}_State", pipeline_run_id, execution_id, f" Folder for {Table}  : FOLDER_NOT_EXISTS", 'FOLDER_NOT_EXISTS')
    
    if objCount == 0:
        log_str = "===== NO FILES FOUND ====="
        logs.info(log_str)
        logs.info(f"[get_list_of_files] Table: {Table}, Mode: {Mode}, Object count: {objCount}")
        logs.info("Branching directly to END task")
        logs.info("="*len(log_str))
        return 'end'
    
    logs.info(f"===== FILES FOUND =====")
    logs.info(f"[get_list_of_files] Table: {Table}, Mode: {Mode}, Object count: {objCount}")
    logs.info(f"=======================")
    return f'snowfake_stage_task_{Table}'

def update_previous_state(**kwargs):
    table_info = kwargs['table_info_dict']
    Table = table_info['mirror_table']
    Mode = table_info['sync_type']

    obj_modified_time = kwargs['ti'].xcom_pull(task_ids=f"get_list_of_files_{Table}", key=str(Table).title() + "_" + str(Mode) + "_Max_Modified_Time")
    if not obj_modified_time:
        print("::: No XCom value found for key:", str(Table).title() + "_" + str(Mode) + "_Max_Modified_Time")
        return None

    # Convert all values to datetime objects
    times = []
    for v in obj_modified_time.values():
        try:
            dt = datetime.fromisoformat(v)
            times.append(dt)
        except Exception:
            continue  # skip values that can't be parsed

    if times:
        max_time = max(times)
        print("::: Maximum timestamp:", max_time)
        max_time_str = max_time.strftime('%Y-%m-%d %H:%M:%S')
        # Upsert into Snowflake
        upsert_query = f"""
        MERGE INTO EMPOWER_DB.UTILS.MAXI_RAW_STATE_TABLE AS target
        USING (SELECT '{Table}' AS TABLE_NAME, '{max_time_str}' AS LAST_MODIFIED_DATE) AS source
        ON target.TABLE_NAME = source.TABLE_NAME
        WHEN MATCHED THEN
            UPDATE SET LAST_MODIFIED_DATE = source.LAST_MODIFIED_DATE
        WHEN NOT MATCHED THEN
            INSERT (TABLE_NAME, LAST_MODIFIED_DATE) VALUES (source.TABLE_NAME, source.LAST_MODIFIED_DATE);
        """
        try:
            snowflake_hook.run(sql=upsert_query)
            logs.info(f"::: Upserted LAST_MODIFIED_DATE for table {Table}: {max_time_str}")
        except Exception as e:
            logs.error(f"::: Error upserting LAST_MODIFIED_DATE for table {Table}: {e}")
            raise
        return max_time_str
    else:
        print("::: No valid timestamps found.")
        return None

def get_list_of_tables(**kwargs):
    table_info = kwargs['table_info_dict']
    table = table_info['staging_table']
    # Check if specific tables were requested in dag_run config
    if 'table_name' in kwargs['dag_run'].conf:
        conf_tables = kwargs['dag_run'].conf["table_name"]
        # Handle both single string and list of tables
        if isinstance(conf_tables, str):
            conf_tables = [conf_tables]
        # Check if current table is in the requested list
        if table in conf_tables:
            logs.info(f"::: Table {table} is in the requested list. Processing...")
            return f"start_ingestion_task_{table}"
        else:
            logs.info(f"::: Table {table} is NOT in the requested list. Skipping...")
            return f"skip_{table}"
    # If no table_name in config, process all tables
    logs.info("No table filter specified.")
    return 'end'

   
def send_generic_mail(subject, body_html):
    smtp_settings_json = Variable.get("smtp_settings_password")
    smtp_settings = json.loads(smtp_settings_json)
    smtp_host = smtp_settings["smtp_host"]
    smtp_port = int(smtp_settings["smtp_port"])
    smtp_user = smtp_settings["smtp_user"]
    smtp_password = smtp_settings["smtp_password"]
    sender_email = "DPM_L1_Team@bajajallianz.co.in"
    recipient_email = [ "ashraf.shaik01@bajajgeneral.com", "pratik.kulkarni@bajajgeneral.com", "satish.phirke@bajajgeneral.com"] #"tejas.thorat01@bajajgeneral.com",  "srinivas.gurram01@bajajgeneral.com", 
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = ", ".join(recipient_email)
    msg['Subject'] = subject
    msg.attach(MIMEText(body_html, 'html'))
    try:
        with smtplib.SMTP(smtp_host, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_password)
            server.send_message(msg)
        print(f"Email sent: {subject}")
    except Exception as e:
        print(f"Failed to send email: {e}")


def send_report_email(table_name_local, **kwargs):
    ti = kwargs['ti']
    mirror_table_local = table_name_local
    # Pull XComs pushed by mirror job
    dup_key = f"MIRROR_DUPLICATE_REPORT_{mirror_table_local}"
    sum_key = f"MIRROR_DAILY_SUMMARY_{mirror_table_local}"
    mirr_key = f"MIRROR_RESULT_{mirror_table_local}"
    mirr_res = ti.xcom_pull(key=mirr_key)
    duplicate_json = ti.xcom_pull(key=dup_key)
    summary_json = ti.xcom_pull(key=sum_key)
    
    try:
        duplicate_data = json.loads(duplicate_json)
    except Exception:
        duplicate_data = duplicate_json
    
    try:
        summary_data = json.loads(summary_json)
    except Exception:
        summary_data = summary_json

    # -------------------------------
    # Build Duplicate Report HTML
    # -------------------------------
    if isinstance(duplicate_data, dict) and 'error' in duplicate_data:
        # Show error message
        dup_html = f"""
        <div style='padding: 15px; background: #fff3cd; border: 1px solid #ffc107; border-radius: 5px;'>
            <strong style='color: #856404;'> Error occurred while fetching duplicate report:</strong>
            <pre style='background: #f8f9fa; color: #2d2d2d; padding: 10px; margin-top: 10px; border-radius: 5px; overflow-x: auto;'>{duplicate_data['error']}</pre>
            <p style='margin-top: 10px; color: #856404;'><em>Please run the query manually for more information.</em></p>
        </div>
        """
        total_files = 0
    else:
        # -------------------------------
        # Convert column-wise dict → row-wise list
        # -------------------------------
        rows = []
        indices = list(duplicate_data["DATA"].keys())
        for idx in indices:
            data_value = duplicate_data["DATA"][idx]
            
            # Check if DATA contains errorCode: 0 and mask it
            masked_data = data_value
            try:
                # Try to parse DATA as JSON
                if isinstance(data_value, str):
                    data_json = json.loads(data_value)
                elif isinstance(data_value, dict):
                    data_json = data_value
                else:
                    data_json = None
                
                # Check if errorCode exists and is 0
                if data_json and data_json.get("errorCode") == 0:
                    masked_data = "*****"
            except:
                # If parsing fails, keep original data
                pass
            
            rows.append({
                "FK_COL": duplicate_data["FK_COL"][idx],
                "FILE_COUNT": duplicate_data["FILE_COUNT"][idx],
                "DISTINCT_FILE_NAMES": duplicate_data["DISTINCT_FILE_NAMES"][idx],
                "FILE_NAMES": duplicate_data["FILE_NAMES"][idx],
                "S3_FILE_TIMESTAMP": duplicate_data["S3_FILE_TIMESTAMP"][idx],
                "DATA": masked_data
            })
        
        total_row_count = len(rows)
        display_rows = rows[:5] if total_row_count > 5 else rows
        
        # -------------------------------
        # Build HTML table
        # -------------------------------
        dup_html = f"""
        <div style='padding: 10px; background: #e3f2fd; border-left: 4px solid #2196f3; margin-bottom: 15px;'>
            <strong>Total Rows: {total_row_count}</strong>
            {f" (Showing top 5)" if total_row_count > 5 else ""}
        </div>
        <table class='table'>
            <tr>
                <th>Foreign Key</th>
                <th>File Count</th>
                <th>Distinct File Names</th>
                <th>File Names</th>
                <th>S3 File Timestamp</th>
                <th>Data</th>
            </tr>
        """

        for row in display_rows:
            dup_html += f"""
            <tr>
                <td>{row['FK_COL']}</td>
                <td>{row['FILE_COUNT']}</td>
                <td>{row['DISTINCT_FILE_NAMES']}</td>
                <td>{row['FILE_NAMES']}</td>
                <td>{row['S3_FILE_TIMESTAMP']}</td>
                <td>{row['DATA']}</td>
            </tr>
            """
        dup_html += "</table>"
        
        # Add SQL query to fetch all records
        dup_html += f"""
        <div style='margin-top: 20px; padding: 15px; background: #f5f5f5; border-radius: 5px;'>
            <strong style='color: #2c3e50;'>Query to Get All Duplicate Records:</strong>
            <pre style='background: #2d2d2d; color: #f1f1f1; padding: 12px; margin-top: 10px; border-radius: 5px; overflow-x: auto; white-space: pre-wrap;'>SELECT 
                DATA, 
                nvl(DATA:{{foreign_key}}::STRING, 'null') AS fk_col,
                COUNT(FILE_NAME) AS file_count,
                COUNT(DISTINCT FILE_NAME) AS distinct_file_names,
                LISTAGG(FILE_NAME, ', ') AS file_names,
                LISTAGG(FILE_TIMESTAMP, ', ') AS s3_file_timestamp
            FROM {{stg_db}}.{{stg_schema}}.{{staging_table}}
            WHERE DATE(INC_JOB_CREATED_AT) = DATE('{{start_time}}')
            GROUP BY DATA
            HAVING COUNT(*) > 1;</pre>
        </div>
        """
        
        total_files = 0

       
    # -------------------------------
    # Build Summary HTML
    # -------------------------------
    if isinstance(summary_data, dict) and 'error' in summary_data:
        # Show error message
        metadata_html = f"""
        <div style='padding: 15px; background: #fff3cd; border: 1px solid #ffc107; border-radius: 5px;'>
            <strong style='color: #856404;'> Error occurred while fetching summary data:</strong>
            <pre style='background: #f8f9fa; color: #2d2d2d; padding: 10px; margin-top: 10px; border-radius: 5px; overflow-x: auto;'>{summary_data['error']}</pre>
            <p style='margin-top: 10px; color: #856404;'><em>Please run the query manually for more information.</em></p>
        </div>
        """
        total_files = 0
    elif isinstance(summary_data, dict):
        total_files = summary_data.get('total_count', 0)
        metadata_html = f"""
        <table class='table'>
            <tr><th>Total Records</th><td>{summary_data.get('total_count', 0)}</td></tr>
            <tr><th>Distinct Records</th><td>{summary_data.get('distinct_count', 0)}</td></tr>
            <tr><th>Start Time</th><td>{summary_data.get('start_time', 'N/A')}</td></tr>
            <tr><th>End Time</th><td>{summary_data.get('end_time', 'N/A')}</td></tr>
        </table>
        """
    else:
        total_files = 0
        metadata_html = f"<pre>{summary_data}</pre>"
    
    execution_time = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
    job_name = f"Mirror Job: {mirror_table_local}"
    subject = "DAG RUN SUCCESSFUL: MAXI_RAW_S3_TO_SF_INU_DAG"
    body = f"""
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Daily Ingestion Report</title>
        <style>
            body {{ font-family: Arial, sans-serif; background: #f4f6f9; padding: 20px; color: #333; }}
            .section {{ background: #ffffff; padding: 18px; margin-bottom: 18px; border-radius: 10px; box-shadow: 0px 2px 6px rgba(0,0,0,0.08); }}
            h2 {{ margin-top: 0; color: #2c3e50; }}
            .table {{ width: 100%; border-collapse: collapse; margin-top: 12px; }}
            .table th, .table td {{ padding: 10px; border: 1px solid #dfe6e9; font-size: 14px; }}
            .table th {{ background: #f1f2f6; font-weight: bold; }}
            details {{ background: #fafafa; padding: 12px; border: 1px solid #dcdde1; border-radius: 8px; margin-top: 12px; }}
            summary {{ font-size: 15px; font-weight: bold; cursor: pointer; color: #2d3436; }}
            summary:hover {{ color: #0984e3; }}
            pre {{ background: #2d2d2d; color: #f1f1f1; padding: 12px; border-radius: 8px; overflow-x: auto; white-space: pre-wrap; }}
        </style>
    </head>
    <body>
        <div class="section">
            <h2> Daily Processing Summary</h2>
            <table class="table">
                <tr><th>Job Name</th><td>{job_name}</td></tr>
                <tr><th>Execution Time</th><td>{execution_time}</td></tr>
                <tr><th>DAG Run ID</th><td>{kwargs['dag_run'].run_id}</td></tr>
                <tr><th>Total Files Processed</th><td>{total_files}</td></tr>
            </table>
        </div>
        <div class="section">
            <h2> Duplicate Report</h2>
            {dup_html}
        </div>
        <div class="section">
            <h2> Staging job Result</h2>
            {metadata_html}
        </div>
        <div class="section">
            <h2>🛠 Mirror Job Result</h2>
            <details>
                <summary>Click to Expand</summary>
                <pre>{mirr_res}</pre>
            </details>
        </div>
    </body>
    </html>
    """
    send_generic_mail(subject, body)
    logs.info(f"Sent report email for {mirror_table_local}")

 
# Define the DAG
dag = DAG(
    dag_id='MAXI_RAW_S3_TO_SF_INU',
    default_args=DEFAULT_ARGS,
    description="MAXI_RAW_S3_TO_SF_INU_DAG",
    start_date=datetime.strptime("2024-12-25 00:00:00", "%Y-%m-%d %H:%M:%S"),
    schedule_interval=None,
    is_paused_upon_creation=True,
    catchup=False,
    tags=[f'MAXIMUS_RAW', 'INGESTION', 'INU']
)
 
# Define tasks dynamically based on json_data
start = DummyOperator(task_id="start", dag=dag)
end = DummyOperator(task_id="end", dag=dag)
 
task_mapping = {}
data = load_config_from_s3()
json_config = {
	"RUN_ID" : "",
	"aws_region" : "ap-south-1",
	"table_mapping" : []
}

for row in data:
    json_config["table_mapping"].append(
        {
            "cron": str(row["CRON"]),
            "pipeline_name": str(row["PIPELINE_NAME"]),
            "mirror_table": str(row["MIRROR_TABLE"]),
            "mirror_schema": str(row["MIRROR_SCHEMA"]),
            "mirror_db": str(row["MIRROR_DB"]),
            "staging_table": str(row["STAGING_TABLE"]),
            "staging_schema": str(row["STAGING_SCHEMA"]),
            "staging_db": str(row["STAGING_DB"]),
            "bucket": str(row["BUCKET"]),
            "foreign_key": str(row["FOREIGN_KEY"]),
            "variant_key": str(row["VARIANT_KEYS"]),
            "file_format": str(row["FILE_FORMAT"]),
            "s3_path": str(row["S3_PATH"]),
            "sync_type": str(row["SYNC_TYPE"]),
        }
    )
	
for table_info_dict in json_config['table_mapping']:
    table_name = table_info_dict["staging_table"]
 
    # Branch task to check if this table should be processed
    get_list_of_tables_task = BranchPythonOperator(
        task_id=f"check_table_{table_name}",  # Different task ID
        python_callable=get_list_of_tables,
        op_kwargs={"table_info_dict": table_info_dict},
        dag=dag
    )
 
    # Task to get previous state
    combined_task = PythonOperator(
        task_id=f"start_ingestion_task_{table_name}",
        python_callable=get_previous_state,
        op_kwargs={"table_info_dict": table_info_dict},
        dag=dag
    )
    
    # Skip task for tables that shouldn't be processed
    skip_task = DummyOperator(
        task_id=f"skip_{table_name}",
        dag=dag
    )
    
    get_list_of_file = BranchPythonOperator(
        task_id=f"get_list_of_files_{table_name}",
        provide_context=True,
        python_callable=get_list_of_files,
        op_kwargs={"table_info_dict": table_info_dict},
        trigger_rule="all_success",
        dag=dag
    )
    
    snowfake_stage_task = PythonOperator(
        task_id=f"snowfake_stage_task_{table_name}",
        provide_context=True,
        python_callable=snowflake_staging_job,
        op_kwargs={"table_info_dict": table_info_dict},
        trigger_rule="all_success",
        dag=dag
    )
    
    snowfake_mirror_task = PythonOperator(
        task_id=f"snowfake_mirror_task_{table_name}",
        provide_context=True,
        python_callable=snowflake_mirror_job,
        op_kwargs={"table_info_dict": table_info_dict},
        trigger_rule="all_success",
        dag=dag
    )

    update_previous_state_task = PythonOperator(
        task_id=f"update_previous_state_{table_name}",
        python_callable=update_previous_state,
        op_kwargs={"table_info_dict": table_info_dict},
        dag=dag
     )
    
    send_report_task = PythonOperator(
        task_id=f"send_report_{table_info_dict['mirror_table']}",
        python_callable=send_report_email,
        op_kwargs={"table_name_local": table_info_dict['mirror_table']},
        provide_context=True,
        dag=dag,
    )
    
    # Set up branching dependencies
    start >> get_list_of_tables_task
    get_list_of_tables_task >> [combined_task, skip_task]
    combined_task >> get_list_of_file 
    get_list_of_file >> [snowfake_stage_task, end]
    snowfake_stage_task >> snowfake_mirror_task >> update_previous_state_task >> send_report_task >> end
    skip_task >> end