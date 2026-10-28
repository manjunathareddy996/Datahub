{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_POLICY_GROUP from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 6 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_polp_sp_pv'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_GROUP:
    is_hashdiff: true
    columns:
      - 'CHILD_POLICY_PLAN_CODE'
      - 'EMPLOYER_ORGANISATION_NAME'
      - 'GLOBAL_ACCOUNT_INDICATOR'
      - 'GROUP_NAME'
      - 'INSURED_EMPLOYEE_CODE'
      - 'PROGRAM_IDENTIFIER'
derived_columns:
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  CHILD_POLICY_PLAN_CODE: 'child_policy_plan'
  EMPLOYER_ORGANISATION_NAME: 'employee_company'
  GLOBAL_ACCOUNT_INDICATOR: 'global_account_policy'
  GROUP_NAME: 'group_name'
  INSURED_EMPLOYEE_CODE: 'employee_code'
  PROGRAM_IDENTIFIER: 'program_id'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
