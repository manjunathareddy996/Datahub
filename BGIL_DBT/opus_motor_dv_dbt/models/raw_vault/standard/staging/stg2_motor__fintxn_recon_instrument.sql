-- automate_dv.stage() for SAT_FINTXN_RECON_INSTRUMENT, read off central view stitch_motor__v06_distribution_channel.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v06_distribution_channel'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INSTRUMENT_AMOUNT'
      - 'INSTRUMENT_DATE'
      - 'INSTRUMENT_SEQUENCE_CK'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_RECON_INSTRUMENT__INSTRUMENT_AMOUNT, FINTXN_RECON_INSTRUMENT__INSTRUMENT_DATE) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  INSTRUMENT_SEQUENCE_CK: 'FINTXN_RECON_INSTRUMENT__INSTRUMENT_SEQUENCE_CK'
  INSTRUMENT_AMOUNT: 'FINTXN_RECON_INSTRUMENT__INSTRUMENT_AMOUNT'
  INSTRUMENT_DATE: 'FINTXN_RECON_INSTRUMENT__INSTRUMENT_DATE'
  LOAD_DATETIME: 'FINANCIAL_TRANSACTION_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v06_distribution_channel'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
