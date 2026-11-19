-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_TP_FORENSIC, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PANCHANAMA_DETAIL'
      - 'POLICE_STATION_NAME'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_TP_FORENSIC__PANCHANAMA_DETAIL, AUG_CLAIM_TP_FORENSIC__POLICE_STATION_NAME) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  PANCHANAMA_DETAIL: 'AUG_CLAIM_TP_FORENSIC__PANCHANAMA_DETAIL'
  POLICE_STATION_NAME: 'AUG_CLAIM_TP_FORENSIC__POLICE_STATION_NAME'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V02_CLAIM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
