-- automate_dv.stage() for SAT_AUG_QUOTE_PREMIUM_RATE_SLAB, read off central view stitch_v33_quote.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v33_quote'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREMIUM_RATING_BASIS'
      - 'RATE_APPLICABILITY_STAGE'
      - 'RATE_RECORD_DATE'
      - 'RATE_SOURCE_NAME'
      - 'SUM_INSURED_SLAB_AMOUNT'
      - 'PREMIUM_TYPE_CK'
      - 'SUM_INSURED_SLAB_CK'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_PREMIUM_RATE_SLAB__PREMIUM_RATING_BASIS, AUG_QUOTE_PREMIUM_RATE_SLAB__RATE_APPLICABILITY_STAGE, AUG_QUOTE_PREMIUM_RATE_SLAB__RATE_RECORD_DATE, AUG_QUOTE_PREMIUM_RATE_SLAB__RATE_SOURCE_NAME, AUG_QUOTE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  PREMIUM_TYPE_CK: 'AUG_QUOTE_PREMIUM_RATE_SLAB__PREMIUM_TYPE_CK'
  SUM_INSURED_SLAB_CK: 'AUG_QUOTE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_CK'
  PREMIUM_RATING_BASIS: 'AUG_QUOTE_PREMIUM_RATE_SLAB__PREMIUM_RATING_BASIS'
  RATE_APPLICABILITY_STAGE: 'AUG_QUOTE_PREMIUM_RATE_SLAB__RATE_APPLICABILITY_STAGE'
  RATE_RECORD_DATE: 'AUG_QUOTE_PREMIUM_RATE_SLAB__RATE_RECORD_DATE'
  RATE_SOURCE_NAME: 'AUG_QUOTE_PREMIUM_RATE_SLAB__RATE_SOURCE_NAME'
  SUM_INSURED_SLAB_AMOUNT: 'AUG_QUOTE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v33_quote'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
