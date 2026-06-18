CREATE OR REPLACE PROCEDURE BAGIC_PREPROD_CURATED_DB.UTILS.PIVOT_VARIANT_TABLE(
    SRC_TABLE STRING, 
    PIVOT_COL STRING,
    PIVOT_VALUE STRING)
  RETURNS VARIANT 
  LANGUAGE JAVASCRIPT
  EXECUTE AS CALLER
  AS
  $$
  var query ;
  var pvt_qry ;
  var pvt_col_name ;
  var col_alias ;
  var pvt_col_list = [];
  var pvt_alias ;
  query = `CREATE OR REPLACE TEMPORARY TABLE ${SRC_TABLE}_TEMP AS
    SELECT * EXCLUDE(${PIVOT_COL}) FROM (
    SELECT *, 
     UPPER(REGEXP_REPLACE(REGEXP_REPLACE(${PIVOT_COL}, '[^A-Za-z0-9_ ]', ''),'\\\\s+', '_')) AS ${PIVOT_COL}_PVT FROM ${SRC_TABLE})`;
  var stmt = snowflake.createStatement({ sqlText: query });
  var rst = stmt.execute();
  query = `SELECT LISTAGG(DISTINCT ${PIVOT_COL}_PVT, ',')  FROM ${SRC_TABLE}_TEMP`;
  var stmt = snowflake.createStatement({ sqlText: query });
  var rst = stmt.execute();
  if (rst.next()) {
    pvt_col_name = rst.getColumnValue(1);  
    }
  pvt_col_list =  pvt_col_name.split(',').map(x => x.trim());
  pvt_alias = pvt_col_list.map(item => `"'${item}'" as ${item}`).join(', ');
  var pvt_cols = pvt_col_list.map(item => `"'${item}'"`).join(', ');
  query = `CREATE OR REPLACE TABLE ${SRC_TABLE}_PIVOT AS
          SELECT * EXCLUDE (${pvt_cols}) FROM (
          SELECT *, ${pvt_alias} FROM ${SRC_TABLE}_TEMP PIVOT(MAX(${PIVOT_VALUE}) FOR ${PIVOT_COL}_PVT IN (ANY ORDER BY ${PIVOT_COL}_PVT)))`;
  var stmt = snowflake.createStatement({ sqlText: query });
  var rst = stmt.execute();
  return query;
  $$;