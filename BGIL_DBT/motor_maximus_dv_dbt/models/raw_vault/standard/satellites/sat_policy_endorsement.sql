-- Standard ma_sat() for SAT_POLICY_ENDORSEMENT (parent HUB_POLICY, history Multi-Active SCD2), fed whole from central view stitch_mxm__v13_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__policy_endorsement'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'ENDORSEMENT_NUMBER_CK'
src_payload:
  - 'EFFECTIVE_DATE'
  - 'ENDORSEMENT_NUMBER'
  - 'ENDORSEMENT_REASON'
  - 'ENDORSEMENT_TYPE'
  - 'PREMIUM_IMPACT_AMOUNT'
  - 'SUM_INSURED_IMPACT_AMOUNT'
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
