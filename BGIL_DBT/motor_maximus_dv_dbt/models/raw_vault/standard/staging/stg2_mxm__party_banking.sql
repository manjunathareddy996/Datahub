-- automate_dv.stage() for SAT_PARTY_BANKING, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACCOUNT_HOLDER_NAME'
      - 'ACCOUNT_NUMBER_MASKED'
      - 'ACCOUNT_TYPE'
      - 'BANK_NAME'
      - 'BRANCH_NAME'
      - 'IFSC_CODE'
      - 'MICR_CODE'
      - 'PRIMARY_ACCOUNT_INDICATOR'
      - 'ACCOUNT_NUMBER_MASKED_CK'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_BANKING__ACCOUNT_HOLDER_NAME, PARTY_BANKING__ACCOUNT_NUMBER_MASKED, PARTY_BANKING__ACCOUNT_TYPE, PARTY_BANKING__BANK_NAME, PARTY_BANKING__BRANCH_NAME, PARTY_BANKING__IFSC_CODE, PARTY_BANKING__MICR_CODE, PARTY_BANKING__PRIMARY_ACCOUNT_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ACCOUNT_NUMBER_MASKED_CK: 'PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK'
  ACCOUNT_HOLDER_NAME: 'PARTY_BANKING__ACCOUNT_HOLDER_NAME'
  ACCOUNT_NUMBER_MASKED: 'PARTY_BANKING__ACCOUNT_NUMBER_MASKED'
  ACCOUNT_TYPE: 'PARTY_BANKING__ACCOUNT_TYPE'
  BANK_NAME: 'PARTY_BANKING__BANK_NAME'
  BRANCH_NAME: 'PARTY_BANKING__BRANCH_NAME'
  IFSC_CODE: 'PARTY_BANKING__IFSC_CODE'
  MICR_CODE: 'PARTY_BANKING__MICR_CODE'
  PRIMARY_ACCOUNT_INDICATOR: 'PARTY_BANKING__PRIMARY_ACCOUNT_INDICATOR'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
