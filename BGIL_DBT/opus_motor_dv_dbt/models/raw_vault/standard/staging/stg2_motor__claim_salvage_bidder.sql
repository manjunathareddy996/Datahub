-- automate_dv.stage() for SAT_CLAIM_SALVAGE_BIDDER, read off central view stitch_motor__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BIDDER_NAME'
      - 'BID_AMOUNT'
      - 'BID_DATE'
      - 'BIDDER_SEQUENCE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_SALVAGE_BIDDER__BIDDER_NAME, CLAIM_SALVAGE_BIDDER__BID_AMOUNT, CLAIM_SALVAGE_BIDDER__BID_DATE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  BIDDER_SEQUENCE_CK: 'CLAIM_SALVAGE_BIDDER__BIDDER_SEQUENCE_CK'
  BIDDER_NAME: 'CLAIM_SALVAGE_BIDDER__BIDDER_NAME'
  BID_AMOUNT: 'CLAIM_SALVAGE_BIDDER__BID_AMOUNT'
  BID_DATE: 'CLAIM_SALVAGE_BIDDER__BID_DATE'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_MOTOR_V03_CLAIM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
