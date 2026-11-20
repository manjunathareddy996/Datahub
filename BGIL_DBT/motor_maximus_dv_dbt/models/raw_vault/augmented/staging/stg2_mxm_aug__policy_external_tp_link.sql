-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_EXTERNAL_TP_LINK, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TP_INSURER_BRANCH_ADDRESS_TEXT'
      - 'TP_POLICY_CLAIM_AMOUNT'
      - 'TP_POLICY_CLAIM_DATE'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_EXTERNAL_TP_LINK__TP_INSURER_BRANCH_ADDRESS_TEXT, AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_AMOUNT, AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_DATE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  TP_INSURER_BRANCH_ADDRESS_TEXT: 'AUG_POLICY_EXTERNAL_TP_LINK__TP_INSURER_BRANCH_ADDRESS_TEXT'
  TP_POLICY_CLAIM_AMOUNT: 'AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_AMOUNT'
  TP_POLICY_CLAIM_DATE: 'AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_DATE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v12_policy'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
