{{ config(materialized='view') }}

-- MAXIMUS PARTNER stage() for STAKE_CODE, sourced from
-- BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY.
-- Produces the STAKE_CODE_HKEY used by HUB_STAKE_CODE (and later LNK_PARTY_STAKE_CODE).

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_relparty'
hashed_columns:
  STAKE_CODE_HKEY: 'STAKE_CODE_NK'
derived_columns:
  STAKE_CODE_BK: "stake_code"
  STAKE_CODE_NK: "'HUB_STAKE_CODE|' || (stake_code)"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
