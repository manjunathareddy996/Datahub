-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_CLAIM_BENEFIT_HEAD (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v07_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_benefit_head'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'CUMULATIVE_BONUS_AMOUNT_ON_HEAD'
  - 'HEAD_ASSESSED_DURATION_DAYS'
  - 'HEAD_BASE_SUM_INSURED'
  - 'HEAD_BASIS_COUNT'
  - 'HEAD_BASIS_DESCRIPTION'
  - 'HEAD_CLAIMED_DURATION_DAYS'
  - 'HEAD_CLAIMED_PERIOD_FROM_DATE'
  - 'HEAD_CLAIMED_PERIOD_TO_DATE'
  - 'HEAD_EVENT_DATE'
  - 'HEAD_ONSET_DATE'
  - 'HEAD_RESOLUTION_DATE'
  - 'SUM_INSURED_FOR_HEAD'
  - 'TRAVEL_FROM_CITY'
  - 'TRAVEL_TO_CITY'
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
