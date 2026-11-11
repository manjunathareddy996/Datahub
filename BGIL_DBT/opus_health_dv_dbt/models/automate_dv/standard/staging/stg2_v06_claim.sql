-- automate_dv.stage() over central view stitch_v06_claim: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  LOCATION_HKEY: 'LOCATION_NK'
  POLICY_HKEY: 'POLICY_NK'
  CLAIM_LOCATION_HKEY: 'CLAIM_LOCATION_NK'
  CLAIM_POLICY_HKEY: 'CLAIM_POLICY_NK'
  POLICY_LOCATION_HKEY: 'POLICY_LOCATION_NK'
derived_columns:
  CLAIM_BK: 'CLAIM_BK'
  CLAIM_NK: "'HUB_CLAIM|' || CLAIM_BK"
  LOCATION_BK: 'LOCATION_BK'
  LOCATION_NK: "'HUB_LOCATION|' || LOCATION_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  CLAIM_LOCATION_NK: "case when __LNK_CLAIM_LOCATION = 1 then 'LNK_CLAIM_LOCATION|' || CLAIM_BK || '|' || LOCATION_BK end"
  CLAIM_POLICY_NK: "case when __LNK_CLAIM_POLICY = 1 then 'LNK_CLAIM_POLICY|' || CLAIM_BK || '|' || POLICY_BK end"
  POLICY_LOCATION_NK: "case when __LNK_POLICY_LOCATION = 1 then 'LNK_POLICY_LOCATION|' || LOCATION_BK || '|' || POLICY_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
