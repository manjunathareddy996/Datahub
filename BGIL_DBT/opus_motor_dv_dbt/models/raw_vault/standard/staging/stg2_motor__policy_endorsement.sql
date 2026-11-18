-- automate_dv.stage() for SAT_POLICY_ENDORSEMENT, read off central view stitch_motor__v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v15_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ENDORSEMENT_CHANNEL'
      - 'ENDORSEMENT_DATE'
      - 'ENDORSEMENT_NUMBER'
      - 'ENDORSEMENT_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_ENDORSEMENT__ENDORSEMENT_CHANNEL, POLICY_ENDORSEMENT__ENDORSEMENT_DATE, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER) is not null then 'HUB_POLICY|' || POLICY_BK end"
  ENDORSEMENT_NUMBER_CK: 'POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK'
  ENDORSEMENT_CHANNEL: 'POLICY_ENDORSEMENT__ENDORSEMENT_CHANNEL'
  ENDORSEMENT_DATE: 'POLICY_ENDORSEMENT__ENDORSEMENT_DATE'
  ENDORSEMENT_NUMBER: 'POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
