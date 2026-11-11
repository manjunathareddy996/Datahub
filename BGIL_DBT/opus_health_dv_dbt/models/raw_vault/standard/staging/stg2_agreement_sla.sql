-- automate_dv.stage() for SAT_AGREEMENT_SLA, read off central view stitch_v01_agreement.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v01_agreement'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SERVICE_LEVEL_TARGET'
      - 'TAT_COMMITMENT'
derived_columns:
  AGREEMENT_NK: "case when coalesce(AGREEMENT_SLA__SERVICE_LEVEL_TARGET, AGREEMENT_SLA__TAT_COMMITMENT) is not null then 'HUB_AGREEMENT|' || AGREEMENT_BK end"
  SERVICE_LEVEL_TARGET: 'AGREEMENT_SLA__SERVICE_LEVEL_TARGET'
  TAT_COMMITMENT: 'AGREEMENT_SLA__TAT_COMMITMENT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v01_agreement'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
