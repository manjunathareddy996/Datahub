-- hub() for HUB_PARTY, unioned over every central view that carries its key.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_mxm__v03_claim'
  - 'stg2_mxm__v04_claim'
  - 'stg2_mxm__v08_location'
  - 'stg2_mxm__v09_party'
  - 'stg2_mxm__v10_party'
  - 'stg2_mxm__v11_party'
  - 'stg2_mxm__v12_policy'
  - 'stg2_mxm__v14_risk_object'
src_pk: 'PARTY_HKEY'
src_nk: 'PARTY_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                   src_nk=metadata_dict['src_nk'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
