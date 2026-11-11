-- automate_dv.stage() for SAT_POLICY_PREMIUM_SETTLEMENT, read off central view stitch_v34_risk_object.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v34_risk_object'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREMIUM_REALISATION_DATE'
      - 'SETTLEMENT_LINE_SEQUENCE_CK'
derived_columns:
  POLICY_NK: "case when POLICY_PREMIUM_SETTLEMENT__PREMIUM_REALISATION_DATE is not null then 'HUB_POLICY|' || POLICY_BK end"
  SETTLEMENT_LINE_SEQUENCE_CK: 'POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK'
  PREMIUM_REALISATION_DATE: 'POLICY_PREMIUM_SETTLEMENT__PREMIUM_REALISATION_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v34_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
