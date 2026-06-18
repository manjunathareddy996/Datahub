CREATE OR REPLACE PROCEDURE BAGIC_PREPROD_CURATED_DB.UTILS.WRAPPER_PROC("SRC_DB" VARCHAR, "SRC_SCHEMA" VARCHAR, "SRC_TABLE" VARCHAR, "TARGET_DB" VARCHAR, "TARGET_SCHEMA" VARCHAR, "VARIANT_COLUMN" VARCHAR, "VARIANT_KEYS" VARCHAR, "RELATION_COLUMNS" VARCHAR, "FOREIGN_KEY_PATH" VARCHAR, "METADATA_FLAG" BOOLEAN, "SYNC_MODE" VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
var output = {
        metadata_proc: null,
        flatten_proc: null,
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
                WHERE s.DATA:errorCode = 0
            )
            WHERE rn = 1
        `;

        try {
            snowflake.execute({ sqlText: view_fnl });
        } catch (view_err) {
            throw new Error("Failed to create view: " + view_err.message);
        }
        
        if(BASE_METADATA_FLAG === 1){
            // CALL METADATA PROCEDURE
            var callMeta = `
                CALL BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_METADATA_TABLE_PROC(
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
            CALL BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_FLATTEN_VARIANT_TABLE_PROC(
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
                AND s.DATA:errorCode = 0
            )
            WHERE rn = 1
        `;
        
        try {
            snowflake.execute({ sqlText: view_fnl });
        } catch (view_err) {
            throw new Error("Failed to create view: " + view_err.message);
        }
        final_src_table = `${SRC_TABLE}_VW`;
        // CALL FLATTEN PROCEDURE
        var flattenCall = `
            CALL BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_FLATTEN_VARIANT_TABLE_PROC(
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
                CALL BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_UPSERT_JOB(
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