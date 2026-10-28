{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_FNOL from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 7 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmap_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_FNOL:
    is_hashdiff: true
    columns:
      - 'ADD_ON_CLAIM_ELECTED_INDICATOR'
      - 'CLAIM_PERSON_NAME'
      - 'DELAYED_INTIMATION_REASON'
      - 'INTIMATED_CAUSE_OF_CLAIM'
      - 'REGISTRATION_FLAGS'
      - 'REPORTED_BY_EMAIL'
      - 'THIRD_PARTY_INVOLVEMENT_INDICATOR'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  ADD_ON_CLAIM_ELECTED_INDICATOR: 'are_you_claiming_for_add_on'
  CLAIM_PERSON_NAME: 'name_of_person'
  DELAYED_INTIMATION_REASON: 'delay_reason_for_registration'
  INTIMATED_CAUSE_OF_CLAIM: 'cause_of_claim'
  REGISTRATION_FLAGS: 'registration_flags'
  REPORTED_BY_EMAIL: 'caller_email_id'
  THIRD_PARTY_INVOLVEMENT_INDICATOR: 'do_you_want_third_party_involvemnt'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
