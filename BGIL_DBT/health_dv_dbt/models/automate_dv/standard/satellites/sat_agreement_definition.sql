{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_AGREEMENT_DEFINITION (HUB_AGREEMENT grain) -- stitch-backed, 4 table(s) joined.
-- Source: stg2_agreement_definition.

{%- set yaml_metadata -%}
source_model: 'stg2_agreement_definition'
src_pk: 'AGREEMENT_HKEY'
src_payload:
  - 'AGREEMENT_CATEGORY'
  - 'AGREEMENT_NAME'
  - 'AGREEMENT_STATUS'
  - 'AGREEMENT_TYPE'
  - 'EFFECTIVE_DATE'
  - 'EXECUTION_DATE'
  - 'EXPIRY_DATE'
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
