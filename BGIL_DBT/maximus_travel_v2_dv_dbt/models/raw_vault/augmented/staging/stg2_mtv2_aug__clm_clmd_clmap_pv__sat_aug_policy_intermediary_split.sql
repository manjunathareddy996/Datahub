{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_POLICY_INTERMEDIARY_SPLIT from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 2 payload column(s); the child key is INTERMEDIARY_REFERENCE.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmap_pv'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_INTERMEDIARY_SPLIT:
    is_hashdiff: true
    columns:
      - 'COMMISSION_CHANGE_EFFECTIVE_DATE'
      - 'INTERMEDIARY_REFERENCE'
      - 'SUB_CHANNEL_NAME'
derived_columns:
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w1_policyno),'')) is not null then nullif(trim(w1_policyno), '') end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w1_policyno),'')) is not null then nullif(trim(w1_policyno), '') end),''))"
  INTERMEDIARY_REFERENCE: "coalesce(nullif(trim(sub_imd_code), ''),'')"
  COMMISSION_CHANGE_EFFECTIVE_DATE: 'cast(null as varchar)'
  SUB_CHANNEL_NAME: 'subchannel_name'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
