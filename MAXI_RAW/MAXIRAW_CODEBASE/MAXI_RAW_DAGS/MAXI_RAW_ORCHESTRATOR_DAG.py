from datetime import timezone, timedelta, datetime
import logging
from croniter import croniter
from collections import defaultdict
import json
from airflow import DAG
from airflow.operators.python_operator import PythonOperator, BranchPythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
import boto3


DAG_ID = 'MAXI_RAW_ORCHESTRATOR_DAG'
cron_expression = '0 * * * *'

BUCKET = "empower-bagic-s3-mount"
KEY = "utils/MAXIMUS_RAW_MASTER/MAXIMUS_RAW_MASTER.json"
REGION = "ap-south-1"
SNOWFLAKE_CONN_ID = 'copy_cmd_snowflake'
SOURCE = 'MAXIMUS_RAW'

################## LOGGING SETUP ##################
# import os

# log_dir = "/home/shaik/Documents/master_dag_dev/"
# log_file = os.path.join(log_dir, "dag_run.log")

# logs = logging.getLogger(__name__)
# logs.setLevel(logging.INFO)

# file_handler = logging.FileHandler(log_file)
# file_handler.setLevel(logging.INFO)

# formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
# file_handler.setFormatter(formatter)

# # Add handler to logger
# logs.addHandler(file_handler)

# logs.info("started logging")

#################### utils ##########################

def load_config_from_s3():
    s3 = boto3.client("s3", region_name=REGION)
    obj = s3.get_object(Bucket=BUCKET, Key=KEY)
    data = json.loads(obj["Body"].read().decode("utf-8"))
    return data

#####################################################

tables_info_dict = {}
tables_info_dict['tables_mapping'] = load_config_from_s3()
# logs.info(f'Tables info loaded: {tables_info_dict["tables_mapping"]}')
print(f'Tables info loaded: {tables_info_dict["tables_mapping"]}')

structured_data = defaultdict(lambda: defaultdict(set))
for table_mapping in tables_info_dict['tables_mapping']:
    structured_data[SOURCE][table_mapping['SYNC_TYPE']].add(table_mapping['STAGING_TABLE']) 

# default_args={
#         'owner': 'EMPOWER',
#         'depends_on_past': False,
#         'email': ['empower@lumiq.ai'],
#         'email_on_failure': False,
#         'email_on_retry': False
#     },
dag = DAG(
    dag_id=DAG_ID,
    description="Orchestration Master DAG For MAXIMUS RAW Ingestion",
    start_date=datetime.strptime("2025-11-01 00:00:00", "%Y-%m-%d %H:%M:%S"),
    schedule_interval=cron_expression,
    is_paused_upon_creation=True,
    catchup=False,
    max_active_runs=20,
    tags=['ORCHESTRATOR', 'INGESTION','MAXIMUS_RAW']
)

# GET_TABLES_TO_RUN_TASK
def get_tables_to_run(**kwargs):
    IST = timezone(timedelta(hours=5, minutes=30)) 
    raw_end_window = (kwargs["dag_run"].start_date).astimezone(IST)
    # logs.info(f'Exact DAG start time : {raw_end_window}')
    print(f'Exact DAG start time : {raw_end_window}')
    end_window = raw_end_window.replace(second=0,microsecond=0)
    cron = croniter(cron_expression, end_window)
    start_window = cron.get_prev(datetime)
    # logs.info(f'CRON start time :{start_window} \n CRON end time:{end_window}') 
    print(f'CRON start time :{start_window} \n CRON end time:{end_window}') #from dag current run it make a previous 15 min window

    grouped_tables = defaultdict(list)
    if 'table_name' in kwargs['dag_run'].conf:
        mode = 'manual'
        passed_tables = kwargs['dag_run'].conf['table_name']
        for table in kwargs['tables_mapping']:
            if table['STAGING_TABLE'] in passed_tables:
                grouped_tables[SOURCE].append(table) # no source in json mapping
    else : 
        mode = 'scheduled'
        for table in kwargs['tables_mapping']:
            try:
                table_cron = croniter(table['CRON'],raw_end_window)
                table_last_run = table_cron.get_prev(datetime)
                test = False
                if start_window < table_last_run <= end_window:
                    grouped_tables[SOURCE].append(table)
                    test = True
                # logs.info(f'Last scheduled run for table {table["Table"]} is {table_last_run} : table_run {test}')
                print(f'Last scheduled run for table {table["STAGING_TABLE"]} is {table_last_run} : table_run {test}')
            except Exception as e:
                # logs.warning(f"The sheduling for table {table['Table']} failed with the following error : {e}")
                print(f'The sheduling for table {table["STAGING_TABLE"]} failed with the following error : {e}')
    grouped_tables = dict(grouped_tables)
    ti=kwargs['ti']
    # logs.info(f'The tables for {mode} run are : {grouped_tables}')
    print(f'The tables for {mode} run are : {grouped_tables}')
    for keys,values in grouped_tables.items():
        ti.xcom_push(key=keys,value=values) # pushing source wise tables mapping
    return list(map(lambda x: f"CHECK_{x.upper()}_TABLES_TASK",grouped_tables.keys()))

# check_source_inu_or_fro_tables_task
def check_source_tables(Source, **kwargs):
    ti=kwargs['ti']
    source_table_mapping = ti.xcom_pull(task_ids = 'GET_TABLES_TO_RUN_TASK', key=Source) # get json cofig of tables of that source
    grouped_tables = defaultdict(list)
    for table in source_table_mapping:
        grouped_tables[table['SYNC_TYPE']].append(table) #AT THIS POINT ONLY HAVE TABLE NAMES
    grouped_tables = dict(grouped_tables)
    downstreamed = []
    # logs.info(f'The final dictionary as source wise grouping : {grouped_tables}')
    print(f'The final dictionary as source wise grouping : {grouped_tables}')
    for keys,values in grouped_tables.items(): #pushing sync type wise tables mapping
        ti.xcom_push(key=keys,value=values)
        downstreamed.append(f'TRIGGER_{Source.upper()}_{keys.upper()}_TABLES_TASK')
    return downstreamed

# trigger_source_target_dags_task
def trigger_source_target_dags(Source, Sync_Type, **kwargs):
    ti=kwargs['ti']
    sync_type_table_mapping = ti.xcom_pull(task_ids=f'CHECK_{Source.upper()}_TABLES_TASK', key = f'{Sync_Type}') # WHAT IS OUTPUT HERE?
    grouped_tables = defaultdict(list)
    if Sync_Type == 'FRO':
        key_dag = 'MAXI_RAW_S3_TO_SF_FRO'
    elif Sync_Type == 'INU':
        key_dag = 'MAXI_RAW_S3_TO_SF_INU'

    for table in sync_type_table_mapping:
        key=key_dag
        grouped_tables[key].append(table['STAGING_TABLE'])
    grouped_tables = dict(grouped_tables)
    
    # logs.info(f'The tables grouping according to Sync_Type are : {grouped_tables}')
    print(f'The tables grouping according to Sync_Type are : {grouped_tables}')
    for keys,values in grouped_tables.items():
        if Sync_Type == 'FRO':
            conf = {"table_name":values}
            trigger_task = TriggerDagRunOperator(
                    task_id = f'Trigger_Dag_{keys}',
                    trigger_dag_id = keys,
                    conf=conf,
                    wait_for_completion=False
                )
            # logs.info(f'Triggering DAG {keys} with conf {conf}')
            print(f'Triggering DAG {keys} with conf {conf}')
            trigger_task.execute(kwargs)
        elif Sync_Type == 'INU':
            conf = {"sync_mode" : Sync_Type , "table_name":values}
            trigger_task = TriggerDagRunOperator(
                task_id = f'Trigger_Dag_{keys}',
                trigger_dag_id = keys,
                conf=conf,
                wait_for_completion=False
            )
            # logs.info(f'Triggering DAG {keys} with conf {conf}')
            print(f'Triggering DAG {keys} with conf {conf}')
            trigger_task.execute(kwargs)



get_tables_to_run_task = BranchPythonOperator(
    task_id = 'GET_TABLES_TO_RUN_TASK',
    python_callable = get_tables_to_run,
    op_kwargs = tables_info_dict.copy(),
    provide_context=True,
    weight_rule = "upstream",
    dag=dag
)

def check_source_tables_task_maker(Source):
    check_source_tables_task = BranchPythonOperator(
        task_id = f'CHECK_{Source.upper()}_TABLES_TASK',
        python_callable = check_source_tables,
        op_args = [Source],
        provide_context = True,
  weight_rule = "upstream",
        dag=dag
    )
    return check_source_tables_task

def trigger_source_target_dags_task_maker(Source,Sync_Type):
    trigger_source_target_dags_task = PythonOperator(
        task_id = f'TRIGGER_{Source.upper()}_{Sync_Type.upper()}_TABLES_TASK',
        python_callable = trigger_source_target_dags,
        op_args = [Source,Sync_Type],
        provide_context = True,
  weight_rule = "upstream",
        dag=dag
    )
    return trigger_source_target_dags_task

for source in structured_data.keys():
    check_inu_or_fro_tables_task = check_source_tables_task_maker(source)
    get_tables_to_run_task >> check_inu_or_fro_tables_task
    for sync_type in structured_data[source].keys():
        trigger_source_target_dags_task = trigger_source_target_dags_task_maker(source,sync_type)
        check_inu_or_fro_tables_task >> trigger_source_target_dags_task

############################  JSON CONFIG FILE UPDATE EVERY 15 MIN ############################


snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)

staging_db = "BAGIC_PREPROD_CURATED_DB"
staging_schema = "UTILS"
stage_name = "s3_master_json_stg"
file_name = "MAXIMUS_RAW_MASTER.json"

def read_master_from_s3():
    s3 = boto3.client("s3", region_name=REGION)
    obj = s3.get_object(Bucket=BUCKET, Key=KEY)
    data = json.loads(obj["Body"].read().decode("utf-8"))
    print("read master success")
    return data
 
def fetch_data_from_sf_stage():
    query = f"""
    SELECT $1 FROM @{staging_db}.{staging_schema}.{stage_name}/{file_name}
    """
    result = snowflake_hook.get_first(query)
    print("fetch sf success")
    return result[0] if result else None
 
def update_json(**kwargs):
    s3 = boto3.client("s3", region_name=REGION)
 
    # Read data
    old_data = read_master_from_s3()
    new_data_raw = fetch_data_from_sf_stage()
    
    # Parse the JSON string from Snowflake
    new_data = json.loads(new_data_raw) if isinstance(new_data_raw, str) else new_data_raw
 
    print("----- OLD DATA -----")
    print(json.dumps(old_data, indent=2))
    print("----- NEW DATA -----")
    print(json.dumps(new_data, indent=2))
 
    # Compare the actual data (both are lists)
    if json.dumps(old_data, sort_keys=True) == json.dumps(new_data, sort_keys=True):
        print("No change detected. JSON not updated.")
        return
 
    # Backup old JSON with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_key = KEY.replace(".json", f"_{timestamp}.json")
 
    s3.copy_object(
        Bucket=BUCKET,
        CopySource=f"{BUCKET}/{KEY}",
        Key=backup_key
    )
 
    # Write updated JSON to S3
    s3.put_object(
        Bucket=BUCKET,
        Key=KEY,
        Body=json.dumps(new_data, indent=2)
    )
 
    print(f"Updated {KEY} and backup created at {backup_key}")


 

 
update_json_task = PythonOperator(
    task_id="update_json",
    python_callable=update_json,
    provide_context=True,
    dag = dag

)
 
update_json_task
