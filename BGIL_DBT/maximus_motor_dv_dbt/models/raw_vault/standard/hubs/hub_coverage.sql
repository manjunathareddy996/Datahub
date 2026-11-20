-- hub() for HUB_COVERAGE, unioned over every central view that carries its key.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_mxm__v01_assessment'
  - 'stg2_mxm__v05_coverage'
  - 'stg2_mxm__v07_financial_transaction'
  - 'stg2_mxm__v14_risk_object'
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
