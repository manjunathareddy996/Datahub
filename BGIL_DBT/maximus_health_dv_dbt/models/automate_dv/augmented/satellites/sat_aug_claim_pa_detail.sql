-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_CLAIM_PA_DETAIL (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v02_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_pa_detail'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'DISABILITY_DESCRIPTION'
  - 'DISABLEMENT_DURATION'
  - 'DISABLEMENT_DURATION_WEEKS'
  - 'LEAVE_DURATION'
  - 'LEAVE_PERIOD_FROM_DATE'
  - 'LEAVE_PERIOD_TO_DATE'
  - 'MEMBER_DISABILITY_INDICATOR'
  - 'NSBP_IPTT_DISABILITY_TYPE'
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
