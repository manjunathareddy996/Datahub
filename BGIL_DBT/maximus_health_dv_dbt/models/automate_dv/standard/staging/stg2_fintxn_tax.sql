-- automate_dv.stage() for SAT_FINTXN_TAX, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMPONENT_TAX_AMOUNT'
      - 'GSTIN'
      - 'HSN_SAC_CODE'
      - 'SERVICE_TAX_APPLICABLE_INDICATOR'
      - 'SERVICE_TAX_REGISTRATION_NUMBER'
      - 'TAX_APPLICABLE_INDICATOR'
      - 'TAX_RATE'
      - 'TDS_SECTION'
      - 'TAX_TYPE_CK'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_TAX__COMPONENT_TAX_AMOUNT, FINTXN_TAX__GSTIN, FINTXN_TAX__HSN_SAC_CODE, FINTXN_TAX__SERVICE_TAX_APPLICABLE_INDICATOR, FINTXN_TAX__SERVICE_TAX_REGISTRATION_NUMBER, FINTXN_TAX__TAX_APPLICABLE_INDICATOR, FINTXN_TAX__TAX_RATE, FINTXN_TAX__TDS_SECTION) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  TAX_TYPE_CK: 'FINTXN_TAX__TAX_TYPE_CK'
  COMPONENT_TAX_AMOUNT: 'FINTXN_TAX__COMPONENT_TAX_AMOUNT'
  GSTIN: 'FINTXN_TAX__GSTIN'
  HSN_SAC_CODE: 'FINTXN_TAX__HSN_SAC_CODE'
  SERVICE_TAX_APPLICABLE_INDICATOR: 'FINTXN_TAX__SERVICE_TAX_APPLICABLE_INDICATOR'
  SERVICE_TAX_REGISTRATION_NUMBER: 'FINTXN_TAX__SERVICE_TAX_REGISTRATION_NUMBER'
  TAX_APPLICABLE_INDICATOR: 'FINTXN_TAX__TAX_APPLICABLE_INDICATOR'
  TAX_RATE: 'FINTXN_TAX__TAX_RATE'
  TDS_SECTION: 'FINTXN_TAX__TDS_SECTION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
