-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_POLICY_FOLLOW_UP_LOG (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v02_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_follow_up_log'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'ENTRY_TIMESTAMP_CK'
src_payload:
  - 'EFFECTIVE_DATE'
  - 'ENTRY_DATE'
  - 'ENTRY_REMARKS'
  - 'ENTRY_TIME'
  - 'RELATED_ENDORSEMENT_OR_CLAIM_REFERENCE'
  - 'STATUS_CODE'
  - 'SUB_STATUS_CODE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
