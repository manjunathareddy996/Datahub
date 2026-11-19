-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_QUOTE_PRIOR_INSURANCE (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_motor__v23_quote.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__quote_prior_insurance'
src_pk: 'QUOTE_HKEY'
src_cdk:
  - 'PRIOR_POLICY_COMPONENT_CK'
src_payload:
  - 'PRIOR_INSURER_NAME'
  - 'PRIOR_POLICY_CLAIM_COUNT'
  - 'PRIOR_POLICY_END_DATE'
  - 'PRIOR_POLICY_NUMBER'
  - 'PRIOR_POLICY_START_DATE'
  - 'PRIOR_TENURE_YEARS'
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
