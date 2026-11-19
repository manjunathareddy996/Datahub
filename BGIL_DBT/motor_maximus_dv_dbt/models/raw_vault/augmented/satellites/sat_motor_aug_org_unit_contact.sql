-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_ORG_UNIT_CONTACT (parent HUB_ORG_UNIT, history SCD2), fed whole from central view stitch_mxm__v08_location.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__org_unit_contact'
src_pk: 'ORG_UNIT_HKEY'
src_cdk:
  - 'CONTACT_POINT_TYPE_CK'
src_payload:
  - 'ALTERNATE_MOBILE_NUMBER'
  - 'EMAIL_ADDRESS'
  - 'FAX_NUMBER'
  - 'LANDLINE_NUMBER'
  - 'MOBILE_NUMBER'
  - 'SOCIAL_MEDIA_HANDLE'
  - 'STD_CODE'
  - 'WHATSAPP_NUMBER'
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
