-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_CO_RI_SHARE, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CO_INSURANCE_APPLICABLE_INDICATOR'
      - 'CO_INSURANCE_LOSS_RESERVE_AMOUNT'
      - 'CO_INSURANCE_STATUS'
      - 'CO_INSURANCE_TYPE'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_APPLICABLE_INDICATOR, AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_LOSS_RESERVE_AMOUNT, AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_STATUS, AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  CO_INSURANCE_APPLICABLE_INDICATOR: 'AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_APPLICABLE_INDICATOR'
  CO_INSURANCE_LOSS_RESERVE_AMOUNT: 'AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_LOSS_RESERVE_AMOUNT'
  CO_INSURANCE_STATUS: 'AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_STATUS'
  CO_INSURANCE_TYPE: 'AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
