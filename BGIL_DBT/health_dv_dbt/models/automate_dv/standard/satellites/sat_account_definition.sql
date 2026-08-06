{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_ACCOUNT_DEFINITION (HUB_FINANCIAL_ACCOUNT grain) -- stitch-backed, 2 table(s) joined.
-- Source: stg2_account_definition.

{%- set yaml_metadata -%}
source_model: 'stg2_account_definition'
src_pk: 'FINANCIAL_ACCOUNT_HKEY'
src_payload:
  - 'ACCOUNT_CATEGORY'
  - 'ACCOUNT_TYPE'
  - 'CLOSING_DATE'
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
