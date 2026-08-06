{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_RISK_OBJECT_CORE (HUB_RISK_OBJECT grain) -- single contributing table.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_ba_hcp_prod_8428_gpg_loader__risk_object_core'
src_pk: 'RISK_OBJECT_HK'
src_payload:
  - 'RISK_CLASS_CODE'
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
