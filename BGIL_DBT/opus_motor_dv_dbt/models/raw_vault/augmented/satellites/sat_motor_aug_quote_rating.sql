-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_QUOTE_RATING (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_motor__v23_quote.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__quote_rating'
src_pk:
  - 'QUOTE_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'COLLECTED_PREMIUM_AMOUNT'
  - 'COMMISSION_AMOUNT'
  - 'COMMISSION_BASE_AMOUNT'
  - 'COMMISSION_BASE_NET_RATEABLE_VALUE'
  - 'COMMISSION_RATE'
  - 'FINAL_PREMIUM'
  - 'LOADING_PERCENTAGE'
  - 'MAXIMUM_COMMISSION_RATE'
  - 'MINIMUM_COMMISSION_RATE'
  - 'MULTI_POLICY_DISCOUNT_PERCENTAGE'
  - 'NET_PREMIUM_COMPONENT'
  - 'NO_CLAIM_BONUS_AMOUNT'
  - 'PAYOUT_APPLICABLE_INDICATOR'
  - 'SERVICE_TAX_AMOUNT'
  - 'STAMP_DUTY_AMOUNT'
  - 'THEFT_EXCESS_AMOUNT'
  - 'TOTAL_ACT_LIABILITY_PREMIUM'
  - 'TOTAL_IEV_AMOUNT'
  - 'TOTAL_OWN_DAMAGE_PREMIUM'
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
