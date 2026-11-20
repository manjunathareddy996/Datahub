-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_FINANCIAL_PROFILE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BANKING_DETAIL_TEXT'
      - 'CREDIT_CARD_DETAIL_TEXT'
      - 'CREDIT_LIMIT_REFERENCE_TEXT'
      - 'INCOME_TAX_RETURN_FILED_TWO_YEARS_INDICATOR'
      - 'MONTHLY_GROSS_INCOME'
      - 'MONTHLY_INCOME'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_FINANCIAL_PROFILE__BANKING_DETAIL_TEXT, AUG_PARTY_FINANCIAL_PROFILE__CREDIT_CARD_DETAIL_TEXT, AUG_PARTY_FINANCIAL_PROFILE__CREDIT_LIMIT_REFERENCE_TEXT, AUG_PARTY_FINANCIAL_PROFILE__INCOME_TAX_RETURN_FILED_TWO_YEARS_INDICATOR, AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_GROSS_INCOME, AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_INCOME) is not null then 'HUB_PARTY|' || PARTY_BK end"
  BANKING_DETAIL_TEXT: 'AUG_PARTY_FINANCIAL_PROFILE__BANKING_DETAIL_TEXT'
  CREDIT_CARD_DETAIL_TEXT: 'AUG_PARTY_FINANCIAL_PROFILE__CREDIT_CARD_DETAIL_TEXT'
  CREDIT_LIMIT_REFERENCE_TEXT: 'AUG_PARTY_FINANCIAL_PROFILE__CREDIT_LIMIT_REFERENCE_TEXT'
  INCOME_TAX_RETURN_FILED_TWO_YEARS_INDICATOR: 'AUG_PARTY_FINANCIAL_PROFILE__INCOME_TAX_RETURN_FILED_TWO_YEARS_INDICATOR'
  MONTHLY_GROSS_INCOME: 'AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_GROSS_INCOME'
  MONTHLY_INCOME: 'AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_INCOME'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
