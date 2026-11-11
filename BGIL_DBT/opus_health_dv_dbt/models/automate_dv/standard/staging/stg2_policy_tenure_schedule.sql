-- automate_dv.stage() for SAT_POLICY_TENURE_SCHEDULE, read off central view stitch_v13_financial_account.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v13_financial_account'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TENURE_PREMIUM'
      - 'TENURE_SEQUENCE_CK'
derived_columns:
  POLICY_NK: "case when POLICY_TENURE_SCHEDULE__TENURE_PREMIUM is not null then 'HUB_POLICY|' || POLICY_BK end"
  TENURE_SEQUENCE_CK: 'POLICY_TENURE_SCHEDULE__TENURE_SEQUENCE_CK'
  TENURE_PREMIUM: 'POLICY_TENURE_SCHEDULE__TENURE_PREMIUM'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v13_financial_account'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
