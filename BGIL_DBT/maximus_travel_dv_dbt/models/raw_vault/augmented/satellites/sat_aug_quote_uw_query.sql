{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat() for SAT_AUG_QUOTE_UW_QUERY.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, QUOTE_HKEY, single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_quote_uw_query'
src_pk: 'QUOTE_HKEY'
src_payload:
  - 'QUERY_CODE'
  - 'QUERY_DESCRIPTION'
  - 'QUERY_REPLY_TEXT'
  - 'QUERY_STATUS'
  - 'QUERY_TYPE'
  - 'RAISED_BY_ROLE'
  - 'RAISED_BY_USER_REFERENCE'
  - 'REPLIED_BY_ROLE'
  - 'REPLIED_BY_USER_REFERENCE'
  - 'REPLY_DATE_TIME'
  - 'SERVICE_REQUEST_NUMBER'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
