-- automate_dv.stage() for SAT_PROPOSAL_UNDERWRITING, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REFERRAL_DATE'
      - 'REFERRAL_REASON'
derived_columns:
  PROPOSAL_NK: "case when coalesce(PROPOSAL_UNDERWRITING__REFERRAL_DATE, PROPOSAL_UNDERWRITING__REFERRAL_REASON) is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  REFERRAL_DATE: 'PROPOSAL_UNDERWRITING__REFERRAL_DATE'
  REFERRAL_REASON: 'PROPOSAL_UNDERWRITING__REFERRAL_REASON'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
