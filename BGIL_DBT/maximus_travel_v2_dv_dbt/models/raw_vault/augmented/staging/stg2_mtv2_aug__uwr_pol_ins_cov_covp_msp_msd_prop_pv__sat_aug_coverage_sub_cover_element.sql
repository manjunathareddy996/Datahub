{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_COVERAGE_SUB_COVER_ELEMENT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- Reads the fan-out model up_mtv2__uwr_pol_ins_cov_covp_msp_msd_prop_pv__aug_sat_aug_coverage_sub_cover_element: 4 instance(s) on this view.
--
-- 1 payload column(s); the child key is SUB_COVER_CODE.

{%- set yaml_metadata -%}
source_model: 'up_mtv2__uwr_pol_ins_cov_covp_msp_msd_prop_pv__aug_sat_aug_coverage_sub_cover_element'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF_COVERAGE_SUB_COVER_ELEMENT:
    is_hashdiff: true
    columns:
      - 'SUB_COVER_APPLICABILITY'
      - 'SUB_COVER_CODE'
derived_columns:
  COVERAGE_NK: "'HUB_COVERAGE|' || (COVERAGE_BK)"
  COVERAGE_BK: 'COVERAGE_BK'
  SUB_COVER_CODE: 'SUB_COVER_CODE'
  SUB_COVER_APPLICABILITY: 'SUB_COVER_APPLICABILITY'
  RECORD_SOURCE: 'record_source'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
