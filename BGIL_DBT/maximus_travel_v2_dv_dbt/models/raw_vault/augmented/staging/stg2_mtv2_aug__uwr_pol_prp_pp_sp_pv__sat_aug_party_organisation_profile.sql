{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_ORGANISATION_PROFILE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 7 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_prp_pp_sp_pv'
hashed_columns:
  PARTY_HKEY__PROPOSER: 'PARTY_NK__PROPOSER'
  HASHDIFF_PARTY_ORGANISATION_PROFILE:
    is_hashdiff: true
    columns:
      - 'BUSINESS_REGISTRATION_DATE'
      - 'BUSINESS_TYPE_CODE'
      - 'INFRASTRUCTURE_SUB_SECTOR'
      - 'OTHER_INDUSTRY_TYPE_DESCRIPTION'
      - 'REGISTERED_BUSINESS_TRUST_INDICATOR'
      - 'REGISTERED_COMPANY_DECLARED_INDICATOR'
      - 'TRADE_NAME'
derived_columns:
  PARTY_BK__PROPOSER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__PROPOSER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  BUSINESS_REGISTRATION_DATE: 'date_of_registration'
  BUSINESS_TYPE_CODE: 'business_type'
  INFRASTRUCTURE_SUB_SECTOR: 'infrastructure_subsector'
  OTHER_INDUSTRY_TYPE_DESCRIPTION: 'other_client_industry_type'
  REGISTERED_BUSINESS_TRUST_INDICATOR: 'is_the_organisation_a_registered_business_trust'
  REGISTERED_COMPANY_DECLARED_INDICATOR: 'are_you_registered_company'
  TRADE_NAME: 'trade_name'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
