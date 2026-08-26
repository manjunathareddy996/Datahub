{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_LNK_ROLE_PROVIDER (HUB_PARTY grain, role-special: 'provider').

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
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
