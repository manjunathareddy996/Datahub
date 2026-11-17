-- link() for LNK_PROPOSAL_RISK_OBJECT. Every row's legs come from one source row on one central view.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_motor__v06_distribution_channel'
  - 'stg2_motor__v11_party'
  - 'stg2_motor__v14_policy'
  - 'stg2_motor__v15_policy'
  - 'stg2_motor__v22_quote'
  - 'stg2_motor__v24_risk_object'
src_pk: 'PROPOSAL_RISK_OBJECT_HKEY'
src_fk:
  - 'PROPOSAL_HKEY'
  - 'RISK_OBJECT_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                    src_fk=metadata_dict['src_fk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
