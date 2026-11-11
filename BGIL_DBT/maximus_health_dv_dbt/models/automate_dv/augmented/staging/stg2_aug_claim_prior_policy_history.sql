-- automate_dv.stage() for SAT_AUG_CLAIM_PRIOR_POLICY_HISTORY, read off central view stitch_v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRIOR_CLAIM_HISTORY_DESCRIPTION'
      - 'PRIOR_POLICY_HISTORY_DETAIL'
      - 'PRIOR_POLICY_NUMBER_CK'
      - 'PRIOR_POLICY_REFERENCE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_CLAIM_HISTORY_DESCRIPTION, AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_HISTORY_DETAIL) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  PRIOR_POLICY_NUMBER_CK: 'AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_NUMBER_CK'
  PRIOR_POLICY_REFERENCE_CK: 'AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_REFERENCE_CK'
  PRIOR_CLAIM_HISTORY_DESCRIPTION: 'AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_CLAIM_HISTORY_DESCRIPTION'
  PRIOR_POLICY_HISTORY_DETAIL: 'AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_HISTORY_DETAIL'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
