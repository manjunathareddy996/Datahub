CREATE OR REPLACE PROCEDURE BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_METADATA_TABLE_PROC("SRC_DB" VARCHAR, "SRC_SCHEMA" VARCHAR, "SRC_TABLE" VARCHAR, "TARGET_DB" VARCHAR, "TARGET_SCHEMA" VARCHAR, "VARIANT_COLUMN" VARCHAR, "SYNC_MODE" VARCHAR, "RECURSIVE_FLAG" BOOLEAN DEFAULT FALSE)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
    var metadata_diff_str = '''';
    if (SYNC_MODE && SYNC_MODE.toUpperCase() === ''INU'') {
    /**
    Recursive flag True: When a recursive call is made (a nested table), a temporary metadata table is created.
    This is a simple and fast approach since child tables are considered subsets of the main table''s data and don''t need a full schema comparison.
    */
    if(RECURSIVE_FLAG === 1){
            var query = `
                CREATE OR REPLACE TEMPORARY TABLE ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_metadata AS
            SELECT 
                input_col_type,
                key_path, 
                key_name, 
                CASE
                    WHEN LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','') = ''''
                    THEN ''VARIANT''
                    ELSE LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','')
                END as key_type,
                col_alias, 
                ARRAY_SIZE(SPLIT(key_path, ''.'')) -1 as level,
                NULL AS TABLE_NAME,
                CURRENT_TIMESTAMP AS UPDATED_AT
            FROM (
                SELECT DISTINCT
                    TYPEOF(t.${VARIANT_COLUMN}) AS input_col_type,
                    REGEXP_REPLACE(REGEXP_REPLACE(f.path, ''\\\\\\\\[[0-9]+\\\\\\\\]'', ''''), ''^\\\\\\\\.'', '''', 1, 1) as key_path,
                    SPLIT_PART(key_path, ''.'', -1) as key_name,
                    CASE 
                        WHEN TYPEOF(f.value) IN (''OBJECT'', ''ARRAY'') THEN ''VARIANT''
                        ELSE TYPEOF(f.value)
                    END as key_type,
                     BAGIC_PREPROD_CURATED_DB.UTILS.convert_col_name_to_snake_case(key_name) as col_alias
                FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE}_TEMP t,
                LATERAL FLATTEN(PARSE_JSON(TO_VARIANT(t.${VARIANT_COLUMN})), recursive=>true) f
            ) WHERE trim(key_path) != ''''
            GROUP BY input_col_type, key_path, key_name, col_alias
            ORDER BY LOWER(key_path)
        `;
    
            var stmtCreate = snowflake.createStatement({ sqlText: query });
            stmtCreate.execute();

            var checkCountQuery = `SELECT COUNT(*) as cnt FROM ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_metadata`;
            var stmtCheckCount = snowflake.createStatement({ sqlText: checkCountQuery });
            var rsCheckCount = stmtCheckCount.execute();
            var metaRowCount = 0;
            
            if (rsCheckCount.next()) {
                metaRowCount = rsCheckCount.getColumnValue(1);
            }
            
            // If no rows found in _TEMP table, try base table without _TEMP suffix
            if (metaRowCount === 0) {
                var createMetaFromBaseQuery = `
                    CREATE OR REPLACE TEMPORARY TABLE ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_metadata AS
                    SELECT 
                        input_col_type,
                        key_path, 
                        key_name, 
                        CASE
                            WHEN LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','') = ''''
                            THEN ''VARIANT''
                            ELSE LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','')
                        END as key_type,
                        col_alias, 
                        ARRAY_SIZE(SPLIT(key_path, ''.'')) -1 as level,
                        NULL AS TABLE_NAME,
                        CURRENT_TIMESTAMP AS UPDATED_AT
                    FROM (
                        SELECT DISTINCT
                            TYPEOF(t.${VARIANT_COLUMN}) AS input_col_type,
                            REGEXP_REPLACE(REGEXP_REPLACE(f.path, ''\\\\\\\\[[0-9]+\\\\\\\\]'', ''''), ''^\\\\\\\\.'', '''', 1, 1) as key_path,
                            SPLIT_PART(key_path, ''.'', -1) as key_name,
                            CASE 
                                WHEN TYPEOF(f.value) IN (''OBJECT'', ''ARRAY'') THEN ''VARIANT''
                                ELSE TYPEOF(f.value)
                            END as key_type,
                            BAGIC_PREPROD_CURATED_DB.UTILS.convert_col_name_to_snake_case(key_name) as col_alias
                        FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} t,
                        LATERAL FLATTEN(PARSE_JSON(TO_VARIANT(t.${VARIANT_COLUMN})), recursive=>true) f
                    ) WHERE trim(key_path) != ''''
                    GROUP BY input_col_type, key_path, key_name, col_alias
                    ORDER BY LOWER(key_path)
                `;        
                var stmtCreateMetaBase = snowflake.createStatement({ sqlText: createMetaFromBaseQuery });
                stmtCreateMetaBase.execute();
            }
        }
        else{
        /**
        The drift query uses a detailed GROUP BY clause to prevent rows with the same key but different data types from being merged.
         This allows to accurately detect type inconsistencies, such as a column changing to a VARIANT, and handle the situation appropriately to prevent errors.
        */
        var driftQry = `
            SELECT 
                input_col_type,
                key_path, 
                key_name, 
                CASE
                    WHEN LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','') = ''''
                    THEN ''VARIANT''
                    ELSE LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','')
                END as key_type,
                col_alias, 
                ARRAY_SIZE(SPLIT(key_path, ''.'')) -1 AS level,
                NULL AS TABLE_NAME,
                CURRENT_TIMESTAMP AS UPDATED_AT
            FROM (
                SELECT DISTINCT
                    TYPEOF(t.${VARIANT_COLUMN}) AS input_col_type,
                    REGEXP_REPLACE(REGEXP_REPLACE(f.path, ''\\\\\\\\[[0-9]+\\\\\\\\]'', ''''), ''^\\\\\\\\.'', '''', 1, 1) AS key_path,
                    SPLIT_PART(key_path, ''.'', -1) AS key_name,
                    CASE 
                        WHEN TYPEOF(f.value) IN (''OBJECT'', ''ARRAY'') THEN ''VARIANT''
                        ELSE TYPEOF(f.value)
                    END AS key_type,
                     BAGIC_PREPROD_CURATED_DB.UTILS.convert_col_name_to_snake_case(key_name) AS col_alias
                FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} t,
                LATERAL FLATTEN(PARSE_JSON(TO_VARIANT(t.${VARIANT_COLUMN})), recursive=>true) f
            )
            WHERE TRIM(key_path) <> ''''
            GROUP BY input_col_type, key_path, key_name, col_alias
            ORDER BY LOWER(key_path)`;
            
         // Check for drift
            var driftCheck = snowflake.createStatement({
                sqlText: `
                    SELECT 
                        n.key_path,
                        n.key_type,
                        o.key_type,
                        n.col_alias
                    FROM (${driftQry}) n
                    JOIN ${TARGET_DB}.${TARGET_SCHEMA}.${SRC_TABLE}_metadata o
                      ON n.key_path = o.key_path
                    WHERE UPPER(n.key_type) != UPPER(o.key_type)
                `
            }).execute();
            
            var driftCount = 0;
            var driftDetails = [];
            var driftInserts = [];
     
            while (driftCheck.next()) {
                driftCount++;
                var keyPath = driftCheck.getColumnValue(1);
                var newType = driftCheck.getColumnValue(2);
                var oldType = driftCheck.getColumnValue(3);
                var colAlias = driftCheck.getColumnValue(4);
                
                driftDetails.push(" " + driftCount + ". Path: " + keyPath + " | Old Type: " + oldType + " | New Type: " + newType);
                
                // Prepare insert statement for drift correction table
                var metaTableName = SRC_TABLE.toUpperCase().replace(/_VW.*$/, ''_VW_METADATA'');
                driftInserts.push(`
                    (''${TARGET_DB}'', ''${TARGET_SCHEMA}'', ''${SRC_TABLE}'', ''${metaTableName}'', 
                     ''${keyPath}'', ''${colAlias.toUpperCase()}'', ''${newType}'')
                `);
            }
     
            if (driftCount > 0) {
                // Insert all drifts into correction table
                var insertDriftSql = `
                    INSERT INTO BAGIC_PREPROD_CURATED_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS 
                        (MIRROR_DB, MIRROR_SCHEMA, MIRROR_TABLE, META_TABLE, KEY_PATH, COLUMN_NAME, NEW_DTYPE)
                    VALUES ${driftInserts.join('','')}
                `;
                snowflake.createStatement({ sqlText: insertDriftSql }).execute();
                
                // **STOP THE SCHEDULE by clearing CRON in MASTER_TABLE_INFO**
                var stageTableName = SRC_TABLE.toUpperCase().replace(/_VW$/, '''');
                try {
                    var stopScheduleSql = `
                        UPDATE BAGIC_PREPROD_CURATED_DB.UTILS.MASTER_TABLE_INFO
                        SET CRON = ''''
                        WHERE STAGING_TABLE = ''${stageTableName}''
                    `;
                    var stopResult = snowflake.createStatement({ sqlText: stopScheduleSql }).execute();
                    
                    // Mark schedule as stopped in drift table
                    var markScheduleSql = `
                        UPDATE BAGIC_PREPROD_CURATED_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS
                        SET SCHEDULE_STOPPED = TRUE
                        WHERE MIRROR_TABLE = ''${SRC_TABLE}'' AND STATUS = ''PENDING''
                    `;
                    snowflake.createStatement({ sqlText: markScheduleSql }).execute();
                    
                } catch (schedErr) {
                    // If schedule stop fails, log but continue
                }
                
                throw "Type drift detected in " + driftCount + " field(s): " + 
                      driftDetails.join("\\n") + 
                      " SCHEDULE STOPPED for table: " + stageTableName + 
                      " Drift records created in BAGIC_PREPROD_CURATED_DB.UTILS.SCHEMA_DRIFT_CORRECTIONS. " +
                      "Run CALL BAGIC_PREPROD_CURATED_DB.UTILS.APPLY_DRIFT_CORRECTIONS() to fix all drifts, But before that make sure the table names are correct here it is created using parent table but you need to update the nested table names where actual colums are present.";
            }

        // Compare new and old metadata, insert new columns if any
        var newMetaQry = `
            SELECT 
                input_col_type,
                key_path, 
                key_name, 
                CASE
                    WHEN LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','') = ''''
                    THEN ''VARIANT''
                    ELSE LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','')
                END as key_type, 
                col_alias, 
                ARRAY_SIZE(SPLIT(key_path, ''.'')) -1 as level,
                NULL AS TABLE_NAME,
                CURRENT_TIMESTAMP AS UPDATED_AT
            FROM (
                SELECT DISTINCT
                    TYPEOF(t.${VARIANT_COLUMN}) AS input_col_type,
                    REGEXP_REPLACE(REGEXP_REPLACE(f.path, ''\\\\\\\\[[0-9]+\\\\\\\\]'', ''''), ''^\\\\\\\\.'', '''', 1, 1) as key_path,
                    SPLIT_PART(key_path, ''.'', -1) as key_name,
                    CASE       
                        WHEN TYPEOF(f.value) IN (''OBJECT'', ''ARRAY'') THEN ''VARIANT''
                        ELSE TYPEOF(f.value)
                    END as key_type,
                     BAGIC_PREPROD_CURATED_DB.UTILS.convert_col_name_to_snake_case(key_name) as col_alias
                FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} t,
                LATERAL FLATTEN(PARSE_JSON(TO_VARIANT(t.${VARIANT_COLUMN})), recursive=>true) f
            ) WHERE trim(key_path) != ''''
            GROUP BY input_col_type, key_path, key_name, col_alias
            ORDER BY LOWER(key_path)
        `;
        var compareQry = `
            SELECT n.* FROM (${newMetaQry}) n
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
                    WHEN LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','') = ''''
                    THEN ''VARIANT''
                    ELSE LISTAGG(CASE WHEN key_type NOT IN (''NULL'', ''NULL_VALUE'') THEN key_type END, '','')
                END as key_type,
                col_alias, 
                ARRAY_SIZE(SPLIT(key_path, ''.'')) -1 as level,
                NULL AS TABLE_NAME,
                CURRENT_TIMESTAMP AS UPDATED_AT
            FROM (
                SELECT DISTINCT
                    TYPEOF(t.${VARIANT_COLUMN}) AS input_col_type,
                    REGEXP_REPLACE(REGEXP_REPLACE(f.path, ''\\\\\\\\[[0-9]+\\\\\\\\]'', ''''), ''^\\\\\\\\.'', '''', 1, 1) as key_path,
                    SPLIT_PART(key_path, ''.'', -1) as key_name,
                    CASE 
                        
                        WHEN TYPEOF(f.value) IN (''OBJECT'', ''ARRAY'') THEN ''VARIANT''
                        ELSE TYPEOF(f.value)
                    END as key_type,
                     BAGIC_PREPROD_CURATED_DB.UTILS.convert_col_name_to_snake_case(key_name) as col_alias
                FROM ${SRC_DB}.${SRC_SCHEMA}.${SRC_TABLE} t,
                LATERAL FLATTEN(PARSE_JSON(TO_VARIANT(t.${VARIANT_COLUMN})), recursive=>true) f
            ) WHERE trim(key_path) != ''''
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