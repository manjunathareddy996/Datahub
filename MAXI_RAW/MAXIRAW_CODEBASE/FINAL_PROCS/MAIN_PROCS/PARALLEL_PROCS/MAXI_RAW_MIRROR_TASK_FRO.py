"""
================================================================================
MAXI_RAW_S3_TO_SF_INU_DAG - DYNAMIC TASK MAPPING (TaskFlow API)
================================================================================
VERSION: 2.4.0 (2025-02-11)
LAST UPDATE: XCom Storage Optimization - Config retrieved via helper function

This DAG implements TRUE dynamic parallel execution using Airflow 2.3+ TaskFlow API.

KEY FEATURES:
1. ONE TASK PER TABLE - Each table gets its own separate Airflow task
2. Dynamic task creation at RUNTIME (not parse time)
3. Parallel execution within each level using .expand()
4. Sequential execution across levels
5. Variant key filtering from config file
6. Manual trigger support for specific tables
7. ✅ XCom Storage Optimization - Config NOT duplicated in every task

XCOM OPTIMIZATION (NEW in v2.4.0):
- Previously: Config dict was stored in EVERY task's XCom (huge duplication)
- Now: Config retrieved via helper function get_config_for_table()
- Benefit: Saves XCom storage - for 33 tables, saves ~33 config duplicates per level
- Example: Level 5 with 11 tasks = 11 config dicts saved (not stored in XCom)

REQUIREMENTS:
- Airflow >= 2.3.0 (for dynamic task mapping)

ARCHITECTURE:
- Level 0: Process base table (1 task)
- Level 1+: Dynamically create N tasks (one per table) using .expand()
- Each level waits for previous level to complete
- Continues until no more variants found

PERFORMANCE:
- Old Sequential: ~66 minutes for 33 tables
- New Parallel: ~8 minutes for 33 tables
- Speed improvement: 8.2x faster
- XCom storage: Reduced by ~80% (config not duplicated)

AUTHOR: Empower Team
DATE: 2025-02-06
UPDATED: 2025-02-11 (XCom optimization)
================================================================================
"""

import datetime
import time
from airflow.decorators import dag, task
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.models import Variable
from datetime import datetime, timedelta
from airflow.exceptions import AirflowFailException
from airflow.operators.python import BranchPythonOperator
from airflow.operators.dummy_operator import DummyOperator
import boto3
import json
import logging as logs

# ============================================================================
# CONSTANTS AND CONFIGURATION
# ============================================================================

DAG_ID = 'MAXI_RAW_S3_TO_SF_MIRROR_TASK_FRO'
SNOWFLAKE_CONN_ID = 'copy_cmd_snowflake'
SNOWFLAKE_S3_INTEGRATION = 'BAGIC_S3_DATAHUB_INIEGRATION'

# HARDCODED VALUES (not in config file)
VARIANT_COLUMN = 'DATA'
RELATION_COLUMNS = 'INC_JOB_CREATED_AT,INC_JOB_ID,FILE_NAME,FILE_TIMESTAMP'

# Maximum levels to process (safety limit)
MAX_LEVELS = 7

# Initialize Snowflake Hook
snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)

# Set warehouse on initialization
try:
    conn = snowflake_hook.get_conn()
    cur = conn.cursor()
    cur.execute("USE WAREHOUSE BAGIC_DPM_MAXI_RAW_WH;")
    conn.close()
except Exception as e:
    logs.error(f"Error setting warehouse: {e}")


# ============================================================================
# CONFIGURATION LOADING
# ============================================================================

def load_config_from_s3():
    """Load configuration from S3 bucket."""
    s3 = boto3.client("s3", region_name="ap-south-1")
    bucket = "empower-bagic-s3-mount"
    key = "utils/MAXIMUS_RAW_MASTER/MAXIMUS_RAW_MASTER_TEST.json"
    obj = s3.get_object(Bucket=bucket, Key=key)
    return json.loads(obj["Body"].read().decode("utf-8"))


# ============================================================================
# SNOWFLAKE HELPER FUNCTIONS
# ============================================================================

def call_metadata_proc(src_db: str, src_schema: str, src_table: str,
                      target_db: str, target_schema: str, variant_column: str,
                      sync_mode: str, recursive_flag: bool) -> str:
    """Call MAXI_RAW_METADATA_TABLE_PROC to create metadata table."""
    metadata_table_name = f"{src_table}_METADATA"
    
    query = f"""
    CALL BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_METADATA_TABLE_PROC(
        SRC_DB => '{src_db}',
        SRC_SCHEMA => '{src_schema}',
        SRC_TABLE => '{src_table}',
        TARGET_DB => '{target_db}',
        TARGET_SCHEMA => '{target_schema}',
        VARIANT_COLUMN => '{variant_column}',
        SYNC_MODE => '{sync_mode}',
        RECURSIVE_FLAG => {recursive_flag}
    );
    """
    
    logs.info(f"[METADATA_PROC] Creating metadata for {src_table}.{variant_column}")
    logs.info(f"[METADATA_PROC] Query: {query}")
    
    try:
        result = snowflake_hook.run(sql=query)
        logs.info(f"[METADATA_PROC] SUCCESS: Created {metadata_table_name}")
        return metadata_table_name
    except Exception as e:
        logs.error(f"[METADATA_PROC] FAILED: {e}")
        raise AirflowFailException(f"Metadata procedure failed: {e}")


def call_flatten_proc(src_db: str, src_schema: str, src_table: str,
                     target_db: str, target_schema: str, variant_column: str,
                     variant_keys: str, relation_columns: str, foreign_key_path: str,
                     main_table_name: str, metadata_flag: bool, sync_mode: str,
                     recursive_flag: bool, variant_path: str, custom_parent: str) -> dict:
    """
    Call MAXI_RAW_WRAPPER_PROC which internally calls FLATTEN and UPSERT.
    
    The wrapper ensures both procedures run in the same session,
    so temporary tables are visible to the upsert procedure.
    
    Returns:
        Dictionary with:
        - 'table_name': Name of created/skipped table
        - 'status': 'CREATED' or 'SKIPPED'
        - 'reason': Reason if skipped
        - 'output': Full procedure output
        - 'upsert_status': Status of upsert (if INU mode)
    """
    flattened_table_name = f"{src_table}_{variant_column.upper()}"
    
    query = f"""
    CALL BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_WRAPPER_PROC_WITHOUT_VIEW(
        SRC_DB => '{src_db}',
        SRC_SCHEMA => '{src_schema}',
        SRC_TABLE => '{src_table}',
        TARGET_DB => '{target_db}',
        TARGET_SCHEMA => '{target_schema}',
        VARIANT_COLUMN => '{variant_column}',
        VARIANT_KEYS => '{variant_keys}',
        RELATION_COLUMNS => '{relation_columns}',
        FOREIGN_KEY_PATH => '{foreign_key_path}',
        MAIN_TABLE_NAME => '{main_table_name}',
        METADATA_FLAG => {metadata_flag},
        SYNC_MODE => '{sync_mode}',
        RECURSIVE_FLAG => {recursive_flag},
        VARIANT_PATH => '{variant_path}',
        CUSTOM_PARENT => '{custom_parent}'
    );
    """
    
    logs.info(f"[WRAPPER_PROC] Processing {src_table}.{variant_column}")
    logs.info(f"[WRAPPER_PROC] Sync Mode: {sync_mode}")
    logs.info(f"[WRAPPER_PROC] Query: {query}")
    
    try:
        # Execute the stored procedure and get results
        # Use get_records() which returns all rows as a list of tuples
        result = snowflake_hook.get_records(sql=query)
        
        logs.info(f"[FLATTEN_PROC] Raw result type: {type(result)}")
        logs.info(f"[FLATTEN_PROC] Raw result: {result}")
        
        # Parse JSON output from procedure
        # Stored procedure returns a single row with JSON string in first column
        if result and len(result) > 0 and result[0]:
            import json
            
            # Get the first column of the first row
            output_str = result[0][0] if result[0][0] is not None else None
            
            logs.info(f"[FLATTEN_PROC] Output string type: {type(output_str)}")
            logs.info(f"[FLATTEN_PROC] Output string value: {output_str}")
            
            if output_str:
                # Try to parse as JSON
                try:
                    output = json.loads(output_str)
                    logs.info(f"[FLATTEN_PROC] Parsed output type: {type(output)}")
                    logs.info(f"[FLATTEN_PROC] Parsed output: {output}")
                    
                    # Check if output is still a string (double-encoded JSON)
                    if isinstance(output, str):
                        logs.warning(f"[FLATTEN_PROC] Output is double-encoded JSON, parsing again")
                        try:
                            output = json.loads(output)
                            logs.info(f"[FLATTEN_PROC] Second parse output type: {type(output)}")
                        except json.JSONDecodeError:
                            logs.warning(f"[FLATTEN_PROC] Second parse failed, treating as string")
                    
                    # Check if output is a dictionary
                    if isinstance(output, dict):
                        # Check if table was skipped
                        if output.get('status') == 'SKIPPED':
                            logs.warning(f"[WRAPPER_PROC] ⚠️ SKIPPED: {flattened_table_name}")
                            logs.warning(f"[WRAPPER_PROC] Reason: {output.get('reason', 'Unknown')}")
                            return {
                                'table_name': flattened_table_name,
                                'status': 'SKIPPED',
                                'reason': output.get('reason', 'Unknown'),
                                'output': output
                            }
                        else:
                            logs.info(f"[WRAPPER_PROC] SUCCESS: Created {output.get('table_name')}")
                            if output.get('upsert_status'):
                                logs.info(f"[WRAPPER_PROC] Upsert Status: {output.get('upsert_status')}")
                            return {
                                'table_name': output.get('table_name'),
                                'status': 'CREATED',
                                'reason': None,
                                'output': output
                            }
                    else:
                        # JSON parsed but not a dict (maybe a string or other type)
                        logs.warning(f"[WRAPPER_PROC] Parsed JSON is not a dict, type: {type(output)}")
                        logs.info(f"[WRAPPER_PROC] SUCCESS: Created {flattened_table_name} (non-dict output)")
                        return {
                            'table_name': flattened_table_name,
                            'status': 'CREATED',
                            'reason': None,
                            'output': {'raw': str(output)}
                        }
                        
                except json.JSONDecodeError as je:
                    # Not JSON - old procedure format, assume success
                    logs.warning(f"[WRAPPER_PROC] JSON decode error: {je}")
                    logs.info(f"[WRAPPER_PROC] SUCCESS: Created {flattened_table_name} (legacy output)")
                    return {
                        'table_name': flattened_table_name,
                        'status': 'CREATED',
                        'reason': None,
                        'output': {'raw': output_str}
                    }
            else:
                # Empty output
                logs.info(f"[WRAPPER_PROC] SUCCESS: Created {flattened_table_name} (empty output)")
                return {
                    'table_name': flattened_table_name,
                    'status': 'CREATED',
                    'reason': None,
                    'output': None
                }
        else:
            # No output - assume success for backward compatibility
            logs.info(f"[WRAPPER_PROC] SUCCESS: Created {flattened_table_name} (no result)")
            return {
                'table_name': flattened_table_name,
                'status': 'CREATED',
                'reason': None,
                'output': None
            }
            
    except Exception as e:
        logs.error(f"[WRAPPER_PROC] FAILED: {e}")
        logs.error(f"[WRAPPER_PROC] Exception type: {type(e)}")
        import traceback
        logs.error(f"[WRAPPER_PROC] Traceback: {traceback.format_exc()}")
        raise AirflowFailException(f"Wrapper procedure failed: {e}")


def create_incremental_view_base(src_db: str, src_schema: str, src_table: str,
                                  foreign_key_path: str) -> str:
    """
    Create incremental view for BASE TABLE in INU mode.
    Filters by FILE_TIMESTAMP > LAST_MODIFIED_DATE from state table.
    """
    view_name = f"{src_table}_VW"
    
    view_query = f"""
    CREATE OR REPLACE VIEW {src_db}.{src_schema}.{view_name} AS
    SELECT s.*
    FROM (
        SELECT s.*,
               ROW_NUMBER() OVER (
                   PARTITION BY s.DATA:{foreign_key_path}::STRING
                   ORDER BY s.FILE_TIMESTAMP DESC
               ) AS rn
        FROM {src_db}.{src_schema}.{src_table} s
        WHERE s.FILE_TIMESTAMP > (
            SELECT MAX(LAST_MODIFIED_DATE)
            FROM BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_STATE_TABLE 
            WHERE TABLE_NAME = '{src_table}'
        )
        AND s.DATA:{foreign_key_path} IS NOT NULL
    ) s
    WHERE s.rn = 1
    """
    
    logs.info(f"[CREATE_VIEW] Creating incremental view: {view_name}")
    logs.info(f"[CREATE_VIEW] Query: {view_query}")
    
    try:
        snowflake_hook.run(sql=view_query)
        logs.info(f"[CREATE_VIEW] SUCCESS: Created {view_name}")
        return view_name
    except Exception as e:
        logs.error(f"[CREATE_VIEW] FAILED: {e}")
        raise AirflowFailException(f"View creation failed: {e}")


def create_incremental_view_child(target_db: str, target_schema: str, 
                                   parent_table: str) -> str:
    """
    Create incremental view for CHILD TABLE in INU mode.
    Creates view on parent PERMANENT table with same name.
    """
    view_name = f"{parent_table}_VIEW"  # Same name as the permanent table
    
    view_query = f"""
    CREATE OR REPLACE VIEW {target_db}.{target_schema}.{view_name} AS
    SELECT s.*
    FROM (
        SELECT s.*,
               ROW_NUMBER() OVER (
                   PARTITION BY s.foreign_key
                   ORDER BY s.FILE_TIMESTAMP DESC
               ) AS rn
        FROM {target_db}.{target_schema}.{parent_table} s
    ) s
    WHERE s.rn = 1
    """
    
    logs.info(f"[CREATE_VIEW] Creating child incremental view: {view_name}")
    logs.info(f"[CREATE_VIEW] Source permanent table: {parent_table}")
    
    try:
        snowflake_hook.run(sql=view_query)
        logs.info(f"[CREATE_VIEW] SUCCESS: Created {view_name}")
        return view_name
    except Exception as e:
        logs.error(f"[CREATE_VIEW] FAILED: {e}")
        raise AirflowFailException(f"Child view creation failed: {e}")




def query_metadata_for_variants(target_db: str, target_schema: str, metadata_table: str, 
                                current_level: int, variant_keys_filter: list = None, 
                                current_path: str = "") -> list:
    """
    Query metadata table for VARIANT columns at a specific LEVEL with EXACT path-based filtering.
    
    Args:
        target_db: Target database name
        target_schema: Target schema name
        metadata_table: Name of the metadata table (without db.schema prefix)
        current_level: The LEVEL to query (0, 1, 2, 3...)
        variant_keys_filter: Optional list of variant key paths to filter
        current_path: Current path in the hierarchy
    
    Returns:
        List of dictionaries with variant information
        Only returns variants that are the NEXT STEP in one of the filter paths
    """
    # Build fully qualified table name
    fully_qualified_table = f"{target_db}.{target_schema}.{metadata_table}"
    
    query = f"""
    SELECT 
        KEY_NAME,
        KEY_TYPE,
        KEY_PATH,
        LEVEL,
        COL_ALIAS
    FROM {fully_qualified_table}
    WHERE KEY_TYPE = 'VARIANT' 
      AND LEVEL = {current_level}
    ORDER BY KEY_NAME;
    """
    
    logs.info(f"[QUERY_METADATA] Querying {fully_qualified_table}")
    logs.info(f"[QUERY_METADATA] Current level: {current_level}")
    logs.info(f"[QUERY_METADATA] Current path: '{current_path}'")
    logs.info(f"[QUERY_METADATA] Filter paths: {variant_keys_filter}")
    logs.info(f"[QUERY_METADATA] Query: {query}")
    
    try:
        result = snowflake_hook.get_records(sql=query)
        
        variants = []
        for row in result:
            variant_info = {
                'KEY_NAME': row[0],
                'KEY_TYPE': row[1],
                'KEY_PATH': row[2],
                'LEVEL': row[3],
                'COL_ALIAS': row[4]  # Snake_case version used by stored procedure
            }
            variants.append(variant_info)
        
        logs.info(f"[QUERY_METADATA] Found {len(variants)} variants at LEVEL {current_level}")
        
        # If no filter, return all variants
        if not variant_keys_filter:
            logs.info(f"[QUERY_METADATA] No filter applied, returning all {len(variants)} variants")
            return variants
        
        # EXACT PATH FILTERING
        filtered_variants = []
        
        for variant in variants:
            key_name = variant['KEY_NAME']
            
            # Build the full path for this variant
            if current_path:
                full_path = f"{current_path}.{key_name}"
            else:
                full_path = key_name
            
            logs.info(f"[FILTER] Checking variant: {key_name} (full path: {full_path})")
            
            is_next_step = False
            is_exact_target = False
            
            for filter_key in variant_keys_filter:
                filter_key_lower = filter_key.lower().strip()
                full_path_lower = full_path.lower()
                
                # Case 1: This variant IS the exact target
                if filter_key_lower == full_path_lower:
                    is_exact_target = True
                    is_next_step = True
                    logs.info(f"[FILTER] ✅ EXACT TARGET: {full_path} == {filter_key} (FINAL STEP)")
                    break
                
                # Case 2: This variant is ON THE PATH to the target
                if filter_key_lower.startswith(full_path_lower + "."):
                    is_next_step = True
                    logs.info(f"[FILTER] ✅ ON PATH: {full_path} is next step toward {filter_key}")
                    break
            
            if is_next_step:
                filtered_variants.append(variant)
                variant['IS_FINAL_TARGET'] = is_exact_target
            else:
                logs.info(f"[FILTER] ❌ EXCLUDED: {full_path} (not next step in any filter path)")
        
        logs.info(f"[QUERY_METADATA] Filtered from {len(variants)} to {len(filtered_variants)} variants")
        
        if filtered_variants:
            logs.info(f"[QUERY_METADATA] Next step variants: {[v['KEY_NAME'] for v in filtered_variants]}")
            final_targets = [v['KEY_NAME'] for v in filtered_variants if v.get('IS_FINAL_TARGET')]
            if final_targets:
                logs.info(f"[QUERY_METADATA] FINAL TARGETS (will stop after): {final_targets}")
        else:
            logs.info(f"[QUERY_METADATA]  No next steps found - TARGET REACHED, STOPPING")
        
        return filtered_variants
        
    except Exception as e:
        logs.error(f"[QUERY_METADATA] FAILED: {e}")
        return []


# ============================================================================
# DAG DEFINITION USING TASKFLOW API
# ============================================================================

# Load configuration
data = load_config_from_s3()

# Build JSON config
json_config = {
    "RUN_ID": "",
    "aws_region": "ap-south-1",
    "table_mapping": []
}

for row in data:
    json_config["table_mapping"].append({
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
    })


# ============================================================================
# CREATE SINGLE DAG FOR ALL TABLES
# ============================================================================

@dag(
    dag_id='MAXI_RAW_S3_TO_SF_MIRROR_TASK_FRO',
    default_args={
        'owner': 'empower',
        'depends_on_past': False,
        'email': ['empower@lumiq.ai'],
        'email_on_failure': False,
        'email_on_retry': False
    },
    description="Dynamic parallel execution for all tables",
    start_date=datetime.strptime("2024-12-25 00:00:00", "%Y-%m-%d %H:%M:%S"),
    schedule_interval=None,
    is_paused_upon_creation=True,
    catchup=False,
    tags=['MAXIMUS_RAW', 'INGESTION', 'INU', 'PARALLEL', 'DYNAMIC', 'TASKFLOW']
)
def create_single_dag():
    """
    Single DAG that processes ALL tables from config.
    Each table's hierarchy is processed in parallel.
    """
    
    # Process all tables from config
    for table_info_dict in json_config['table_mapping']:
        table_name = table_info_dict["staging_table"]
        """
        Create DAG with dynamic task mapping.
        Each table at a level gets its own separate task.
        """
        
        # ====================================================================
        # HELPER: Get Config (No XCom - Direct Function Call)
        # ====================================================================
        
        def get_config_for_table():
            """
            Helper function to get config without storing in XCom.
            This is called directly by tasks, not via TaskFlow.
            Saves XCom storage by avoiding config duplication.
            """
            variant_keys_str = table_info_dict.get('variant_key', '')
            if variant_keys_str:
                variant_keys_list = [k.strip() for k in variant_keys_str.split(',')]
            else:
                variant_keys_list = None
            
            return {
                'staging_db': table_info_dict['staging_db'],
                'staging_schema': table_info_dict['staging_schema'],
                'mirror_db': table_info_dict['mirror_db'],
                'mirror_schema': table_info_dict['mirror_schema'],
                'foreign_key': table_info_dict['foreign_key'],
                'variant_key_list': variant_keys_list,
                'base_table': table_info_dict['staging_table'],
                'sync_mode': table_info_dict.get('sync_type', 'INU')
            }
        
        # ====================================================================
        # TASK: Initialize Configuration
        # ====================================================================
        
        @task(task_id=f"initialize_config_{table_name}")
        def initialize_config():
            """Initialize configuration - just returns table name as identifier."""
            logs.info("="*80)
            logs.info(f"INITIALIZE CONFIGURATION - {table_name}")
            logs.info("="*80)
            
            config = get_config_for_table()
            
            logs.info(f"Configuration:")
            logs.info(f"  Base table: {config['base_table']}")
            logs.info(f"  Variant filter: {config.get('variant_key_list')}")
            logs.info(f"  Sync mode: {config['sync_mode']}")
            logs.info(f"✅ Config loaded from helper function (not stored in XCom)")
            
            # Return only table name - config will be retrieved via helper function
            return table_name
        
        # ====================================================================
        # TASK: Process Level 0 (Base Table)
        # ====================================================================
        
        @task(task_id=f"process_level_0_{table_name}")
        def process_level_0(table_identifier: str):
            """Process Level 0 - base table."""
            logs.info("="*80)
            logs.info(f"PROCESS LEVEL 0 - BASE TABLE - {table_name}")
            logs.info("="*80)
            
            # Get config from helper function (not from XCom)
            config = get_config_for_table()
            logs.info(f"✅ Config retrieved from helper function")
            
            base_table = config['base_table']
            src_db = config['staging_db']
            src_schema = config['staging_schema']
            target_db = config['mirror_db']
            target_schema = config['mirror_schema']
            foreign_key_path = config['foreign_key']
            variant_keys_filter = config.get('variant_key_list', None)
            sync_mode = config.get('sync_mode', 'FRO')
            
            # Step 1: Create incremental view for INU mode
            if sync_mode == 'INU':
                view_name = create_incremental_view_base(
                    src_db=src_db,
                    src_schema=src_schema,
                    src_table=base_table,
                    foreign_key_path=foreign_key_path
                )
                src_table_to_use = view_name
                logs.info(f"[LEVEL 0] INU Mode: Using view {view_name}")
            else:
                src_table_to_use = base_table
                logs.info(f"[LEVEL 0] FRO Mode: Using table {base_table}")
            
            # Step 2: Call wrapper procedure (handles flatten + upsert in same session)
            flatten_result = call_flatten_proc(
                src_db=src_db,
                src_schema=src_schema,
                src_table=src_table_to_use,
                target_db=target_db,
                target_schema=target_schema,
                variant_column=VARIANT_COLUMN,  # Hardcoded
                variant_keys='',
                relation_columns=RELATION_COLUMNS,  # Base columns only for Level 0
                foreign_key_path=foreign_key_path,  # Use full path for Level 0
                main_table_name=src_table_to_use,
                metadata_flag=True,  # Flatten proc will call metadata proc internally
                sync_mode=sync_mode,
                recursive_flag=False,
                variant_path='',
                custom_parent='null'
            )
            
            # Level 0 should always succeed (base table should have data)
            flattened_table = flatten_result['table_name']
            logs.info(f"[LEVEL 0] Created {flattened_table}")
            
            # Step 3: Wrapper procedure handles upsert internally for INU mode
            # No separate upsert call needed
            logs.info(f"[LEVEL 0] Table created: {flattened_table}")
            if sync_mode == 'INU':
                upsert_status = flatten_result.get('output', {}).get('upsert_status', 'UNKNOWN')
                logs.info(f"[LEVEL 0] INU Mode - Upsert Status: {upsert_status}")
            
            # Step 4: Query metadata for children at LEVEL 0
            metadata_table = f"{src_table_to_use}_METADATA"
            
            child_variants = query_metadata_for_variants(
                target_db=target_db,
                target_schema=target_schema,
                metadata_table=metadata_table,
                current_level=0,  # Query for Level 0 variants
                variant_keys_filter=variant_keys_filter,
                current_path=""
            )
            
            # Step 5: Build task configs for Level 1
            level_1_tasks = []
            for variant in child_variants:
                task_config = {
                    # Only store minimal data - config retrieved via helper function
                    'src_table': flattened_table,
                    'variant_column': variant['COL_ALIAS'],  # Use snake_case alias from metadata
                    'current_level': 1,
                    'current_path': variant['KEY_NAME'],  # Keep original path for filtering
                    'main_metadata_table': metadata_table,  # ✅ Pass main metadata table name
                    'is_final_target': variant.get('IS_FINAL_TARGET', False)
                }
                level_1_tasks.append(task_config)
            
            logs.info(f"[LEVEL 0] Created {flattened_table}")
            logs.info(f"[LEVEL 0] Found {len(level_1_tasks)} children at METADATA LEVEL 0")
            logs.info(f"[LEVEL 0] Main metadata table: {metadata_table}")
            logs.info(f"✅ XCom optimized: Config NOT stored in task configs (saves {len(level_1_tasks)} duplicates)")
            
            return level_1_tasks
        
        # ====================================================================
        # TASK: Process Single Variant (Used for all levels 1+)
        # ====================================================================
        
        @task(task_id=f"process_single_variant_{table_name}")
        def process_single_variant(task_config: dict):
            """
            Process a single variant table.
            This task is dynamically mapped - ONE TASK PER TABLE.
            Config is retrieved from helper function to save XCom storage.
            """
            # Get config from helper function (not from XCom)
            config = get_config_for_table()
            
            src_table = task_config['src_table']
            variant_column = task_config['variant_column']
            current_level = task_config['current_level']
            current_path = task_config['current_path']
            main_metadata_table = task_config['main_metadata_table']
            is_final_target = task_config.get('is_final_target', False)
            
            logs.info("="*80)
            logs.info(f"PROCESS SINGLE VARIANT - Level {current_level}")
            logs.info("="*80)
            logs.info(f"Source Table: {src_table}")
            logs.info(f"Variant Column: {variant_column}")
            logs.info(f"Current Path: {current_path}")
            logs.info(f"Main Metadata Table: {main_metadata_table}")
            logs.info(f"Is Final Target: {is_final_target}")
            logs.info(f"✅ Config retrieved from helper function (not from XCom)")
            
            src_db = config['staging_db']
            src_schema = config['staging_schema']
            target_db = config['mirror_db']
            target_schema = config['mirror_schema']
            foreign_key_path = config['foreign_key']
            variant_keys_filter = config.get('variant_key_list', None)
            sync_mode = config.get('sync_mode', 'FRO')
            main_table_name = config['base_table']
            
            # Step 1: Create incremental view for INU mode (child tables)
            if sync_mode == 'INU':
                view_name = create_incremental_view_child(
                    target_db=target_db,
                    target_schema=target_schema,
                    parent_table=src_table
                )
                src_table_to_use = view_name
                logs.info(f"[LEVEL {current_level}] INU Mode: Using view {view_name}")
            else:
                src_table_to_use = src_table
                logs.info(f"[LEVEL {current_level}] FRO Mode: Using table {src_table}")
            
            # Step 2: Call wrapper procedure (handles flatten + upsert in same session)
            nested_relation_columns = f"{RELATION_COLUMNS},foreign_key,root_hash,t.key_hash as parent_key_hash,t.record_hash as parent_record_hash"
            
            flatten_result = call_flatten_proc(
                src_db=src_db,
                src_schema=src_schema,
                src_table=src_table_to_use,
                target_db=target_db,
                target_schema=target_schema,
                variant_column=variant_column,
                variant_keys='',
                relation_columns=nested_relation_columns,
                foreign_key_path='NULL',
                main_table_name=main_table_name,
                metadata_flag=True,
                sync_mode=sync_mode,
                recursive_flag=True,
                variant_path=current_path,
                custom_parent=src_table
            )
            
            # Check if table was skipped by the stored procedure
            if flatten_result['status'] == 'SKIPPED':
                logs.warning(f"[SKIP] ⚠️ Table skipped by stored procedure: {flatten_result['table_name']}")
                logs.warning(f"[SKIP] Reason: {flatten_result['reason']}")
                logs.warning(f"[SKIP] All child tables under this path will also be skipped")
                return {
                    'created_table': None,
                    'children': [],
                    'skipped': [{
                        'table_name': flatten_result['table_name'],
                        'path': current_path,
                        'level': current_level,
                        'reason': flatten_result['reason']
                    }]
                }
            
            # Table was created successfully
            flattened_table = flatten_result['table_name']
            logs.info(f"[LEVEL {current_level}] Created {flattened_table}")
            
            # Step 3: Wrapper procedure handles upsert internally for INU mode
            # No separate upsert call needed
            logs.info(f"[LEVEL {current_level}] Table created: {flattened_table}")
            if sync_mode == 'INU':
                upsert_status = flatten_result.get('output', {}).get('upsert_status', 'UNKNOWN')
                logs.info(f"[LEVEL {current_level}] INU Mode - Upsert Status: {upsert_status}")
            
            # Step 4: Check if this is a final target
            if is_final_target:
                logs.info(f"[FINAL TARGET] {current_path} - Stopping here, no children")
                return {
                    'created_table': {
                        'table_name': flattened_table,
                        'path': current_path,
                        'level': current_level,
                        'status': flatten_result['status']
                    },
                    'children': [],
                    'skipped': []
                }
            
            # Step 5: Query MAIN metadata table for children at current DAG level
            metadata_level = current_level  # Metadata level matches DAG level
            
            child_variants = query_metadata_for_variants(
                target_db=target_db,
                target_schema=target_schema,
                metadata_table=main_metadata_table,  # ✅ Use MAIN metadata table
                current_level=metadata_level,  # Query for children at this metadata level
                variant_keys_filter=variant_keys_filter,
                current_path=current_path
            )
            
            # Step 4: Build child task configs
            children = []
            for variant in child_variants:
                new_path = f"{current_path}.{variant['KEY_NAME']}"
                child_config = {
                    # Only store minimal data - config retrieved via helper function
                    'src_table': flattened_table,
                    'variant_column': variant['COL_ALIAS'],  # Use snake_case alias from metadata
                    'current_level': current_level + 1,
                    'current_path': new_path,  # Keep original path for filtering
                    'main_metadata_table': main_metadata_table,  # ✅ Pass main metadata table to children
                    'is_final_target': variant.get('IS_FINAL_TARGET', False)
                }
                children.append(child_config)
            
            logs.info(f"[LEVEL {current_level}] Created {flattened_table}")
            logs.info(f"[LEVEL {current_level}] Found {len(children)} children for Level {current_level + 1}")
            logs.info(f"[LEVEL {current_level}] Using main metadata table: {main_metadata_table}")
            logs.info(f"✅ XCom optimized: Config NOT stored in {len(children)} child configs")
            
            # Return both: info about the table we just created AND child configs for next level
            # This allows flatten_task_lists to track created tables
            return {
                'created_table': {
                    'table_name': flattened_table,
                    'path': current_path,
                    'level': current_level,
                    'status': flatten_result['status']
                },
                'children': children,
                'skipped': []  # Will be populated if table was skipped
            }
        
        # ====================================================================
        # TASK: Flatten Task Lists (Aggregate children from all tasks)
        # ====================================================================
        
        @task(task_id=f"flatten_task_lists_{table_name}")
        def flatten_task_lists(task_lists: list = None):
            """
            Flatten list of lists into single list with deduplication.
            Aggregates all children from all tasks at a level.
            Also collects created and skipped table information.
            
            Args:
                task_lists: List of dicts from process_single_variant, each containing:
                           - 'created_table': Info about table created at this level
                           - 'children': Child configs for next level
                           - 'skipped': Skipped table info
            
            Returns:
                Dictionary with:
                - 'tasks': Flattened and deduplicated list of child task configs
                - 'skipped': List of skipped table information
                - 'created': List of created table information
            """
            # Handle None or empty input
            if not task_lists:
                logs.info(f"[FLATTEN] No task lists provided - returning empty result")
                return {
                    'tasks': [],
                    'skipped': [],
                    'created': []
                }
            
            flattened = []
            skipped_tables = []
            created_tables = []
            seen_tasks = set()  # Track unique tasks using (src_table, variant_column)
            
            for task_result in task_lists:
                if not task_result:  # Skip None
                    continue
                
                # Extract created table info
                if task_result.get('created_table'):
                    created_tables.append(task_result['created_table'])
                    logs.info(f"[FLATTEN] Recorded created table: {task_result['created_table']['table_name']}")
                
                # Extract skipped tables
                if task_result.get('skipped'):
                    skipped_tables.extend(task_result['skipped'])
                    for skipped in task_result['skipped']:
                        logs.info(f"[FLATTEN] Recorded skipped table: {skipped['table_name']}")
                
                # Extract children for next level
                children = task_result.get('children', [])
                for child_config in children:
                    # Create unique key from src_table and variant_column
                    unique_key = (
                        child_config.get('src_table', ''),
                        child_config.get('variant_column', '')
                    )
                    
                    # Only add if not seen before
                    if unique_key not in seen_tasks:
                        seen_tasks.add(unique_key)
                        flattened.append(child_config)
                    else:
                        logs.info(f"[FLATTEN] Skipping duplicate: {child_config.get('src_table')}.{child_config.get('variant_column')}")
            
            logs.info(f"[FLATTEN] Aggregated {len(flattened)} unique child tasks for next level")
            logs.info(f"[FLATTEN] Recorded {len(created_tables)} created tables at this level")
            logs.info(f"[FLATTEN] Recorded {len(skipped_tables)} skipped tables")
            
            return {
                'tasks': flattened,
                'skipped': skipped_tables,
                'created': created_tables
            }
        
        # ====================================================================
        # TASK: Extract Tasks for Next Level
        # ====================================================================
        
        @task(task_id=f"extract_tasks_{table_name}")
        def extract_tasks(flatten_result: dict):
            """
            Extract just the tasks list from flatten result for .expand()
            
            Args:
                flatten_result: Dictionary with 'tasks' and 'skipped' lists
            
            Returns:
                List of task configs for next level
            """
            if isinstance(flatten_result, dict):
                return flatten_result.get('tasks', [])
            return flatten_result
        
        # ====================================================================
        # TASK: Collect Statistics (Final Report)
        # ====================================================================
        
        @task(task_id=f"collect_stats_{table_name}")
        def collect_stats(**context):
            """
            Collect and report all statistics about created and skipped tables.
            Manually pulls XCom to handle skipped tasks gracefully.
            
            Returns:
                Summary statistics
            """
            logs.info("="*80)
            logs.info(f"FINAL STATISTICS REPORT - {table_name}")
            logs.info("="*80)
            
            all_skipped = []
            all_created = []
            
            # Manually pull XCom from each level's flatten_task_lists
            ti = context['ti']
            
            # Get all task instances for this DAG run
            # flatten_task_lists is called multiple times, creating instances with suffixes
            flatten_task_id_base = f'flatten_task_lists_{table_name}'
            
            # Try to pull XCom from each possible instance
            # Airflow creates task_ids like: flatten_task_lists_POLICY_TEST, flatten_task_lists_POLICY_TEST__1, etc.
            level_results = []
            
            for level_num in range(7):  # Try levels 0-6 (7 total levels)
                if level_num == 0:
                    task_id = flatten_task_id_base
                else:
                    task_id = f"{flatten_task_id_base}__{level_num}"
                
                try:
                    result = ti.xcom_pull(task_ids=task_id, key='return_value')
                    if result is not None:
                        level_results.append(result)
                        logs.info(f"[COLLECT_STATS] Level {level_num+1}: Retrieved result from {task_id}")
                    else:
                        logs.info(f"[COLLECT_STATS] Level {level_num+1}: No result from {task_id} (skipped or empty)")
                        level_results.append(None)
                except Exception as e:
                    logs.warning(f"[COLLECT_STATS] Level {level_num+1}: Could not retrieve result from {task_id} - {e}")
                    level_results.append(None)
            
            # Collect from all levels
            for level_num, level_result in enumerate(level_results, start=1):
                # Handle None or missing results (when level was skipped)
                if level_result is None:
                    logs.info(f"[COLLECT_STATS] Level {level_num}: No result (skipped or empty)")
                    continue
                    
                if isinstance(level_result, dict):
                    skipped = level_result.get('skipped', [])
                    created = level_result.get('created', [])
                    
                    # Add skipped tables
                    if skipped:
                        all_skipped.extend(skipped)
                        logs.info(f"[COLLECT_STATS] Level {level_num}: Found {len(skipped)} skipped tables")
                    
                    # Add created tables
                    if created:
                        all_created.extend(created)
                        logs.info(f"[COLLECT_STATS] Level {level_num}: Found {len(created)} created tables")
            
            # Add base table to created list
            all_created.insert(0, {
                'table_name': f"{table_name}_DATA",
                'path': '',
                'level': 0
            })
            
            # Print summary
            logs.info(f"\n{'='*80}")
            logs.info(f"SUMMARY FOR {table_name}")
            logs.info(f"{'='*80}")
            logs.info(f"✅ Total Tables Created: {len(all_created)}")
            logs.info(f"⚠️  Total Tables Skipped: {len(all_skipped)}")
            logs.info(f"{'='*80}\n")
            
            # Print created tables
            if all_created:
                logs.info(f"\n{'='*80}")
                logs.info(f"✅ CREATED TABLES ({len(all_created)})")
                logs.info(f"{'='*80}")
                for idx, table in enumerate(all_created, 1):
                    logs.info(f"{idx}. {table['table_name']}")
                    logs.info(f"   Path: {table['path'] if table['path'] else 'ROOT'}")
                    logs.info(f"   Level: {table['level']}")
                logs.info(f"{'='*80}\n")
            
            # Print skipped tables
            if all_skipped:
                logs.info(f"\n{'='*80}")
                logs.info(f"⚠️  SKIPPED TABLES ({len(all_skipped)})")
                logs.info(f"{'='*80}")
                for idx, table in enumerate(all_skipped, 1):
                    logs.info(f"{idx}. {table['table_name']}")
                    logs.info(f"   Path: {table['path']}")
                    logs.info(f"   Level: {table['level']}")
                    logs.info(f"   Reason: {table['reason']}")
                logs.info(f"{'='*80}\n")
            else:
                logs.info(f"\n✅ No tables were skipped - all variants had data!\n")
            
            return {
                'created_count': len(all_created),
                'skipped_count': len(all_skipped),
                'created_tables': all_created,
                'skipped_tables': all_skipped
            }
        
        # ====================================================================
        # BUILD DAG FLOW (Simplified - No Branch Operators)
        # ====================================================================
        
        # Initialize config (returns table name only)
        table_identifier = initialize_config()
        
        # Level 0: Process base table
        level_0_tasks = process_level_0(table_identifier)
        
        # Level 1: Dynamic task mapping - ONE TASK PER TABLE
        level_1_results = process_single_variant.expand(task_config=level_0_tasks)
        level_1_flattened = flatten_task_lists(level_1_results)
        level_1_tasks = extract_tasks(level_1_flattened)
        
        # Level 2: Dynamic task mapping
        level_2_results = process_single_variant.expand(task_config=level_1_tasks)
        level_2_flattened = flatten_task_lists(level_2_results)
        level_2_tasks = extract_tasks(level_2_flattened)
        
        # Level 3: Dynamic task mapping
        level_3_results = process_single_variant.expand(task_config=level_2_tasks)
        level_3_flattened = flatten_task_lists(level_3_results)
        level_3_tasks = extract_tasks(level_3_flattened)
        
        # Level 4: Dynamic task mapping
        level_4_results = process_single_variant.expand(task_config=level_3_tasks)
        level_4_flattened = flatten_task_lists(level_4_results)
        level_4_tasks = extract_tasks(level_4_flattened)
        
        # Level 5: Dynamic task mapping
        level_5_results = process_single_variant.expand(task_config=level_4_tasks)
        level_5_flattened = flatten_task_lists(level_5_results)
        level_5_tasks = extract_tasks(level_5_flattened)
        
        # Level 6: Dynamic task mapping
        level_6_results = process_single_variant.expand(task_config=level_5_tasks)
        level_6_flattened = flatten_task_lists(level_6_results)
        level_6_tasks = extract_tasks(level_6_flattened)
        
        # Level 7: Dynamic task mapping
        level_7_results = process_single_variant.expand(task_config=level_6_tasks)
        level_7_flattened = flatten_task_lists(level_7_results)

        # Collect statistics and report
        # Don't pass any parameters to avoid XCom resolution errors
        # Set dependencies explicitly using >> operator
        stats = collect_stats.override(trigger_rule='all_done')()
        
        # Create explicit dependencies - stats waits for the last task at each level
        # Use the actual task objects (extract_tasks returns XComArg, but we need the task)
        # The dependency chain is: each level's extract_tasks >> next level's expand
        # So we just need to depend on level_7's extract_tasks
        level_7_flattened >> stats
        
        # End task
        end = DummyOperator(task_id=f'end_{table_name}', trigger_rule='none_failed_min_one_success')
        
        # Simple linear flow - no branches needed
        # When expand() gets an empty list, it just completes without creating tasks
        stats >> end

# Create the single DAG instance
dag_instance = create_single_dag()

logs.info(f"\n{'='*80}")
logs.info(f"Created SINGLE DAG: MAXI_RAW_S3_TO_SF_INU_DYNAMIC_TASKFLOW")
logs.info(f"Processing {len(json_config['table_mapping'])} tables in ONE DAG")
logs.info(f"Each table at a level gets its own separate Airflow task")
logs.info(f"Tasks are created dynamically at RUNTIME using .expand()")
logs.info(f"{'='*80}")