-- automate_dv.stage() for SAT_AUG_PARTY_FRAUD_PROFILE, read off central view stitch_v01_agreement.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v01_agreement'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FRAUD_SUSPICION_REASON'
derived_columns:
  PARTY_NK: "case when AUG_PARTY_FRAUD_PROFILE__FRAUD_SUSPICION_REASON is not null then 'HUB_PARTY|' || PARTY_BK end"
  FRAUD_SUSPICION_REASON: 'AUG_PARTY_FRAUD_PROFILE__FRAUD_SUSPICION_REASON'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v01_agreement'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
