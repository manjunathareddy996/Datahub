{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_RELATION
-- Covers this view's 3 key slot(s) and its 1 1:1 satellite target(s) in one pass,
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
--   PARTY_HKEY__INSURED_MEMBER         HUB_PARTY / insured-member  (2 row(s) in the map)
--   POLICY_HKEY__INSURED_MEMBER        HUB_POLICY / insured-member  (2 row(s) in the map)
--   POLICY_PARTY_HKEY__INSURED_MEMBER  LNK_POLICY_PARTY / insured-member  LINK
--   HASHDIFF_LNK_POLICY_PARTY_ROLE     SAT_LNK_POLICY_PARTY_ROLE payload 1 of 3 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_mbr_party_relation'
hashed_columns:
  PARTY_HKEY__INSURED_MEMBER: 'PARTY_NK__INSURED_MEMBER'
  POLICY_HKEY__INSURED_MEMBER: 'POLICY_NK__INSURED_MEMBER'
  POLICY_PARTY_HKEY__INSURED_MEMBER: 'POLICY_PARTY_NK__INSURED_MEMBER'
  HASHDIFF_LNK_POLICY_PARTY_ROLE:
    is_hashdiff: true
    columns:
      - 'ATTRIBUTION_PERCENTAGE'
      - 'PARTY_ROLE_TYPE'
      - 'ROLE_EFFECTIVE_DATE'
      - 'ROLE_END_DATE'
      - 'ROLE_SEQUENCE'
derived_columns:
  PARTY_BK__INSURED_MEMBER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__INSURED_MEMBER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  POLICY_BK__INSURED_MEMBER: "nullif(trim(case when coalesce(nullif(trim(foreign_key),'')) is not null then nullif(trim(foreign_key), '') end),'')"
  POLICY_NK__INSURED_MEMBER: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(foreign_key),'')) is not null then nullif(trim(foreign_key), '') end),''))"
  POLICY_PARTY_BK__INSURED_MEMBER: "coalesce(nullif(trim(case when coalesce(nullif(trim(foreign_key),'')) is not null then nullif(trim(foreign_key), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''),'')"
  POLICY_PARTY_NK__INSURED_MEMBER: "'LNK_POLICY_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(foreign_key),'')) is not null then nullif(trim(foreign_key), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''),''))"
  ATTRIBUTION_PERCENTAGE: 'cast(null as varchar)'
  PARTY_ROLE_TYPE: "coalesce(nullif(trim(stake_name), ''),'')"
  ROLE_EFFECTIVE_DATE: 'start_date'
  ROLE_END_DATE: 'cast(null as varchar)'
  ROLE_SEQUENCE: "'1'"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_RELATION'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
