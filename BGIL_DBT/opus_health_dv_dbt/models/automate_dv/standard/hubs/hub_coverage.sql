-- hub() for HUB_COVERAGE, unioned over every central view that carries its key.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_v03_assessment'
  - 'stg2_v12_coverage'
  - 'stg2_v20_party'
  - 'stg2_v24_policy'
  - 'stg2_v25_policy'
  - 'stg2_v31_product'
  - 'stg2_v32_product'
src_pk: 'COVERAGE_HKEY'
src_nk: 'COVERAGE_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                   src_nk=metadata_dict['src_nk'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
