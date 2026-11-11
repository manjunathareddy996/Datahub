-- hub() for HUB_PROPOSAL, unioned over every central view that carries its key.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_v03_assessment'
  - 'stg2_v13_financial_account'
  - 'stg2_v28_policy'
  - 'stg2_v31_product'
  - 'stg2_v32_product'
  - 'stg2_v33_quote'
src_pk: 'PROPOSAL_HKEY'
src_nk: 'PROPOSAL_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                   src_nk=metadata_dict['src_nk'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
