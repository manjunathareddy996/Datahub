{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_CLAIM_FNOL (HUB_CLAIM grain) -- single contributing table.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_tpa_claim_details_ws__claim_fnol'
src_pk: 'CLAIM_HK'
src_payload:
  - 'PRELIMINARY_LOSS_ESTIMATE'
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
