-- automate_dv.stage() for SAT_AUG_POLICY_TERMS, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CO_PAYMENT_APPLICABLE_INDICATOR'
      - 'CO_PAYMENT_OPTED_INDICATOR'
      - 'GEOGRAPHICAL_EXTENSION_CODE'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_TERMS__CO_PAYMENT_APPLICABLE_INDICATOR, AUG_POLICY_TERMS__CO_PAYMENT_OPTED_INDICATOR, AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CO_PAYMENT_APPLICABLE_INDICATOR: 'AUG_POLICY_TERMS__CO_PAYMENT_APPLICABLE_INDICATOR'
  CO_PAYMENT_OPTED_INDICATOR: 'AUG_POLICY_TERMS__CO_PAYMENT_OPTED_INDICATOR'
  GEOGRAPHICAL_EXTENSION_CODE: 'AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
