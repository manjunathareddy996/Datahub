-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CLAIM_PRIOR_POLICY_HISTORY (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v03_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_prior_policy_history'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'PRIOR_POLICY_NUMBER_CK'
  - 'PRIOR_POLICY_REFERENCE_CK'
src_payload:
  - 'PRIOR_CLAIM_HISTORY_DESCRIPTION'
  - 'PRIOR_POLICY_HISTORY_DETAIL'
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
