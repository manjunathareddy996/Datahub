-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_INTERMEDIARY_SPLIT, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SERVICE_CHARGE_RATE'
      - 'INTERMEDIARY_REFERENCE_CK'
derived_columns:
  POLICY_NK: "case when AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_RATE is not null then 'HUB_POLICY|' || POLICY_BK end"
  INTERMEDIARY_REFERENCE_CK: 'AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK'
  SERVICE_CHARGE_RATE: 'AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_RATE'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
