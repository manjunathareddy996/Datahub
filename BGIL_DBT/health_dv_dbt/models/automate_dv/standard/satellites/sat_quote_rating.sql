{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_QUOTE_RATING (HUB_QUOTE grain) -- single contributing table.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_grp_hlt_dtls__quote_rating'
src_pk: 'QUOTE_HK'
src_payload:
  - 'DISCOUNT_AMOUNT'
  - 'GROSS_PREMIUM'
  - 'TOTAL_ANNUAL_PREMIUM'
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
