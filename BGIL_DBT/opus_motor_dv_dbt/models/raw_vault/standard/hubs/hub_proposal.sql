-- hub() for HUB_PROPOSAL, unioned over every central view that carries its key.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_motor__v06_distribution_channel'
  - 'stg2_motor__v09_party'
  - 'stg2_motor__v10_party'
  - 'stg2_motor__v11_party'
  - 'stg2_motor__v14_policy'
  - 'stg2_motor__v15_policy'
  - 'stg2_motor__v21_product'
  - 'stg2_motor__v22_quote'
  - 'stg2_motor__v24_risk_object'
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
