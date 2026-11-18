-- automate_dv.stage() for SAT_AUG_CLAIM_SUB_FILE, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SUB_FILE_NUMBER'
      - 'SUB_FILE_REMARKS'
      - 'SUB_FILE_NUMBER_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER, AUG_CLAIM_SUB_FILE__SUB_FILE_REMARKS) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  SUB_FILE_NUMBER_CK: 'AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER_CK'
  SUB_FILE_NUMBER: 'AUG_CLAIM_SUB_FILE__SUB_FILE_NUMBER'
  SUB_FILE_REMARKS: 'AUG_CLAIM_SUB_FILE__SUB_FILE_REMARKS'
  LOAD_DATETIME: 'AUG_CLAIM_SUB_FILE__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
