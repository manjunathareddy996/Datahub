{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_COVERAGE_DEFINITION (parent HUB_COVERAGE).
-- Round-2: added the 17 wide-benefit unpivot branches (Correction C) -- each Free Cover
-- Limit column on BJAZ_TRV_LOADER_DATA_MV is its own coverage instance, keyed by
-- POLICY_REF || benefit-name literal (see hub_coverage.sql).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_coverage_definition_bjaz_trv_plan_mv'
  - 'stg2_coverage_definition_bjaz_trv_rider_dtls_mv'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_acchospexp'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_adventuresportbenefit'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_bouncedhotel'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_compvisitfamilymember'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_delayofcheckedbaggage'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_emergencyhotelextension'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_emermedicalevac'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_homeburglaryinsurance'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_hospdailyallow'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_lossofbaggage'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_lossofcheckedbaggage'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_missedconnection'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_personalliability'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_repatonofremains'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_tripcancellation'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_tripcurtailment'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_mv_tripdelaybyscheduledaircraft'
src_pk: 'COVERAGE_HKEY'
src_payload:
  - 'COVERAGE_DESCRIPTION'
  - 'COVERAGE_NAME'
  - 'FREE_COVER_LIMIT'
  - 'PERIL_COVERED'
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
