{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_POLICY_DISCOUNT_LOADING_APPLIED (HUB_POLICY grain) -- union of 3 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_ba_hcp_dt_premium__policy_discount_loading_applied'
  - 'stg2_sat_ba_hcp_pol_mst__policy_discount_loading_applied'
  - 'stg2_sat_bjaz_health_webservice_info__policy_discount_loading_applied'
src_pk: 'POLICY_HK'
src_cdk:
  - 'ITEM_CODE_CK'
src_payload:
  - 'AMOUNT_APPLIED'
  - 'PERCENTAGE_APPLIED'
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
