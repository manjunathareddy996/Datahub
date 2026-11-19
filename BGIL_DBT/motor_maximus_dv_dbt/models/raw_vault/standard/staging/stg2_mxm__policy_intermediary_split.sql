-- automate_dv.stage() for SAT_POLICY_INTERMEDIARY_SPLIT, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMMISSION_AMOUNT'
      - 'INTERMEDIARY_REFERENCE'
      - 'SUB_IMD_CODE'
      - 'INTERMEDIARY_REFERENCE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE, POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  INTERMEDIARY_REFERENCE_CK: 'POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK'
  COMMISSION_AMOUNT: 'POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT'
  INTERMEDIARY_REFERENCE: 'POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE'
  SUB_IMD_CODE: 'POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
