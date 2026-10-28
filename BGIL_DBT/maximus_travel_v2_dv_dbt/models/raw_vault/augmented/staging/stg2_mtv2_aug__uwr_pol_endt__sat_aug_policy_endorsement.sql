{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_POLICY_ENDORSEMENT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_ENDORSEMENT_DETAILS
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 5 payload column(s); the child key is ENDORSEMENT_NUMBER.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_endt'
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
  ENDORSEMENT_NUMBER: "coalesce(nullif(trim(endorsement_number), ''),'')"
  ENDORSEMENT_APPROVAL_DATE: 'endorsement_approved_date'
  ENDORSEMENT_INVOICE_REFERENCE: 'cast(null as varchar)'
  ENDORSEMENT_REMARKS: 'remarks'
  ENDORSEMENT_UNIQUE_IDENTIFICATION_CODE: 'cast(null as varchar)'
  REVISED_SUM_INSURED_AMOUNT: 'endorsement_revised_sum_insured'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_ENDORSEMENT_DETAILS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
