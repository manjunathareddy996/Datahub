-- Standard sat() for SAT_POLICY_PREMIUM_SUMMARY (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v27_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_policy_premium_summary'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'ADD_ON_PREMIUM'
  - 'BASE_PREMIUM'
  - 'ENVIRONMENT_RELIEF_FUND_AMOUNT'
  - 'GROSS_PREMIUM'
  - 'GROUP_DISCOUNT_AMOUNT'
  - 'INSTALMENT_COUNT'
  - 'INSTALMENT_INDICATOR'
  - 'LONG_TERM_DISCOUNT_AMOUNT'
  - 'NET_PREMIUM'
  - 'NO_CLAIM_BONUS_AMOUNT'
  - 'PREMIUM_PAYMENT_STATUS'
  - 'TERRORISM_PREMIUM'
  - 'TOTAL_PREMIUM_COLLECTED'
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
