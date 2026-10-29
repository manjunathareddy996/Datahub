{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS
-- Covers this view's 1 key slot(s) and its 0 1:1 satellite target(s) in one pass,
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
--   ORG_UNIT_HKEY                      HUB_ORG_UNIT  (1 row(s) in the map)

{%- set yaml_metadata -%}
source_model: 'stg_mt__uwr_pol_off'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
derived_columns:
  ORG_UNIT_BK: "nullif(trim(case when coalesce(nullif(trim(office_code),'')) is not null then 'ORGUNIT:' || nullif(trim(office_code), '') end),'')"
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || (nullif(trim(case when coalesce(nullif(trim(office_code),'')) is not null then 'ORGUNIT:' || nullif(trim(office_code), '') end),''))"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
