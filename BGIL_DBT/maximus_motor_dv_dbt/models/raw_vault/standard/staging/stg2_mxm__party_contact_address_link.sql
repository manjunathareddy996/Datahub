-- automate_dv.stage() for SAT_PARTY_CONTACT_ADDRESS_LINK, read off central view stitch_mxm__v08_location.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v08_location'
hashed_columns:
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_PROOF_TYPE'
      - 'ADDRESS_USAGE_TYPE'
      - 'ADDRESS_USAGE_TYPE_CK'
derived_columns:
  PARTY_LOCATION_NK: "case when coalesce(PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_TYPE, PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE) is not null then 'LNK_PARTY_LOCATION|' || LOCATION_BK || '|' || PARTY_BK end"
  ADDRESS_USAGE_TYPE_CK: 'PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK'
  ADDRESS_PROOF_TYPE: 'PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_TYPE'
  ADDRESS_USAGE_TYPE: 'PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE'
  LOAD_DATETIME: 'LOCATION_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v08_location'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
