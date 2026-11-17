{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat_multi_source() for SAT_POLICY_COVERAGE_SCHEDULE.
-- Writes the SAME physical table as opus_partner / opus_health: separate projects, separate
-- pipelines, one shared vault. Grain is unchanged: POLICY_HKEY, multi-active on
-- COVERAGE_REFERENCE + COVERAGE_SEQUENCE, bare HASHDIFF.
--
-- ma_sat_multi_source groups change detection by (POLICY_HKEY, RECORD_SOURCE) and takes the watermark
-- from MAX(DBT_RUN_TS) of MAXIMUS_TRAVEL_* rows only, so this project never compares against the
-- other projects' rows on the shared table. One satfeed per stage (no UNION).

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mt_sat_policy_coverage_schedule__clm_clmd_clmap_pv'
  - 'satfeed_mt_sat_policy_coverage_schedule__uwr_pol_ins_cov'
  - 'satfeed_mt_sat_policy_coverage_schedule__uwr_pol_ins_cov_covp_sp_pv'
  - 'satfeed_mt_sat_policy_coverage_schedule__uwr_pol_ins_rskp_sp_pv'
  - 'satfeed_mt_sat_policy_coverage_schedule__uwr_pol_polp_msp_msd_prop_pv'
  - 'satfeed_mt_sat_policy_coverage_schedule__uwr_pol_polp_sp_pv'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'COVERAGE_REFERENCE'
  - 'COVERAGE_SEQUENCE'
src_payload:
  - 'COVERAGE_END_DATE'
  - 'COVERAGE_OPTED_INDICATOR'
  - 'COVERAGE_START_DATE'
  - 'CO_PAYMENT_PERCENTAGE'
  - 'DEDUCTIBLE_AMOUNT'
  - 'LIMIT_AMOUNT'
  - 'PREMIUM_FOR_COVERAGE'
  - 'SUM_INSURED'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  satfeed_mt_sat_policy_coverage_schedule__clm_clmd_clmap_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_policy_coverage_schedule__uwr_pol_ins_cov: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_policy_coverage_schedule__uwr_pol_ins_cov_covp_sp_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_policy_coverage_schedule__uwr_pol_ins_rskp_sp_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_policy_coverage_schedule__uwr_pol_polp_msp_msd_prop_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_policy_coverage_schedule__uwr_pol_polp_sp_pv: 'MAXIMUS_TRAVEL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ ma_sat_multi_source(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model'],
                       src_record_source_map=metadata_dict['src_record_source_map'],
                       src_column_map={
                        'satfeed_mt_sat_policy_coverage_schedule__clm_clmd_clmap_pv': ['COVERAGE_END_DATE', 'COVERAGE_OPTED_INDICATOR', 'COVERAGE_START_DATE', 'CO_PAYMENT_PERCENTAGE', 'DEDUCTIBLE_AMOUNT', 'LIMIT_AMOUNT', 'PREMIUM_FOR_COVERAGE', 'SUM_INSURED'],
                        'satfeed_mt_sat_policy_coverage_schedule__uwr_pol_ins_cov': ['COVERAGE_END_DATE', 'COVERAGE_OPTED_INDICATOR', 'COVERAGE_START_DATE', 'CO_PAYMENT_PERCENTAGE', 'DEDUCTIBLE_AMOUNT', 'LIMIT_AMOUNT', 'PREMIUM_FOR_COVERAGE', 'SUM_INSURED'],
                        'satfeed_mt_sat_policy_coverage_schedule__uwr_pol_ins_cov_covp_sp_pv': ['COVERAGE_END_DATE', 'COVERAGE_OPTED_INDICATOR', 'COVERAGE_START_DATE', 'CO_PAYMENT_PERCENTAGE', 'DEDUCTIBLE_AMOUNT', 'LIMIT_AMOUNT', 'PREMIUM_FOR_COVERAGE', 'SUM_INSURED'],
                        'satfeed_mt_sat_policy_coverage_schedule__uwr_pol_ins_rskp_sp_pv': ['COVERAGE_END_DATE', 'COVERAGE_OPTED_INDICATOR', 'COVERAGE_START_DATE', 'CO_PAYMENT_PERCENTAGE', 'DEDUCTIBLE_AMOUNT', 'LIMIT_AMOUNT', 'PREMIUM_FOR_COVERAGE', 'SUM_INSURED'],
                        'satfeed_mt_sat_policy_coverage_schedule__uwr_pol_polp_msp_msd_prop_pv': ['COVERAGE_END_DATE', 'COVERAGE_OPTED_INDICATOR', 'COVERAGE_START_DATE', 'CO_PAYMENT_PERCENTAGE', 'DEDUCTIBLE_AMOUNT', 'LIMIT_AMOUNT', 'PREMIUM_FOR_COVERAGE', 'SUM_INSURED'],
                        'satfeed_mt_sat_policy_coverage_schedule__uwr_pol_polp_sp_pv': ['COVERAGE_END_DATE', 'COVERAGE_OPTED_INDICATOR', 'COVERAGE_START_DATE', 'CO_PAYMENT_PERCENTAGE', 'DEDUCTIBLE_AMOUNT', 'LIMIT_AMOUNT', 'PREMIUM_FOR_COVERAGE', 'SUM_INSURED']
                       }) }}
