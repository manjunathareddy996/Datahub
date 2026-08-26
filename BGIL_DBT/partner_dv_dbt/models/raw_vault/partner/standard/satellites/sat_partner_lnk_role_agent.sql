{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_LNK_ROLE_AGENT (HUB_PARTY grain, role-special: 'agent').

{%- set yaml_metadata -%}
source_model:
  - 'stg2_rolesat_bjaz_intermediary__lnk_role_agent'
  - 'stg2_rolesat_bjaz_intermediary_hist__lnk_role_agent'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AGENT_CODE'
  - 'IRDAI_AGENT_LICENCE_NUMBER'
  - 'LICENCE_CATEGORY'
  - 'LICENCE_EXPIRY_DATE'
  - 'LICENCE_ISSUE_DATE'
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
