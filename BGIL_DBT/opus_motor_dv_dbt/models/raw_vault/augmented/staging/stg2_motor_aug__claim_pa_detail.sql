-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_PA_DETAIL, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PA_CLAIM_INDICATOR'
derived_columns:
  CLAIM_NK: "case when AUG_CLAIM_PA_DETAIL__PA_CLAIM_INDICATOR is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  PA_CLAIM_INDICATOR: 'AUG_CLAIM_PA_DETAIL__PA_CLAIM_INDICATOR'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v02_claim'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
