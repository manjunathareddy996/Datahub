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
