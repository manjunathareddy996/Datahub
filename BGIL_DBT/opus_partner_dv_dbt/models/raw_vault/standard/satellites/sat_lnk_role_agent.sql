{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_LNK_ROLE_AGENT (HUB_PARTY grain, role-special: 'agent') -- single source.
-- Change detection and watermark are per (PARTY_HKEY, RECORD_SOURCE), so other projects' rows
-- are never touched.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_rolesat_bjaz_intermediary__lnk_role_agent'
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
src_record_source_map:
  stg2_rolesat_bjaz_intermediary__lnk_role_agent: 'OPUS_PARTNER'
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
                        'stg2_rolesat_bjaz_intermediary__lnk_role_agent': ['AGENT_CODE', 'IRDAI_AGENT_LICENCE_NUMBER', 'LICENCE_CATEGORY', 'LICENCE_EXPIRY_DATE', 'LICENCE_ISSUE_DATE']
                    }) }}
