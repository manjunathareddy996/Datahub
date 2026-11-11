-- hub() for HUB_PAYMENT_INSTRUMENT, unioned over every central view that carries its key.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_v09_claim'
  - 'stg2_v11_claim'
src_pk: 'PAYMENT_INSTRUMENT_HKEY'
src_nk: 'PAYMENT_INSTRUMENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                   src_nk=metadata_dict['src_nk'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
