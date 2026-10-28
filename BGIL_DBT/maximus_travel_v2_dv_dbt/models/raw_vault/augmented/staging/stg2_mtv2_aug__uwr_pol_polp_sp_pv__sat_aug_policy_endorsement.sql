{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_POLICY_ENDORSEMENT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 5 payload column(s); the child key is ENDORSEMENT_NUMBER.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_polp_sp_pv'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_ENDORSEMENT:
    is_hashdiff: true
    columns:
      - 'ENDORSEMENT_APPROVAL_DATE'
      - 'ENDORSEMENT_INVOICE_REFERENCE'
      - 'ENDORSEMENT_NUMBER'
      - 'ENDORSEMENT_REMARKS'
      - 'ENDORSEMENT_UNIQUE_IDENTIFICATION_CODE'
      - 'REVISED_SUM_INSURED_AMOUNT'
derived_columns:
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  ENDORSEMENT_NUMBER: "coalesce(nullif(trim(bagic_endorsement_number), ''),'')"
  ENDORSEMENT_APPROVAL_DATE: 'cast(null as varchar)'
  ENDORSEMENT_INVOICE_REFERENCE: 'endorsement_invoice'
  ENDORSEMENT_REMARKS: 'cast(null as varchar)'
  ENDORSEMENT_UNIQUE_IDENTIFICATION_CODE: 'unique_identification_code_for_endt'
  REVISED_SUM_INSURED_AMOUNT: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
