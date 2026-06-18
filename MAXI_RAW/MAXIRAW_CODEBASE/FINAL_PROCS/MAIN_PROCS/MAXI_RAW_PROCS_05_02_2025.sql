//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                        -- FUNCTIONS --
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE OR REPLACE FUNCTION EMPOWER_DB.UTILS.CONVERT_PATH_TO_SNAKE_CASE("INPUT_PATH" VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
AS '
    if (!INPUT_PATH) return null;
    
    // Replace dots with underscores first
    var result = INPUT_PATH.replace(/\\./g, ''_'');
    
    // Convert camelCase to snake_case
    result = result.replace(/([a-z])([A-Z])/g, ''$1_$2'');
    
    // Convert to lowercase
    result = result.toLowerCase();
    
    return result;
';

----------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION EMPOWER_DB.UTILS.CONVERT_COL_NAME_TO_SNAKE_CASE("INPUT_STRING" VARCHAR(16777216))
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
AS '
    // NEW: Check if input contains bracket notation like ["..."] or [''...'']
    var bracketMatch = INPUT_STRING.match(/[\\["''"]([^"''\\]]+)["''"]\\]/);
    
    var input_str = INPUT_STRING;
    
    if (bracketMatch) {
        // Extract the content inside brackets and use it as input
        input_str = bracketMatch[1];
    }
    
    // EXISTING LOGIC: Standard conversion (now applied to bracket content too)
    // Step 1: Handle consecutive uppercase letters
    input_str = input_str.charAt(0).toUpperCase() + input_str.slice(1);
    var modifiedString = input_str.replace(/([A-Z])/g, ''_$1'');
    modifiedString = modifiedString.replace('' '', ''_'');
 
    // Step 2: Replace single uppercase letters with underscores
    modifiedString = modifiedString.replace(/([A-Z])/g, ''_$1'');
    modifiedString = modifiedString.replace(/_(.)_/g, ''$1'').replace(/(_\\w)(_)(\\w)/g, function(match, p1, p2, p3) {
        return p1 + p3;
    });
 
    // Step 3: Convert the entire string to lowercase
    var snake_case_string = modifiedString.toLowerCase();
    var finalstr = snake_case_string.replace(/__+/g, ''_'').replace(/^_/, '''').replace(/(_\\w)$/g, function(match) {
        return match.replace(''_'', '''');
    });
 
    // Step 4: Remove any leading underscores
    finalstr = finalstr.replace(/\\s+/g, ''_'') // Replace spaces with underscores
            .replace(/[^a-z0-9_]/g, ''_'')     // Replace special chars with underscore
            .replace(/_+/g, ''_'')             // Remove consecutive underscores
            .replace(/^_+|_+$/g, '''');        // Remove leading/trailing underscores
 
    // Step 5: Remove prefix "str_" if present
    if (finalstr.startsWith(''str_'')) {
        finalstr = finalstr.substring(4);
    }
 
    return finalstr;
';

--------------------------------------------------------------------------------------------------------------------------------

? BAGIC_PREPROD_CURATED_DB.UTILS.GET_DTYPE

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                        -- PROCEDURES --
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CREATE OR REPLACE PROCEDURE EMPOWER_DB.UTILS.APPLY_DRIFT_CORRECTIONS()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
    var processedCount = 0;
    var errorCount = 0;
    var results = [];

    
    // Get all pending drift corrections grouped by table
    var queueSql = `
    SELECT 
        MIRROR_DB,
        MIRROR_SCHEMA,
        MIRROR_TABLE,
        META_TABLE,
        OBJECT_AGG(KEY_PATH::VARCHAR, NEW_DTYPE::VARIANT) AS PATH_TYPE_MAP,
        OBJECT_AGG(COLUMN_NAME::VARCHAR, NEW_DTYPE::VARIANT) AS COL_TYPE_MAP
    FROM EMPOWER_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS
    WHERE STATUS = ''PENDING''
    GROUP BY MIRROR_DB, MIRROR_SCHEMA, MIRROR_TABLE, META_TABLE
    ORDER BY MIRROR_TABLE
`;
    
    var queue = snowflake.execute({ sqlText: queueSql });
    
    while (queue.next()) {
        var mirDb = queue.getColumnValue(1);
        var mirSchema = queue.getColumnValue(2);
        var mirTable = queue.getColumnValue(3);
        var metaTable = queue.getColumnValue(4);
        var pathTypeMap = queue.getColumnValue(5);
        var colTypeMap = queue.getColumnValue(6);
        
        try {
            var fullMetaTable = mirDb + ''.'' + mirSchema + ''.'' + metaTable;
            var fullTable = mirDb + ''.'' + mirSchema + ''.'' + mirTable;
            
            // Update metadata table
            var pathMap = pathTypeMap;
            var driftCount = 0;
            for (var path in pathMap) {
                var newType = pathMap[path];
                var metaSql = `
                    UPDATE ${fullMetaTable}
                    SET key_type = ''${newType}''
                    WHERE key_path = ''${path}''
                `;
                snowflake.execute({ sqlText: metaSql });
                driftCount++;
            }
            
            // Get column info and build SELECT list
            var colSql = `
                SELECT column_name, data_type
                FROM ${mirDb}.information_schema.columns
                WHERE UPPER(table_schema) = UPPER(''${mirSchema}'')
                AND UPPER(table_name) = UPPER(''${mirTable}'')
                ORDER BY ordinal_position
            `;
            var rs = snowflake.execute({ sqlText: colSql });
            var selectList = [];
            var colMap = colTypeMap;
            
            while (rs.next()) {
                var col = rs.getColumnValue(1);
                var oldType = rs.getColumnValue(2);
                
                if (colMap[col]) {
                    var newType = colMap[col];
                    if (oldType === ''VARIANT'') {
                        selectList.push("CASE WHEN " + col + " IS NULL THEN NULL ELSE " + col + "::STRING END::" + newType + " AS " + col);
                    } else {
                        selectList.push(col + "::" + newType + " AS " + col);
                    }
                } else {
                    selectList.push(col);
                }
            }
            
            // Clone and recreate table
            var ts = new Date().toISOString().replace(/[-:TZ.]/g,'''');
            var cloneTable = mirDb + ''.'' + mirSchema + ''.'' + mirTable + ''_CLONE_'' + ts;
            var cloneSql = "CREATE TABLE " + cloneTable + " CLONE " + fullTable;
            snowflake.execute({ sqlText: cloneSql });
            
            var recreateSql = "CREATE OR REPLACE TABLE " + fullTable + " AS SELECT " + selectList.join('','') + " FROM " + fullTable;
            snowflake.execute({ sqlText: recreateSql });
            
            // Update drift correction status
            var updateSql = `
                UPDATE EMPOWER_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS
                SET STATUS = ''SUCCESS'',
                    PROCESSED_AT = CURRENT_TIMESTAMP()
                WHERE MIRROR_DB = ''${mirDb}''
                  AND MIRROR_SCHEMA = ''${mirSchema}''
                  AND MIRROR_TABLE = ''${mirTable}''
                  AND STATUS = ''PENDING''
            `;
            snowflake.execute({ sqlText: updateSql });
            
            processedCount++;
            results.push("Fixed: " + mirTable + " (" + driftCount + " drift(s))");
            
        } catch (err) {
            var errorMsg = err.message.replace(/''/g, "''''");
            var updateSql = `
                UPDATE EMPOWER_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS
                SET STATUS = ''ERROR'',
                    ERROR_MESSAGE = ''${errorMsg}'',
                    PROCESSED_AT = CURRENT_TIMESTAMP()
                WHERE MIRROR_DB = ''${mirDb}''
                  AND MIRROR_SCHEMA = ''${mirSchema}''
                  AND MIRROR_TABLE = ''${mirTable}''
                  AND STATUS = ''PENDING''
            `;
            snowflake.execute({ sqlText: updateSql });
            
            errorCount++;
            results.push("Error on " + mirTable + ": " + err.message);
        }
    }
    
    var summary = `
    === Drift Correction Summary ===
    Tables Fixed: ${processedCount}
    Tables Failed: ${errorCount}
    Total: ${processedCount + errorCount}
    
    Details:
    ${results.join(''\\\\n'')}
    
      IMPORTANT: Re-enable schedules for fixed tables in MASTER_TABLE_INFO
    `;
    
    return summary;
';

CREATE OR REPLACE TABLE EMPOWER_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS CLONE EMPOWER_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS;

--------------------------------------------------------------------------------------------------------------------------------

-- BAGIC_PREPROD_CURATED_DB.UTILS.CREATE_VARIANT_METADATA_TABLES_PROC
-- BAGIC_PREPROD_CURATED_DB.UTILS.FIND_MALFORMED_JSON_FILES

--------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE EMPOWER_DB.UTILS.MANAGE_MASTER_CONFIG("OPERATION" VARCHAR, "CONFIG_JSON" VARCHAR DEFAULT null)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
    // Helper function to log operations
    function logOperation(operation, status, recordCount, affectedTables, errorMsg) {
        try {
            var logSql = `
                INSERT INTO EMPOWER_DB.UTILS.MASTER_JSON_SYNC_LOG
                (OPERATION_TYPE, SYNC_STATUS, RECORD_COUNT, AFFECTED_TABLES, ERROR_MESSAGE, EXECUTED_BY)
                VALUES (?, ?, ?, ?, ?, CURRENT_USER())
            `;
            var stmt = snowflake.createStatement({
                sqlText: logSql,
                binds: [operation, status, recordCount, affectedTables, errorMsg]
            });
            stmt.execute();
        } catch (e) {
            // Silent fail for logging errors
        }
    }

    // Helper function to sync JSON to S3
    function syncJsonToS3() {
        try {
            var copySql = `
                COPY INTO @s3_master_json_stg/MAXIMUS_RAW_MASTER.json
                FROM (
                    SELECT ARRAY_AGG(json_obj) AS master_config
                    FROM (
                        SELECT OBJECT_CONSTRUCT(
                            ''INCLUDE'', INCLUDE,
                            ''CRON'', CRON,
                            ''PIPELINE_NAME'', PIPELINE_NAME,
                            ''MIRROR_TABLE'', MIRROR_TABLE,
                            ''MIRROR_SCHEMA'', MIRROR_SCHEMA,
                            ''MIRROR_DB'', MIRROR_DB,
                            ''STAGING_TABLE'', STAGING_TABLE,
                            ''STAGING_SCHEMA'', STAGING_SCHEMA,
                            ''STAGING_DB'', STAGING_DB,
                            ''BUCKET'', BUCKET,
                            ''FOREIGN_KEY'', FOREIGN_KEY,
                            ''VARIANT_KEYS'', VARIANT_KEYS,
                            ''SYNC_TYPE'', SYNC_TYPE,
                            ''FILE_FORMAT'', FILE_FORMAT,
                            ''S3_PATH'', S3_PATH
                        ) AS json_obj
                        FROM EMPOWER_DB.UTILS.MASTER_TABLE_INFO
                        WHERE INCLUDE = ''Y'' 
                          AND IS_ACTIVE = TRUE
                    )
                    WHERE json_obj <> OBJECT_CONSTRUCT()
                )
                FILE_FORMAT = (TYPE = JSON COMPRESSION = NONE)
                OVERWRITE = TRUE
                SINGLE = TRUE
                HEADER = FALSE
            `;
            
            snowflake.execute({ sqlText: copySql });
            
            // Get count of synced records
            var countSql = `
                SELECT COUNT(*) AS cnt 
                FROM EMPOWER_DB.UTILS.MASTER_TABLE_INFO 
                WHERE INCLUDE = ''Y'' AND IS_ACTIVE = TRUE
            `;
            var countResult = snowflake.execute({ sqlText: countSql });
            countResult.next();
            
            return countResult.getColumnValue(1);
        } catch (e) {
            throw new Error("JSON Sync Failed: " + e.message);
        }
    }

    // Validate operation
    var validOps = [''INSERT'', ''UPDATE'', ''DELETE'', ''BULK_UPSERT'', ''SYNC_JSON''];
    if (!validOps.includes(OPERATION.toUpperCase())) {
        return ''ERROR: Invalid operation. Valid operations: INSERT, UPDATE, DELETE, BULK_UPSERT, SYNC_JSON'';
    }

    var operation = OPERATION.toUpperCase();
    var affectedTables = '''';
    var recordCount = 0;

    try {
        // ============================================
        // OPERATION 1: INSERT - Add New Configuration
        // ============================================
        if (operation === ''INSERT'') {
            if (!CONFIG_JSON) {
                return ''ERROR: CONFIG_JSON is required for INSERT operation'';
            }

            var configObj = JSON.parse(CONFIG_JSON);
            
            var insertSql = `
                INSERT INTO EMPOWER_DB.UTILS.MASTER_TABLE_INFO (
                    INCLUDE, CRON, PIPELINE_NAME, MIRROR_TABLE, MIRROR_SCHEMA, MIRROR_DB,
                    STAGING_TABLE, STAGING_SCHEMA, STAGING_DB, BUCKET, FOREIGN_KEY,
                    VARIANT_KEYS, SYNC_TYPE, FILE_FORMAT, S3_PATH, COMMENTS,
                    CREATED_BY, CREATED_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_DATE, IS_ACTIVE
                )
                SELECT 
                    COALESCE(f.value:"INCLUDE"::STRING, ''Y''),
                    f.value:"CRON"::STRING,
                    f.value:"PIPELINE_NAME"::STRING,
                    f.value:"MIRROR_TABLE"::STRING,
                    f.value:"MIRROR_SCHEMA"::STRING,
                    f.value:"MIRROR_DB"::STRING,
                    f.value:"STAGING_TABLE"::STRING,
                    f.value:"STAGING_SCHEMA"::STRING,
                    f.value:"STAGING_DB"::STRING,
                    f.value:"BUCKET"::STRING,
                    f.value:"FOREIGN_KEY"::STRING,
                    f.value:"VARIANT_KEYS"::STRING,
                    f.value:"SYNC_TYPE"::STRING,
                    f.value:"FILE_FORMAT"::STRING,
                    f.value:"S3_PATH"::STRING,
                    f.value:"COMMENTS"::STRING,
                    CURRENT_USER(),
                    CURRENT_TIMESTAMP(),
                    CURRENT_USER(),
                    CURRENT_TIMESTAMP(),
                    TRUE
                FROM TABLE(FLATTEN(INPUT => PARSE_JSON(?)))f
            `;
            
            var stmt = snowflake.createStatement({
                sqlText: insertSql,
                binds: [CONFIG_JSON]
            });
            var result = stmt.execute();
            recordCount = result.getNumRowsAffected();
            affectedTables = configObj.STAGING_TABLE || ''Multiple'';
            
            // Auto-sync JSON after insert
            syncJsonToS3();
            
            logOperation(''INSERT'', ''SUCCESS'', recordCount, affectedTables, null);
            return `SUCCESS: ${recordCount} record(s) inserted and JSON synced.`;
        }

        // ============================================
        // OPERATION 2: UPDATE - Modify Existing Configuration
        // ============================================
        else if (operation === ''UPDATE'') {
            if (!CONFIG_JSON) {
                return ''ERROR: CONFIG_JSON is required for UPDATE operation'';
            }

            var configObj = JSON.parse(CONFIG_JSON);
            
            if (!configObj.STAGING_TABLE) {
                return ''ERROR: STAGING_TABLE is required in CONFIG_JSON for UPDATE'';
            }

            // Build dynamic UPDATE statement
            var updateFields = [];
            var bindValues = [];
            
            var fieldMapping = {
                ''INCLUDE'': ''INCLUDE'',
                ''CRON'': ''CRON'',
                ''PIPELINE_NAME'': ''PIPELINE_NAME'',
                ''MIRROR_TABLE'': ''MIRROR_TABLE'',
                ''MIRROR_SCHEMA'': ''MIRROR_SCHEMA'',
                ''MIRROR_DB'': ''MIRROR_DB'',
                ''STAGING_SCHEMA'': ''STAGING_SCHEMA'',
                ''STAGING_DB'': ''STAGING_DB'',
                ''BUCKET'': ''BUCKET'',
                ''FOREIGN_KEY'': ''FOREIGN_KEY'',
                ''VARIANT_KEYS'': ''VARIANT_KEYS'',
                ''SYNC_TYPE'': ''SYNC_TYPE'',
                ''FILE_FORMAT'': ''FILE_FORMAT'',
                ''S3_PATH'': ''S3_PATH'',
                ''COMMENTS'': ''COMMENTS''
            };

            for (var key in configObj) {
                if (key !== ''STAGING_TABLE'' && fieldMapping[key]) {
                    updateFields.push(fieldMapping[key] + '' = ?'');
                    bindValues.push(configObj[key]);
                }
            }

            if (updateFields.length === 0) {
                return ''ERROR: No fields to update in CONFIG_JSON'';
            }

            updateFields.push(''LAST_MODIFIED_BY = CURRENT_USER()'');
            updateFields.push(''LAST_MODIFIED_DATE = CURRENT_TIMESTAMP()'');

            var updateSql = `
                UPDATE EMPOWER_DB.UTILS.MASTER_TABLE_INFO
                SET ${updateFields.join('', '')}
                WHERE STAGING_TABLE = ?
            `;
            
            bindValues.push(configObj.STAGING_TABLE);

            var stmt = snowflake.createStatement({
                sqlText: updateSql,
                binds: bindValues
            });
            var result = stmt.execute();
            recordCount = result.getNumRowsAffected();
            affectedTables = configObj.STAGING_TABLE;

            if (recordCount === 0) {
                return `WARNING: No records updated. STAGING_TABLE ''${configObj.STAGING_TABLE}'' not found.`;
            }

            // Auto-sync JSON after update
            syncJsonToS3();
            
            logOperation(''UPDATE'', ''SUCCESS'', recordCount, affectedTables, null);
            return `SUCCESS: ${recordCount} record(s) updated and JSON synced.`;
        }

        // ============================================
        // OPERATION 3: DELETE - Soft Delete Configuration
        // ============================================
        else if (operation === ''DELETE'') {
            if (!CONFIG_JSON) {
                return ''ERROR: CONFIG_JSON with STAGING_TABLE is required for DELETE'';
            }

            var configObj = JSON.parse(CONFIG_JSON);
            
            if (!configObj.STAGING_TABLE) {
                return ''ERROR: STAGING_TABLE is required in CONFIG_JSON for DELETE'';
            }

            var deleteSql = `
                UPDATE EMPOWER_DB.UTILS.MASTER_TABLE_INFO
                SET IS_ACTIVE = FALSE,
                    INCLUDE = ''N'',
                    LAST_MODIFIED_BY = CURRENT_USER(),
                    LAST_MODIFIED_DATE = CURRENT_TIMESTAMP(),
                    COMMENTS = COALESCE(COMMENTS || '' | '', '''') || ''Deleted on '' || CURRENT_TIMESTAMP()
                WHERE STAGING_TABLE = ?
            `;

            var stmt = snowflake.createStatement({
                sqlText: deleteSql,
                binds: [configObj.STAGING_TABLE]
            });
            var result = stmt.execute();
            recordCount = result.getNumRowsAffected();
            affectedTables = configObj.STAGING_TABLE;

            if (recordCount === 0) {
                return `WARNING: No records deleted. STAGING_TABLE ''${configObj.STAGING_TABLE}'' not found.`;
            }

            // Auto-sync JSON after delete
            syncJsonToS3();
            
            logOperation(''DELETE'', ''SUCCESS'', recordCount, affectedTables, null);
            return `SUCCESS: ${recordCount} record(s) soft-deleted and JSON synced.`;
        }

        // ============================================
        // OPERATION 4: BULK_UPSERT - Insert or Update Multiple
        // ============================================
        else if (operation === ''BULK_UPSERT'') {
            if (!CONFIG_JSON) {
                return ''ERROR: CONFIG_JSON is required for BULK_UPSERT'';
            }

            var mergeSql = `
                MERGE INTO EMPOWER_DB.UTILS.MASTER_TABLE_INFO t
                USING (
                    SELECT 
                        COALESCE(f.value:"INCLUDE"::STRING, ''Y'') AS INCLUDE,
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
                        f.value:"COMMENTS"::STRING AS COMMENTS
                    FROM TABLE(FLATTEN(INPUT => PARSE_JSON(?))) f
                ) s
                ON t.STAGING_TABLE = s.STAGING_TABLE
                
                WHEN MATCHED AND s.INCLUDE = ''N'' THEN UPDATE SET
                    INCLUDE = ''N'',
                    IS_ACTIVE = FALSE,
                    LAST_MODIFIED_BY = CURRENT_USER(),
                    LAST_MODIFIED_DATE = CURRENT_TIMESTAMP(),
                    COMMENTS = COALESCE(s.COMMENTS, t.COMMENTS)
                    
                WHEN MATCHED AND s.INCLUDE = ''Y'' THEN UPDATE SET
                    INCLUDE = s.INCLUDE,
                    CRON = COALESCE(s.CRON, t.CRON),
                    PIPELINE_NAME = COALESCE(s.PIPELINE_NAME, t.PIPELINE_NAME),
                    MIRROR_TABLE = COALESCE(s.MIRROR_TABLE, t.MIRROR_TABLE),
                    MIRROR_SCHEMA = COALESCE(s.MIRROR_SCHEMA, t.MIRROR_SCHEMA),
                    MIRROR_DB = COALESCE(s.MIRROR_DB, t.MIRROR_DB),
                    STAGING_SCHEMA = COALESCE(s.STAGING_SCHEMA, t.STAGING_SCHEMA),
                    STAGING_DB = COALESCE(s.STAGING_DB, t.STAGING_DB),
                    BUCKET = COALESCE(s.BUCKET, t.BUCKET),
                    FOREIGN_KEY = COALESCE(s.FOREIGN_KEY, t.FOREIGN_KEY),
                    VARIANT_KEYS = COALESCE(s.VARIANT_KEYS, t.VARIANT_KEYS),
                    SYNC_TYPE = COALESCE(s.SYNC_TYPE, t.SYNC_TYPE),
                    FILE_FORMAT = COALESCE(s.FILE_FORMAT, t.FILE_FORMAT),
                    S3_PATH = COALESCE(s.S3_PATH, t.S3_PATH),
                    COMMENTS = COALESCE(s.COMMENTS, t.COMMENTS),
                    IS_ACTIVE = TRUE,
                    LAST_MODIFIED_BY = CURRENT_USER(),
                    LAST_MODIFIED_DATE = CURRENT_TIMESTAMP()
                    
                WHEN NOT MATCHED AND s.INCLUDE = ''Y'' THEN INSERT (
                    INCLUDE, CRON, PIPELINE_NAME, MIRROR_TABLE, MIRROR_SCHEMA, MIRROR_DB,
                    STAGING_TABLE, STAGING_SCHEMA, STAGING_DB, BUCKET, FOREIGN_KEY,
                    VARIANT_KEYS, SYNC_TYPE, FILE_FORMAT, S3_PATH, COMMENTS,
                    CREATED_BY, CREATED_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_DATE, IS_ACTIVE
                ) VALUES (
                    s.INCLUDE, s.CRON, s.PIPELINE_NAME, s.MIRROR_TABLE, s.MIRROR_SCHEMA, s.MIRROR_DB,
                    s.STAGING_TABLE, s.STAGING_SCHEMA, s.STAGING_DB, s.BUCKET, s.FOREIGN_KEY,
                    s.VARIANT_KEYS, s.SYNC_TYPE, s.FILE_FORMAT, s.S3_PATH, s.COMMENTS,
                    CURRENT_USER(), CURRENT_TIMESTAMP(), CURRENT_USER(), CURRENT_TIMESTAMP(), TRUE
                )
            `;

            var stmt = snowflake.createStatement({
                sqlText: mergeSql,
                binds: [CONFIG_JSON]
            });
            var result = stmt.execute();
            recordCount = result.getNumRowsAffected();
            affectedTables = ''Multiple'';

            // Auto-sync JSON after bulk upsert
            var syncCount = syncJsonToS3();
            
            logOperation(''BULK_UPSERT'', ''SUCCESS'', recordCount, affectedTables, null);
            return `SUCCESS: ${recordCount} record(s) upserted, ${syncCount} active configs in JSON.`;
        }

        // ============================================
        // OPERATION 5: SYNC_JSON - Manual JSON Sync
        // ============================================
        else if (operation === ''SYNC_JSON'') {
            var syncCount = syncJsonToS3();
            
            logOperation(''SYNC_JSON'', ''SUCCESS'', syncCount, ''N/A'', null);
            return `SUCCESS: Master JSON synced with ${syncCount} active configurations.`;
        }

    } catch (err) {
        logOperation(operation, ''ERROR'', 0, affectedTables, err.message);
        return ''ERROR: '' + err.message;
    }
';

CREATE TABLE EMPOWER_DB.UTILS.MASTER_TABLE_INFO CLONE BAGIC_PREPROD_CURATED_DB.UTILS.MASTER_TABLE_INFO;

CREATE TABLE EMPOWER_DB.UTILS.MASTER_JSON_SYNC_LOG CLONE BAGIC_PREPROD_CURATED_DB.UTILS.MASTER_JSON_SYNC_LOG;

--------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE EMPOWER_DB.UTILS.MAXI_RAW_FLATTEN_VARIANT_TABLE_PROC("SRC_DB" VARCHAR(16777216), "SRC_SCHEMA" VARCHAR(16777216), "SRC_TABLE" VARCHAR(16777216), "TARGET_DB" VARCHAR(16777216), "TARGET_SCHEMA" VARCHAR(16777216), "VARIANT_COLUMN" VARCHAR(16777216), "VARIANT_KEYS" VARCHAR(16777216), "RELATION_COLUMNS" VARCHAR(16777216), "FOREIGN_KEY_PATH" VARCHAR(16777216), "MAIN_TABLE_NAME" VARCHAR(16777216), "METADATA_FLAG" BOOLEAN DEFAULT FALSE, "SYNC_MODE" VARCHAR(10) DEFAULT 'FRO', "RECURSIVE_FLAG" BOOLEAN DEFAULT FALSE, "VARIANT_PATH" VARCHAR(16777216) DEFAULT '', "CUSTOM_PARENT" VARCHAR(16777216) DEFAULT 'null')
RETURNS VARIANT
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
    // --- SYNC_MODE LOGIC ---
    var tbl_typ = '''';
    var temp_tbl_prfx = '''';
    var meta_prfx = '''';
    if (SYNC_MODE && SYNC_MODE.toUpperCase() === ''INU'') {
        tbl_typ = ''TEMPORARY'';
        temp_tbl_prfx = ''_TEMP'';
        if(RECURSIVE_FLAG === 1){
            meta_prfx = ''_TEMP'';
        };
    };
    var custom_parent_tbl = CUSTOM_PARENT;    
    if(custom_parent_tbl.toLowerCase() === ''null''){
            custom_parent_tbl = SRC_TABLE;
    };
    
    // Step 1: Retrieve the keys from the VARIANT column
    var variant_keys_list = VARIANT_KEYS.split('','');
    var variant_input_keys_list = variant_keys_list.map(x => x.trim());
    var variant_lvl_map = {};
    var variant_tbl_map = {};
    var variant_alias_map = {};
    var output = {};
    var fromQry = '''';
    const removeDuplicatesFromList = arr => [...new Set(arr)];
    const removeDuplicates = obj => Object.fromEntries(Object.entries(obj).map(([k, v]) => [k, [...new Set(v.split('','').map(e => e.trim()))].join('','')]));
    // --- METADATA TABLE LOGIC ---
    var resultSet;
    var metadata_diff_str = '''';

    // --- BASE TABLE CHECK IN INU ---
    if(!RECURSIVE_FLAG && SYNC_MODE === "INU"){
        var mode_changed = false;
        var original_sync_mode = SYNC_MODE;
        var base_table_status = {};
        var base_tbl_full_name = `${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_${VARIANT_COLUMN}`;
        var check_base_tbl_qry = `
            SELECT 1 
            FROM ${base_tbl_full_name}
            LIMIT 1
        `;
        var tbl_exists = false;
        try {
            var stmt_check = snowflake.createStatement({ sqlText: check_base_tbl_qry });
            var rs_check = stmt_check.execute();
            tbl_exists = true;
        } catch(e){
            tbl_exists = false;
        }
            
        base_table_status = {
            checked: true,
            table_name: base_tbl_full_name,
            exists: tbl_exists,
            original_mode: original_sync_mode,
            check_timestamp: new Date().toISOString()
        };
            
            if (!tbl_exists) {
                mode_changed = true;
                var changed_mode = "FRO";
                
                base_table_status.action = "MODE_SWITCHED_TO_FRO";
                base_table_status.reason = "Base table does not exist, performing full refresh";
                base_table_status.changed_mode = changed_mode;
                var stg_tbl_name = SRC_TABLE.replace(/_VW$/i, "");
                // Call the procedure in FRO mode to create base table
                var callFRO = `CALL EMPOWER_DB.UTILS.WRAPPER_PROC(
                    ''${SRC_DB}'', ''${SRC_SCHEMA}'', ''${stg_tbl_name}'', 
                    ''${TARGET_DB}'', ''${TARGET_SCHEMA}'', ''${VARIANT_COLUMN}'', 
                    '''', ''${RELATION_COLUMNS}'', ''${FOREIGN_KEY_PATH}'', 
                     ${METADATA_FLAG}, ''${changed_mode}''
                )`;
                
                base_table_status.fro_call_sql = callFRO;
                
                try {
                    var stmt_fro = snowflake.createStatement({ sqlText: callFRO });
                    var rs_fro = stmt_fro.execute();
                    
                    if (rs_fro.next()) {
                        var fro_output = rs_fro.getColumnValue(1);
                        base_table_status.fro_result = "SUCCESS";
                    }
                    
                    // Now table exists, can proceed with original INU logic
                    base_table_status.post_fro_status = "Base table created successfully, proceeding with INU mode";
                    
                } catch (fro_err) {
                    base_table_status.fro_result = "FAILED";
                    base_table_status.fro_error = fro_err.message;
                    
                    var errorWithStatus = {
                        error: "Failed to create base table in FRO mode: " + fro_err.message,
                        base_table_status: base_table_status
                    };
                    throw new Error(JSON.stringify(errorWithStatus));
                }
            }
            else if(tbl_exists){
                base_table_status.action = "Base table exists, proceeding with INU mode";
            }
        output["base_table_check"] = base_table_status;
    } 

    if (METADATA_FLAG === 1) {
        // Call the new metadata handler procedure
        var callMeta = `CALL EMPOWER_DB.UTILS.MAXI_RAW_METADATA_TABLE_PROC(
                ''${SRC_DB}'', ''${SRC_SCHEMA}'', ''${SRC_TABLE}'', ''${TARGET_DB}'', ''${TARGET_SCHEMA}'', ''${VARIANT_COLUMN}'', ''${SYNC_MODE}'', ''${RECURSIVE_FLAG}''
            )`;
        var stmtMeta = snowflake.createStatement({ sqlText: callMeta });
        var rsMeta = stmtMeta.execute();
        if (rsMeta.next()) {
            metadata_diff_str = rsMeta.getColumnValue(1);
        }
    }
    
    // If not using metadata logic, still try to query the metadata table (legacy behavior)    
    var query = `SELECT * FROM ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_METADATA${meta_prfx} ORDER BY LOWER(key_path)`;
    var stmt = snowflake.createStatement({ sqlText: query });
    resultSet = stmt.execute();

    /** Determine the target table name for the variant data.
     It first attempts to retrieve a pre-defined table name from a metadata table,
     falling back to a default name if the metadata entry doesn''t exist or is null.
    */
    var temp_tbl_name = '''';
    var get_temp_tbl_name = `SELECT TABLE_NAME FROM ${TARGET_DB}.${TARGET_SCHEMA}.${MAIN_TABLE_NAME}_METADATA WHERE KEY_PATH = ''${VARIANT_PATH}'';`;
    var stmt = snowflake.createStatement({ sqlText: get_temp_tbl_name });
    var res = stmt.execute();
    
    if (res.next()) {
        var tbl_name = res.getColumnValue(1); 
        // Check if the retrieved value is null
        if (tbl_name !== null) {
            temp_tbl_name = tbl_name;
        } else {
            temp_tbl_name = `${SRC_TABLE}_${VARIANT_COLUMN}`;
        }
    } else {
        // This block is for when no rows are returned at all
        temp_tbl_name = `${SRC_TABLE}_${VARIANT_COLUMN}`;
    }

    var jsonKeysDType = {};
    var jsonKeysAlias = {};
    var jsonKeysPath = {};
    var jsonKeysPathLevel = {};
    var tableQryMap = {};
    var inputColTypeSet = new Set();
    var flattenRequired = ''N'';
    while (resultSet.next()) {
        var colType = resultSet.getColumnValue(1);
        var path = resultSet.getColumnValue(2);
        var key = resultSet.getColumnValue(3);
        var dtype = resultSet.getColumnValue(4);
        var lvl = resultSet.getColumnValue(6);
        var alias = resultSet.getColumnValue(5);
        var dtypeList = dtype.split('','').map(x => x.trim().toUpperCase());        
        dtypeList = removeDuplicatesFromList(dtypeList);
        if (dtypeList.length > 1) {
            dtype = ''VARIANT'';
        }
        inputColTypeSet.add(colType);
        jsonKeysDType[path] = dtype;
        jsonKeysPath[path] = key;
        jsonKeysPathLevel[path] = lvl;
        jsonKeysAlias[path] = alias;
    }
    if (variant_input_keys_list.length > 0) {
        for (var p = 0; p < variant_input_keys_list.length; p++){
            var path = variant_input_keys_list[p];
            path = path.replace(/"/g, "''");
            if (jsonKeysDType[path] === ''VARIANT'') {
                lvl = jsonKeysPathLevel[path];
                for (var i = 0; i <= lvl; i++){
                    var kn = path.split(''.'');
                    var kk = kn.slice(0, i+1).join(''.'');

                    variant_alias_map[kk] = jsonKeysAlias[kk];
                    if (variant_lvl_map.hasOwnProperty(i)) {
                        variant_lvl_map[i] = variant_lvl_map[i] + '','' + kk;
                    } else {
                        variant_lvl_map[i] = kk;
                    }
                    if (i === 0) {
                        variant_tbl_map[kk] = VARIANT_COLUMN;
                    } else {
                        var c = kn.slice(0,i);
                        var t = c.join(''_'');
                        variant_tbl_map[kk] = t;
                    }
                }
            }
        }
    }

    variant_lvl_map = removeDuplicates(variant_lvl_map);
    variant_tbl_map = removeDuplicates(variant_tbl_map);
    variant_alias_map = removeDuplicates(variant_alias_map);

    var inputColTypeArr = Array.from(inputColTypeSet);
    for (var i = 0; i < inputColTypeArr.length; i++){
        if (inputColTypeArr.includes(''ARRAY'')) {
            flattenRequired = ''Y'';
        }
    }

    // Step 2: Dynamically generate column projections with type inference and casting
    
    var columns = [];
    // Always include RELATION_COLUMNS if present
    if (RELATION_COLUMNS.trim() != '''') {
        columns.push(`${RELATION_COLUMNS}`);
    } 

    // change
    // Add foreign_key and root_hash column logic only if not already present in RELATION_COLUMNS
    var relColsLower = RELATION_COLUMNS.trim().toLowerCase();
   if (!relColsLower.includes(''foreign_key'')) {
    var foreignKeyCol = '''';
    if (FOREIGN_KEY_PATH && FOREIGN_KEY_PATH.trim() !== '''') {
        if (flattenRequired === ''Y'') {
            foreignKeyCol = `f.value:${FOREIGN_KEY_PATH}::VARCHAR AS foreign_key`;
        } else {
            foreignKeyCol = `t.${VARIANT_COLUMN}:${FOREIGN_KEY_PATH}::VARCHAR AS foreign_key`;
        }
    } else {
        foreignKeyCol = `NULL AS foreign_key`;
    }
    columns.push(foreignKeyCol);
}

    if (!relColsLower.includes(''root_hash'')) {
        var rootHashCol = `HASH(t.${VARIANT_COLUMN}) AS root_hash`;
        columns.push(rootHashCol);
    }

    for (var kpath in jsonKeysDType) {
        if (jsonKeysDType.hasOwnProperty(kpath) && jsonKeysPathLevel[kpath] === 0) {
            if (flattenRequired === ''Y''){
                var vr_col = ''f.value'';
            } else {
                var vr_col = `t.${VARIANT_COLUMN}`;
            }
            var k = jsonKeysPath[kpath];
            var v = jsonKeysDType[kpath];
            var col_name = jsonKeysAlias[kpath];

            // Handle keys with square brackets
            if (k.includes(''['') && k.includes('']'')) {
                // Check if it''s a quoted string like [''Query Details''] or numeric like [0]
                if (k.includes("''")) {
                    // Remove [''...''] and wrap in double quotes
                    k = k.replace(/\\[''/g, '''').replace(/''\\]/g, '''');
                    k = `"${k}"`;
                }
                // Numeric index like [0] stays as is
            }
            
            columns.push(`${vr_col}:${k}::${v} AS "${col_name}"`);
        }
    }
    columns.push(`HASH(t.${VARIANT_COLUMN}) as key_hash`);
    var hashCols = columns.filter(c => 
    !c.toUpperCase().includes(''INC_JOB_CREATED_AT'') &&
    !c.toUpperCase().includes(''INC_JOB_ID'') &&
    !c.toUpperCase().includes(''FILE_NAME'') &&
    !c.toUpperCase().includes(''FILE_TIMESTAMP'') &&
    !c.toUpperCase().includes(''ROOT_HASH'') &&
    !c.toUpperCase().includes(''KEY_HASH'') 
    );
    columns.push(`HASH(${hashCols.map(c => c.split('' AS '')[0]).join('', '')}) AS record_hash`);
    columns.push(`t.${VARIANT_COLUMN}`);
    columns.push(`CURRENT_TIMESTAMP AS REC_REFRESH_AT`);
    columns.push(`CURRENT_USER AS REC_REFRESHED_BY`);
    /**columns.push(`UUID_STRING() AS BATCH_ID`); **/


    // Step 3: Construct and return the final query with dynamic casting
    var finalTableQuery = '''';
    var res1 = '''';
    var temp = temp_tbl_prfx;
    var finalQuery = '''';
    //flag logic
    if(RECURSIVE_FLAG && SYNC_MODE.toUpperCase() === ''INU'' ){
        try {
            // Try to create table,  will fail if exists
            temp_tbl_prfx = '''';
            /** Dynamically builds the FROM clause.
            This logic is crucial for handling recursive calls and ensuring the correct parent table is used.
            It checks the `RECURSIVE_FLAG` to decide whether to query the original source table (for the initial call)
            or a temporary parent table (identified by `_temp` prefix) during subsequent recursive calls for nested data.
            It also adds a `LATERAL FLATTEN` clause when `flattenRequired` is true to process arrays within the variant data.
            */
            if (flattenRequired === ''Y'') {
                    fromQry = `FROM ${SRC_DB}.${SRC_SCHEMA}.${custom_parent_tbl}${temp_tbl_prfx} t, LATERAL FLATTEN(input => t.${VARIANT_COLUMN}) f`; 
            } else {
                    fromQry = `FROM ${SRC_DB}.${SRC_SCHEMA}.${custom_parent_tbl}${temp_tbl_prfx} t`;
            }
            finalQuery = `SELECT ${columns.join('', '')}, ''${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE}'' AS parent_table_name ${fromQry}`;
            finalTableQuery = `CREATE TABLE  ${TARGET_DB}.${TARGET_SCHEMA}.${temp_tbl_name} AS ${finalQuery};`;
            stmt = snowflake.createStatement({ sqlText: finalTableQuery });
            res1 = stmt.execute();
            // If table is created from above query then creates it temp table with current view
            temp_tbl_prfx = temp;
            if (flattenRequired === ''Y'') {
                    fromQry = `FROM ${SRC_DB}.${SRC_SCHEMA}.${custom_parent_tbl}${temp_tbl_prfx} t, LATERAL FLATTEN(input => t.${VARIANT_COLUMN}) f`;
            } else {
                    fromQry = `FROM ${SRC_DB}.${SRC_SCHEMA}.${custom_parent_tbl}${temp_tbl_prfx} t`;
            }
            finalQuery = `SELECT ${columns.join('', '')}, ''${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE}'' AS parent_table_name ${fromQry}`;
            finalTableQuery = `CREATE OR REPLACE ${tbl_typ} TABLE ${TARGET_DB}.${TARGET_SCHEMA}.${temp_tbl_name}${temp_tbl_prfx} AS ${finalQuery};`;
            stmt = snowflake.createStatement({ sqlText: finalTableQuery });
           // output[TARGET_DB + ''.'' + TARGET_SCHEMA + ''.'' + temp_tbl_name + temp_tbl_prfx] = finalTableQuery;
            res1 = stmt.execute();
        } catch (err) {
            // Table already exists so creating temparary table for it for upsert later.
            temp_tbl_prfx = temp;
            if (flattenRequired === ''Y'') {
                    fromQry = `FROM ${SRC_DB}.${SRC_SCHEMA}.${custom_parent_tbl}${temp_tbl_prfx} t, LATERAL FLATTEN(input => t.${VARIANT_COLUMN}) f`;
            } else {
                    fromQry = `FROM ${SRC_DB}.${SRC_SCHEMA}.${custom_parent_tbl}${temp_tbl_prfx} t`;
            }
            finalQuery = `SELECT ${columns.join('', '')}, ''${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE}'' AS parent_table_name ${fromQry}`;
            finalTableQuery = `CREATE OR REPLACE ${tbl_typ} TABLE ${TARGET_DB}.${TARGET_SCHEMA}.${temp_tbl_name}${temp_tbl_prfx} AS ${finalQuery};`;
            stmt = snowflake.createStatement({ sqlText: finalTableQuery });
           // output[TARGET_DB + ''.'' + TARGET_SCHEMA + ''.'' + temp_tbl_name + temp_tbl_prfx] = finalTableQuery;
            res1 = stmt.execute();
        }  
    }else{
            temp_tbl_prfx = temp;
            if (flattenRequired === ''Y'') {
                if (RECURSIVE_FLAG) {
                    fromQry = `FROM ${SRC_DB}.${SRC_SCHEMA}.${custom_parent_tbl}${temp_tbl_prfx} t, LATERAL FLATTEN(input => t.${VARIANT_COLUMN}) f`;
                } else {
                    fromQry = `FROM ${SRC_DB}.${SRC_SCHEMA}.${custom_parent_tbl} t, LATERAL FLATTEN(input => t.${VARIANT_COLUMN}) f`;
                }
            } else {
                if (RECURSIVE_FLAG) {
                    fromQry = `FROM ${SRC_DB}.${SRC_SCHEMA}.${custom_parent_tbl}${temp_tbl_prfx} t`;
                } else {
                    fromQry = `FROM ${SRC_DB}.${SRC_SCHEMA}.${custom_parent_tbl} t`;
                }
            }
            finalQuery = `SELECT ${columns.join('', '')}, ''${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE}'' AS parent_table_name ${fromQry}`;
            finalTableQuery = `CREATE OR REPLACE ${tbl_typ} TABLE ${TARGET_DB}.${TARGET_SCHEMA}.${temp_tbl_name}${temp_tbl_prfx} AS ${finalQuery};`;
            /** For the ''INU'' synchronization mode, temporary tables are created with a ''_temp'' prefix.
            The `temp_tbl_prfx` variable is appended here to ensure the correct naming convention is applied to the output table name.
            */
            //output[TARGET_DB + ''.'' + TARGET_SCHEMA + ''.'' + temp_tbl_name + temp_tbl_prfx] = finalTableQuery;
            stmt = snowflake.createStatement({ sqlText: finalTableQuery });
            var res1 = stmt.execute();
    }   
    
    for (var vcol in variant_lvl_map) {
        var variantColList  = variant_lvl_map[vcol].split('','');
        variantColList = variantColList.map(x => x.trim());
        var test2 = variantPath;
        var variantPath = variantColList[0];
        variantPath = '''';
        for (var i = 0; i < variantColList.length; i++) {
            var col = variantColList[i];
            var col_id = variant_tbl_map[col];
            if (col_id === VARIANT_COLUMN) {
                var nested_src_tbl = `${SRC_TABLE}_${VARIANT_COLUMN}`;
            } else {
                col_id_new = col_id.replace(/''/g, ''"'');
                var qry2 =  `SELECT  EMPOWER_DB.UTILS.convert_col_name_to_snake_case(''${col_id_new}'')`;
                var stmt2 = snowflake.createStatement({ sqlText: qry2 });
                var res2 = stmt2.execute();
                if (res2.next()) {
                    col_id = res2.getColumnValue(1);
                }
                
                var nested_src_tbl = `${SRC_TABLE}_${VARIANT_COLUMN}_${col_id}`;
            }
            var tbl_name = `SELECT TABLE_NAME FROM ${TARGET_DB}.${TARGET_SCHEMA}.${MAIN_TABLE_NAME}_METADATA WHERE KEY_PATH = ''${test2}'';`;
            var stmt = snowflake.createStatement({ sqlText: tbl_name });
            var res = stmt.execute();
            var c_tbl = null;
            if(res.next()){
                c_tbl = res.getColumnValue(1); 
            }
            // change
            // Always pass down the foreign_key and root_hash columns to child tables
           var nestedColsArr = RELATION_COLUMNS.trim() ? RELATION_COLUMNS.split('','').map(x => x.trim().toLowerCase()) : [];
            var nestedCols = RELATION_COLUMNS.trim() ? RELATION_COLUMNS : '''';
            if (!nestedColsArr.includes(''foreign_key'')) nestedCols += (nestedCols ? '', '' : '''') + ''foreign_key'';
            if (!nestedColsArr.includes(''root_hash'')) nestedCols += (nestedCols ? '', '' : '''') + ''root_hash'';
            nestedCols += (nestedCols ? '', '' : '''') + ''t.key_hash as parent_key_hash, t.record_hash as parent_record_hash'';
            var nestedColsUnique = Array.from(new Set(nestedCols.split('','').map(x => x.trim().toLowerCase()))).join('', '');
            var nestedRelationCols = nestedColsUnique;
            var callRecursive = `CALL EMPOWER_DB.UTILS.MAXI_RAW_FLATTEN_VARIANT_TABLE_PROC(''${TARGET_DB}'',''${TARGET_SCHEMA}'', ''${nested_src_tbl}'', ''${TARGET_DB}'',''${TARGET_SCHEMA}'',''${variant_alias_map[col]}'','''',''${nestedRelationCols}'', NULL, ''${MAIN_TABLE_NAME}'', TRUE, ''${SYNC_MODE}'', ''${METADATA_FLAG}'', ''${variantPath}'', ''${c_tbl}'')`;
            stmt = snowflake.createStatement({ sqlText: callRecursive });
            res1 = stmt.execute();
            if (res1.next()) {
                tblQry = res1.getColumnValue(1);
            }
            finalTableQuery = finalTableQuery + tblQry; 
        }
    }
    if(metadata_diff_str !== ''''){
        output[''metadata_diff''] = metadata_diff_str;
    }
    output["finalTableQuery"] = finalTableQuery;
    return JSON.stringify(output);
';

--------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE EMPOWER_DB.UTILS.NULL_PATHS CLONE BAGIC_PREPROD_CURATED_DB.UTILS.NULL_PATHS;
select * a.b.c;
CREATE OR REPLACE PROCEDURE EMPOWER_DB.UTILS.MAXI_RAW_METADATA_TABLE_PROC("SRC_DB" VARCHAR, "SRC_SCHEMA" VARCHAR, "SRC_TABLE" VARCHAR, "TARGET_DB" VARCHAR, "TARGET_SCHEMA" VARCHAR, "VARIANT_COLUMN" VARCHAR, "SYNC_MODE" VARCHAR, "RECURSIVE_FLAG" BOOLEAN DEFAULT FALSE)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
var metadata_diff_str = '''';

if (SYNC_MODE && SYNC_MODE.toUpperCase() === ''INU'') {
    /**
    Recursive flag True: When a recursive call is made (a nested table), a temporary metadata table is created.
    This is a simple and fast approach since child tables are considered subsets of the main table''s data
    and don''t need a full schema comparison.
    */
    if(RECURSIVE_FLAG === 1){
        var query = `
            CREATE OR REPLACE TEMPORARY TABLE ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_METADATA_TEMP AS
            SELECT
                input_col_type,
                key_path,
                key_name,
                CASE
                    WHEN LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','') = '''' THEN ''NULL''
                    ELSE LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','')
                END as key_type,
                col_alias,
                ARRAY_SIZE(SPLIT(key_path, ''.'')) -1 as level,
                NULL AS TABLE_NAME,
                CURRENT_TIMESTAMP AS UPDATED_AT
            FROM (
                SELECT DISTINCT
                    TYPEOF(t."${VARIANT_COLUMN}") AS input_col_type,
                    REGEXP_REPLACE(REGEXP_REPLACE(f.path, ''\\\\\\\\[[0-9]+\\\\\\\\]'', ''''), ''^\\\\\\\\.'', '''', 1, 1) as key_path,
                    SPLIT_PART(key_path, ''.'', -1) as key_name,
                    CASE
                        WHEN TYPEOF(f.value) IN (''OBJECT'', ''ARRAY'') THEN ''VARIANT''
                        ELSE TYPEOF(f.value)
                    END as key_type,
                    EMPOWER_DB.UTILS.convert_col_name_to_snake_case(key_name) as col_alias
                FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE}_TEMP t,
                LATERAL FLATTEN(PARSE_JSON(TO_VARIANT(t."${VARIANT_COLUMN}")), recursive=>true) f
            ) agg
            WHERE trim(key_path) != ''''
            GROUP BY input_col_type, key_path, key_name, col_alias
            ORDER BY LOWER(key_path)
        `;

        var stmtCreate = snowflake.createStatement({ sqlText: query });
        stmtCreate.execute();

        var checkCountQuery = `SELECT COUNT(*) as cnt FROM ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_METADATA_TEMP`;
        var stmtCheckCount = snowflake.createStatement({ sqlText: checkCountQuery });
        var rsCheckCount = stmtCheckCount.execute();
        var metaRowCount = 0;

        if (rsCheckCount.next()) {
            metaRowCount = rsCheckCount.getColumnValue(1);
        }

        // If no rows found in _TEMP table, try base table without _TEMP suffix
        if (metaRowCount === 0) {
            var createMetaFromBaseQuery = `
                CREATE OR REPLACE TEMPORARY TABLE ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_METADATA_TEMP AS
                SELECT
                    input_col_type,
                    key_path,
                    key_name,
                    CASE
                        WHEN LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','') = '''' THEN ''NULL''
                        ELSE LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','')
                    END as key_type,
                    col_alias,
                    ARRAY_SIZE(SPLIT(key_path, ''.'')) -1 as level,
                    NULL AS TABLE_NAME,
                    CURRENT_TIMESTAMP AS UPDATED_AT
                FROM (
                    SELECT DISTINCT
                        TYPEOF(t."${VARIANT_COLUMN}") AS input_col_type,
                        REGEXP_REPLACE(REGEXP_REPLACE(f.path, ''\\\\\\\\[[0-9]+\\\\\\\\]'', ''''), ''^\\\\\\\\.'', '''', 1, 1) as key_path,
                        SPLIT_PART(key_path, ''.'', -1) as key_name,
                        CASE
                            WHEN TYPEOF(f.value) IN (''OBJECT'', ''ARRAY'') THEN ''VARIANT''
                            ELSE TYPEOF(f.value)
                        END as key_type,
                        EMPOWER_DB.UTILS.convert_col_name_to_snake_case(key_name) as col_alias
                    FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} t,
                    LATERAL FLATTEN(PARSE_JSON(TO_VARIANT(t."${VARIANT_COLUMN}")), recursive=>true) f
                ) agg
                WHERE trim(key_path) != ''''
                GROUP BY input_col_type, key_path, key_name, col_alias
                ORDER BY LOWER(key_path)
            `;

            var stmtCreateMetaBase = snowflake.createStatement({ sqlText: createMetaFromBaseQuery });
            stmtCreateMetaBase.execute();
        }

        var prefixPath = '''';
        var parentMetaTblName = '''';

        var match = SRC_TABLE.match(/(.*)_VW/i);
        if (match) {
            parentMetaTblName = match[1]; // Gets everything before _VW
        }

        var match = SRC_TABLE.match(/_VW_(.*)/i);
        if (match) {
            var afterVW = match[1]; // Gets everything after _VW_

            if (afterVW.toUpperCase() === ''DATA'') {
                extractedTable = ''''; // Empty if only DATA
            }
            // Check if it starts with DATA_ and has something after
            else if (afterVW.match(/^DATA_(.+)/i)) {
                extractedTable = afterVW.replace(/^DATA_/i, ''''); // Remove DATA_ prefix
            }
            // Otherwise, keep as is
            else {
                extractedTable = afterVW;
            }
        }

        // Build prefix path
        if (VARIANT_COLUMN !== ''DATA'') {
            if(extractedTable !== ''''){
                extractedTable = extractedTable + ''_'';
            }
            prefixPath = extractedTable + VARIANT_COLUMN + ''_'';
            prefixPath = prefixPath.toLowerCase();
        }

        var updateMeta = `
            UPDATE ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_METADATA_TEMP temp
            SET key_type = perm.key_type
            FROM ${TARGET_DB}.${TARGET_SCHEMA}.${parentMetaTblName}_VW_METADATA perm
            WHERE CONCAT(''${prefixPath}'', EMPOWER_DB.UTILS.CONVERT_PATH_TO_SNAKE_CASE(temp.key_path))
                  = EMPOWER_DB.UTILS.CONVERT_PATH_TO_SNAKE_CASE(perm.key_path)
              AND temp.key_type = ''NULL''
              AND perm.key_type != ''NULL''
        `;

        var stmtupdateMeta = snowflake.createStatement({ sqlText: updateMeta });
        stmtupdateMeta.execute();

    } else{
        /**
        The drift query uses a detailed GROUP BY clause to prevent rows with the same key but different data types
        from being merged. This allows to accurately detect type inconsistencies, such as a column changing to a VARIANT,
        and handle the situation appropriately to prevent errors.
        */
        var driftQry = `
            SELECT
                input_col_type,
                key_path,
                key_name,
                CASE
                    WHEN LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','') = '''' THEN ''NULL''
                    ELSE LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','')
                END as key_type,
                col_alias,
                ARRAY_SIZE(SPLIT(key_path, ''.'')) -1 AS level,
                NULL AS TABLE_NAME,
                CURRENT_TIMESTAMP AS UPDATED_AT
            FROM (
                SELECT DISTINCT
                    TYPEOF(t."${VARIANT_COLUMN}") AS input_col_type,
                    REGEXP_REPLACE(REGEXP_REPLACE(f.path, ''\\\\\\\\[[0-9]+\\\\\\\\]'', ''''), ''^\\\\\\\\.'', '''', 1, 1) as key_path,
                    SPLIT_PART(key_path, ''.'', -1) AS key_name,
                    CASE
                        WHEN TYPEOF(f.value) IN (''OBJECT'', ''ARRAY'') THEN ''VARIANT''
                        ELSE TYPEOF(f.value)
                    END AS key_type,
                    EMPOWER_DB.UTILS.convert_col_name_to_snake_case(key_name) AS col_alias
                FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} t,
                LATERAL FLATTEN(PARSE_JSON(TO_VARIANT(t."${VARIANT_COLUMN}")), recursive=>true) f
            )
            WHERE TRIM(key_path) <> ''''
            GROUP BY input_col_type, key_path, key_name, col_alias
            ORDER BY LOWER(key_path)`;

        // Check for drift
        var driftCheck = snowflake.createStatement({
            sqlText: `
                SELECT n.key_path, n.key_type, o.key_type, n.col_alias
                FROM (${driftQry}) n
                JOIN ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_metadata o
                  ON n.key_path = o.key_path
                WHERE UPPER(n.key_type) != UPPER(o.key_type)
            `
        }).execute();

        var driftCount = 0;
        var driftDetails = [];
        var driftInserts = [];
        var nullInserts = [];
        var nullCount = 0;

        while (driftCheck.next()) {
            var keyPath = driftCheck.getColumnValue(1);
            var newType = driftCheck.getColumnValue(2);
            var oldType = driftCheck.getColumnValue(3);
            var colAlias = driftCheck.getColumnValue(4);

            // If newType is NULL or NULL_VALUE, keep the oldType
            if (newType == ''NULL'') {
                newType = oldType;
                nullCount += 1;
                nullInserts.push(`
                    (''${keyPath}'', ''${newType}'', ''${colAlias.toUpperCase()}'', ''${SRC_TABLE}'')
                `);
            } else {
                driftCount++;
                driftDetails.push(" " + driftCount + ". Path: " + keyPath + " | Old Type: " + oldType + " | New Type: " + newType);

                // Prepare insert statement for drift correction table
                var metaTableName = SRC_TABLE.toUpperCase().replace(/_VW.*$/, ''_VW_METADATA'');
                driftInserts.push(`
                    (''${TARGET_DB}'', ''${TARGET_SCHEMA}'', ''${SRC_TABLE}'', ''${metaTableName}'', ''${keyPath}'', ''${colAlias.toUpperCase()}'', ''${newType}'')
                `);
            }
        }

        if (nullCount > 0){
            var insertNullSql = `
                INSERT INTO EMPOWER_DB.UTILS.NULL_PATHS
                (KEY_PATH, KEY_TYPE, COL_ALIAS, SRC_TABLE)
                VALUES ${nullInserts.join('','')}
            `;
            snowflake.createStatement({ sqlText: insertNullSql }).execute();
        }

        if (driftCount > 0) {
            // Insert all drifts into correction table
            var insertDriftSql = `
                INSERT INTO EMPOWER_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS
                (MIRROR_DB, MIRROR_SCHEMA, MIRROR_TABLE, META_TABLE, KEY_PATH, COLUMN_NAME, NEW_DTYPE)
                VALUES ${driftInserts.join('','')}
            `;
            snowflake.createStatement({ sqlText: insertDriftSql }).execute();

            // **STOP THE SCHEDULE by clearing CRON in MASTER_TABLE_INFO**
            var stageTableName = SRC_TABLE.toUpperCase().replace(/_VW$/, '''');

            try {
                var stopScheduleSql = `CALL EMPOWER_DB.UTILS.MANAGE_MASTER_CONFIG(
                    ''UPDATE'',
                    ''{ "STAGING_TABLE": "${stageTableName}", "CRON": "", "COMMENTS": "stopped incremental load" }''
                )`;
                var stopResult = snowflake.createStatement({ sqlText: stopScheduleSql }).execute();

                // Mark schedule as stopped in drift table
                var markScheduleSql = `
                    UPDATE EMPOWER_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS
                    SET SCHEDULE_STOPPED = TRUE
                    WHERE MIRROR_TABLE = ''${SRC_TABLE}''
                      AND STATUS = ''PENDING''
                `;
                snowflake.createStatement({ sqlText: markScheduleSql }).execute();

            } catch (schedErr) {
                // If schedule stop fails, log but continue
            }

            throw "Type drift detected in " + driftCount + " field(s): " + driftDetails.join("\\n") +
                  " SCHEDULE STOPPED for table: " + stageTableName +
                  " Drift records created in EMPOWER_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS. " +
                  "Run CALL EMPOWER_DB.UTILS.APPLY_DRIFT_CORRECTIONS() to fix all drifts, But before that make sure the table names are correct here it is created using parent table but you need to update the nested table names where actual colums are present.";
        }

        // Compare new and old metadata, insert new columns if any
        var newMetaQry = `
            SELECT
                input_col_type,
                key_path,
                key_name,
                CASE
                    WHEN LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','') = '''' THEN ''VARIANT''
                    ELSE LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','')
                END as key_type,
                col_alias,
                ARRAY_SIZE(SPLIT(key_path, ''.'')) -1 as level,
                NULL AS TABLE_NAME,
                CURRENT_TIMESTAMP AS UPDATED_AT
            FROM (
                SELECT DISTINCT
                    TYPEOF(t."${VARIANT_COLUMN}") AS input_col_type,
                    REGEXP_REPLACE(REGEXP_REPLACE(f.path, ''\\\\\\\\[[0-9]+\\\\\\\\]'', ''''), ''^\\\\\\\\.'', '''', 1, 1) as key_path,
                    SPLIT_PART(key_path, ''.'', -1) as key_name,
                    CASE
                        WHEN TYPEOF(f.value) IN (''OBJECT'', ''ARRAY'') THEN ''VARIANT''
                        ELSE TYPEOF(f.value)
                    END as key_type,
                    EMPOWER_DB.UTILS.convert_col_name_to_snake_case(key_name) as col_alias
                FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} t,
                LATERAL FLATTEN(PARSE_JSON(TO_VARIANT(t."${VARIANT_COLUMN}")), recursive=>true) f
            )
            WHERE trim(key_path) != ''''
            GROUP BY input_col_type, key_path, key_name, col_alias
            ORDER BY LOWER(key_path)
        `;

        var compareQry = `
            SELECT n.*
            FROM (${newMetaQry}) n
            LEFT JOIN ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_metadata o
              ON n.key_path = o.key_path
            WHERE o.key_path IS NULL
        `;

        var stmtCompare = snowflake.createStatement({ sqlText: compareQry });
        var rsCompare = stmtCompare.execute();

        var insertCount = 0;
        var newKeyPaths = [];

        while (rsCompare.next()) {
            var insertQry = `
                INSERT INTO ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_metadata
                (input_col_type, key_path, key_name, key_type, col_alias, level, table_name, updated_at)
                VALUES (
                    ''${rsCompare.getColumnValue(1)}'',
                    ''${rsCompare.getColumnValue(2)}'',
                    ''${rsCompare.getColumnValue(3)}'',
                    ''${rsCompare.getColumnValue(4)}'',
                    ''${rsCompare.getColumnValue(5)}'',
                    ${rsCompare.getColumnValue(6)},
                    NULL,
                    CURRENT_TIMESTAMP
                )
            `;

            var stmtInsert = snowflake.createStatement({ sqlText: insertQry });
            stmtInsert.execute();

            newKeyPaths.push(rsCompare.getColumnValue(2)); // Collect key_path
            insertCount++;
        }

        if (insertCount > 0) {
            metadata_diff_str = ''New key_path(s) added: '' + newKeyPaths.join('', '');
        } else {
            metadata_diff_str = ''No new columns at any level.'';
        }
    }

    return metadata_diff_str;

} else if (SYNC_MODE && SYNC_MODE.toUpperCase() === ''FRO'') {
    // creates temporary meta data tables for recursive calls.
    var tbl_typ = '''';
    if(RECURSIVE_FLAG === 1){
        tbl_typ = ''TEMPORARY'';
    }

    // Only create/replace the metadata table for FRO
    var query = `
        CREATE OR REPLACE ${tbl_typ} TABLE ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_metadata AS
        SELECT
            input_col_type,
            key_path,
            key_name,
            CASE
                WHEN LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','') = '''' THEN ''VARIANT''
                ELSE LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','')
            END as key_type,
            col_alias,
            ARRAY_SIZE(SPLIT(key_path, ''.'')) -1 as level,
            NULL AS TABLE_NAME,
            CURRENT_TIMESTAMP AS UPDATED_AT
        FROM (
            SELECT DISTINCT
                TYPEOF(t."${VARIANT_COLUMN}") AS input_col_type,
                REGEXP_REPLACE(REGEXP_REPLACE(f.path, ''\\\\\\\\[[0-9]+\\\\\\\\]'', ''''), ''^\\\\\\\\.'', '''', 1, 1) as key_path,
                SPLIT_PART(key_path, ''.'', -1) as key_name,
                CASE
                    WHEN TYPEOF(f.value) IN (''OBJECT'', ''ARRAY'') THEN ''VARIANT''
                    ELSE TYPEOF(f.value)
                END as key_type,
                EMPOWER_DB.UTILS.convert_col_name_to_snake_case(key_name) as col_alias
            FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} t,
            LATERAL FLATTEN(PARSE_JSON(TO_VARIANT(t."${VARIANT_COLUMN}")), recursive=>true) f
        )
        WHERE trim(key_path) != ''''
        GROUP BY input_col_type, key_path, key_name, col_alias
        ORDER BY LOWER(key_path)
    `;

    var stmt = snowflake.createStatement({ sqlText: query });
    stmt.execute();

    var commitStmt = snowflake.createStatement({ sqlText: ''COMMIT'' });
    commitStmt.execute();

    return ''Metadata table created'';

} else {
    return ''Invalid SYNC_MODE'';
}
';

--------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE EMPOWER_DB.UTILS.MAXI_RAW_UPSERT_JOB("SRC_DB" VARCHAR(100), "SRC_SCHEMA" VARCHAR(100), "SOURCE_TABLE" VARCHAR(100), "TARGET_DB" VARCHAR(100), "TARGET_SCHEMA" VARCHAR(100), "TARGET_TABLE" VARCHAR(100), "FOREIGNKEYS" VARIANT)
RETURNS VARCHAR(1000)
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
var sqlStatement, result, table_count;
var src_col_dict = {};
var src_column_lists_value = "";
var allColumnList = [];
var addColumns = "";

try {
    // 1. Check if target table exists
    sqlStatement = `SELECT COUNT(1) 
                    FROM ${TARGET_DB}.INFORMATION_SCHEMA.TABLES 
                    WHERE TABLE_SCHEMA = UPPER(''${TARGET_SCHEMA}'') 
                      AND TABLE_NAME = UPPER(''${TARGET_TABLE}'') 
                      AND TABLE_TYPE = ''BASE TABLE'';`;

    result = snowflake.execute({sqlText: sqlStatement});
    result.next();
    table_count = result.getColumnValue(1);

    if (table_count == 0) {
        throw `Mirror Table ${TARGET_DB}.${TARGET_SCHEMA}.${TARGET_TABLE} does not exist.`;
    }

    // 2. Get SOURCE TABLE column metadata (INCREMENTAL)
    sqlStatement = `SELECT LISTAGG(CONCAT(column_name, '':'', DATA_TYPE), '','') 
                    WITHIN GROUP (ORDER BY ordinal_position)
                    FROM ${SRC_DB}.INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_SCHEMA = UPPER(''${SRC_SCHEMA}'') 
                      AND TABLE_NAME = UPPER(''${SOURCE_TABLE}'');`;

    result = snowflake.execute({sqlText: sqlStatement});
    if (result.next() && result.getColumnValue(1)) {
        result.getColumnValue(1).split(",").forEach(x => {
            let [col, type] = x.split(":");
            src_col_dict[col.trim().toUpperCase()] = type.trim();
        });
        src_column_lists_value = Object.keys(src_col_dict).map(col => `s.${col}`).join(",");
    } else {
        throw `No column data returned for source table using query: ${sqlStatement}`;
    }

    // 3. Get target table column list
    sqlStatement = `SELECT LISTAGG(column_name, '','') 
                    WITHIN GROUP (ORDER BY ordinal_position) 
                    FROM ${TARGET_DB}.INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_SCHEMA = UPPER(''${TARGET_SCHEMA}'') 
                      AND TABLE_NAME = UPPER(''${TARGET_TABLE}'');`;

    result = snowflake.execute({sqlText: sqlStatement});
    if (result.next() && result.getColumnValue(1)) {
        allColumnList = result.getColumnValue(1).split(",").map(col => col.trim().toUpperCase());
    } else {
        throw `No column data returned for target table using query: ${sqlStatement}`;
    }

    // added alter logic here
    // Identify missing columns in target and build ADD COLUMN statement
    for (var col in src_col_dict) {
        if (!allColumnList.includes(col)) {
            addColumns += `${col} ${src_col_dict[col]}, `;
        }
    }
    addColumns = addColumns.replace(/, $/, "");

    // Begin transaction
    snowflake.execute({sqlText: "BEGIN;"});

    // Add missing columns if any
    if (addColumns !== "") {
        sqlStatement = `ALTER TABLE ${TARGET_DB}.${TARGET_SCHEMA}.${TARGET_TABLE} ADD COLUMN ${addColumns};`;
        snowflake.execute({sqlText: sqlStatement});
    }

    // 4. Build join condition dynamically (foreign keys + record hash)
    const joinCondition = [
        ...FOREIGNKEYS.map(fk => `s.${fk} = t.${fk}`),
        "s.RECORD_HASH = t.RECORD_HASH"
    ].join(" AND ");

    const fkList = FOREIGNKEYS.join(", ");

    const nullCheckCol = FOREIGNKEYS[0];  // take first FK column

    sqlStatement = `
        CREATE OR REPLACE TEMPORARY VIEW ${TARGET_DB}.${TARGET_SCHEMA}.${TARGET_TABLE}_view1 AS
        SELECT s.*
        FROM ${SRC_DB}.${SRC_SCHEMA}.${SOURCE_TABLE} s
        LEFT JOIN ${TARGET_DB}.${TARGET_SCHEMA}.${TARGET_TABLE} t
        ON ${joinCondition}
        WHERE t.${nullCheckCol} IS NULL;
    `;
    snowflake.execute({sqlText: sqlStatement});

    // 6. Delete matching records from target (same foreign keys as view1)
    sqlStatement = `
        DELETE FROM ${TARGET_DB}.${TARGET_SCHEMA}.${TARGET_TABLE} t
        WHERE (${fkList}) IN (
            SELECT DISTINCT ${fkList}
            FROM ${TARGET_DB}.${TARGET_SCHEMA}.${TARGET_TABLE}_view1
        );
    `;
    snowflake.execute({sqlText: sqlStatement});

    // 7. Create view2 (records from source that should be inserted)
    sqlStatement = `
        CREATE OR REPLACE TEMPORARY VIEW ${TARGET_DB}.${TARGET_SCHEMA}.${TARGET_TABLE}_view2 AS
        SELECT s.*
        FROM ${SRC_DB}.${SRC_SCHEMA}.${SOURCE_TABLE} s
        WHERE (${fkList}) IN (
            SELECT DISTINCT ${fkList}
            FROM ${TARGET_DB}.${TARGET_SCHEMA}.${TARGET_TABLE}_view1 
        );
    `;
    snowflake.execute({sqlText: sqlStatement});

    // 8. Insert new records from view2 into target
    sqlStatement = `
        INSERT INTO ${TARGET_DB}.${TARGET_SCHEMA}.${TARGET_TABLE}
        SELECT ${allColumnList}
        FROM ${TARGET_DB}.${TARGET_SCHEMA}.${TARGET_TABLE}_view2
    `;
    snowflake.execute({sqlText: sqlStatement});

    // 9. Commit
    snowflake.execute({sqlText: "COMMIT;"});

    return ` Data successfully upserted into ${TARGET_DB}.${TARGET_SCHEMA}.${TARGET_TABLE}`;
} catch (err) {
    snowflake.execute({sqlText: "ROLLBACK;"});
    throw `Error executing procedure: ${err}`;
}
';

--------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE EMPOWER_DB.UTILS.SNOWFLAKE_COPY_INA_STAGING_JOB_MAXI_RAW("DB" VARCHAR(100), "SCHEMANAME" VARCHAR(100), "TABLENAME" VARCHAR(100), "STAGE_NAME" VARCHAR(100), "FILE_FORMAT" VARCHAR(100), "INC_JOB_ID" VARCHAR(100), "FILE_LIST" ARRAY)
RETURNS VARCHAR(1000)
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
var result;
var sqlStatement;

try {
    var auditColumns = {
        "INC_JOB_CREATED_AT": "TO_TIMESTAMP_NTZ(CONVERT_TIMEZONE(''Asia/Kolkata'', CURRENT_TIMESTAMP()))",
        "INC_JOB_CREATED_BY": "CURRENT_USER",
        "INC_JOB_ID": "''" + INC_JOB_ID + "''"
    };

    // Quote all file names for SQL
    var all_files = "";
    for (var i = 0; i < FILE_LIST.length; i++) {
        all_files += "''" + FILE_LIST[i] + "''";
        if (i < FILE_LIST.length - 1) {
            all_files += ", ";
        }
    }

    snowflake.execute({sqlText: "BEGIN TRANSACTION"});

    // Always create table if not exists
    sqlStatement = "CREATE TABLE IF NOT EXISTS " + DB + "." + SCHEMANAME + "." + TABLENAME + " ( " +
        "DATA VARIANT, " +
        "FILE_NAME VARCHAR, " +
        "FILE_TIMESTAMP TIMESTAMP_NTZ, " +
        "INC_JOB_CREATED_AT TIMESTAMP_NTZ, " +
        "INC_JOB_CREATED_BY VARCHAR, " +
        "INC_JOB_ID VARCHAR" + 
        ")";
    snowflake.execute({sqlText: sqlStatement});

    // COPY INTO with actual file metadata timestamp
    sqlStatement = "COPY INTO " + DB + "." + SCHEMANAME + "." + TABLENAME +
        " (DATA, FILE_NAME, FILE_TIMESTAMP, INC_JOB_CREATED_AT, INC_JOB_CREATED_BY, INC_JOB_ID) " +
        "FROM ( " +
        "SELECT TRY_PARSE_JSON($1) AS DATA, " +
        "METADATA$FILENAME AS FILE_NAME, " +
        "METADATA$FILE_LAST_MODIFIED AS FILE_TIMESTAMP, " +
        "TO_TIMESTAMP_NTZ(CONVERT_TIMEZONE(''Asia/Kolkata'', CURRENT_TIMESTAMP())) AS INC_JOB_CREATED_AT, " +
        "CURRENT_USER() AS INC_JOB_CREATED_BY, " +
        "''" + INC_JOB_ID + "'' AS INC_JOB_ID " + 
        "FROM @" + DB + "." + SCHEMANAME + "." + STAGE_NAME + " ) " +
        "FILES = (" + all_files + ") " +
        "FILE_FORMAT = " + FILE_FORMAT + " FORCE = TRUE;";

    snowflake.execute({sqlText: sqlStatement});
    snowflake.execute({sqlText: "COMMIT"});

    return "Data successfully copied with actual S3 file timestamps.";
} catch (err) {
    try {
        snowflake.execute({sqlText: "ROLLBACK"});
    } catch(e) {
        // ignore rollback failure
    }
    throw "Data Copy Failed With Error: " + err + 
          " | Error Code: " + err.code + 
          " | Error State: " + err.state + 
          " | Error Message: " + err.message + 
          " | Query: " + sqlStatement;
}
';

--------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE EMPOWER_DB.UTILS.WRAPPER_PROC("SRC_DB" VARCHAR, "SRC_SCHEMA" VARCHAR, "SRC_TABLE" VARCHAR, "TARGET_DB" VARCHAR, "TARGET_SCHEMA" VARCHAR, "VARIANT_COLUMN" VARCHAR, "VARIANT_KEYS" VARCHAR, "RELATION_COLUMNS" VARCHAR, "FOREIGN_KEY_PATH" VARCHAR, "METADATA_FLAG" BOOLEAN, "SYNC_MODE" VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
var output = {
        metadata_proc: null,
        flatten_proc: null,
        audit_records: null,
        upsert_proc: []
};
try {
    var final_src_table = `${SRC_TABLE}_VW`;
    var BASE_METADATA_FLAG = false;

    if(SYNC_MODE !== "FRO" && SYNC_MODE !== "INU"){
        throw new Error("Invalid SYNC_MODE value: " + SYNC_MODE + ". Allowed values are FRO and INU.");
    }

    if(SYNC_MODE === ''FRO''){
        // CREATE VIEW
        var view_fnl = `
            CREATE OR REPLACE VIEW ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE}_VW AS
            SELECT *
            FROM (
                SELECT s.*,
                       ROW_NUMBER() OVER (
                           PARTITION BY s.DATA:${FOREIGN_KEY_PATH}::STRING
                           ORDER BY s.FILE_TIMESTAMP DESC
                       ) AS rn
                FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} s
                WHERE s.DATA:${FOREIGN_KEY_PATH} IS NOT NULL
            )
            WHERE rn = 1
        `;

        try {
            snowflake.execute({ sqlText: view_fnl });
        } catch (view_err) {
            throw new Error("Failed to create view: " + view_err.message);
        }

        var audit_insert = `
            INSERT INTO BAGIC_PROD_STAGING_DB.MAXI_RAW.STAGING_AUDIT_TABLE (
                TOPIC_NAME,
                FILE_NAME,
                FILE_TIMESTAMP,
                INC_JOB_CREATED_AT,
                INC_JOB_ID
            )
            SELECT 
                ''${SRC_TABLE}'' AS TOPIC_NAME,
                s.FILE_NAME,
                s.FILE_TIMESTAMP,
                s.INC_JOB_CREATED_AT,
                s.INC_JOB_ID
            FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} s
            WHERE s.DATA:${FOREIGN_KEY_PATH} IS NULL
        `;

        try {
            var audit_stmt = snowflake.execute({ sqlText: audit_insert });
            // var rows_inserted = audit_stmt.getNumRowsInserted();
            // output.audit_records = rows_inserted;
        } catch (audit_err) {
            throw new Error("Auditing failed: " + audit_err.message);
        }
        
        
        if(BASE_METADATA_FLAG === 1){
            // CALL METADATA PROCEDURE
            var callMeta = `
                CALL EMPOWER_DB.UTILS.MAXI_RAW_METADATA_TABLE_PROC(
                    ''${SRC_DB}'', ''${SRC_SCHEMA}'', ''${final_src_table}'',
                    ''${TARGET_DB}'', ''${TARGET_SCHEMA}'', ''${VARIANT_COLUMN}'',
                    ''${SYNC_MODE}'', FALSE
                )
            `;
            try {
                var stmtMeta = snowflake.execute({ sqlText: callMeta });
                stmtMeta.next();
                output.metadata_proc = stmtMeta.getColumnValue(1);
            } catch (meta_err) {
                throw new Error("METADATA_TABLE_PROC failed: " + meta_err.message);
                }
        }

        // CALL FLATTEN PROCEDURE
        var flattenCall = `
            CALL EMPOWER_DB.UTILS.MAXI_RAW_FLATTEN_VARIANT_TABLE_PROC(
                ''${SRC_DB}'', ''${SRC_SCHEMA}'', ''${final_src_table}'',
                ''${TARGET_DB}'', ''${TARGET_SCHEMA}'',
                ''${VARIANT_COLUMN}'', ''${VARIANT_KEYS}'', ''${RELATION_COLUMNS}'',
                ''${FOREIGN_KEY_PATH}'', ''${final_src_table}'',
                ${METADATA_FLAG}, ''${SYNC_MODE}'', FALSE, '''', ''null''
            )
        `;
        
        try {
            var stmtFlatten = snowflake.execute({ sqlText: flattenCall });
            stmtFlatten.next();
            output.flatten_proc = stmtFlatten.getColumnValue(1);
        } catch (flatten_err) {
            throw new Error("MAXI_RAW_FLATTEN_VARIANT_TABLE_PROC failed: " + flatten_err.message);
        }

    } else if(SYNC_MODE === ''INU''){
        // CREATE VIEW
        var view_fnl = `
            CREATE OR REPLACE VIEW ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE}_VW AS
            SELECT *
            FROM (
                SELECT s.*,
                       ROW_NUMBER() OVER (
                           PARTITION BY s.DATA:${FOREIGN_KEY_PATH}::STRING
                           ORDER BY s.FILE_TIMESTAMP DESC
                       ) AS rn
                FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} s
                WHERE s.FILE_TIMESTAMP > (SELECT LAST_MODIFIED_DATE FROM EMPOWER_DB.UTILS.MAXI_RAW_STATE_TABLE WHERE TABLE_NAME = ''${SRC_TABLE}'')
                AND s.DATA:${FOREIGN_KEY_PATH} IS NOT NULL
            )
            WHERE rn = 1
        `;
        
        try {
            snowflake.execute({ sqlText: view_fnl });
        } catch (view_err) {
            throw new Error("Failed to create view: " + view_err.message);
        }
        
         var audit_insert = `
            INSERT INTO BAGIC_PROD_STAGING_DB.MAXI_RAW.STAGING_AUDIT_TABLE (
                TOPIC_NAME,
                FILE_NAME,
                FILE_TIMESTAMP,
                INC_JOB_CREATED_AT,
                INC_JOB_ID
            )
            SELECT 
                ''${SRC_TABLE}'' AS TOPIC_NAME,
                s.FILE_NAME,
                s.FILE_TIMESTAMP,
                s.INC_JOB_CREATED_AT,
                s.INC_JOB_ID
            FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} s
            WHERE s.DATA:${FOREIGN_KEY_PATH} IS NULL
        `;

        try {
            var audit_stmt = snowflake.execute({ sqlText: audit_insert });
          //  var rows_inserted = audit_stmt.getNumRowsInserted();
           // output.audit_records = rows_inserted;
        } catch (audit_err) {
            throw new Error("Auditing failed: " + audit_err.message);
        }
        
        final_src_table = `${SRC_TABLE}_VW`;
        // CALL FLATTEN PROCEDURE
        var flattenCall = `
            CALL EMPOWER_DB.UTILS.MAXI_RAW_FLATTEN_VARIANT_TABLE_PROC(
                ''${SRC_DB}'', ''${SRC_SCHEMA}'', ''${final_src_table}'',
                ''${TARGET_DB}'', ''${TARGET_SCHEMA}'',
                ''${VARIANT_COLUMN}'', ''${VARIANT_KEYS}'', ''${RELATION_COLUMNS}'',
                ''${FOREIGN_KEY_PATH}'', ''${final_src_table}'',
                ${METADATA_FLAG}, ''${SYNC_MODE}'', FALSE, '''', ''null''
            )
        `;

         try {
            var stmtFlatten = snowflake.execute({ sqlText: flattenCall });
            stmtFlatten.next();
            var flattenOutput = stmtFlatten.getColumnValue(1);
            output.flatten_proc = JSON.parse(flattenOutput);
        } catch (flatten_err) {
            throw new Error("MAXI_RAW_FLATTEN_VARIANT_TABLE_PROC failed: " + flatten_err.message);
        }

        output.metadata_proc = output.flatten_proc.metadata_diff;

        // EXTRACT TABLES FROM FLATTEN OUTPUT AND UPSERT
        var tables = [];
        var regex = /CREATE\\s+OR\\s+REPLACE\\s+TEMPORARY\\s+TABLE\\s+[\\w.]+\\.([\\w]+)_TEMP\\s+AS/gi;
        var match;
        
        while ((match = regex.exec(output.flatten_proc.finalTableQuery)) !== null) {
            tables.push(match[1]);
        }

        if (tables.length === 0) {
            throw new Error("No temporary tables found in flatten output. Check MAXI_RAW_FLATTEN_VARIANT_TABLE_PROC output.");
        }
        output.tablesForUpsert = tables;
        for (var i = 0; i < tables.length; i++) {
            var targetTable = tables[i];
            var sourceTable = targetTable + "_TEMP";
            var upsertCall = `
                CALL EMPOWER_DB.UTILS.MAXI_RAW_UPSERT_JOB(
                    ''${TARGET_DB}'', ''${TARGET_SCHEMA}'', ''${sourceTable}'',
                    ''${TARGET_DB}'', ''${TARGET_SCHEMA}'', ''${targetTable}'',
                    ARRAY_CONSTRUCT(''FOREIGN_KEY'')
                )
            `;
            
            try {
                var stmtUpsert = snowflake.execute({ sqlText: upsertCall });
                output.upsert_proc.push({
                    table: targetTable,
                    result: "JSON_UPSERT_JOB executed successfully"
                });
            } catch (upsert_err) {
                throw new Error("JSON_UPSERT_JOB failed for table " + targetTable + ": " + upsert_err.message);
            }
        }
    } 

    return JSON.stringify(output);

} catch (err) {
    // Log the error details
    var errorDetails = {
        error_message: err.message,
        error_stack: err.stack,
        partial_output: output,
        sync_mode: SYNC_MODE,
        src_table: SRC_TABLE
    };
    
    // Re-throw the error to mark procedure as FAILED
    throw new Error("WRAPPER_PROC failed: " + JSON.stringify(errorDetails));
}
';

//////////////////////////////////////////////////////////////////////////////////////////////

-- DONE
