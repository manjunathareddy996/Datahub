-- automate_dv.stage() for SAT_AUG_CLAIM_SALVAGE_BIDDER, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BIDDER_DETAILS_TEXT'
      - 'BID_INVITATION_SENT_DATE'
      - 'BIDDER_SEQUENCE_CK'
      - 'BIDDER_NAME_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_SALVAGE_BIDDER__BIDDER_DETAILS_TEXT, AUG_CLAIM_SALVAGE_BIDDER__BID_INVITATION_SENT_DATE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  BIDDER_SEQUENCE_CK: 'AUG_CLAIM_SALVAGE_BIDDER__BIDDER_SEQUENCE_CK'
  BIDDER_NAME_CK: 'AUG_CLAIM_SALVAGE_BIDDER__BIDDER_NAME_CK'
  BIDDER_DETAILS_TEXT: 'AUG_CLAIM_SALVAGE_BIDDER__BIDDER_DETAILS_TEXT'
  BID_INVITATION_SENT_DATE: 'AUG_CLAIM_SALVAGE_BIDDER__BID_INVITATION_SENT_DATE'
  LOAD_DATETIME: 'AUG_CLAIM_SALVAGE_BIDDER__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
