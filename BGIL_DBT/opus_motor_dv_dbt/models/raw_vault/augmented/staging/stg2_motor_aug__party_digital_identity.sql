-- automate_dv.stage() for SAT_AUG_PARTY_DIGITAL_IDENTITY, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BROWSER_NAME'
      - 'CLIENT_IP_ADDRESS'
      - 'CONNECTION_BANDWIDTH'
      - 'FORWARDED_IP_ADDRESS'
      - 'MACHINE_IP_ADDRESS'
      - 'PROXY_IP_ADDRESS'
      - 'THIRD_IP_ADDRESS'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
      - 'ACCESS_CHANNEL_CK'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_DIGITAL_IDENTITY__BROWSER_NAME, AUG_PARTY_DIGITAL_IDENTITY__CLIENT_IP_ADDRESS, AUG_PARTY_DIGITAL_IDENTITY__CONNECTION_BANDWIDTH, AUG_PARTY_DIGITAL_IDENTITY__FORWARDED_IP_ADDRESS, AUG_PARTY_DIGITAL_IDENTITY__MACHINE_IP_ADDRESS, AUG_PARTY_DIGITAL_IDENTITY__PROXY_IP_ADDRESS, AUG_PARTY_DIGITAL_IDENTITY__THIRD_IP_ADDRESS) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK'
  ACCESS_CHANNEL_CK: 'AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK'
  BROWSER_NAME: 'AUG_PARTY_DIGITAL_IDENTITY__BROWSER_NAME'
  CLIENT_IP_ADDRESS: 'AUG_PARTY_DIGITAL_IDENTITY__CLIENT_IP_ADDRESS'
  CONNECTION_BANDWIDTH: 'AUG_PARTY_DIGITAL_IDENTITY__CONNECTION_BANDWIDTH'
  FORWARDED_IP_ADDRESS: 'AUG_PARTY_DIGITAL_IDENTITY__FORWARDED_IP_ADDRESS'
  MACHINE_IP_ADDRESS: 'AUG_PARTY_DIGITAL_IDENTITY__MACHINE_IP_ADDRESS'
  PROXY_IP_ADDRESS: 'AUG_PARTY_DIGITAL_IDENTITY__PROXY_IP_ADDRESS'
  THIRD_IP_ADDRESS: 'AUG_PARTY_DIGITAL_IDENTITY__THIRD_IP_ADDRESS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
