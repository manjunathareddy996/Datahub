-- automate_dv.stage() for SAT_AUG_CLAIM_COMPARABLE_CLAIM, read off central view stitch_motor__v01_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v01_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMPARABLE_CLAIM_REFERENCE'
      - 'COMPARISON_SOURCE'
      - 'COMPARABLE_CLAIM_REFERENCE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE, AUG_CLAIM_COMPARABLE_CLAIM__COMPARISON_SOURCE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  COMPARABLE_CLAIM_REFERENCE_CK: 'AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE_CK'
  COMPARABLE_CLAIM_REFERENCE: 'AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE'
  COMPARISON_SOURCE: 'AUG_CLAIM_COMPARABLE_CLAIM__COMPARISON_SOURCE'
  LOAD_DATETIME: 'AUG_CLAIM_COMPARABLE_CLAIM__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v01_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
