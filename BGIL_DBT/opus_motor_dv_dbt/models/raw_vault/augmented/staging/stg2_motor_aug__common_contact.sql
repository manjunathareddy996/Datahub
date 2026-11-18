-- automate_dv.stage() for SAT_AUG_COMMON_CONTACT, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ALTERNATE_LANDLINE_NUMBER'
      - 'PREFERRED_CONTACT_DATE'
      - 'CONTACT_POINT_TYPE_CK'
      - 'CONTACT_PRIORITY_ORDER_CK'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_COMMON_CONTACT__ALTERNATE_LANDLINE_NUMBER, AUG_COMMON_CONTACT__PREFERRED_CONTACT_DATE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CONTACT_POINT_TYPE_CK: 'AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK'
  CONTACT_PRIORITY_ORDER_CK: 'AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK'
  ALTERNATE_LANDLINE_NUMBER: 'AUG_COMMON_CONTACT__ALTERNATE_LANDLINE_NUMBER'
  PREFERRED_CONTACT_DATE: 'AUG_COMMON_CONTACT__PREFERRED_CONTACT_DATE'
  LOAD_DATETIME: 'AUG_COMMON_CONTACT__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
