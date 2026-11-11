-- automate_dv.stage() for SAT_PARTY_IDENTIFICATION, read off central view stitch_v16_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AADHAAR_NUMBER'
      - 'AGE_PROOF_TYPE'
      - 'EIA_NUMBER'
      - 'GSTIN'
      - 'GST_REGISTRATION_STATUS'
      - 'IDENTIFICATION_NUMBER'
      - 'PAN_NUMBER'
      - 'PASSPORT_NUMBER'
      - 'TAN_NUMBER'
      - 'IDENTIFICATION_TYPE_CODE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_IDENTIFICATION__AADHAAR_NUMBER, PARTY_IDENTIFICATION__AGE_PROOF_TYPE, PARTY_IDENTIFICATION__EIA_NUMBER, PARTY_IDENTIFICATION__GSTIN, PARTY_IDENTIFICATION__GST_REGISTRATION_STATUS, PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER, PARTY_IDENTIFICATION__PAN_NUMBER, PARTY_IDENTIFICATION__PASSPORT_NUMBER, PARTY_IDENTIFICATION__TAN_NUMBER) is not null then 'HUB_PARTY|' || PARTY_BK end"
  IDENTIFICATION_TYPE_CODE_CK: 'PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK'
  AADHAAR_NUMBER: 'PARTY_IDENTIFICATION__AADHAAR_NUMBER'
  AGE_PROOF_TYPE: 'PARTY_IDENTIFICATION__AGE_PROOF_TYPE'
  EIA_NUMBER: 'PARTY_IDENTIFICATION__EIA_NUMBER'
  GSTIN: 'PARTY_IDENTIFICATION__GSTIN'
  GST_REGISTRATION_STATUS: 'PARTY_IDENTIFICATION__GST_REGISTRATION_STATUS'
  IDENTIFICATION_NUMBER: 'PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER'
  PAN_NUMBER: 'PARTY_IDENTIFICATION__PAN_NUMBER'
  PASSPORT_NUMBER: 'PARTY_IDENTIFICATION__PASSPORT_NUMBER'
  TAN_NUMBER: 'PARTY_IDENTIFICATION__TAN_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
