-- automate_dv.stage() for SAT_AUG_CLAIM_FRAUD, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AML_WAIVER_INDICATOR'
      - 'AML_WAIVER_REASON'
      - 'BYPASS_AUTHORISED_BY_USER_REFERENCE'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_FRAUD__AML_WAIVER_INDICATOR, AUG_CLAIM_FRAUD__AML_WAIVER_REASON, AUG_CLAIM_FRAUD__BYPASS_AUTHORISED_BY_USER_REFERENCE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  AML_WAIVER_INDICATOR: 'AUG_CLAIM_FRAUD__AML_WAIVER_INDICATOR'
  AML_WAIVER_REASON: 'AUG_CLAIM_FRAUD__AML_WAIVER_REASON'
  BYPASS_AUTHORISED_BY_USER_REFERENCE: 'AUG_CLAIM_FRAUD__BYPASS_AUTHORISED_BY_USER_REFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
