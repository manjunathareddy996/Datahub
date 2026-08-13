{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL sat() for SAT_AGREEMENT_COMMERCIAL_TERMS (HUB_AGREEMENT grain) -- single contributing table.

{%- set yaml_metadata -%}
source_model: 'stg2_sat_bjaz_intermediary__agreement_commercial_terms'
src_pk: 'AGREEMENT_HKEY'
src_payload:
  - 'COMMISSIONSTRUCTURE'
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
