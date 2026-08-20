# Demo: Multi-Source Satellite with Duplicate Detection

This demo illustrates the duplicate-insert problem described in Section 30:
- Two source tables (`table_a`, `table_b`) independently update the same entity (keyed by `id`).
- Both feed a single satellite (`sat_a_b`) via `sat_multi_source` macro.
- Even when a source's own data hasn't changed, a record gets inserted as a duplicate
  because sat() picks MAX load_date for the PK from ANY source and compares against that.

## Layer flow:
```
source (table_a, table_b)
  -> stg_a, stg_b          (trim + null cleaning)
  -> stg2_a, stg2_b        (hash key + hashdiff generation)
  -> sat_a_b                (multi-source satellite via sat_multi_source macro)
```
## ERROR

DBT job failed: 1 model(s) failed out of 5 total (total time: 6.59s)
First error in model 'sat_a_b': Database Error in model sat_a_b (models/raw_vault/partner/standard/satellites/sat_a_b.sql)
  000904 (42000): SQL compilation error: error line 20 at position 8
  invalid identifier 'A.PHONE_1'
  compiled code at target/run/dev_dv_dbt/models/raw_vault/partner/standard/satellites/sat_a_b.sql. 
Context: DBT 1.9.4, Command: dbt run.
 Check logs/dbt.log for more details.


 DBT job failed: 1 model(s) failed out of 1 total (total time: 4.43s)
First error in model 'sat_a_b': Database Error in model sat_a_b (models/raw_vault/partner/standard/satellites/sat_a_b.sql)
  000904 (42000): SQL compilation error: error line 21 at position 8
  invalid identifier 'A.PHONE_2'
  compiled code at target/run/dev_dv_dbt/models/raw_vault/partner/standard/satellites/sat_a_b.sql. 
Context: DBT 1.9.4, Command: dbt run.
 Check logs/dbt.log for more details.
