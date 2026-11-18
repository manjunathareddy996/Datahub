-- automate_dv.stage() for SAT_AUG_FINTXN_PREMIUM, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COLLECTED_PREMIUM_AMOUNT'
      - 'FINAL_PREMIUM'
      - 'IMT_ENDORSEMENT_CODE_LIST'
      - 'NET_PREMIUM_COMPONENT'
      - 'NO_CLAIM_BONUS_AMOUNT'
      - 'TOTAL_ACT_LIABILITY_PREMIUM'
      - 'TOTAL_IEV_AMOUNT'
      - 'TOTAL_OWN_DAMAGE_PREMIUM'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(AUG_FINTXN_PREMIUM__COLLECTED_PREMIUM_AMOUNT, AUG_FINTXN_PREMIUM__FINAL_PREMIUM, AUG_FINTXN_PREMIUM__IMT_ENDORSEMENT_CODE_LIST, AUG_FINTXN_PREMIUM__NET_PREMIUM_COMPONENT, AUG_FINTXN_PREMIUM__NO_CLAIM_BONUS_AMOUNT, AUG_FINTXN_PREMIUM__TOTAL_ACT_LIABILITY_PREMIUM, AUG_FINTXN_PREMIUM__TOTAL_IEV_AMOUNT, AUG_FINTXN_PREMIUM__TOTAL_OWN_DAMAGE_PREMIUM) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  COLLECTED_PREMIUM_AMOUNT: 'AUG_FINTXN_PREMIUM__COLLECTED_PREMIUM_AMOUNT'
  FINAL_PREMIUM: 'AUG_FINTXN_PREMIUM__FINAL_PREMIUM'
  IMT_ENDORSEMENT_CODE_LIST: 'AUG_FINTXN_PREMIUM__IMT_ENDORSEMENT_CODE_LIST'
  NET_PREMIUM_COMPONENT: 'AUG_FINTXN_PREMIUM__NET_PREMIUM_COMPONENT'
  NO_CLAIM_BONUS_AMOUNT: 'AUG_FINTXN_PREMIUM__NO_CLAIM_BONUS_AMOUNT'
  TOTAL_ACT_LIABILITY_PREMIUM: 'AUG_FINTXN_PREMIUM__TOTAL_ACT_LIABILITY_PREMIUM'
  TOTAL_IEV_AMOUNT: 'AUG_FINTXN_PREMIUM__TOTAL_IEV_AMOUNT'
  TOTAL_OWN_DAMAGE_PREMIUM: 'AUG_FINTXN_PREMIUM__TOTAL_OWN_DAMAGE_PREMIUM'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
