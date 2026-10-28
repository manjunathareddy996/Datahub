{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_TRAVEL_DETAIL from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 15 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmrsk_rska_properties_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_TRAVEL_DETAIL:
    is_hashdiff: true
    columns:
      - 'ACCIDENTAL_INDICATOR'
      - 'AFFECTED_ITEMS_DESCRIPTION'
      - 'BAGGAGE_DELIVERY_DATE'
      - 'BAGGAGE_DELIVERY_TIME'
      - 'BENEFIT_DAYS_AVAILED'
      - 'CLAIMED_EVENT_DURATION'
      - 'CLAIM_LINE_INSURED_PERSON_RELATIONSHIP'
      - 'INCIDENT_DESCRIPTION'
      - 'INCIDENT_TIME'
      - 'NUMBER_OF_BAGS_AFFECTED'
      - 'PURPOSE_OF_VISIT'
      - 'RELEASE_DATE'
      - 'RELEASE_TIME'
      - 'TRIP_DESTINATION_COUNTRY'
      - 'WEATHER_CONDITION_AT_INCIDENT'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  ACCIDENTAL_INDICATOR: 'accidental'
  AFFECTED_ITEMS_DESCRIPTION: 'pcs_descreption'
  BAGGAGE_DELIVERY_DATE: 'baggage_delivery_date'
  BAGGAGE_DELIVERY_TIME: 'baggage_delivery_time'
  BENEFIT_DAYS_AVAILED: 'cast(null as varchar)'
  CLAIMED_EVENT_DURATION: 'total_duration'
  CLAIM_LINE_INSURED_PERSON_RELATIONSHIP: 'pertinent_person_insuredspousechildren'
  INCIDENT_DESCRIPTION: 'description_of_incident'
  INCIDENT_TIME: 'time_of_incident'
  NUMBER_OF_BAGS_AFFECTED: 'number_of_bags'
  PURPOSE_OF_VISIT: 'purpose_of_visit'
  RELEASE_DATE: 'date_of_release'
  RELEASE_TIME: 'time_of_release'
  TRIP_DESTINATION_COUNTRY: 'trip_end_country'
  WEATHER_CONDITION_AT_INCIDENT: 'weather_condition'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
