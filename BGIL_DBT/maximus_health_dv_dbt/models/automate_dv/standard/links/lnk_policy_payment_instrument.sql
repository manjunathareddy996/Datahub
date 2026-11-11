-- link() for LNK_POLICY_PAYMENT_INSTRUMENT. Every row's legs come from one source row on one central view.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_v08_financial_transaction'
  - 'stg2_v11_party'
src_pk: 'POLICY_PAYMENT_INSTRUMENT_HKEY'
src_fk:
  - 'PAYMENT_INSTRUMENT_HKEY'
  - 'POLICY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                    src_fk=metadata_dict['src_fk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
