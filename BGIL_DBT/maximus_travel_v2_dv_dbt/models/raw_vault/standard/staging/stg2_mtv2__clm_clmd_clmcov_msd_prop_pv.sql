{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- Covers this view's 3 key slot(s) and its 4 1:1 satellite target(s) in one pass,
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
--   CLAIM_HKEY                         HUB_CLAIM  (12 row(s) in the map)
--   DOCUMENT_HKEY                      HUB_DOCUMENT  (11 row(s) in the map)
--   LOCATION_HKEY                      HUB_LOCATION  (3 row(s) in the map)
--   HASHDIFF_CLAIM_BENEFIT_HEAD        SAT_CLAIM_BENEFIT_HEAD payload 1 of 7 live here
--   HASHDIFF_CLAIM_HEADER              SAT_CLAIM_HEADER payload 1 of 14 live here
--   HASHDIFF_COMMON_ADDRESS            SAT_COMMON_ADDRESS payload 3 of 16 live here
--   HASHDIFF_DOCUMENT_DEFINITION       SAT_DOCUMENT_DEFINITION payload 4 of 6 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmcov_msd_prop_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  LOCATION_HKEY: 'LOCATION_NK'
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
  HASHDIFF_DOCUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'DOCUMENT_NAME'
      - 'DOCUMENT_REFERENCE_NUMBER'
      - 'DOCUMENT_TYPE'
      - 'ISSUE_DATE'
      - 'RECEIVED_DATE'
      - 'SOURCE_CHANNEL'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  DOCUMENT_BK: "nullif(trim(case when coalesce(nullif(trim(inward_number),'')) is not null then 'INWARD:' || nullif(trim(inward_number), '') end),'')"
  DOCUMENT_NK: "'HUB_DOCUMENT|' || (nullif(trim(case when coalesce(nullif(trim(inward_number),'')) is not null then 'INWARD:' || nullif(trim(inward_number), '') end),''))"
  LOCATION_BK: "nullif(trim(case when coalesce(nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(city), ''), '') || '|' || coalesce(nullif(trim(state), ''), '') || '|' || coalesce(nullif(trim(pin_code), ''), '')), '||')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(city), ''), '') || '|' || coalesce(nullif(trim(state), ''), '') || '|' || coalesce(nullif(trim(pin_code), ''), '')), '||')), '[[:space:]]+', ' '))) end),''))"
  ADDRESS_LINE_1: 'cast(null as varchar)'
  ADDRESS_LINE_2: 'cast(null as varchar)'
  ADDRESS_LINE_3: 'cast(null as varchar)'
  ADDRESS_TYPE_CODE: 'cast(null as varchar)'
  APPROVED_AMOUNT: 'cast(null as varchar)'
  BENEFIT_HEAD_CODE: "coalesce(nullif(trim(cover_taken), ''),'')"
  CARE_OF_NAME: 'cast(null as varchar)'
  CATASTROPHE_CODE: 'cast(null as varchar)'
  CITY: 'city'
  CLAIMED_AMOUNT: 'cast(null as varchar)'
  CLAIM_CATEGORY: 'cast(null as varchar)'
  CLAIM_HANDLER_REFERENCE: 'cast(null as varchar)'
  CLAIM_REFERENCE_NUMBER: 'cast(null as varchar)'
  CLAIM_STATUS: 'cast(null as varchar)'
  CLAIM_SUB_STATUS: 'cast(null as varchar)'
  CLAIM_TYPE: 'cast(null as varchar)'
  COUNTRY_CODE: 'cast(null as varchar)'
  COUNTRY_NAME: 'cast(null as varchar)'
  COVERAGE_REFERENCE: 'cast(null as varchar)'
  DEDUCTION_AMOUNT: 'cast(null as varchar)'
  DEDUCTION_REASON: 'cast(null as varchar)'
  DISTRICT: 'cast(null as varchar)'
  DOCUMENT_NAME: 'document_details'
  DOCUMENT_REFERENCE_NUMBER: 'cast(null as varchar)'
  DOCUMENT_TYPE: 'document_type_inward'
  HANDLING_ORG_UNIT_CODE: 'cast(null as varchar)'
  HEAD_DESCRIPTION: 'cover_name'
  INTIMATED_BY_ROLE: 'cast(null as varchar)'
  INTIMATION_CHANNEL: 'cast(null as varchar)'
  ISSUE_DATE: 'cast(null as varchar)'
  LANDMARK: 'cast(null as varchar)'
  LOCALITY: 'cast(null as varchar)'
  LOSS_DATE: 'cast(null as varchar)'
  NOTIFICATION_DATE: 'intimation_date'
  POSTAL_CODE: 'pin_code'
  POST_OFFICE_NAME: 'cast(null as varchar)'
  PRIORITY_CODE: 'cast(null as varchar)'
  RECEIVED_DATE: 'document_received_date'
  REGISTRATION_DATE: 'cast(null as varchar)'
  SOURCE_CHANNEL: 'mode_of_inward'
  STATE_CODE: 'cast(null as varchar)'
  STATE_NAME: 'state'
  STREET_NAME: 'cast(null as varchar)'
  SUB_LIMIT_APPLIED: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
