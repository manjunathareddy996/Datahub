-- link() for LNK_POLICY_RISK_OBJECT. Every row's legs come from one source row on one central view.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_v03_assessment'
  - 'stg2_v13_financial_account'
  - 'stg2_v21_party'
  - 'stg2_v28_policy'
  - 'stg2_v31_product'
  - 'stg2_v33_quote'
  - 'stg2_v34_risk_object'
src_pk: 'POLICY_RISK_OBJECT_HKEY'
src_fk:
  - 'POLICY_HKEY'
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
