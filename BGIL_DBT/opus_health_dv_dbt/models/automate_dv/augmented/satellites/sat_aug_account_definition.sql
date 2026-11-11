-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_ACCOUNT_DEFINITION (parent HUB_FINANCIAL_ACCOUNT, history SCD2), fed whole from central view stitch_v13_financial_account.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_account_definition'
src_pk: 'FINANCIAL_ACCOUNT_HKEY'
src_payload:
  - 'BANK_CUSTOMER_IDENTIFIER'
  - 'BANK_CUSTOMER_REFERENCE'
  - 'BRANCH_ADDRESS'
  - 'LOAN_TENURE'
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
