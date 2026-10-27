{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL hub() for HUB_COVERAGE, 3 contributing table(s) + 17 wide-benefit
-- unpivot branches on BJAZ_TRV_LOADER_DATA_MV (round 2, Correction C).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_bjaz_trv_plan_mv__coverage'
  - 'stg2_hub_bjaz_trv_rider_dtls_mv__coverage'
  - 'stg2_hub_bjaz_trv_rider_rate_mast_mv__coverage'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_acchospexp'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_adventuresportbenefit'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_bouncedhotel'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_compvisitfamilymember'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_delayofcheckedbaggage'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_emergencyhotelextension'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_emermedicalevac'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_homeburglaryinsurance'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_hospdailyallow'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_lossofbaggage'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_lossofcheckedbaggage'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_missedconnection'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_personalliability'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_repatonofremains'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_tripcancellation'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_tripcurtailment'
  - 'stg2_hub_bjaz_trv_loader_data_mv__coverage_tripdelaybyscheduledaircraft'
src_pk: 'COVERAGE_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
