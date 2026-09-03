{{ config(materialized='view') }}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) WIDE stage() for HUB_PAYMENT_INSTRUMENT, view 'pd_prop_msdp_pv'.
-- Serves 1 augmented satellite(s), one HASHDIFF each, from 1
-- column(s) with no faithful home in data_7. The KEY is the standard track's own
-- expression for HUB_PAYMENT_INSTRUMENT on this view; the ATTRIBUTE GROUPING is the mapper's
-- proposal and is NOT canonical.

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_prop_msdp_pv'
hashed_columns:
  PAYMENT_INSTRUMENT_HKEY: 'PAYMENT_INSTRUMENT_NK'
  HASHDIFF_AUG_INSTRUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'PAYMENTGATEWAYNAME'
derived_columns:
  PAYMENT_INSTRUMENT_BK: "'HUB_PAYMENT_INSTRUMENT|' || foreign_key"
  PAYMENT_INSTRUMENT_NK: "'HUB_PAYMENT_INSTRUMENT|' || ('HUB_PAYMENT_INSTRUMENT|' || foreign_key)"
  PAYMENTGATEWAYNAME: "gateway_name"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!pd_prop_msdp_pv'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
