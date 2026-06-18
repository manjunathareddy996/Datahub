CREATE OR REPLACE PROCEDURE BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_FLATTEN_VARIANT_TABLE_PROC("SRC_DB" VARCHAR(16777216), "SRC_SCHEMA" VARCHAR(16777216), "SRC_TABLE" VARCHAR(16777216), "TARGET_DB" VARCHAR(16777216), "TARGET_SCHEMA" VARCHAR(16777216), "VARIANT_COLUMN" VARCHAR(16777216), "VARIANT_KEYS" VARCHAR(16777216), "RELATION_COLUMNS" VARCHAR(16777216), "FOREIGN_KEY_PATH" VARCHAR(16777216), "MAIN_TABLE_NAME" VARCHAR(16777216), "METADATA_FLAG" BOOLEAN DEFAULT FALSE, "SYNC_MODE" VARCHAR(10) DEFAULT 'FRO', "RECURSIVE_FLAG" BOOLEAN DEFAULT FALSE, "VARIANT_PATH" VARCHAR(16777216) DEFAULT '', "CUSTOM_PARENT" VARCHAR(16777216) DEFAULT 'null')
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
                var callFRO = `CALL BAGIC_PREPROD_CURATED_DB.UTILS.WRAPPER_PROC(
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
        var callMeta = `CALL BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_METADATA_TABLE_PROC(
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
            columns.push(`${vr_col}:${k}::${v} AS ${col_name}`);
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
        //added on 26th
        var test2 = variantPath;
        var variantPath = variantColList[0];
        variantPath = '''';
        for (var i = 0; i < variantColList.length; i++) {
            var col = variantColList[i];
            var col_id = variant_tbl_map[col];
            if (col_id === VARIANT_COLUMN) {
                var nested_src_tbl = `${SRC_TABLE}_${VARIANT_COLUMN}`;
            } else {
                var qry2 =  `SELECT  BAGIC_PREPROD_CURATED_DB.UTILS.convert_col_name_to_snake_case(''${col_id}'')`;
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
            var callRecursive = `CALL BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_FLATTEN_VARIANT_TABLE_PROC(''${TARGET_DB}'',''${TARGET_SCHEMA}'', ''${nested_src_tbl}'', ''${TARGET_DB}'',''${TARGET_SCHEMA}'',''${variant_alias_map[col]}'','''',''${nestedRelationCols}'', NULL, ''${MAIN_TABLE_NAME}'', TRUE, ''${SYNC_MODE}'', ''${METADATA_FLAG}'', ''${variantPath}'', ''${c_tbl}'')`;
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