-- automate_dv.stage() for SAT_AUG_CLAIM_BILL_DIGITISATION, read off central view stitch_v06_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDENDUM_STATUS'
      - 'REFERENCED_BILL_REFERENCE'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS, AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  ADDENDUM_STATUS: 'AUG_CLAIM_BILL_DIGITISATION__ADDENDUM_STATUS'
  REFERENCED_BILL_REFERENCE: 'AUG_CLAIM_BILL_DIGITISATION__REFERENCED_BILL_REFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
