{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_COVERAGE_DEFINITION (parent HUB_COVERAGE).
-- Round-2: added the 17 wide-benefit unpivot branches (Correction C) -- each Free Cover
-- Limit column on BJAZ_TRV_LOADER_DATA is its own coverage instance, keyed by
-- POLICY_REF || benefit-name literal (see hub_coverage.sql).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_coverage_definition_bjaz_trv_plan'
  - 'stg2_coverage_definition_bjaz_trv_rider_dtls'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_acchospexp'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_adventuresportbenefit'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_bouncedhotel'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_compvisitfamilymember'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_delayofcheckedbaggage'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_emergencyhotelextension'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_emermedicalevac'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_homeburglaryinsurance'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_hospdailyallow'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_lossofbaggage'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_lossofcheckedbaggage'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_missedconnection'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_personalliability'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_repatonofremains'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_tripcancellation'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_tripcurtailment'
  - 'stg2_coverage_definition_bjaz_trv_loader_data_tripdelaybyscheduledaircraft'
src_pk: 'COVERAGE_HKEY'
src_payload:
  - 'COVERAGE_DESCRIPTION'
  - 'COVERAGE_NAME'
  - 'FREE_COVER_LIMIT'
  - 'PERIL_COVERED'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_coverage_definition_bjaz_trv_plan: 'OPUS'
  stg2_coverage_definition_bjaz_trv_rider_dtls: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_acchospexp: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_adventuresportbenefit: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_bouncedhotel: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_compvisitfamilymember: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_delayofcheckedbaggage: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_emergencyhotelextension: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_emermedicalevac: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_homeburglaryinsurance: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_hospdailyallow: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_lossofbaggage: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_lossofcheckedbaggage: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_missedconnection: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_personalliability: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_repatonofremains: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_tripcancellation: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_tripcurtailment: 'OPUS'
  stg2_coverage_definition_bjaz_trv_loader_data_tripdelaybyscheduledaircraft: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map']) }}
