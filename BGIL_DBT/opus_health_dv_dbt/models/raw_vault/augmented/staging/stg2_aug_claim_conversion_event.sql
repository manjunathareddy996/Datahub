-- automate_dv.stage() for SAT_AUG_CLAIM_CONVERSION_EVENT, read off central view stitch_v06_claim.
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
      - 'CONVERSION_DATE'
      - 'CONVERSION_REFERENCE'
      - 'CONVERSION_TYPE_CODE'
      - 'CONVERTED_BY_USER_IDENTIFIER'
      - 'SUPERSEDED_CLAIM_REFERENCE'
      - 'CONVERSION_REFERENCE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE, AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE, AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE, AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER, AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  CONVERSION_REFERENCE_CK: 'AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE_CK'
  CONVERSION_DATE: 'AUG_CLAIM_CONVERSION_EVENT__CONVERSION_DATE'
  CONVERSION_REFERENCE: 'AUG_CLAIM_CONVERSION_EVENT__CONVERSION_REFERENCE'
  CONVERSION_TYPE_CODE: 'AUG_CLAIM_CONVERSION_EVENT__CONVERSION_TYPE_CODE'
  CONVERTED_BY_USER_IDENTIFIER: 'AUG_CLAIM_CONVERSION_EVENT__CONVERTED_BY_USER_IDENTIFIER'
  SUPERSEDED_CLAIM_REFERENCE: 'AUG_CLAIM_CONVERSION_EVENT__SUPERSEDED_CLAIM_REFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
