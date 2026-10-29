{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_RELATION
-- Covers this view's 3 key slot(s) and its 2 1:1 satellite target(s) in one pass,
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
--   PARTY_HKEY                         HUB_PARTY  (4 row(s) in the map)
--   POLICY_HKEY                        HUB_POLICY  (2 row(s) in the map)
--   POLICY_PARTY_HKEY                  LNK_POLICY_PARTY  LINK
--   HASHDIFF_LNK_POLICY_PARTY_ROLE     SAT_LNK_POLICY_PARTY_ROLE payload 1 of 3 live here
--   HASHDIFF_PARTY_IDENTITY            SAT_PARTY_IDENTITY payload 1 of 15 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_policy_relation'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  POLICY_PARTY_HKEY: 'POLICY_PARTY_NK'
  HASHDIFF_LNK_POLICY_PARTY_ROLE:
    is_hashdiff: true
    columns:
      - 'ATTRIBUTION_PERCENTAGE'
      - 'PARTY_ROLE_TYPE'
      - 'ROLE_EFFECTIVE_DATE'
      - 'ROLE_END_DATE'
      - 'ROLE_SEQUENCE'
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
  PARTY_BK: "nullif(trim(case when coalesce(nullif(trim(party_code),'')) is not null then nullif(trim(party_code), '') end),'')"
  PARTY_NK: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(party_code),'')) is not null then nullif(trim(party_code), '') end),''))"
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  POLICY_PARTY_BK: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(party_code),'')) is not null then nullif(trim(party_code), '') end),''),'')"
  POLICY_PARTY_NK: "'LNK_POLICY_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(party_code),'')) is not null then nullif(trim(party_code), '') end),''),''))"
  AGE: 'cast(null as varchar)'
  ATTRIBUTION_PERCENTAGE: 'party_share_percentage'
  COUNTRY_OF_BIRTH: 'cast(null as varchar)'
  COUNTRY_OF_RESIDENCE: 'cast(null as varchar)'
  DATE_OF_BIRTH: 'cast(null as varchar)'
  FIRST_NAME: 'cast(null as varchar)'
  GENDER_CODE: 'cast(null as varchar)'
  LAST_NAME: 'cast(null as varchar)'
  MIDDLE_NAME: 'cast(null as varchar)'
  NATIONALITY: 'cast(null as varchar)'
  PARTY_FULL_NAME: 'party_name'
  PARTY_LEGAL_NAME: 'cast(null as varchar)'
  PARTY_ROLE_TYPE: "coalesce(nullif(trim(stake_code), ''),'')"
  PARTY_STATUS: 'cast(null as varchar)'
  PARTY_SUB_TYPE_CODE: 'cast(null as varchar)'
  PARTY_TYPE_CODE: 'cast(null as varchar)'
  ROLE_EFFECTIVE_DATE: 'cast(null as varchar)'
  ROLE_END_DATE: 'cast(null as varchar)'
  ROLE_SEQUENCE: "'1'"
  SALUTATION: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_RELATION'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
