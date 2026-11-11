-- Standard sat() for SAT_INSTRUMENT_DEFINITION (parent HUB_PAYMENT_INSTRUMENT, history SCD2), fed whole from central view stitch_v11_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_instrument_definition'
src_pk: 'PAYMENT_INSTRUMENT_HKEY'
src_payload:
  - 'ACCOUNT_HOLDER_NAME'
  - 'ACCOUNT_NUMBER_MASKED'
  - 'BANK_NAME'
  - 'BRANCH_NAME'
  - 'CARD_NUMBER_MASKED'
  - 'CARD_TYPE'
  - 'IFSC_CODE'
  - 'MANDATE_REFERENCE'
  - 'MANDATE_STATUS'
  - 'VALID_FROM_DATE'
  - 'VALID_TO_DATE'
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
