-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_PARTY_FINANCIAL_PROFILE (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v09_party.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_PARTY_FINANCIAL_PROFILE | Banking Detail Text | None: emits BANKING_DETAILS; withheld BANK_ACCOUNT_DETAILS
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__party_financial_profile'
src_pk:
  - 'PARTY_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'BANKING_DETAIL_TEXT'
  - 'CREDIT_CARD_DETAIL_TEXT'
  - 'CREDIT_LIMIT_REFERENCE_TEXT'
  - 'INCOME_TAX_RETURN_FILED_TWO_YEARS_INDICATOR'
  - 'MONTHLY_GROSS_INCOME'
  - 'MONTHLY_INCOME'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                   src_payload=metadata_dict['src_payload'],
                   src_hashdiff=metadata_dict['src_hashdiff'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
