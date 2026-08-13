{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_POLICY_COVERAGE_SCHEDULE (HUB_POLICY grain) -- union of 6 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_ba_hcp_dt_pol_cov__policy_coverage_schedule'
  - 'stg2_sat_ba_hcp_prod_8432_ecp_loader__policy_coverage_schedule'
  - 'stg2_sat_ba_hcp_prod_8433_fhc_loader__policy_coverage_schedule'
  - 'stg2_sat_bjaz_grp_hlt_dtls__policy_coverage_schedule'
  - 'stg2_sat_bjaz_grp_hlt_maternity_dtls__policy_coverage_schedule'
  - 'stg2_sat_bjaz_hg_pol_dtls__policy_coverage_schedule'
src_pk: 'POLICY_HK'
src_cdk:
  - 'COVERAGE_REFERENCE_CK'
  - 'COVERAGE_SEQUENCE_CK'
src_payload:
  - 'COVERAGE_OPTED_INDICATOR'
  - 'CO_PAYMENT_AMOUNT'
  - 'CO_PAYMENT_PERCENTAGE'
  - 'PREMIUM_FOR_COVERAGE'
  - 'SUB_LIMIT_AMOUNT'
  - 'SUM_INSURED'
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
