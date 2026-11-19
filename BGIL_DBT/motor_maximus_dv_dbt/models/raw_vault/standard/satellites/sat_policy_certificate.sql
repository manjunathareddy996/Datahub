-- Standard ma_sat() for SAT_POLICY_CERTIFICATE (parent HUB_POLICY, history Multi-Active SCD2), fed whole from central view stitch_mxm__v14_risk_object.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__policy_certificate'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'CERTIFICATE_NUMBER_CK'
src_payload:
  - 'CERTIFICATE_NUMBER'
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
