-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_PARTY_VEHICLE_PRIOR_INSURANCE (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v11_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__party_vehicle_prior_insurance'
src_pk:
  - 'PARTY_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'LINE_OF_BUSINESS_CK'
  - 'PREVIOUS_POLICY_NUMBER_CK'
src_payload:
  - 'PREVIOUS_CLAIM_AMOUNT'
  - 'PREVIOUS_POLICY_PREMIUM'
  - 'PREVIOUS_POLICY_START_DATE'
  - 'PREVIOUS_PRODUCT_NAME'
  - 'PREVIOUS_PRODUCT_REFERENCE'
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
