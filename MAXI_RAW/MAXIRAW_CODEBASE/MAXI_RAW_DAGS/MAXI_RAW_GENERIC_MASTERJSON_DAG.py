from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import boto3, json, os
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
 
BUCKET = "empower-bagic-s3-mount"
KEY = "utils/MAXIMUS_RAW_MASTER/MAXIMUS_RAW_MASTER.json"
REGION = "ap-south-1"
SNOWFLAKE_CONN_ID = 'copy_cmd_snowflake'
 
##############################
staging_db = "BAGIC_PREPROD_CURATED_DB"
staging_schema = "UTILS"
stage_name = "s3_master_json_stg"
file_name = "MAXIMUS_RAW_MASTER.json"
##############################
 
# Initialize Snowflake Hook
snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)
 
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
 
    print(f"✅ Updated {KEY} and backup created at {backup_key}")

default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=2)
}
 
with DAG(
    dag_id="MAXI_RAW_GENERIC_MASTERJSON_DAG",
    default_args=default_args,
    schedule_interval="*/15 * * * *",  # every 15 min
    start_date=datetime(2025, 11, 13),
    catchup=False
) as dag:
 
    update_json_task = PythonOperator(
        task_id="update_json",
        python_callable=update_json,
        provide_context=True
    )
 
    update_json_task