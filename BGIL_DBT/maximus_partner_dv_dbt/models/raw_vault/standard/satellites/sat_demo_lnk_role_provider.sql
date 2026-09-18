{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE'],
        database=var('partner_vault_database', 'BAGIC_PREPROD_CURATED_DB'),
        schema='BGIL_DATA_MODEL',
        tags=['shared_vault_demo']
    )
}}

-- ============================================================================================
-- SHARED-VAULT PILOT -- side B (Maximus). Throwaway table, safe to drop.
--
-- Writes the SAME relation as partner_dv_dbt's model of the same name:
--
--   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_DEMO_LNK_ROLE_PROVIDER
--
-- Four things make that work, and each is a deliberate departure from the existing
-- sat_lnk_role_provider model:
--
--   1. database + schema pinned explicitly. schema resolves verbatim because BGIL_DATA_MODEL is in
--      the absolute_schemas var (see macros/generate_schema_name.sql), so it is NOT prefixed with
--      the target schema the way this project's other models are.
--
--   2. sat_multi_source() instead of automate_dv.sat(). automate_dv's sat partitions its
--      change-detection window by src_pk ALONE, so a Partner row for a given PARTY_HKEY would
--      shadow Maximus's latest row and suppress legitimate inserts. sat_multi_source partitions by
--      (src_pk, src_source) and keeps a separate watermark per record-source group, which is the
--      isolation two independent pipelines need inside one table.
--
--   3. HASHDIFF, not HASHDIFF_LNK_ROLE_PROVIDER -- aliased in the stage view feeding this model.
--      Two differently-named hashdiff columns in one table would leave each project NULL in the
--      other's, and Maximus's change detection reads that column back out of the target.
--
--   4. merge + unique_key matching Partner's, so re-runs are idempotent rather than appending
--      duplicates the way a bare incremental config does.
--
-- Payload declares ONLY what Maximus populates. Partner's EMPANELMENT_STATUS,
-- RE_EMPANELMENT_DUE_DATE, NETWORK_INDICATOR and PREFERRED_PROVIDER_INDICATOR are absent here and
-- stay absent: append_new_columns never drops target columns, and the merge only writes the
-- columns this model selects, so Partner's data is untouched and Maximus's rows simply carry NULL
-- in them.
--
-- Delete both pilot models once the mechanic is signed off.
-- ============================================================================================

{%- set yaml_metadata -%}
source_model:
  - 'stg2_mp_sat__pd_prop_sp_pv__lnk_role_provider'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'DEEMPANELMENTDATE'
  - 'DELISTINGDATE'
  - 'DELISTINGINDICATOR'
  - 'EMPANELMENT_DATE'
  - 'EVALUATIONDATE'
  - 'ICUNURSECOUNT'
  - 'MOUREFERENCE'
  - 'MOUSTATUS'
  - 'NABHACCREDITEDINDICATOR'
  - 'NURSETOBEDRATIO'
  - 'NURSETOPATIENTRATIO'
  - 'PROVIDERCATEGORY'
  - 'PROVIDER_TYPE'
  - 'SERVICESCOPEDESCRIPTION'
  - 'SPECIALISATION'
  - 'SUPPLIER_ID'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_mp_sat__pd_prop_sp_pv__lnk_role_provider: 'MAXIMUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_mp_sat__pd_prop_sp_pv__lnk_role_provider': ['DEEMPANELMENTDATE', 'DELISTINGDATE', 'DELISTINGINDICATOR', 'EMPANELMENT_DATE', 'EVALUATIONDATE', 'ICUNURSECOUNT', 'MOUREFERENCE', 'MOUSTATUS', 'NABHACCREDITEDINDICATOR', 'NURSETOBEDRATIO', 'NURSETOPATIENTRATIO', 'PROVIDERCATEGORY', 'PROVIDER_TYPE', 'SERVICESCOPEDESCRIPTION', 'SPECIALISATION', 'SUPPLIER_ID']
                    }) }}
