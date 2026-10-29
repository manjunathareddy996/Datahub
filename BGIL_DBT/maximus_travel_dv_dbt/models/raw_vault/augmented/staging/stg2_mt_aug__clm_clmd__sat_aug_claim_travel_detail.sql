{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_CLAIM_TRAVEL_DETAIL from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 15 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'stg_mt__clm_clmd'
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
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(claimno),'')) is not null then nullif(trim(claimno), '') end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(claimno),'')) is not null then nullif(trim(claimno), '') end),''))"
  ACCIDENTAL_INDICATOR: 'cast(null as varchar)'
  AFFECTED_ITEMS_DESCRIPTION: 'cast(null as varchar)'
  BAGGAGE_DELIVERY_DATE: 'cast(null as varchar)'
  BAGGAGE_DELIVERY_TIME: 'cast(null as varchar)'
  BENEFIT_DAYS_AVAILED: 'no_of_days_availed_conv'
  CLAIMED_EVENT_DURATION: 'cast(null as varchar)'
  CLAIM_LINE_INSURED_PERSON_RELATIONSHIP: 'cast(null as varchar)'
  INCIDENT_DESCRIPTION: 'cast(null as varchar)'
  INCIDENT_TIME: 'cast(null as varchar)'
  NUMBER_OF_BAGS_AFFECTED: 'cast(null as varchar)'
  PURPOSE_OF_VISIT: 'cast(null as varchar)'
  RELEASE_DATE: 'cast(null as varchar)'
  RELEASE_TIME: 'cast(null as varchar)'
  TRIP_DESTINATION_COUNTRY: 'cast(null as varchar)'
  WEATHER_CONDITION_AT_INCIDENT: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
