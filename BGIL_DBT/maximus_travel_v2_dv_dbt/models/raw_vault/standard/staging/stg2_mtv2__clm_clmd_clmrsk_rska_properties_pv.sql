{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
-- Covers this view's 8 key slot(s) and its 13 1:1 satellite target(s) in one pass,
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
--   CLAIM_HKEY                         HUB_CLAIM  (95 row(s) in the map)
--   CLAIM_HKEY__LINKED_BAGGAGE_DELAY_CLAIM HUB_CLAIM / linked-baggage-delay-claim  (1 row(s) in the map)
--   CLAIM_HKEY__LINKED_HEALTH_CLAIM    HUB_CLAIM / linked-health-claim  (1 row(s) in the map)
--   CLAIM_HKEY__LINKED_TRIP_DELAY_CLAIM HUB_CLAIM / linked-trip-delay-claim  (1 row(s) in the map)
--   COVERAGE_HKEY                      HUB_COVERAGE  (1 row(s) in the map)
--   LOCATION_HKEY__CLAIM_LOSS_LOCATION HUB_LOCATION / claim-loss-location  (2 row(s) in the map)
--   LOCATION_HKEY__TREATING_HOSPITAL_ADDRESS HUB_LOCATION / treating-hospital-address  (2 row(s) in the map)
--   PARTY_HKEY__TREATING_HOSPITAL_PROVIDER HUB_PARTY / treating-hospital-provider  (3 row(s) in the map)
--   HASHDIFF_CLAIM_BENEFIT_HEAD        SAT_CLAIM_BENEFIT_HEAD payload 3 of 7 live here
--   HASHDIFF_CLAIM_FRAUD               SAT_CLAIM_FRAUD payload 1 of 6 live here
--   HASHDIFF_CLAIM_HEADER              SAT_CLAIM_HEADER payload 1 of 14 live here
--   HASHDIFF_CLAIM_HEALTH_DETAIL       SAT_CLAIM_HEALTH_DETAIL payload 14 of 16 live here
--   HASHDIFF_CLAIM_INVESTIGATION_FINDING SAT_CLAIM_INVESTIGATION_FINDING payload 1 of 1 live here
--   HASHDIFF_CLAIM_PA_DETAIL           SAT_CLAIM_PA_DETAIL payload 2 of 2 live here
--   HASHDIFF_CLAIM_REPUDIATION         SAT_CLAIM_REPUDIATION payload 1 of 2 live here
--   HASHDIFF_CLAIM_RESERVE_HEAD        SAT_CLAIM_RESERVE_HEAD payload 2 of 2 live here
--   HASHDIFF_CLAIM_TP_FORENSIC         SAT_CLAIM_TP_FORENSIC payload 3 of 3 live here
--   HASHDIFF_CLAIM_TRAVEL_DETAIL       SAT_CLAIM_TRAVEL_DETAIL payload 6 of 6 live here
--   HASHDIFF_COMMON_ADDRESS            SAT_COMMON_ADDRESS payload 3 of 16 live here
--   HASHDIFF_COMMON_CONTACT            SAT_COMMON_CONTACT payload 1 of 9 live here
--   HASHDIFF_PARTY_IDENTITY            SAT_PARTY_IDENTITY payload 1 of 15 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmrsk_rska_properties_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  CLAIM_HKEY__LINKED_BAGGAGE_DELAY_CLAIM: 'CLAIM_NK__LINKED_BAGGAGE_DELAY_CLAIM'
  CLAIM_HKEY__LINKED_HEALTH_CLAIM: 'CLAIM_NK__LINKED_HEALTH_CLAIM'
  CLAIM_HKEY__LINKED_TRIP_DELAY_CLAIM: 'CLAIM_NK__LINKED_TRIP_DELAY_CLAIM'
  COVERAGE_HKEY: 'COVERAGE_NK'
  LOCATION_HKEY__CLAIM_LOSS_LOCATION: 'LOCATION_NK__CLAIM_LOSS_LOCATION'
  LOCATION_HKEY__TREATING_HOSPITAL_ADDRESS: 'LOCATION_NK__TREATING_HOSPITAL_ADDRESS'
  PARTY_HKEY__TREATING_HOSPITAL_PROVIDER: 'PARTY_NK__TREATING_HOSPITAL_PROVIDER'
  HASHDIFF_CLAIM_BENEFIT_HEAD:
    is_hashdiff: true
    columns:
      - 'APPROVED_AMOUNT'
      - 'BENEFIT_HEAD_CODE'
      - 'CLAIMED_AMOUNT'
      - 'COVERAGE_REFERENCE'
      - 'DEDUCTION_AMOUNT'
      - 'DEDUCTION_REASON'
      - 'HEAD_DESCRIPTION'
      - 'SUB_LIMIT_APPLIED'
  HASHDIFF_CLAIM_FRAUD:
    is_hashdiff: true
    columns:
      - 'FRAUD_SCORE'
      - 'FRAUD_TRIGGER_REASON'
      - 'FRAUD_TYPE'
      - 'INVESTIGATION_REFERENCE'
      - 'INVESTIGATION_REFERRED_INDICATOR'
      - 'INVESTIGATION_STATUS'
  HASHDIFF_CLAIM_HEADER:
    is_hashdiff: true
    columns:
      - 'CATASTROPHE_CODE'
      - 'CLAIM_CATEGORY'
      - 'CLAIM_HANDLER_REFERENCE'
      - 'CLAIM_REFERENCE_NUMBER'
      - 'CLAIM_STATUS'
      - 'CLAIM_SUB_STATUS'
      - 'CLAIM_TYPE'
      - 'HANDLING_ORG_UNIT_CODE'
      - 'INTIMATED_BY_ROLE'
      - 'INTIMATION_CHANNEL'
      - 'LOSS_DATE'
      - 'NOTIFICATION_DATE'
      - 'PRIORITY_CODE'
      - 'REGISTRATION_DATE'
  HASHDIFF_CLAIM_HEALTH_DETAIL:
    is_hashdiff: true
    columns:
      - 'ADMISSION_DATE'
      - 'ADVERSE_MEDICAL_HISTORY_DESCRIPTION'
      - 'AILMENT_DESCRIPTION'
      - 'DISCHARGE_DATE'
      - 'DISEASE_CATEGORY'
      - 'HEALTH_CLAIM_REMARKS'
      - 'ICD_CODE'
      - 'ICD_DESCRIPTION'
      - 'LENGTH_OF_STAY'
      - 'MEDICALLY_ADMISSIBLE_INDICATOR'
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
      - 'PRE_EXISTING_DISEASE_RELATED_INDICATOR'
      - 'PRE_EXISTING_ILLNESS_DESCRIPTION'
      - 'SYSTEM_OF_MEDICINE'
      - 'TREATING_DOCTOR_NAME'
      - 'TREATMENT_TYPE'
  HASHDIFF_CLAIM_INVESTIGATION_FINDING:
    is_hashdiff: true
    columns:
      - 'FINDING_DESCRIPTION'
      - 'FINDING_SEQUENCE'
  HASHDIFF_CLAIM_PA_DETAIL:
    is_hashdiff: true
    columns:
      - 'DISABILITY_PERCENTAGE'
      - 'DISABILITY_TYPE'
  HASHDIFF_CLAIM_REPUDIATION:
    is_hashdiff: true
    columns:
      - 'REPUDIATION_REASON'
      - 'REPUDIATION_REMARKS'
  HASHDIFF_CLAIM_RESERVE_HEAD:
    is_hashdiff: true
    columns:
      - 'OPENING_RESERVE'
      - 'RESERVE_HEAD_CODE'
      - 'REVISED_RESERVE'
  HASHDIFF_CLAIM_TP_FORENSIC:
    is_hashdiff: true
    columns:
      - 'FIR_DATE'
      - 'FIR_NUMBER'
      - 'FIR_TIME'
  HASHDIFF_CLAIM_TRAVEL_DETAIL:
    is_hashdiff: true
    columns:
      - 'CLAIM_SUB_TYPE'
      - 'COUNTRY_OF_INCIDENT'
      - 'CURRENCY_OF_LOSS'
      - 'INCIDENT_DATE'
      - 'LOSS_AMOUNT_FOREIGN'
      - 'LOSS_AMOUNT_INR'
  HASHDIFF_COMMON_ADDRESS:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'ADDRESS_LINE_3'
      - 'ADDRESS_TYPE_CODE'
      - 'CARE_OF_NAME'
      - 'CITY'
      - 'COUNTRY_CODE'
      - 'COUNTRY_NAME'
      - 'DISTRICT'
      - 'LANDMARK'
      - 'LOCALITY'
      - 'POSTAL_CODE'
      - 'POST_OFFICE_NAME'
      - 'STATE_CODE'
      - 'STATE_NAME'
      - 'STREET_NAME'
  HASHDIFF_COMMON_CONTACT:
    is_hashdiff: true
    columns:
      - 'ALTERNATE_EMAIL_ADDRESS'
      - 'ALTERNATE_MOBILE_NUMBER'
      - 'CONTACT_POINT_TYPE'
      - 'CONTACT_POINT_USAGE'
      - 'CONTACT_PRIORITY_ORDER'
      - 'EMAIL_ADDRESS'
      - 'FAX_NUMBER'
      - 'LANDLINE_NUMBER'
      - 'MOBILE_NUMBER'
      - 'SOCIAL_MEDIA_HANDLE'
      - 'STD_CODE'
  HASHDIFF_PARTY_IDENTITY:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'COUNTRY_OF_BIRTH'
      - 'COUNTRY_OF_RESIDENCE'
      - 'DATE_OF_BIRTH'
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
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_BK__LINKED_BAGGAGE_DELAY_CLAIM: "nullif(trim(case when coalesce(nullif(trim(linked_delay_of_baggage_claim),'')) is not null then nullif(trim(linked_delay_of_baggage_claim), '') end),'')"
  CLAIM_NK__LINKED_BAGGAGE_DELAY_CLAIM: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(linked_delay_of_baggage_claim),'')) is not null then nullif(trim(linked_delay_of_baggage_claim), '') end),''))"
  CLAIM_BK__LINKED_HEALTH_CLAIM: "nullif(trim(case when coalesce(nullif(trim(linked_health_claim),'')) is not null then nullif(trim(linked_health_claim), '') end),'')"
  CLAIM_NK__LINKED_HEALTH_CLAIM: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(linked_health_claim),'')) is not null then nullif(trim(linked_health_claim), '') end),''))"
  CLAIM_BK__LINKED_TRIP_DELAY_CLAIM: "nullif(trim(case when coalesce(nullif(trim(linked_trip_delay_claim_number),'')) is not null then nullif(trim(linked_trip_delay_claim_number), '') end),'')"
  CLAIM_NK__LINKED_TRIP_DELAY_CLAIM: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(linked_trip_delay_claim_number),'')) is not null then nullif(trim(linked_trip_delay_claim_number), '') end),''))"
  COVERAGE_BK: "nullif(trim(case when coalesce(nullif(trim(cover_code),'')) is not null then 'COV:' || nullif(trim(cover_code), '') end),'')"
  COVERAGE_NK: "'HUB_COVERAGE|' || (nullif(trim(case when coalesce(nullif(trim(cover_code),'')) is not null then 'COV:' || nullif(trim(cover_code), '') end),''))"
  LOCATION_BK__CLAIM_LOSS_LOCATION: "nullif(trim(case when coalesce(nullif(trim(location),''), nullif(trim(city_name),''), nullif(trim(country_of_loss),'')) is not null then md5(upper(regexp_replace(trim(upper(nullif(trim(coalesce(nullif(trim(location), ''), '') || '|' || coalesce(nullif(trim(city_name), ''), '') || '|' || coalesce(nullif(trim(country_of_loss), ''), '')), '||'))), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__CLAIM_LOSS_LOCATION: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(location),''), nullif(trim(city_name),''), nullif(trim(country_of_loss),'')) is not null then md5(upper(regexp_replace(trim(upper(nullif(trim(coalesce(nullif(trim(location), ''), '') || '|' || coalesce(nullif(trim(city_name), ''), '') || '|' || coalesce(nullif(trim(country_of_loss), ''), '')), '||'))), '[[:space:]]+', ' '))) end),''))"
  LOCATION_BK__TREATING_HOSPITAL_ADDRESS: "nullif(trim(case when coalesce(nullif(trim(hospital_address),''), nullif(trim(hospital_country),''), nullif(trim(hospital_name),'')) is not null then md5(upper(regexp_replace(trim(upper(nullif(trim(coalesce(nullif(trim(hospital_address), ''), '') || '|' || coalesce(nullif(trim(hospital_country), ''), '') || '|' || coalesce(nullif(trim(hospital_name), ''), '')), '||'))), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__TREATING_HOSPITAL_ADDRESS: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(hospital_address),''), nullif(trim(hospital_country),''), nullif(trim(hospital_name),'')) is not null then md5(upper(regexp_replace(trim(upper(nullif(trim(coalesce(nullif(trim(hospital_address), ''), '') || '|' || coalesce(nullif(trim(hospital_country), ''), '') || '|' || coalesce(nullif(trim(hospital_name), ''), '')), '||'))), '[[:space:]]+', ' '))) end),''))"
  PARTY_BK__TREATING_HOSPITAL_PROVIDER: "nullif(trim(case when coalesce(nullif(trim(hospital_id),'')) is not null then 'PROVIDER:' || nullif(trim(hospital_id), '') end),'')"
  PARTY_NK__TREATING_HOSPITAL_PROVIDER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(hospital_id),'')) is not null then 'PROVIDER:' || nullif(trim(hospital_id), '') end),''))"
  ADDRESS_LINE_1: 'coalesce(hospital_address, location)'
  ADDRESS_LINE_2: 'cast(null as varchar)'
  ADDRESS_LINE_3: 'cast(null as varchar)'
  ADDRESS_TYPE_CODE: 'cast(null as varchar)'
  ADMISSION_DATE: 'actual_date_of_admission_doa'
  AGE: 'cast(null as varchar)'
  AILMENT_DESCRIPTION: 'final_diagnosis'
  ALTERNATE_EMAIL_ADDRESS: 'cast(null as varchar)'
  ALTERNATE_MOBILE_NUMBER: 'cast(null as varchar)'
  APPROVED_AMOUNT: 'cast(null as varchar)'
  BENEFIT_HEAD_CODE: "nullif(trim(coalesce(nullif(trim(cover_code), ''), '') || '#' || coalesce(nullif(trim(subcover_code), ''), '')), '#')"
  CARE_OF_NAME: 'cast(null as varchar)'
  CATASTROPHE_CODE: 'cast(null as varchar)'
  CITY: 'city_name'
  CLAIMED_AMOUNT: 'cast(null as varchar)'
  CLAIM_CATEGORY: 'cast(null as varchar)'
  CLAIM_HANDLER_REFERENCE: 'cast(null as varchar)'
  CLAIM_REFERENCE_NUMBER: 'cast(null as varchar)'
  CLAIM_STATUS: 'cast(null as varchar)'
  CLAIM_SUB_STATUS: 'cast(null as varchar)'
  CLAIM_SUB_TYPE: 'type'
  CLAIM_TYPE: 'cast(null as varchar)'
  CONTACT_POINT_TYPE: "'LANDLINE_HOSPITAL'"
  CONTACT_POINT_USAGE: 'cast(null as varchar)'
  CONTACT_PRIORITY_ORDER: "'1'"
  COUNTRY_CODE: 'cast(null as varchar)'
  COUNTRY_NAME: 'hospital_country'
  COUNTRY_OF_BIRTH: 'cast(null as varchar)'
  COUNTRY_OF_INCIDENT: 'country_of_loss'
  COUNTRY_OF_RESIDENCE: 'cast(null as varchar)'
  COVERAGE_REFERENCE: 'cast(null as varchar)'
  CURRENCY_OF_LOSS: 'loss_amount_currency'
  DATE_OF_BIRTH: 'cast(null as varchar)'
  DEDUCTION_AMOUNT: 'difference_in_amount'
  DEDUCTION_REASON: 'cast(null as varchar)'
  DISABILITY_PERCENTAGE: 'percentage_of_disability'
  DISABILITY_TYPE: 'ttdptd'
  DISCHARGE_DATE: 'actual_date_of_discharge_dod'
  DISTRICT: 'cast(null as varchar)'
  EMAIL_ADDRESS: 'cast(null as varchar)'
  FAX_NUMBER: 'cast(null as varchar)'
  FINDING_DESCRIPTION: 'investigation_findings'
  FINDING_SEQUENCE: "coalesce(nullif(trim(investigation_number), ''),'')"
  FIRST_NAME: 'cast(null as varchar)'
  FIR_DATE: 'fir_date'
  FIR_NUMBER: 'fir'
  FRAUD_SCORE: 'cast(null as varchar)'
  FRAUD_TRIGGER_REASON: 'cast(null as varchar)'
  FRAUD_TYPE: 'cast(null as varchar)'
  GENDER_CODE: 'cast(null as varchar)'
  HANDLING_ORG_UNIT_CODE: 'cast(null as varchar)'
  HEAD_DESCRIPTION: 'subcover_name'
  HEALTH_CLAIM_REMARKS: 'medical_comments'
  ICD_CODE: 'icd_description'
  INCIDENT_DATE: 'date_of_incident'
  INTIMATED_BY_ROLE: 'cast(null as varchar)'
  INTIMATION_CHANNEL: 'cast(null as varchar)'
  INVESTIGATION_REFERENCE: 'investigation_number'
  INVESTIGATION_REFERRED_INDICATOR: 'cast(null as varchar)'
  INVESTIGATION_STATUS: 'cast(null as varchar)'
  LANDLINE_NUMBER: 'hospital_contact_no'
  LANDMARK: 'cast(null as varchar)'
  LAST_NAME: 'cast(null as varchar)'
  LENGTH_OF_STAY: 'hospitalization_days'
  LOCALITY: 'cast(null as varchar)'
  LOSS_AMOUNT_FOREIGN: 'loss_amount'
  LOSS_AMOUNT_INR: 'loss_amount_in_inr'
  LOSS_DATE: 'event_date'
  MIDDLE_NAME: 'cast(null as varchar)'
  MOBILE_NUMBER: 'cast(null as varchar)'
  NATIONALITY: 'cast(null as varchar)'
  NOTIFICATION_DATE: 'cast(null as varchar)'
  OPENING_RESERVE: 'loss_reserve_inr'
  PARTY_FULL_NAME: 'hospital_name'
  PARTY_LEGAL_NAME: 'cast(null as varchar)'
  PARTY_STATUS: 'cast(null as varchar)'
  PARTY_SUB_TYPE_CODE: 'cast(null as varchar)'
  PARTY_TYPE_CODE: 'cast(null as varchar)'
  POSTAL_CODE: 'cast(null as varchar)'
  POST_OFFICE_NAME: 'cast(null as varchar)'
  PRE_EXISTING_DISEASE_RELATED_INDICATOR: 'preexisting'
  PRIORITY_CODE: 'cast(null as varchar)'
  REGISTRATION_DATE: 'cast(null as varchar)'
  REPUDIATION_REASON: 'ground_of_rejection'
  RESERVE_HEAD_CODE: "coalesce(nullif(trim('LOSS' || '#' || coalesce(nullif(trim(cover_code), ''), '')), 'LOSS#'),'')"
  REVISED_RESERVE: 'modified_reserve_against_loss_compensation'
  SALUTATION: 'cast(null as varchar)'
  SOCIAL_MEDIA_HANDLE: 'cast(null as varchar)'
  STATE_CODE: 'cast(null as varchar)'
  STATE_NAME: 'cast(null as varchar)'
  STD_CODE: 'cast(null as varchar)'
  STREET_NAME: 'cast(null as varchar)'
  SUB_LIMIT_APPLIED: 'sublimit'
  TREATING_DOCTOR_NAME: 'treating_doctor_details'
  TREATMENT_TYPE: 'mode_of_treatment'
  ADVERSE_MEDICAL_HISTORY_DESCRIPTION: 'adverse_medical_history'
  DISEASE_CATEGORY: 'disease_category'
  ICD_DESCRIPTION: 'cast(null as varchar)'
  MEDICALLY_ADMISSIBLE_INDICATOR: 'cast(null as varchar)'
  PRE_EXISTING_DISEASE_DESCRIPTION: 'preexisting_description'
  PRE_EXISTING_ILLNESS_DESCRIPTION: 'preexisting_illness'
  SYSTEM_OF_MEDICINE: 'system_of_medicine'
  REPUDIATION_REMARKS: 'cast(null as varchar)'
  FIR_TIME: 'fir_time'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
