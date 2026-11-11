-- automate_dv.stage() for SAT_AUG_POLICY_FOLLOW_UP_LOG, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EFFECTIVE_DATE'
      - 'ENTRY_DATE'
      - 'ENTRY_REMARKS'
      - 'ENTRY_TIME'
      - 'RELATED_ENDORSEMENT_OR_CLAIM_REFERENCE'
      - 'STATUS_CODE'
      - 'SUB_STATUS_CODE'
      - 'ENTRY_TIMESTAMP_CK'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_FOLLOW_UP_LOG__EFFECTIVE_DATE, AUG_POLICY_FOLLOW_UP_LOG__ENTRY_DATE, AUG_POLICY_FOLLOW_UP_LOG__ENTRY_REMARKS, AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIME, AUG_POLICY_FOLLOW_UP_LOG__RELATED_ENDORSEMENT_OR_CLAIM_REFERENCE, AUG_POLICY_FOLLOW_UP_LOG__STATUS_CODE, AUG_POLICY_FOLLOW_UP_LOG__SUB_STATUS_CODE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  ENTRY_TIMESTAMP_CK: 'AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIMESTAMP_CK'
  EFFECTIVE_DATE: 'AUG_POLICY_FOLLOW_UP_LOG__EFFECTIVE_DATE'
  ENTRY_DATE: 'AUG_POLICY_FOLLOW_UP_LOG__ENTRY_DATE'
  ENTRY_REMARKS: 'AUG_POLICY_FOLLOW_UP_LOG__ENTRY_REMARKS'
  ENTRY_TIME: 'AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIME'
  RELATED_ENDORSEMENT_OR_CLAIM_REFERENCE: 'AUG_POLICY_FOLLOW_UP_LOG__RELATED_ENDORSEMENT_OR_CLAIM_REFERENCE'
  STATUS_CODE: 'AUG_POLICY_FOLLOW_UP_LOG__STATUS_CODE'
  SUB_STATUS_CODE: 'AUG_POLICY_FOLLOW_UP_LOG__SUB_STATUS_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
