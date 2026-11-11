-- automate_dv.stage() for SAT_COMMON_CONTACT, read off central view stitch_v13_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v13_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ALTERNATE_EMAIL_ADDRESS'
      - 'ALTERNATE_MOBILE_NUMBER'
      - 'EMAIL_ADDRESS'
      - 'FAX_NUMBER'
      - 'LANDLINE_NUMBER'
      - 'MOBILE_NUMBER'
      - 'PREFERRED_CONTACT_METHOD'
      - 'PREFERRED_CONTACT_TIME'
      - 'STD_CODE'
      - 'CONTACT_POINT_TYPE_CK'
      - 'CONTACT_PRIORITY_ORDER_CK'
derived_columns:
  PARTY_NK: "case when coalesce(COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS, COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER, COMMON_CONTACT__EMAIL_ADDRESS, COMMON_CONTACT__FAX_NUMBER, COMMON_CONTACT__LANDLINE_NUMBER, COMMON_CONTACT__MOBILE_NUMBER, COMMON_CONTACT__PREFERRED_CONTACT_METHOD, COMMON_CONTACT__PREFERRED_CONTACT_TIME, COMMON_CONTACT__STD_CODE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CONTACT_POINT_TYPE_CK: 'COMMON_CONTACT__CONTACT_POINT_TYPE_CK'
  CONTACT_PRIORITY_ORDER_CK: 'COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK'
  ALTERNATE_EMAIL_ADDRESS: 'COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS'
  ALTERNATE_MOBILE_NUMBER: 'COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER'
  EMAIL_ADDRESS: 'COMMON_CONTACT__EMAIL_ADDRESS'
  FAX_NUMBER: 'COMMON_CONTACT__FAX_NUMBER'
  LANDLINE_NUMBER: 'COMMON_CONTACT__LANDLINE_NUMBER'
  MOBILE_NUMBER: 'COMMON_CONTACT__MOBILE_NUMBER'
  PREFERRED_CONTACT_METHOD: 'COMMON_CONTACT__PREFERRED_CONTACT_METHOD'
  PREFERRED_CONTACT_TIME: 'COMMON_CONTACT__PREFERRED_CONTACT_TIME'
  STD_CODE: 'COMMON_CONTACT__STD_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v13_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
