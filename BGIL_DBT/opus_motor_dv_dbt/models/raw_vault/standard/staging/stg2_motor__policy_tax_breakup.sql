-- automate_dv.stage() for SAT_POLICY_TAX_BREAKUP, read off central view stitch_motor__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CESS_AMOUNT'
      - 'CGST_AMOUNT'
      - 'IGST_AMOUNT'
      - 'SGST_AMOUNT'
      - 'STAMP_DUTY_AMOUNT'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_TAX_BREAKUP__CESS_AMOUNT, POLICY_TAX_BREAKUP__CGST_AMOUNT, POLICY_TAX_BREAKUP__IGST_AMOUNT, POLICY_TAX_BREAKUP__SGST_AMOUNT, POLICY_TAX_BREAKUP__STAMP_DUTY_AMOUNT) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CESS_AMOUNT: 'POLICY_TAX_BREAKUP__CESS_AMOUNT'
  CGST_AMOUNT: 'POLICY_TAX_BREAKUP__CGST_AMOUNT'
  IGST_AMOUNT: 'POLICY_TAX_BREAKUP__IGST_AMOUNT'
  SGST_AMOUNT: 'POLICY_TAX_BREAKUP__SGST_AMOUNT'
  STAMP_DUTY_AMOUNT: 'POLICY_TAX_BREAKUP__STAMP_DUTY_AMOUNT'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V10_PARTY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
