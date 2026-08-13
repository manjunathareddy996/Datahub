{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_FIN_CHARGE_RATE (HUB_POLICY grain) -- single contributing table.
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): converted sat() -> ma_sat(),
-- child key CHARGE_TYPE_CK, per data_7's Phase 7 grain change for this satellite.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_grp_tpa_extn__fin_charge_rate'
src_pk: 'POLICY_HK'
src_cdk:
  - 'CHARGE_TYPE_CK'
src_payload:
  - 'CHARGE_AMOUNT'
  - 'CHARGE_RATE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model']) }}
