-- automate_dv.stage() for SAT_PARTY_MARKETING, read off central view stitch_motor__v06_distribution_channel.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v06_distribution_channel'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CAMPAIGN_REFERENCE'
      - 'CAMPAIGN_RESPONSE_INDICATOR'
      - 'LEAD_SOURCE'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_MARKETING__CAMPAIGN_REFERENCE, PARTY_MARKETING__CAMPAIGN_RESPONSE_INDICATOR, PARTY_MARKETING__LEAD_SOURCE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CAMPAIGN_REFERENCE: 'PARTY_MARKETING__CAMPAIGN_REFERENCE'
  CAMPAIGN_RESPONSE_INDICATOR: 'PARTY_MARKETING__CAMPAIGN_RESPONSE_INDICATOR'
  LEAD_SOURCE: 'PARTY_MARKETING__LEAD_SOURCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v06_distribution_channel'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
