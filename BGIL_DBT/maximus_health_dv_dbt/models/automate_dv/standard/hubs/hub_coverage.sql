-- hub() for HUB_COVERAGE, unioned over every central view that carries its key.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_v02_claim'
  - 'stg2_v04_claim'
  - 'stg2_v05_claim'
  - 'stg2_v06_coverage'
  - 'stg2_v09_financial_transaction'
  - 'stg2_v15_policy'
  - 'stg2_v16_policy'
  - 'stg2_v17_policy'
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
