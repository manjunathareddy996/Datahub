{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_POLICY_RENEWAL from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 8 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'stg_mt__uwr_pol'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_RENEWAL:
    is_hashdiff: true
    columns:
      - 'EXPIRING_POLICY_INSURER_NAME'
      - 'RENEWAL_APPLICABLE_INDICATOR'
      - 'RENEWAL_INDICATOR'
      - 'RENEWAL_NOTICE_EXCEPTION_CLUSTER_NAME'
      - 'RENEWAL_QUOTE_GENERATED_INDICATOR'
      - 'REPLACED_POLICY_EXPIRY_DATE'
      - 'REPLACED_POLICY_INCEPTION_DATE'
      - 'REPLACED_POLICY_PRODUCT_CODE'
derived_columns:
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(policy_number),'')) is not null then nullif(trim(policy_number), '') end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(policy_number),'')) is not null then nullif(trim(policy_number), '') end),''))"
  EXPIRING_POLICY_INSURER_NAME: 'cast(null as varchar)'
  RENEWAL_APPLICABLE_INDICATOR: 'cast(null as varchar)'
  RENEWAL_INDICATOR: 'renewal_flag'
  RENEWAL_NOTICE_EXCEPTION_CLUSTER_NAME: 'cast(null as varchar)'
  RENEWAL_QUOTE_GENERATED_INDICATOR: 'cast(null as varchar)'
  REPLACED_POLICY_EXPIRY_DATE: 'cast(null as varchar)'
  REPLACED_POLICY_INCEPTION_DATE: 'cast(null as varchar)'
  REPLACED_POLICY_PRODUCT_CODE: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
