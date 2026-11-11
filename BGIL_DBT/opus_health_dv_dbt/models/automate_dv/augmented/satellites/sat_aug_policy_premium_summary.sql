-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_PREMIUM_SUMMARY (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v27_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_premium_summary'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'BASE_PREMIUM_BEFORE_ADJUSTMENT'
  - 'FULL_YEAR_NET_PREMIUM'
  - 'FULL_YEAR_TERRORISM_PREMIUM'
  - 'MAXIMUM_EXPOSURE_NET_RATE'
  - 'MAXIMUM_EXPOSURE_STANDARD_RATE'
  - 'PREMIUM_INCLUSIVE_OF_COMMISSION_AMOUNT'
  - 'RECEIPT_DETAILS_TEXT'
  - 'RECEIPT_TYPE'
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
