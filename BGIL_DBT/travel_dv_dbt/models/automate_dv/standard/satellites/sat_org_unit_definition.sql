{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_ORG_UNIT_DEFINITION (parent HUB_ORG_UNIT).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_org_unit_definition_ba_trv_data_policy_dtls_mv'
src_pk: 'ORG_UNIT_HKEY'
src_payload:
  - 'COST_CENTRE_CODE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
