-- automate_dv.stage() for SAT_MOTOR_AUG_ORG_UNIT_CONTACT, read off central view stitch_mxm__v08_location.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v08_location'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ALTERNATE_MOBILE_NUMBER'
      - 'EMAIL_ADDRESS'
      - 'FAX_NUMBER'
      - 'LANDLINE_NUMBER'
      - 'MOBILE_NUMBER'
      - 'SOCIAL_MEDIA_HANDLE'
      - 'STD_CODE'
      - 'WHATSAPP_NUMBER'
      - 'CONTACT_POINT_TYPE_CK'
derived_columns:
  ORG_UNIT_NK: "case when coalesce(AUG_ORG_UNIT_CONTACT__ALTERNATE_MOBILE_NUMBER, AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS, AUG_ORG_UNIT_CONTACT__FAX_NUMBER, AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER, AUG_ORG_UNIT_CONTACT__MOBILE_NUMBER, AUG_ORG_UNIT_CONTACT__SOCIAL_MEDIA_HANDLE, AUG_ORG_UNIT_CONTACT__STD_CODE, AUG_ORG_UNIT_CONTACT__WHATSAPP_NUMBER) is not null then 'HUB_ORG_UNIT|' || ORG_UNIT_BK end"
  CONTACT_POINT_TYPE_CK: 'AUG_ORG_UNIT_CONTACT__CONTACT_POINT_TYPE_CK'
  ALTERNATE_MOBILE_NUMBER: 'AUG_ORG_UNIT_CONTACT__ALTERNATE_MOBILE_NUMBER'
  EMAIL_ADDRESS: 'AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS'
  FAX_NUMBER: 'AUG_ORG_UNIT_CONTACT__FAX_NUMBER'
  LANDLINE_NUMBER: 'AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER'
  MOBILE_NUMBER: 'AUG_ORG_UNIT_CONTACT__MOBILE_NUMBER'
  SOCIAL_MEDIA_HANDLE: 'AUG_ORG_UNIT_CONTACT__SOCIAL_MEDIA_HANDLE'
  STD_CODE: 'AUG_ORG_UNIT_CONTACT__STD_CODE'
  WHATSAPP_NUMBER: 'AUG_ORG_UNIT_CONTACT__WHATSAPP_NUMBER'
  LOAD_DATETIME: 'ORG_UNIT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v08_location'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
