-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_INSTRUMENT_DEFINITION (parent HUB_PAYMENT_INSTRUMENT, history SCD2), fed whole from central view stitch_v12_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_instrument_definition'
src_pk: 'PAYMENT_INSTRUMENT_HKEY'
src_payload:
  - 'CHEQUE_PAYABLE_STATE'
  - 'MANDATE_DEBIT_TYPE'
  - 'MANDATE_MAXIMUM_AMOUNT'
  - 'MANDATE_SIGNED_DATE'
  - 'MANDATE_UNTIL_CANCELLED_INDICATOR'
  - 'MICR_CODE'
  - 'PAYABLE_AT_LOCATION'
  - 'UTILITY_BILLER_CODE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                   src_payload=metadata_dict['src_payload'],
                   src_hashdiff=metadata_dict['src_hashdiff'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
