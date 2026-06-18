
CREATE PROCEDURE BAGIC_PREPROD_CURATED_DB.UTILS.UPSERT_MASTERJSON_CONFIGS(CONFIGS STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    var configs_json = CONFIGS.toString();

    var merge_sql = `
        MERGE INTO MASTER_TABLE_INFO t
        USING (
            SELECT 
                f.value:"INCLUDE"::STRING AS INCLUDE,
                f.value:"CRON"::STRING AS CRON,
                f.value:"PIPELINE_NAME"::STRING AS PIPELINE_NAME,
                f.value:"MIRROR_TABLE"::STRING AS MIRROR_TABLE,
                f.value:"MIRROR_SCHEMA"::STRING AS MIRROR_SCHEMA,
                f.value:"MIRROR_DB"::STRING AS MIRROR_DB,
                f.value:"STAGING_TABLE"::STRING AS STAGING_TABLE,
                f.value:"STAGING_SCHEMA"::STRING AS STAGING_SCHEMA,
                f.value:"STAGING_DB"::STRING AS STAGING_DB,
                f.value:"BUCKET"::STRING AS BUCKET,
                f.value:"FOREIGN_KEY"::STRING AS FOREIGN_KEY,
                f.value:"VARIANT_KEYS"::STRING AS VARIANT_KEYS,
                f.value:"SYNC_TYPE"::STRING AS SYNC_TYPE,
                f.value:"FILE_FORMAT"::STRING AS FILE_FORMAT,
                f.value:"S3_PATH"::STRING AS S3_PATH,
            FROM TABLE(
                FLATTEN(INPUT => PARSE_JSON('${configs_json}'))
            ) f
        ) s
        ON t.STAGING_TABLE = s.STAGING_TABLE
        
        -- Delete when INCLUDE flag indicates deletion
        WHEN MATCHED AND s.INCLUDE = 'N' THEN DELETE

        -- Update when matched and INCLUDE is Y
        WHEN MATCHED AND s.INCLUDE = 'Y' THEN UPDATE SET
            INCLUDE = s.INCLUDE,
            CRON = s.CRON,
            PIPELINE_NAME = s.PIPELINE_NAME,
            MIRROR_TABLE = s.MIRROR_TABLE,
            MIRROR_SCHEMA = s.MIRROR_SCHEMA,
            MIRROR_DB = s.MIRROR_DB,
            STAGING_TABLE = s.STAGING_TABLE,
            STAGING_SCHEMA = s.STAGING_SCHEMA,
            STAGING_DB = s.STAGING_DB,
            BUCKET = s.BUCKET,
            FOREIGN_KEY = s.FOREIGN_KEY,
            VARIANT_KEYS = s.VARIANT_KEYS,
            SYNC_TYPE = s.SYNC_TYPE,
            FILE_FORMAT = s.FILE_FORMAT,
            S3_PATH = s.S3_PATH,
            LAST_MODIFIED_BY = CURRENT_USER,
            LAST_MODIFIED_DATE = CURRENT_TIMESTAMP
            
        -- Insert only when INCLUDE is Y
        WHEN NOT MATCHED AND s.INCLUDE = 'Y' THEN INSERT VALUES (
            s.INCLUDE, s.CRON, s.PIPELINE_NAME, s.MIRROR_TABLE, s.MIRROR_SCHEMA, s.MIRROR_DB,
            s.STAGING_TABLE, s.STAGING_SCHEMA, s.STAGING_DB, s.BUCKET, s.FOREIGN_KEY, s.VARIANT_KEYS,
            s.SYNC_TYPE, s.FILE_FORMAT, s.S3_PATH, CURRENT_USER, CURRENT_TIMESTAMP
        )
    `;

    snowflake.execute({ sqlText: merge_sql });

    // Refresh master JSON file
    var copy_sql = `
        COPY INTO @s3_master_json_stg/MAXIMUS_RAW_MASTER.json
        FROM (
            SELECT ARRAY_AGG(json_obj)
            FROM (
                SELECT OBJECT_CONSTRUCT(
                    'INCLUDE', INCLUDE,
                    'CRON', CRON,
                    'PIPELINE_NAME', PIPELINE_NAME,
                    'MIRROR_TABLE', MIRROR_TABLE,
                    'MIRROR_SCHEMA', MIRROR_SCHEMA,
                    'MIRROR_DB', MIRROR_DB,
                    'STAGING_TABLE', STAGING_TABLE,
                    'STAGING_SCHEMA', STAGING_SCHEMA,
                    'STAGING_DB', STAGING_DB,
                    'BUCKET', BUCKET,
                    'FOREIGN_KEY', FOREIGN_KEY,
                    'VARIANT_KEYS', VARIANT_KEYS,
                    'SYNC_TYPE', SYNC_TYPE,
                    'FILE_FORMAT', FILE_FORMAT,
                    'S3_PATH', S3_PATH
                ) AS json_obj
                FROM MASTER_TABLE_INFO
            )
            WHERE json_obj IS NOT NULL
              AND json_obj <> OBJECT_CONSTRUCT()   -- removes {}
        )
        FILE_FORMAT = (TYPE = JSON COMPRESSION = NONE)
        OVERWRITE = TRUE
        SINGLE = TRUE;
    `;
    snowflake.execute({ sqlText: copy_sql });
    

    return 'SUCCESS';
$$;
