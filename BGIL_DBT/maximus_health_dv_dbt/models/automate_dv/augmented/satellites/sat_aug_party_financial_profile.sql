-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PARTY_FINANCIAL_PROFILE (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v12_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_party_financial_profile'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'BANKING_DETAILS_DESCRIPTION'
  - 'CHARGES_FILED_DESCRIPTION'
  - 'CHEQUE_RECEIPTING_BLOCKED_INDICATOR'
  - 'CHEQUE_RECEIPTING_BLOCK_REASON'
  - 'CREDIT_CARD_DETAILS_DESCRIPTION'
  - 'CREDIT_LIMIT_CIN_REFERENCE'
  - 'CREDIT_PROFILE_DESCRIPTION'
  - 'EXEMPTED_INCOME'
  - 'GROSS_INCOME'
  - 'INCOME_TAX_RETURN_FILED_LAST_TWO_YEARS_INDICATOR'
  - 'LOWER_TDS_CERTIFICATE_REFERENCE'
  - 'MONTHLY_GROSS_INCOME'
  - 'MONTHLY_INCOME_DECLARED'
  - 'SECONDARY_INCOME_AMOUNT'
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
