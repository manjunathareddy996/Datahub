-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_POLICY_UNDERWRITING_QUERY (parent HUB_POLICY, history SCD2), fed whole from central view stitch_mxm__v04_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__policy_underwriting_query'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'QUERY_CODE_CK'
src_payload:
  - 'DEFICIENCY_MAIN_REMARKS'
  - 'DEFICIENCY_SUB_REMARKS'
  - 'OPERATIONS_QUERY_TEXT'
  - 'QUERY_CODE'
  - 'QUERY_DETAIL'
  - 'QUERY_RAISED_TIMESTAMP'
  - 'QUERY_REPLY_TEXT'
  - 'QUERY_REPLY_TIMESTAMP'
  - 'QUERY_RESPONSE_TEXT'
  - 'QUERY_STATUS'
  - 'QUERY_TYPE'
  - 'RAISED_BY_ROLE'
  - 'RAISED_BY_USER_REFERENCE'
  - 'REPLIED_BY_ROLE'
  - 'REPLIED_BY_USER_REFERENCE'
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
