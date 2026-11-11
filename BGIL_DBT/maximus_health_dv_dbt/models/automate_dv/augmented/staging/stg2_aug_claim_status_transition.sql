-- automate_dv.stage() for SAT_AUG_CLAIM_STATUS_TRANSITION, read off central view stitch_v05_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v05_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'STATUS_CODE'
      - 'TRANSITION_COMMENTS'
      - 'TRANSITION_DATE'
      - 'TRANSITION_PERFORMED_BY_REFERENCE'
      - 'STATUS_CODE_CK'
      - 'TRANSITION_DATE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE, AUG_CLAIM_STATUS_TRANSITION__TRANSITION_COMMENTS, AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE, AUG_CLAIM_STATUS_TRANSITION__TRANSITION_PERFORMED_BY_REFERENCE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  STATUS_CODE_CK: 'AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE_CK'
  TRANSITION_DATE_CK: 'AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE_CK'
  STATUS_CODE: 'AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE'
  TRANSITION_COMMENTS: 'AUG_CLAIM_STATUS_TRANSITION__TRANSITION_COMMENTS'
  TRANSITION_DATE: 'AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE'
  TRANSITION_PERFORMED_BY_REFERENCE: 'AUG_CLAIM_STATUS_TRANSITION__TRANSITION_PERFORMED_BY_REFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v05_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
