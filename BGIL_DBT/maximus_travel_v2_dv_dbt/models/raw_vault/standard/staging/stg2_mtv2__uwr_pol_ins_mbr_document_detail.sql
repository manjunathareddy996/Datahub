{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_DOCUMENT_DETAIL
-- Covers this view's 1 key slot(s) and its 1 1:1 satellite target(s) in one pass,
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
--   DOCUMENT_HKEY                      HUB_DOCUMENT  (4 row(s) in the map)
--   HASHDIFF_DOCUMENT_DEFINITION       SAT_DOCUMENT_DEFINITION payload 3 of 6 live here

{%- set yaml_metadata -%}
source_model: 'stg_mtv2__uwr_pol_ins_mbr_document_detail'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
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
  DOCUMENT_BK: "nullif(trim(case when coalesce(nullif(trim(document_id),'')) is not null then 'DOC:' || nullif(trim(document_id), '') end),'')"
  DOCUMENT_NK: "'HUB_DOCUMENT|' || (nullif(trim(case when coalesce(nullif(trim(document_id),'')) is not null then 'DOC:' || nullif(trim(document_id), '') end),''))"
  DOCUMENT_NAME: 'document_name'
  DOCUMENT_REFERENCE_NUMBER: 'cast(null as varchar)'
  DOCUMENT_TYPE: 'document_type'
  ISSUE_DATE: 'document_generation_date'
  RECEIVED_DATE: 'cast(null as varchar)'
  SOURCE_CHANNEL: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_DOCUMENT_DETAIL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
