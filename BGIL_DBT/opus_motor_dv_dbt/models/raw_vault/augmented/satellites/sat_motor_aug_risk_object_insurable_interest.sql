-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_RISK_OBJECT_INSURABLE_INTEREST (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v06_distribution_channel.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__risk_object_insurable_interest'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'INTEREST_TYPE_CK'
  - 'INTEREST_HOLDER_REFERENCE_CK'
src_payload:
  - 'FINANCIER_BRANCH_NAME'
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
