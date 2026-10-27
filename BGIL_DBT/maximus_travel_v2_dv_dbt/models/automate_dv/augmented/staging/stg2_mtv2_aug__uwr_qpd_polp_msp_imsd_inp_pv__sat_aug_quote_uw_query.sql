{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_QUOTE_UW_QUERY from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 11 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_QUOTE_UW_QUERY:
    is_hashdiff: true
    columns:
      - 'QUERY_CODE'
      - 'QUERY_DESCRIPTION'
      - 'QUERY_REPLY_TEXT'
      - 'QUERY_STATUS'
      - 'QUERY_TYPE'
      - 'RAISED_BY_ROLE'
      - 'RAISED_BY_USER_REFERENCE'
      - 'REPLIED_BY_ROLE'
      - 'REPLIED_BY_USER_REFERENCE'
      - 'REPLY_DATE_TIME'
      - 'SERVICE_REQUEST_NUMBER'
derived_columns:
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  QUERY_CODE: 'query_code'
  QUERY_DESCRIPTION: 'query_details'
  QUERY_REPLY_TEXT: 'query_reply'
  QUERY_STATUS: 'query_status'
  QUERY_TYPE: 'query_type'
  RAISED_BY_ROLE: 'raised_by_role'
  RAISED_BY_USER_REFERENCE: 'raised_byuser'
  REPLIED_BY_ROLE: 'replied_by_role'
  REPLIED_BY_USER_REFERENCE: 'replied_by_user'
  REPLY_DATE_TIME: 'reply_date_and_time'
  SERVICE_REQUEST_NUMBER: 'sr_number'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
