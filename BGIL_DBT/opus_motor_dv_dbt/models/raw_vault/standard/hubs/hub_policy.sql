-- hub() for HUB_POLICY, unioned over every central view that carries its key.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_motor__v01_claim'
  - 'stg2_motor__v03_claim'
  - 'stg2_motor__v05_coverage'
  - 'stg2_motor__v06_distribution_channel'
  - 'stg2_motor__v08_org_unit'
  - 'stg2_motor__v10_party'
  - 'stg2_motor__v11_party'
  - 'stg2_motor__v12_policy'
  - 'stg2_motor__v13_policy'
  - 'stg2_motor__v14_policy'
  - 'stg2_motor__v15_policy'
  - 'stg2_motor__v16_policy'
  - 'stg2_motor__v17_policy'
  - 'stg2_motor__v18_policy'
  - 'stg2_motor__v19_policy'
  - 'stg2_motor__v21_product'
  - 'stg2_motor__v25_risk_object'
src_pk: 'POLICY_HKEY'
src_nk: 'POLICY_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                   src_nk=metadata_dict['src_nk'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
