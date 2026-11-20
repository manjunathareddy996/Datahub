-- automate_dv.stage() for SAT_PARTY_POLICY_HISTORY, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TOTAL_POLICY_COUNT'
derived_columns:
  PARTY_NK: "case when PARTY_POLICY_HISTORY__TOTAL_POLICY_COUNT is not null then 'HUB_PARTY|' || PARTY_BK end"
  TOTAL_POLICY_COUNT: 'PARTY_POLICY_HISTORY__TOTAL_POLICY_COUNT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v04_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
