from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.models import Variable
import json
import requests
import boto3
from typing import List, Any
import logging as logs
from datetime import datetime , timedelta
import requests
import snowflake.connector
from airflow.hooks.base_hook import BaseHook
import traceback
import pytz
import re
import pytz



class DMSPipelineUtils(object):
    @staticmethod
    def s3_File_Exists(Bucket, Path) -> bool:
        s3 = boto3.resource('s3')
        bucket = s3.Bucket(Bucket)
        Path_Exist = lambda key: bool(list(bucket.objects.filter(Prefix=key)))
        return Path_Exist(Path)

    @staticmethod
    def s3_list_objects(Bucket, Path, MaxKeys = 1000):
        s3 = boto3.client('s3')
        Key = Path.replace("s3://" + Bucket + "/", "")
        s3_list = s3.list_objects_v2(Bucket=Bucket, Prefix=Key, MaxKeys=MaxKeys)
        list_objects = []
        for obj in s3_list['Contents']:
            list_objects.append(obj['Key'])
        return list_objects

    @staticmethod
    def UTCDateTimeNow(date_format = '%Y-%m-%d %H:%M:%S') -> str:
        date = datetime.now(pytz.utc)
        return date.strftime(date_format)

    @staticmethod
    def TimeNow(date_format = '%Y-%m-%d %H:%M:%S') -> str:
        date = datetime.now(tz=pytz.utc)
        date = date.astimezone(pytz.timezone('Asia/Calcutta'))
        return str(date.strftime(date_format))

    @staticmethod
    def removeDoubleSlash(Path:str):
        return Path.replace("//", "/")

    @staticmethod
    def date_diff(start, end, format, buffer=None):
        logs.info(f"Input Format for date difference is {str(format)}")
        start_date = datetime.strptime(start, format)
        logs.info(f"Input start_date - {start_date}")
        if buffer is not None:
            logs.info(f"::::Buffer Time found is {str(buffer)}")
            buffer_dict = dict(buffer)
            start_date = start_date - timedelta(**buffer_dict)

        end_date = datetime.strptime(end, format)
        logs.info(f"start_date - {start_date}")
        logs.info(f"end_date - {end_date}")
        result = []
        current_date = start_date
        while current_date <= end_date:
            if format == '%Y':
                result.append(current_date.year)
                current_date = current_date.replace(year=current_date.year + 1)
            elif format in ('%Y-%m', '%Y/%m', '%Y_%m', '%Y%m'):
                date_object = datetime(current_date.year, current_date.month, 1)
                result.append(date_object.strftime(format))
                year = current_date.year + (current_date.month // 12)
                month = (current_date.month % 12) + 1
                current_date = current_date.replace(year=year, month=month)
            elif format in (
            '%Y-%m-%d', '%Y/%m/%d', '%Y%m%d', '%Y_%m_%d', '%m-%Y-%d', '%d-%m-%Y', '%m/%Y/%d', '%d/%m/%Y', '%m%Y%d',
            '%d%m%Y', '%m_%Y_%d', '%d_%m_%Y'):
                result.append(current_date.strftime(format))
                current_date += timedelta(days=1)
            elif format in ('%Y-%m-%d-%H', '%Y/%m/%d/%H', '%Y%m%d%H', '%Y_%m_%d_%H'):
                result.append(current_date.strftime(format))
                current_date += timedelta(hours=1)
            elif format in ('%Y-%m-%d-%H-%M', '%Y/%m/%d/%H/%M', '%Y%m%d%H%M', '%Y_%m_%d_%H_%M'):
                result.append(current_date.strftime(format))
                current_date += timedelta(minutes=1)
            else:
                raise ValueError(f'Format {format} to check difference is not found')
        return result
    

    @staticmethod
    def pipeline_run_detail(DAG_ID,task_id, pipeline_run_id, execution_engine_id,event_type,task_status):
            
        req = json.dumps({
            "pipeline_id": DAG_ID,
            "pipeline_run_id": pipeline_run_id,
            "task_run_id": task_id,
            "execution_engine_id": execution_engine_id,
            "execution_engine": "SNOWFLAKE",
            "event_type": event_type,
            "task_status": task_status,
            "event_timestamp": datetime.today().strftime('%Y-%m-%dT%H:%M:%S.%fZ')
        })
        backend_url = Variable.get("APP_BASE_URL")
        table_sync_log_endpoint = "/pipeline-run-detail"
        sync_log_api = backend_url + table_sync_log_endpoint
        headers = {'Content-Type': 'application/json'}
        print(f'State API url ::: {sync_log_api}')
        print(f'Request body ::: {req}')
        try:        
            requests.request("POST", sync_log_api, headers=headers, data=req)        
        except Exception as e:
            print(f"Log API not working - {e}")
            pass
        
    @staticmethod        
    def table_sync_log(task_id, pipeline_run_id, execution_engine_id, source_name, storage_level, record_count, update_count, insert_count, delete_count):
            
        req = json.dumps({
            "task_id": task_id,
            "execution_engine_id": execution_engine_id,
            "pipeline_run_id": pipeline_run_id,
            "table_name": source_name,
            "storage_level": storage_level,
            "record_count": record_count,
            "update_count": update_count,
            "insert_count": insert_count,
            "delete_count": delete_count
        })   
        
        backend_url = Variable.get("APP_BASE_URL")
        table_sync_log_endpoint = "/table-sync-log"
        sync_log_api = backend_url + table_sync_log_endpoint

        headers = {'Content-Type': 'application/json'}
        print(f'State API url ::: {sync_log_api}')
        print(f'Request body ::: {req}')
        try:
            
            requests.request("POST", sync_log_api, headers=headers, data=req)
            
        except Exception as e:
            print(f"Log API not working - {e}")
            pass




    @staticmethod
    def s3_list_objects_paginator(Bucket, Path, LastUtcTime = None,CurrentUtcTime=None):
        if CurrentUtcTime is None:
            CurrentUtcTime = DMSPipelineUtils.UTCDateTimeNow(date_format = '%Y-%m-%d %H:%M:%S')
        
        s3 = boto3.client('s3')
        s3_paginator = s3.get_paginator('list_objects_v2')
        Key = Path.replace("s3://" + Bucket + "/", "")
        s3_iterator = s3_paginator.paginate(Bucket=Bucket, Prefix=Key)
        s3_obj_dict = {}
        #logs.info(f's3_obj_dict is {s3_obj_dict}')
        for page in s3_iterator:
            if 'Contents' in page:
                for obj in page['Contents']:
                    last_modified = obj['LastModified'].replace(tzinfo=None)
                    if LastUtcTime < last_modified <= CurrentUtcTime :
                        s3_obj_dict[obj['Key']] = str(last_modified)
        
        return s3_obj_dict


    @staticmethod
    def getDMSS3Files(Bucket, Path, LastRun, CurrentRun, BatchSize,FileFormat='parquet', Mode = 'CDC', BufferTimeInDays =  7):
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
            checkPartition = True
            path_dict = {}
            date_format = '%Y-%m-%d %H:%M:%S'
            format = {
                    'YMD_SLASH':'%Y/%m/%d','YMDH_SLASH':'%Y/%m/%d','YM_SLASH':'%Y/%m','MYD_SLASH':'%m/%Y/%d',
                    'DMY_SLASH':'%d/%m/%Y','YMD_DASH': '%Y-%m-%d','YMDH_DASH': '%Y-%m-%d','YM_DASH': '%Y-%m',
                    'MYD_DASH': '%m-%Y-%d', 'DMY_DASH': '%d-%m-%Y','YMD_UNDERSCORE': '%Y_%m_%d',
                    'YMDH_UNDERSCORE': '%Y_%m_%d','YM_UNDERSCORE': '%Y_%m','MYD_UNDERSCORE': '%m_%Y_%d',
                    'DMY_UNDERSCORE': '%d_%m_%Y','YMD_NONE': '%Y%m%d','YMDH_NONE': '%Y%m%d','YM_NONE': '%Y%m',
                    'MYD_NONE': '%m%Y%d','DMY_NONE': '%d%m%Y','NO_PARTITION':'%Y%m%d'
                    }
            buffer_time= {
                    'YMD':{"days":BufferTimeInDays},
                    'YMDH':{"days":BufferTimeInDays},
                    'YM':{"days":BufferTimeInDays},
                    'MYD':{"days":BufferTimeInDays},
                    'DMY':{"days":BufferTimeInDays},
                    'NO': None
                    }
            if LastRun is None:
                checkPartition = False

            last_utc_dt_str = str(LastRun)
            current_utc_dt_str = str(CurrentRun)
            if ((last_utc_dt_str is None) or (str(last_utc_dt_str).upper() == 'NONE')):
                last_utc_dt_str = '2024-01-01 00:00:00'
            last_utc_dt = datetime.strptime(str(last_utc_dt_str), date_format)
            current_utc_dt = datetime.strptime(str(current_utc_dt_str), date_format)
            logs.info(f'Last Run in UTC {last_utc_dt} and Current Run in UTC {current_utc_dt}')
            logs.info(f'Checking Path for Key {Key}')

            if DMSPipelineUtils.s3_File_Exists(Bucket, Key):
                logs.info(f'Path Key {Key} Exists.')
                if ((Mode == 'CDC') and (checkPartition)):
                    logs.info(f'The Mode is CDC with checkPartition is Enabled.')
                    DMSObjs = DMSPipelineUtils.s3_list_objects(Bucket=Bucket, Path=Key, MaxKeys=100)
                    objs = [x for x in DMSObjs if (not str(x).upper().split('/')[-1].startswith('LOAD000')) and (not str(x).endswith('/')) and (str(x).upper().split('/')[-1].startswith('202'))]
                    if ((len(DMSObjs) > 0) and (len(objs) == 0)):
                        msg = f"No New CDC Files found except LOAD File (Full Load)"
                        logs.warning(msg)
                        return 'Success', [], {}
                    obj = objs[0]
                    obj_key = str(obj).replace(Key, '')
                    obj_key = str('/') + obj_key if not str(obj_key).startswith('/') else str(obj_key)
                    logs.info(f'Validating Partition with the sample Path {obj_key}')
                    dmsFileNamePattern = f'20[2-4][0-9](0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])-[0-9]+(_FILE\d+)?[(.)]{str("Parquet").lower()}'
                    Partitions = {
                        'YM_SLASH': f"/20[2-4][0-9]\/(0[1-9]|1[0-2])\/{dmsFileNamePattern}",
                        'YMD_SLASH': f'/20[2-4][0-9]\/(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01])\/{dmsFileNamePattern}',
                        'YMDH_SLASH': f'/20[2-4][0-9]\/(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01])\/([01][0-9]|2[0-3])\/{dmsFileNamePattern}',
                        'MYD_SLASH':f'/(0[1-9]|1[0-2])\/20[2-4][0-9]\/(0[1-9]|[12][0-9]|3[01])/{dmsFileNamePattern}',
                        'DMY_SLASH':f'/(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/20[2-4][0-9]\/{dmsFileNamePattern}',
                        'YM_DASH': f"/20[2-4][0-9]-(0[1-9]|1[0-2])/{dmsFileNamePattern}",
                        'YMD_DASH': f'/20[2-4][0-9]-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])/{dmsFileNamePattern}',
                        'YMDH_DASH': f'/20[2-4][0-9]-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])-([01][0-9]|2[0-3])\/{dmsFileNamePattern}',
                        'MYD_DASH': f'/(0[1-9]|1[0-2])-20[2-4][0-9]-(0[1-9]|[12][0-9]|3[01])/{dmsFileNamePattern}',
                        'DMY_DASH': f'/(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-20[2-4][0-9]\/{dmsFileNamePattern}',
                        'YM_UNDERSCORE': f"/20[2-4][0-9]_(0[1-9]|1[0-2])/{dmsFileNamePattern}",
                        'YMD_UNDERSCORE': f'/20[2-4][0-9]_(0[1-9]|1[0-2])_(0[1-9]|[12][0-9]|3[01])/{dmsFileNamePattern}',
                        'YMDH_UNDERSCORE': f'/20[2-4][0-9]_(0[1-9]|1[0-2])_(0[1-9]|[12][0-9]|3[01])_([01][0-9]|2[0-3])\/{dmsFileNamePattern}',
                        'MYD_UNDERSCORE': f'/(0[1-9]|1[0-2])_20[2-4][0-9]_(0[1-9]|[12][0-9]|3[01])/{dmsFileNamePattern}',
                        'DMY_UNDERSCORE': f'/(0[1-9]|[12][0-9]|3[01])_(0[1-9]|1[0-2])_20[2-4][0-9]\/{dmsFileNamePattern}',
                        'YM_NONE': f"/20[2-4][0-9](0[1-9]|1[0-2])/{dmsFileNamePattern}",
                        'YMD_NONE': f'/20[2-4][0-9](0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])/{dmsFileNamePattern}',
                        'YMDH_NONE': f'/20[2-4][0-9](0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])([01][0-9]|2[0-3])\/{dmsFileNamePattern}',
                        'MYD_NONE': f'/(0[1-9]|1[0-2])20[2-4][0-9](0[1-9]|[12][0-9]|3[01])/{dmsFileNamePattern}',
                        'DMY_NONE': f'/(0[1-9]|[12][0-9]|3[01])(0[1-9]|1[0-2])20[2-4][0-9]\/{dmsFileNamePattern}',
                        'NO_PARTITION':f'/{dmsFileNamePattern}'
                    }
                    PartitionType = None
                    for part in Partitions:
                        logs.info(f'Validating with Schema {part}')
                        if bool(re.fullmatch(Partitions[part], obj_key)):
                            PartitionType = part
                            break
                    logs.info(f'Final Path Schema found {str(PartitionType)}')
                    if str(PartitionType).upper() in Partitions.keys():
                        partList = DMSPipelineUtils.date_diff(str(last_utc_dt.strftime(format[PartitionType])),
                                            str(current_utc_dt.strftime(format[PartitionType])),
                                            format[PartitionType],
                                            buffer_time[(str(PartitionType).upper().split('_')[0])])
                        for part in partList:
                            if str(PartitionType).upper() == 'NO_PARTITION':
                                Prefix = DMSPipelineUtils.removeDoubleSlash(Key + '/' + str(part) + '-')
                            else:
                                Prefix = DMSPipelineUtils.removeDoubleSlash(Key + '/' + str(part) + '/')
                            s3_obj_dict = DMSPipelineUtils.s3_list_objects_paginator(Bucket=Bucket, Path=Prefix,
                                                                        LastUtcTime=last_utc_dt,
                                                                        CurrentUtcTime=current_utc_dt)
                            if len(s3_obj_dict) > 0:                                               
                                objDict = {x: y for x, y in s3_obj_dict.items() if x is not None and str(Prefix) != str(x) and str(x).endswith(str(FileFormat).lower())}
                                logs.info(f'''Path extracted for Prefix {str(Prefix)} are {str(objDict)}''')
                                path_dict = {**path_dict , **objDict}
                            else:
                                continue
                elif (Mode == 'CDC'):
                    logs.info(f'The Mode is CDC with checkPartition is Disabled.')
                    logs.info('::::Date Partition over source does not exits......')
                    Prefix = Key + str('/') if not str(Key).endswith('/') else str(Key)
                    logs.info(f'The final Prefix is {Prefix}')
                    s3_obj_dict = DMSPipelineUtils.s3_list_objects_paginator(Bucket=Bucket, Path=Prefix, LastUtcTime=last_utc_dt,
                                                                CurrentUtcTime=current_utc_dt)
                    
                    if len(s3_obj_dict) > 0:                                               
                        objDict = {x: y for x, y in s3_obj_dict.items() if x is not None and str(Prefix) != str(x) and str(x).endswith(str(FileFormat).lower())}
                        logs.info(f'''Path extracted for Prefix {str(Prefix)} are {str(objDict)}''')
                        path_dict = {**path_dict , **objDict}
                    else:
                        return 'Success',  {}, {}                       
                else:
                    logs.info(f'The Mode is FRO......')
                    Prefix = Key + str('/') if not str(Key).endswith('/') else str(Key)
                    s3_obj_dict = DMSPipelineUtils.s3_list_objects_paginator(Bucket=Bucket, Path=Prefix, LastUtcTime=last_utc_dt, CurrentUtcTime=current_utc_dt)
                    objDict = {x: y for x, y in s3_obj_dict.items() if x is not None and str(Prefix) != str(x) and str(x).endswith(str(FileFormat).lower()) and str(x).split("/")[-1].startswith('LOAD')}
                    path_dict = {**path_dict , **objDict}
                logs.info(f'''Path extracted are {str(path_dict)}''')              
            else:
                msg = f"Key {Key} path does not exists. "
                logs.error(msg)
                return 'Failed - ' + str(msg), {}, {}

            
            path_dict = {DMSPipelineUtils.removeDoubleSlash(str(x).replace(Key, '')): y for x, y in path_dict.items() if x is not None}
            logs.info(f'Final Source S3 Unsorted Paths are {path_dict}')
            sorted_path_dict = dict(sorted(path_dict.items()))
            logs.info(f'Final Source S3 Sorted Paths are {sorted_path_dict}')

            batch_dict = {}
            batch_modified_time = {}

            objCount = len(sorted_path_dict)
            if objCount > 0:
                batch_count = round(objCount/BatchSize[Mode.upper()])
                logs.info(f"Total no .of files: {objCount}")
                allRunningObj = list(sorted_path_dict.keys())
                for x in range(batch_count+1):
                    if len(allRunningObj) > 0:
                        batch_dict[f'Batch_{x+1}'] = allRunningObj[0:BatchSize[Mode.upper()]]
                        size = len(allRunningObj)
                        allRunningObj = allRunningObj[BatchSize[Mode.upper()]:size]
                        batch_modified_time[f'Batch_{x+1}']  =  str(sorted_path_dict[batch_dict[f'Batch_{x+1}'][-1]])
                    else:
                        break
                logs.info(f"::::Batch Splits are {batch_dict}")
                logs.info(f"::::Batch max last modified times are {batch_modified_time}")
                return 'Success', batch_dict, batch_modified_time
            else:
                return 'Success', {}, {}

            return 'Success', batch_dict
        except Exception as e:
            logs.error(e)
            return 'Failed - ' + str(e), {}, {}

    @staticmethod
    def getPreviousStatesUsingAPI(pipeline_name, Table, watermark_columns):
        
        base_url = Variable.get("APP_BASE_URL")
        get_state_api = f"{base_url}/get-sync-state"

        if get_state_api is not None and get_state_api.strip() != '':  # if state already exists in tables
            request_body = {"pipeline": f"{pipeline_name}", "table_name": Table,
                            "column_name": watermark_columns}
            logs.info(f'State API url ::: {get_state_api}')
            logs.info(f'Request body ::: {request_body}')

            state = requests.request("POST", get_state_api, headers={'Content-Type': 'application/json'},
                                        json=request_body)
            response_status = state.status_code  # 200
            response_body = state.json()  # state
            logs.info(f'State API response ::: {state}')
            logs.info(f'State API status ::: {response_status}')
            logs.info(f'State API body ::: {response_body}')
            # logs.info(f'State API text ::: {state.text}')
            if response_status == 200:
                status = response_body['status']
                if status == 200:
                    # state found
                    edl_state = response_body['data']['column_value']
                    logs.info(f"Get State  response :::: {state}")
                    FullLoad = False
            elif response_status == 404:
                # full load
                edl_state = None
                FullLoad = True
            else:
                raise ValueError(f"Http non 200 Status code : {response_status}")

        else:
            raise ValueError("API URL could not be set")

        return  edl_state

    def setStatesUsingAPI(pipeline_name, Table, watermark_columns, updated_watermark_col_val):
        """
        Write current job states into configure s3 state path.
        :param Config: Config object of properties file.
        :param df: Input state dataframe.The dataframe that return from getCurrentStates method.

        :return status ['Success'|'Failed']
        """

        base_url = Variable.get("APP_BASE_URL")
        set_state_api = f"{base_url}/set-sync-state"

        execution_timestamp = datetime.now().isoformat()

        request_body = {
            "pipeline": f"{pipeline_name}"
            , "table_name": Table
            , "column_name": watermark_columns
            , "column_value": str(updated_watermark_col_val)
            , "execution_timestamp":str(execution_timestamp)
        }
        logs.info(f'State API url ::: {set_state_api}')
        logs.info(f"Request ::: {request_body}")

        state = requests.request("POST", set_state_api, headers={'Content-Type': 'application/json'}, json=request_body)
        
        logs.info(f"status ::: {state.status_code}")
        if state.status_code == 201:
            logs.info("State set successfully")
            print("Success")
            return "Success"
        else:
            try:
                error_message = state.json().get('message')
            except json.JSONDecodeError:
                error_message = state.text
            
            logs.error(f"State set unsuccessful. Error message: {error_message}")
            return f"Failed - Could not set state. Error message: {error_message}"