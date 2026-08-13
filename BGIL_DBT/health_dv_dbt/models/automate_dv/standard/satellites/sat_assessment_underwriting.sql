{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_ASSESSMENT_UNDERWRITING (HUB_ASSESSMENT grain) -- stitch-backed, 3 table(s) joined.
-- Source: stg2_assessment_underwriting.

{%- set yaml_metadata -%}
source_model: 'stg2_assessment_underwriting'
src_pk: 'ASSESSMENT_HKEY'
src_payload:
  - 'SPECIAL_CONDITIONS_RECOMMENDED'
  - 'UNDERWRITING_REMARKS'
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
