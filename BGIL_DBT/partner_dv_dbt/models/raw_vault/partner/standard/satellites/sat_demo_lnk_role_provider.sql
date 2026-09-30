{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE'],
        tags=['shared_vault_demo']
    )
}}

-- ============================================================================================
-- SHARED-VAULT PILOT -- side A (Partner). Throwaway table, safe to drop.
--
-- Identical logic to sat_partner_lnk_role_provider, writing to SAT_DEMO_LNK_ROLE_PROVIDER instead
-- of the production table. maximus_partner_dv_dbt has a model of the same name that writes to this
-- same relation, which is what the pilot is proving:
--
--   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_DEMO_LNK_ROLE_PROVIDER
--
-- Run this project FIRST. It creates the table with Partner's 8 payload columns. The Maximus run
-- then appends its 12 extra columns via on_schema_change='append_new_columns' without dropping
-- anything of Partner's.
--
-- Delete both pilot models once the mechanic is signed off.
-- ============================================================================================

{%- set yaml_metadata -%}
source_model:
  - 'stg2_rolesat_bjaz_hm_hospital_master__lnk_role_provider'
  - 'stg2_rolesat_clm_suppliers__lnk_role_provider'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'EMPANELMENT_DATE'
  - 'EMPANELMENT_STATUS'
  - 'NETWORK_INDICATOR'
  - 'PREFERRED_PROVIDER_INDICATOR'
  - 'PROVIDER_TYPE'
  - 'RE_EMPANELMENT_DUE_DATE'
  - 'SPECIALISATION'
  - 'SUPPLIER_ID'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_rolesat_bjaz_hm_hospital_master__lnk_role_provider: 'OPUS'
  stg2_rolesat_clm_suppliers__lnk_role_provider: 'OPUS'
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
                        'stg2_rolesat_bjaz_hm_hospital_master__lnk_role_provider': ['EMPANELMENT_DATE', 'SPECIALISATION', 'PROVIDER_TYPE', 'NETWORK_INDICATOR', 'PREFERRED_PROVIDER_INDICATOR'],
                        'stg2_rolesat_clm_suppliers__lnk_role_provider': ['EMPANELMENT_DATE', 'RE_EMPANELMENT_DUE_DATE', 'EMPANELMENT_STATUS', 'PROVIDER_TYPE', 'SUPPLIER_ID']
                    }) }}
