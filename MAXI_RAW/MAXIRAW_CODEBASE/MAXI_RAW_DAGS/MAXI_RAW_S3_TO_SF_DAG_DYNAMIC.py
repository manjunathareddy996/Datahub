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

 
# Constants
SOURCE_DB = ''
SOURCE_SCHEMA = ''
S3_BUCKET = ""
S3_DIRECTORY = ""
DAG_ID = f'INGESTION_{SOURCE_DB}_{SOURCE_SCHEMA}_MAXI_RAW_POC'
SNOWFLAKE_CONN_ID = 'copy_cmd_snowflake'
SNOWFLAKE_S3_INTEGRATION = 'BAGIC_S3_DATAHUB_INIEGRATION'
DEFAULT_ARGS = {
    'owner': 'empower',
    'depends_on_past': False,
    'email': ['empower@lumiq.ai'],
    'email_on_failure': False,
    'email_on_retry': False
}
 
BufferBatchSize = 10
 
# FROBatchSize = Variable.get("FRO_DMS_BatchSize")
# FROBatchSize = Variable.get("FRO_DMS_BatchSize")
 
BatchSize = {
    "FRO":100
}
 
TableSuffix = {
    "FRO": '_FRO' # do we need this
}
Stage_Suffix = "_STAGE"
 
# Initialize Snowflake Hook
 
snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)
try:
    conn = snowflake_hook.get_conn()
    cur = conn.cursor()
    cur.execute("USE WAREHOUSE BAGIC_DPM_MAXI_RAW_WH;")
    cur.close()
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
    """Get last successful batch from checkpoint table"""
    query = f"""
        SELECT batch_number
        FROM BAGIC_PREPROD_CURATED_DB.UTILS.CHECKPOINT_TABLE
        WHERE table_name = '{table_name}' and JOB_ID = '{Job_Id}'
        ORDER BY batch_number DESC
        LIMIT 1
    """
    result = snowflake_hook.get_first(query)
    # Return batch as-is, or None if no row exists
    return result[0] if result else None
 
def getDMSS3Files(Bucket, Path, LastRun, CurrentRun, BatchSize, FileFormat='parquet', Mode='FRO', BufferTimeInDays=1):
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
            lst = du.date_diff(start_dt, end_dt, "%Y/%m/%d/%H", buffer={"days": BufferTimeInDays});
            print(lst)
            s3_obj_dict = {}
            for x in lst:
                prefix = Prefix + x
                prefix = prefix + str('/') if not str(prefix).endswith('/') else str(prefix)
                print(prefix)
                if(du.s3_File_Exists(Bucket,prefix)):
                    print("valid path...")
                else:
                    print("invalid path...")
                print(last_utc_dt)
                print(current_utc_dt)
                temp_dict = du.s3_list_objects_paginator(
                    Bucket=Bucket, 
                    Path=prefix,
                    LastUtcTime=last_utc_dt, 
                    CurrentUtcTime=current_utc_dt
                )
                
                s3_obj_dict.update(temp_dict)
            
            print(s3_obj_dict)
            s3_obj_dict = du.s3_list_objects_paginator(Bucket=Bucket, Path=Prefix, LastUtcTime=last_utc_dt, CurrentUtcTime=current_utc_dt)
            print(s3_obj_dict)
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
    run_id = ti.xcom_pull(task_ids=f"start_ingestion_task_{table_name}", key='run_id')
    pipeline_run_id = f"{DAG_ID}_{run_id}"
    # execution_id = pipeline_run_id.replace(f"{DAG_ID}_", "")
    Mode = str(table_info['sync_type']).upper()
    Pipeline = table_info['pipeline_name']
    FileFormat = str(table_info['file_format']).upper()
    stg_db = table_info['staging_db']
    stg_schema = table_info['staging_schema']
    stg_table = f'{Table}' #{Mode}
    stage_name = f'{Table}{Stage_Suffix}' #{Mode}
    src_path = table_info['s3_path']
    start_time = ti.xcom_pull(key=f"start_time_{Table}{Mode}")
    processed_batch_no = 0
    load_history_count = 0
    input_files = []
    load_files = []
 
    print(f"""
    Job Details:
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
 
 
    query_tag = f"ALTER SESSION SET QUERY_TAG = 'INGESTION,STAGING,SNOWFLAKE,{stg_db}.{stg_schema}.{Table},{Pipeline},JOB'; " # removed staging
 
    # Create stage #removed table mode
    stage_qry = f'''
        CREATE STAGE IF NOT EXISTS {stg_db}.{stg_schema}.{Table}{Stage_Suffix}
        STORAGE_INTEGRATION = {SNOWFLAKE_S3_INTEGRATION}
        FILE_FORMAT = ( TYPE = {FileFormat} )
        URL = '{src_path}';
    '''
    print(stage_qry)
    logs.info(f"CREATE STAGE USING Query: {stage_qry}")
    try:
        result = snowflake_hook.run(sql=query_tag + stage_qry)
        logs.info(f"Output of CREATE STAGE query: {result}")
    except Exception as e:
        logs.error(f"Error running CREATE STAGE query: {stage_qry}")
        logs.error(e)
        raise AirflowFailException(e)
 
    # Pull file batch info from XCom
    batchDict = ti.xcom_pull(key=f'{Table.title()}{Mode}_List_of_objects')
    modifiedTs = ti.xcom_pull(key=f'{Table.title()}{Mode}_Max_Modified_Time')
    objCount = ti.xcom_pull(key=f'{Table.title()}{Mode}_object_count')
 
    print("batchDict", batchDict)
 
    print("modifiedTs: ", modifiedTs)
 
    logs.info(f"Object count: {objCount}")
    input_files = [file for files in batchDict.values() for file in files]
    print(input_files)
    # SplitMode = True
    # # file_list = [str(x.split('/')[-1].split('.')[0]).upper() for x in batchDict.keys()]
    # # logs.info(f"File list: {file_list}")
 
    # if (objCount <= BatchSize[Mode] + BufferBatchSize) and Mode == 'FRO' and f'LOAD00001.{FileFormat.lower()}' in input_files:
    #     SplitMode = False
 
    # logs.info(f"Split Mode: {SplitMode}")
    totalbatch = len(batchDict)
    logs.info(f"Total batches: {totalbatch}")
 
    foreign_key_str = table_info['foreign_key']
    foreign_key = ','.join([f"'{str(pk).strip()}'" for pk in foreign_key_str.split(',')])
 
    print("foreign_key: ",foreign_key)
    variant_keys = table_info['variant_key']
 
 
    # print("Split Mode: ",SplitMode)
 
    print(batchDict.keys()) 
        
    # Get the last successful batch
    last_successful_batch = get_checkpoint(Table, Job_Id)
    logs.info(f"Last successful batch for table {Table}: {last_successful_batch}")

    # Sort batchDict keys to ensure correct order
    sorted_batches = sorted(batchDict.keys(), key=lambda x: int(x.split('_')[1]))

    # Truncate staging Table if already exist
    # backup_qry = f"""CREATE OR REPLACE TABLE {stg_db}.{stg_schema}.{Table}_BACKUP CLONE  {stg_db}.{stg_schema}.{Table};"""
    truncate_qry = f"""DROP TABLE IF EXISTS  {stg_db}.{stg_schema}.{Table};"""
    try:
        # result = snowflake_hook.run(sql=query_tag + backup_qry)
        # logs.info(f"Back Up is created for the Staging Table -  {stg_db}.{stg_schema}.{Table} : {Table}_BACKUP ")
        result = str(snowflake_hook.run(sql=query_tag + truncate_qry))
        if re.search(r'already dropped', result, re.IGNORECASE):
            print("FRO re-execution detected for this table")
        logs.info(f"Dropped Staging Table - {stg_db}.{stg_schema}.{Table}, Executed Query result: {result}")
    except Exception as e:
        logs.error(f"Error running drop if exist query: {truncate_qry}")
        logs.error(e)
        raise AirflowFailException(e)

    for x in sorted_batches:
        # Skip batches already processed
        if last_successful_batch:
            last_batch_num = int(last_successful_batch.split('_')[1])
            current_batch_num = int(x.split('_')[1])
            if current_batch_num <= last_batch_num:
                logs.info(f"Skipping already processed batch: {x}")
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
            logs.error(f"Error setting warehouse: {e}")

        # Copy query
        copy_qry = f"""CALL EMPOWER_DB.UTILS.SNOWFLAKE_COPY_INA_STAGING_JOB_MAXI_RAW_POC(
                    DB => '{stg_db}',
                    SCHEMANAME => '{stg_schema}',
                    TABLENAME => '{stg_table}',
                    STAGE_NAME => '{stage_name}',
                    FILE_FORMAT => 'PROD_EXTERNAL_DB.PROD.JSON_FORMAT',
                    INC_JOB_ID => '{Job_Id}',
                    FILE_LIST => {batch_files});"""
        
        logs.info(f"Running staging query for batch {x}: {copy_qry}")

        try:
            result = snowflake_hook.run(sql=query_tag + copy_qry)
            processed_batch_no += 1
            load_history_count += len(batch_files)
            load_files.append(batch_files)
            logs.info(f"Output of batch {x} staging job: {result}")
        except Exception as e:
            logs.error(f"Error running COPY query: {copy_qry}")
            logs.error(e)
            raise AirflowFailException(e)

        watermark_value = modifiedTs.get(x) or '2024-01-01 00:00:00'
        logs.info(f'Commit Batch {x} Max Modified Timestamp: {watermark_value}')

        # ---- Update CHECKPOINT_TABLE after successful batch ----
        upsert_query =f"""
            MERGE INTO BAGIC_PREPROD_CURATED_DB.UTILS.CHECKPOINT_TABLE AS target
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
            logs.info(f"Checkpoint updated for batch {batch_number} of table {Table}")
        except Exception as e:
            logs.error(f"Error updating CHECKPOINT_TABLE for batch {batch_number}: {e}")
            raise

 
def snowflake_mirror_job(**kwargs):
    table_info = kwargs['table_info_dict']
    ti = kwargs['ti']
    Job_Id = ti.xcom_pull(task_ids=f"start_ingestion_task_{table_name}", key='job_id')
    run_id = ti.xcom_pull(task_ids=f"start_ingestion_task_{table_name}", key='run_id')
    pipeline_run_id = f"{DAG_ID}_{run_id}"
    execution_id = pipeline_run_id.replace(f"{DAG_ID}_", "")
    Table = table_info['mirror_table']
    Mode = str(table_info['sync_type']).upper()
    Pipeline = table_info['pipeline_name']
    FileFormat = str(table_info['file_format']).upper()
    stg_db = table_info['staging_db']
    stg_schema = table_info['staging_schema']
    stg_table = f'{Table}' #{Mode}
    stage_name = f'{Table}{Stage_Suffix}' #{Mode}
    src_path = table_info['s3_path']
    start_time = ti.xcom_pull(key=f"start_time_{Table}{Mode}")
    processed_batch_no = 0
    load_history_count = 0
    input_files = []
    load_files = []
 
    print(f"""
    Job Details:
    ------------
    Job ID          : {Job_Id}
    Pipeline Run ID : {pipeline_run_id}
    Execution ID    : {execution_id}
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


    mirror_db = table_info["mirror_db"]
    mirror_schema = table_info["mirror_schema"]
    mirror_table = table_info["mirror_table"]
    staging_table = table_info["staging_table"]
 
    print(mirror_db)
    print(mirror_table)
    
    variant_keys = table_info["variant_key"]
    foreign_key = table_info["foreign_key"]
 
 
    # Mirror job section
    if mirror_db is None or mirror_table is None:
        logs.warning("Mirror database or table info not provided; skipping mirror job.")
        return
 
    logs.info(f"Preparing to run mirror job for table: {mirror_table} in database: {mirror_db}")
    query_tag = f"ALTER SESSION SET QUERY_TAG = 'INGESTION,STAGING,SNOWFLAKE,{stg_db}.{stg_schema}.{Table},{Pipeline},JOB'; "
    try:
        conn = snowflake_hook.get_conn()
        cur = conn.cursor()
        cur.execute("USE WAREHOUSE BAGIC_DPM_MAXI_RAW_WH;")
        cur.close()
        conn.close()
    except Exception as e:
        logs.error(f"Error setting warehouse: {e}")


    mirror_query = f"""
    CALL EMPOWER_DB.UTILS.WRAPPER_PROC(
        SRC_DB => '{stg_db}',
        SRC_SCHEMA => '{stg_schema}',
        SRC_TABLE => '{staging_table}',
        TARGET_DB => '{mirror_db}',
        TARGET_SCHEMA => '{mirror_schema}',
        VARIANT_COLUMN => 'DATA',
        VARIANT_KEYS => '{variant_keys}',
        RELATION_COLUMNS => 'INC_JOB_CREATED_AT',
        FOREIGN_KEY_PATH => '{foreign_key}',
        METADATA_FLAG => TRUE,
        SYNC_MODE => '{Mode}'
    );
    """
 
    logs.info(f"Mirror procedure query prepared: {mirror_query}")
 
    try:
        logs.info("Establishing Snowflake connection...")
        conn = snowflake_hook.get_conn()
        cur = conn.cursor()
        logs.info("Connection established successfully.")
 
        # Set query tag
        logs.info(f"Setting query tag: {query_tag}")
        cur.execute(query_tag)
        logs.info("Query tag set successfully.")
 
        # Execute mirror procedure
        logs.info("Executing mirror procedure...")
        cur.execute(mirror_query)
        result = cur.fetchall()
        logs.info(f"Mirror procedure executed. Raw result: {result}")
 
        raw_result = result[0][0] if result else None
        drift_path = None
 
        # Check for type drift in the procedure output
        if raw_result:
            match = re.search(r"Type drift detected: path '([^']+)'", raw_result)
            if match:
                drift_path = match.group(1)
                logs.warning(f"⚠️ Type drift detected at path: {drift_path}")
                status = 'FAILED'
            else:
                logs.info("No type drift detected.")
                status = 'SUCCESS'
        else:
            logs.warning("Mirror procedure returned no result.")
            status = 'FAILED'
 
        # Update table status
        # logs.info(f"Updating TABLE_STATUS for table {Table} with status '{status}'")
        # status_table_query = f"""
        #     UPDATE SNOWFLAKE_LEARNING_DB.PUBLIC.TABLE_STATUS
        #     SET status = '{status}',
        #         updatedat = CURRENT_TIMESTAMP
        #     WHERE tablename = '{Table}';
        # """
        # cur.execute(status_table_query)
        # conn.commit()
        # logs.info(f"TABLE_STATUS updated successfully for table {Table}")
 
    except Exception as e:
        error_msg = f"Error occurred while running mirror procedure for table {Table}: {e}"
        logs.error(error_msg, exc_info=True)
        raise AirflowFailException(error_msg)
 
    finally:
        if cur:
            logs.info("Closing cursor...")
            cur.close()
        if conn:
            logs.info("Closing Snowflake connection...")
            conn.close()
        logs.info("Mirror job process completed.")

        
def get_previous_state(**kwargs):
    table_info = kwargs['table_info_dict']
    table_name = table_info['mirror_table']
    Pipeline = table_info['pipeline_name']
    Mode = table_info['sync_type']
    job_id = f"job_id_{du.TimeNow(date_format='%Y%m%d_%H%M%S%f')}"
    logs.info(f"::: job id used will be {job_id}")
    kwargs['ti'].xcom_push(key='job_id', value=job_id)
 
    # Fetch last modified date from Snowflake
    query = f"""
        SELECT LAST_MODIFIED_DATE
        FROM BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_STATE_TABLE_POC
        WHERE TABLE_NAME = '{table_name}'
    """
    try:
        result = snowflake_hook.get_first(query)
        if result:
            state = result[0]  # Assuming LAST_MODIFIED_DATE is the first column
            logs.info(f"Last modified date for table {table_name}: {state}")
            logs.info(f"table mode is {Mode}")
            logs.info(f":::The Previous State of Table {table_name}{Mode} & Pipeline {Pipeline} is {state}")
            kwargs['ti'].xcom_push(key=str(f'{table_name}{Mode}_prv_state').upper(), value=state.isoformat() if isinstance(state, datetime) else state)
 
        else:
            raise ValueError(f"No data found for table: {table_name}")
    except Exception as e:
        logs.error(f"Error querying Snowflake: {e}")
        raise
 
    # Push current time and log details
    Current_time = du.UTCDateTimeNow()
    # Current_time='2025-11-27 05:29:29'
 
 
    kwargs['ti'].xcom_push(key=str(f"start_time_{table_name}{Mode}").upper(), value=Current_time.isoformat() if isinstance(Current_time, datetime) else Current_time)
    logs.info(f"start_time_{table_name}{Mode} ::: {Current_time}")
 
    # Log pipeline run details
    run_id = kwargs['task_instance'].xcom_pull(task_ids=f"start_ingestion_task_{table_name}", key='run_id')
    pipeline_run_id = DAG_ID + "_"
    execution_id = pipeline_run_id.replace(f"{DAG_ID}_", "")
    # du.pipeline_run_detail(DAG_ID, f"Previous_{table_name}{Mode}_State", pipeline_run_id, execution_id, f" job for {table_name}  : TRIGGERED", 'TRIGGERED')
 
 
def get_list_of_files(BufferTimeInDays=1, **kwargs):
    table_info = kwargs['table_info_dict']
    Bucket = table_info['bucket']
    FileFormat = str(table_info['file_format']).lower()
    Pipeline = table_info['pipeline_name']
    Table = table_info['mirror_table']
    Mode = table_info['sync_type']
    Path = table_info['s3_path']
 
    objDict = {}
    objModifiedTime = {}
    LastRun = kwargs['ti'].xcom_pull(key=str(f'{Table}{Mode}_prv_state').upper())
    print(str(f'{Table}{Mode}_prv_state').upper())
    print(LastRun)
    CurrentRun = kwargs['ti'].xcom_pull(key=str(f"start_time_{Table}{Mode}").upper())
    print(CurrentRun)
    objCount=0
    status, objDict, objModifiedTime = getDMSS3Files(Bucket, Path, LastRun, CurrentRun, FileFormat=FileFormat, Mode=Mode, BatchSize=BatchSize, BufferTimeInDays=1)
    print("getDMSS3Files output:", status, objDict, objModifiedTime)
    
    if status.upper() == 'SUCCESS':
        logs.info(f"S3 batch return is {objDict}")
        logs.info(f"Batch Modified Time return is {objModifiedTime}")
        objCount = sum(len(v) for v in objDict.values() if isinstance(v, list))
        logs.info(f"objcount: {objCount}")
        kwargs['ti'].xcom_push(key=str(Table).title() + str(Mode) + "_List_of_objects", value=objDict)
        kwargs['ti'].xcom_push(key=str(Table).title() + str(Mode) + "_Max_Modified_Time", value={k: v.isoformat() if isinstance(v, datetime) else v for k, v in objModifiedTime.items()})
        kwargs['ti'].xcom_push(key=str(Table).title() + str(Mode) + "_object_count", value=objCount)
    else:
        kwargs['ti'].xcom_push(key=str(Table).title() + str(Mode) + "_object_count", value=0)
        run_id = kwargs['task_instance'].xcom_pull(task_ids=f"start_ingestion_task_{table_name}", key='run_id')
        pipeline_run_id = DAG_ID + "_"
        execution_id = pipeline_run_id.replace(f"{DAG_ID}_", "")
        # du.pipeline_run_detail(DAG_ID, f"Previous_{Table}{Mode}_State", pipeline_run_id, execution_id, f" Folder for {Table}  : FOLDER_NOT_EXISTS", 'FOLDER_NOT_EXISTS')
        logs.warning(f"Get list of files failed with error - {status}")
    
 
    if objCount == 0:
        return f'End_Pipeline'

def update_previous_state(**kwargs):
    table_info = kwargs['table_info_dict']
    Table = table_info['mirror_table']
    Mode = table_info['sync_type']
    table_name = Table  

    obj_modified_time = kwargs['ti'].xcom_pull(task_ids=f"get_list_of_files_{table_name}", key=str(Table).title() + str(Mode) + "_Max_Modified_Time")
    if not obj_modified_time:
        print("No XCom value found for key:", str(Table).title() + str(Mode) + "_Max_Modified_Time")
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
        print("Maximum timestamp:", max_time)
        max_time_str = max_time.strftime('%Y-%m-%d %H:%M:%S')
        # Upsert into Snowflake
        upsert_query = f"""
        MERGE INTO BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_STATE_TABLE_POC AS target
        USING (SELECT '{table_name}' AS TABLE_NAME, '{max_time_str}' AS LAST_MODIFIED_DATE) AS source
        ON target.TABLE_NAME = source.TABLE_NAME
        WHEN MATCHED THEN
            UPDATE SET LAST_MODIFIED_DATE = source.LAST_MODIFIED_DATE
        WHEN NOT MATCHED THEN
            INSERT (TABLE_NAME, LAST_MODIFIED_DATE) VALUES (source.TABLE_NAME, source.LAST_MODIFIED_DATE);
        """
        try:
            snowflake_hook.run(sql=upsert_query)
            logs.info(f"Upserted LAST_MODIFIED_DATE for table {table_name}: {max_time_str}")
        except Exception as e:
            logs.error(f"Error upserting LAST_MODIFIED_DATE for table {table_name}: {e}")
            raise
        return max_time_str
    else:
        print("No valid timestamps found.")
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
            logs.info(f"✅ Table {table} is in the requested list. Processing...")
            return f"start_ingestion_task_{table}"
        else:
            logs.info(f"⏭️ Table {table} is NOT in the requested list. Skipping...")
            return f"skip_{table}"
    # If no table_name in config, process all tables
    logs.info(f"✅ No table filter specified. Processing table {table}...")
    return f"start_ingestion_task_{table}"
 
# Define the DAG
dag = DAG(
    dag_id='MAXI_RAW_S3_TO_SF_POC_DAG_DYNAMIC',
    default_args=DEFAULT_ARGS,
    description="MAXI_RAW_S3_TO_SF_POC_DAG",
    start_date=datetime.strptime("2024-12-25 00:00:00", "%Y-%m-%d %H:%M:%S"),
    schedule_interval=None,
    is_paused_upon_creation=True,
    catchup=False,
    tags=[f'{SOURCE_DB}_{SOURCE_SCHEMA}', 'INGESTION', 'FRO']
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
    
    get_list_of_file = PythonOperator(
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
    
    # Set up branching dependencies
    start >> get_list_of_tables_task
    get_list_of_tables_task >> [combined_task, skip_task]
    combined_task >> get_list_of_file >> snowfake_stage_task >> snowfake_mirror_task >> update_previous_state_task >> end
    skip_task >> end