{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
-- Covers this view's 4 key slot(s) and its 6 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mtv2_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   PARTY_HKEY__NOMINEE                HUB_PARTY / nominee  (4 row(s) in the map)
--   PARTY_ROLE_HKEY__NOMINEE           LNK_PARTY_ROLE / nominee  LINK
--   QUOTE_HKEY                         HUB_QUOTE  (13 row(s) in the map)
--   RISK_OBJECT_HKEY                   HUB_RISK_OBJECT  (43 row(s) in the map)
--   HASHDIFF_LNK_ROLE_NOMINEE_BENEFICIARY SAT_LNK_ROLE_NOMINEE_BENEFICIARY payload 3 of 3 live here
--   HASHDIFF_PARTY_IDENTITY            SAT_PARTY_IDENTITY payload 1 of 15 live here
--   HASHDIFF_QUOTE_RATING_INPUT        SAT_QUOTE_RATING_INPUT payload 2 of 3 live here
--   HASHDIFF_RISK_HEALTH_MEMBER_MEDICAL SAT_RISK_HEALTH_MEMBER_MEDICAL payload 1 of 1 live here
--   HASHDIFF_RISK_PERSON_MEMBER        SAT_RISK_PERSON_MEMBER payload 1 of 1 live here
--   HASHDIFF_RISK_PERSON_TRAVEL        SAT_RISK_PERSON_TRAVEL payload 6 of 6 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv'
hashed_columns:
  PARTY_HKEY__NOMINEE: 'PARTY_NK__NOMINEE'
  PARTY_ROLE_HKEY__NOMINEE: 'PARTY_ROLE_NK__NOMINEE'
  QUOTE_HKEY: 'QUOTE_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF_LNK_ROLE_NOMINEE_BENEFICIARY:
    is_hashdiff: true
    columns:
      - 'APPOINTEE_NAME'
      - 'NOMINATION_PERCENTAGE'
      - 'RELATIONSHIP_TO_INSURED'
  HASHDIFF_PARTY_IDENTITY:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'COUNTRY_OF_BIRTH'
      - 'COUNTRY_OF_RESIDENCE'
      - 'DATE_OF_BIRTH__SAT_PARTY_IDENTITY'
      - 'FIRST_NAME'
      - 'GENDER_CODE'
      - 'LAST_NAME'
      - 'MIDDLE_NAME'
      - 'NATIONALITY'
      - 'PARTY_FULL_NAME'
      - 'PARTY_LEGAL_NAME'
      - 'PARTY_STATUS'
      - 'PARTY_SUB_TYPE_CODE'
      - 'PARTY_TYPE_CODE'
      - 'SALUTATION'
  HASHDIFF_QUOTE_RATING_INPUT:
    is_hashdiff: true
    columns:
      - 'FACTOR_CODE'
      - 'FACTOR_VALUE'
      - 'PREMIUM_IMPACT'
      - 'RELATIVITY_APPLIED'
  HASHDIFF_RISK_HEALTH_MEMBER_MEDICAL:
    is_hashdiff: true
    columns:
      - 'CONDITION_CODE'
      - 'CONDITION_NAME'
      - 'MEMBER_REFERENCE'
  HASHDIFF_RISK_PERSON_MEMBER:
    is_hashdiff: true
    columns:
      - 'DATE_OF_BIRTH'
      - 'MEMBER_SEQUENCE'
  HASHDIFF_RISK_PERSON_TRAVEL:
    is_hashdiff: true
    columns:
      - 'DESTINATION_COUNTRY'
      - 'GEOGRAPHICAL_ZONE'
      - 'TRIP_DURATION'
      - 'TRIP_END_DATE'
      - 'TRIP_START_DATE'
      - 'TRIP_TYPE'
derived_columns:
  PARTY_BK__NOMINEE: "nullif(trim(case when coalesce(nullif(trim(nominee_name),'')) is not null then 'NOMINEE:' || md5(upper(trim(nullif(trim(nominee_name), '')))) end),'')"
  PARTY_NK__NOMINEE: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(nominee_name),'')) is not null then 'NOMINEE:' || md5(upper(trim(nullif(trim(nominee_name), '')))) end),''))"
  PARTY_ROLE_BK__NOMINEE: "coalesce(nullif(trim(case when coalesce(nullif(trim(nominee_name),'')) is not null then 'NOMINEE:' || md5(upper(trim(nullif(trim(nominee_name), '')))) end),''),'') || '|' || coalesce('NOMINEE','')"
  PARTY_ROLE_NK__NOMINEE: "'LNK_PARTY_ROLE|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(nominee_name),'')) is not null then 'NOMINEE:' || md5(upper(trim(nullif(trim(nominee_name), '')))) end),''),'') || '|' || coalesce('NOMINEE',''))"
  PARTY_ROLE_ROLE: "'NOMINEE'"
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  AGE: 'cast(null as varchar)'
  APPOINTEE_NAME: 'appointee_name'
  CONDITION_CODE: "coalesce(nullif(trim(disease), ''),'')"
  CONDITION_NAME: 'disease'
  COUNTRY_OF_BIRTH: 'cast(null as varchar)'
  COUNTRY_OF_RESIDENCE: 'cast(null as varchar)'
  DATE_OF_BIRTH: 'date_of_birth'
  DATE_OF_BIRTH__SAT_PARTY_IDENTITY: 'cast(null as varchar)'
  DESTINATION_COUNTRY: 'arrival_country'
  FACTOR_CODE: "coalesce(nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || 'ONE_WAY_PREMIUM'), '#ONE_WAY_PREMIUM'),'')"
  FACTOR_VALUE: 'coalesce(premium_rate, rate_per_trip_per_mille, rate_per_trip_per_mille_for_main_sub_cover, office_premium_per_mille_pa, office_premium_per_mille_per_trip, slab_, ace_premium_type)'
  FIRST_NAME: 'cast(null as varchar)'
  GENDER_CODE: 'cast(null as varchar)'
  GEOGRAPHICAL_ZONE: 'geographical_coverage'
  LAST_NAME: 'cast(null as varchar)'
  MEMBER_REFERENCE: "coalesce(nullif(trim(w1_pol_risk_id), ''),'')"
  MEMBER_SEQUENCE: "coalesce(nullif(trim(key_hash), ''),'')"
  MIDDLE_NAME: 'cast(null as varchar)'
  NATIONALITY: 'cast(null as varchar)'
  NOMINATION_PERCENTAGE: 'allocation_percentage'
  PARTY_FULL_NAME: 'nominee_name'
  PARTY_LEGAL_NAME: 'cast(null as varchar)'
  PARTY_STATUS: 'cast(null as varchar)'
  PARTY_SUB_TYPE_CODE: 'cast(null as varchar)'
  PARTY_TYPE_CODE: 'cast(null as varchar)'
  PREMIUM_IMPACT: 'coalesce(one_way_premium, round_trip_premium, fixed_one_way_premium, fixed_round_trip_premium, loading_ace, loading_ace_for_main_sub_cover)'
  RELATIONSHIP_TO_INSURED: 'relation_with_insured'
  RELATIVITY_APPLIED: 'cast(null as varchar)'
  SALUTATION: 'cast(null as varchar)'
  TRIP_DURATION: 'trip_duration_in_days'
  TRIP_END_DATE: 'return_date'
  TRIP_START_DATE: 'departure_date'
  TRIP_TYPE: 'trip_type_tripcal'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
