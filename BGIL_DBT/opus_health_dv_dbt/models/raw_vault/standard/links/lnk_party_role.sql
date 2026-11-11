-- link() for LNK_PARTY_ROLE. Every row's legs come from one source row on one central view.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_v01_agreement'
  - 'stg2_v03_assessment'
  - 'stg2_v11_claim'
  - 'stg2_v16_party'
  - 'stg2_v17_party'
  - 'stg2_v18_party'
  - 'stg2_v19_party'
  - 'stg2_v20_party'
  - 'stg2_v34_risk_object'
src_pk: 'PARTY_ROLE_HKEY'
src_fk:
  - 'PARTY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                    src_fk=metadata_dict['src_fk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
