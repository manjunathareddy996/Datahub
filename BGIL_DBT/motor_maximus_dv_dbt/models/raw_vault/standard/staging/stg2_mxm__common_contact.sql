-- automate_dv.stage() for SAT_COMMON_CONTACT, read off central view stitch_mxm__v08_location.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v08_location'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ALTERNATE_EMAIL_ADDRESS'
      - 'ALTERNATE_MOBILE_NUMBER'
      - 'CONTACT_POINT_USAGE'
      - 'EMAIL_ADDRESS'
      - 'FAX_NUMBER'
      - 'LANDLINE_NUMBER'
      - 'MOBILE_NUMBER'
      - 'SOCIAL_MEDIA_HANDLE'
      - 'STD_CODE'
      - 'CONTACT_POINT_TYPE_CK'
      - 'CONTACT_PRIORITY_ORDER_CK'
derived_columns:
  PARTY_NK: "case when coalesce(COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS, COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER, COMMON_CONTACT__CONTACT_POINT_USAGE, COMMON_CONTACT__EMAIL_ADDRESS, COMMON_CONTACT__FAX_NUMBER, COMMON_CONTACT__LANDLINE_NUMBER, COMMON_CONTACT__MOBILE_NUMBER, COMMON_CONTACT__SOCIAL_MEDIA_HANDLE, COMMON_CONTACT__STD_CODE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CONTACT_POINT_TYPE_CK: 'COMMON_CONTACT__CONTACT_POINT_TYPE_CK'
  CONTACT_PRIORITY_ORDER_CK: 'COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK'
  ALTERNATE_EMAIL_ADDRESS: 'COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS'
  ALTERNATE_MOBILE_NUMBER: 'COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER'
  CONTACT_POINT_USAGE: 'COMMON_CONTACT__CONTACT_POINT_USAGE'
  EMAIL_ADDRESS: 'COMMON_CONTACT__EMAIL_ADDRESS'
  FAX_NUMBER: 'COMMON_CONTACT__FAX_NUMBER'
  LANDLINE_NUMBER: 'COMMON_CONTACT__LANDLINE_NUMBER'
  MOBILE_NUMBER: 'COMMON_CONTACT__MOBILE_NUMBER'
  SOCIAL_MEDIA_HANDLE: 'COMMON_CONTACT__SOCIAL_MEDIA_HANDLE'
  STD_CODE: 'COMMON_CONTACT__STD_CODE'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v08_location'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
