{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- Covers this view's 3 key slot(s) and its 5 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mt_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   PARTY_HKEY__NOMINEE                HUB_PARTY / nominee  (4 row(s) in the map)
--   PARTY_ROLE_HKEY__NOMINEE           LNK_PARTY_ROLE / nominee  LINK
--   RISK_OBJECT_HKEY                   HUB_RISK_OBJECT  (56 row(s) in the map)
--   HASHDIFF_LNK_ROLE_NOMINEE_BENEFICIARY SAT_LNK_ROLE_NOMINEE_BENEFICIARY payload 3 of 3 live here
--   HASHDIFF_PARTY_IDENTITY            SAT_PARTY_IDENTITY payload 1 of 15 live here
--   HASHDIFF_RISK_HEALTH_MEMBER_MEDICAL SAT_RISK_HEALTH_MEMBER_MEDICAL payload 5 of 7 live here
--   HASHDIFF_RISK_PERSON_MEMBER        SAT_RISK_PERSON_MEMBER payload 1 of 1 live here
--   HASHDIFF_RISK_PERSON_TRAVEL        SAT_RISK_PERSON_TRAVEL payload 6 of 6 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_ins_rskp_msp_msd_prop_pv'
hashed_columns:
  PARTY_HKEY__NOMINEE: 'PARTY_NK__NOMINEE'
  PARTY_ROLE_HKEY__NOMINEE: 'PARTY_ROLE_NK__NOMINEE'
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
  HASHDIFF_RISK_HEALTH_MEMBER_MEDICAL:
    is_hashdiff: true
    columns:
      - 'CONDITION_CODE'
      - 'CONDITION_DESCRIPTION'
      - 'CONDITION_NAME'
      - 'CURRENT_MEDICATION_DETAIL'
      - 'MEMBER_REFERENCE'
      - 'PRE_EXISTING_DISEASE_ONSET_MONTH'
      - 'PRE_EXISTING_DISEASE_ONSET_YEAR'
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
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  AGE: 'cast(null as varchar)'
  APPOINTEE_NAME: 'appointee_name'
  CONDITION_CODE: "coalesce(nullif(trim(disease), ''),'')"
  CONDITION_NAME: 'disease'
  COUNTRY_OF_BIRTH: 'cast(null as varchar)'
  COUNTRY_OF_RESIDENCE: 'cast(null as varchar)'
  DATE_OF_BIRTH: 'date_of_birth'
  DATE_OF_BIRTH__SAT_PARTY_IDENTITY: 'cast(null as varchar)'
  DESTINATION_COUNTRY: 'arrival_country'
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
  RELATIONSHIP_TO_INSURED: 'relation_with_insured'
  SALUTATION: 'cast(null as varchar)'
  TRIP_DURATION: 'trip_duration_in_days'
  TRIP_END_DATE: 'return_date'
  TRIP_START_DATE: 'departure_date'
  TRIP_TYPE: 'trip_type_tripcal'
  CONDITION_DESCRIPTION: 'disease_description'
  CURRENT_MEDICATION_DETAIL: 'current_medication'
  PRE_EXISTING_DISEASE_ONSET_MONTH: 'ped_month'
  PRE_EXISTING_DISEASE_ONSET_YEAR: 'ped_year'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
