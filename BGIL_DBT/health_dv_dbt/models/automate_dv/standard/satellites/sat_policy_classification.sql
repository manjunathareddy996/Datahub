{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_POLICY_CLASSIFICATION (HUB_POLICY grain) -- union of 10 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_ba_hcp_dt_premium__policy_classification'
  - 'stg2_sat_ba_hcp_prod_8428_gpg_loader__policy_classification'
  - 'stg2_sat_ba_hcp_prod_8432_ecp_loader__policy_classification'
  - 'stg2_sat_ba_hcp_prod_8433_fhc_loader__policy_classification'
  - 'stg2_sat_ba_hcp_prod_8439_clh_loader__policy_classification'
  - 'stg2_sat_bgil_gmc_final_instl_data__policy_classification'
  - 'stg2_sat_bjaz_bandhan_medi_clam__policy_classification'
  - 'stg2_sat_bjaz_gpg_pol_dtls__policy_classification'
  - 'stg2_sat_bjaz_grp_hlt_dtls__policy_classification'
  - 'stg2_sat_bjaz_health_webservice_info__policy_classification'
src_pk: 'POLICY_HK'
src_cdk:
  - 'CLASSIFICATION_TYPE_CK'
src_payload:
  - 'CLASSIFICATION_VALUE'
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
