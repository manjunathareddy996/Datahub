-- automate_dv.stage() for SAT_MOTOR_AUG_LNK_POLICY_PARTY_ROLE, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  POLICY_PARTY_HKEY: 'POLICY_PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RELATIONSHIP_TO_INSURED'
derived_columns:
  POLICY_PARTY_NK: "case when AUG_LNK_POLICY_PARTY_ROLE__RELATIONSHIP_TO_INSURED is not null then 'LNK_POLICY_PARTY|' || PARTY_BK || '|' || POLICY_BK end"
  RELATIONSHIP_TO_INSURED: 'AUG_LNK_POLICY_PARTY_ROLE__RELATIONSHIP_TO_INSURED'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
