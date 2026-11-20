-- automate_dv.stage() for SAT_CLAIM_CO_RI_SHARE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CO_INSURANCE_OUR_SHARE_PERCENTAGE'
      - 'EXPENSE_SHARE_AMOUNT'
      - 'LEADER_INDICATOR'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_CO_RI_SHARE__CO_INSURANCE_OUR_SHARE_PERCENTAGE, CLAIM_CO_RI_SHARE__EXPENSE_SHARE_AMOUNT, CLAIM_CO_RI_SHARE__LEADER_INDICATOR) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  CO_INSURANCE_OUR_SHARE_PERCENTAGE: 'CLAIM_CO_RI_SHARE__CO_INSURANCE_OUR_SHARE_PERCENTAGE'
  EXPENSE_SHARE_AMOUNT: 'CLAIM_CO_RI_SHARE__EXPENSE_SHARE_AMOUNT'
  LEADER_INDICATOR: 'CLAIM_CO_RI_SHARE__LEADER_INDICATOR'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
