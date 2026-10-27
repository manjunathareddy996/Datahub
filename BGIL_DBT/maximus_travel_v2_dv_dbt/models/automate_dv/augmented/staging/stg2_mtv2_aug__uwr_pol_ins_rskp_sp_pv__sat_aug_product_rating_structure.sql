{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PRODUCT_RATING_STRUCTURE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 1 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_rskp_sp_pv'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF_PRODUCT_RATING_STRUCTURE:
    is_hashdiff: true
    columns:
      - 'DEPOSIT_PREMIUM_BASIS'
derived_columns:
  PRODUCT_BK: "nullif(trim(case when coalesce(nullif(trim(w3_product_code),'')) is not null then 'PROD:' || nullif(trim(w3_product_code), '') end),'')"
  PRODUCT_NK: "'HUB_PRODUCT|' || (nullif(trim(case when coalesce(nullif(trim(w3_product_code),'')) is not null then 'PROD:' || nullif(trim(w3_product_code), '') end),''))"
  DEPOSIT_PREMIUM_BASIS: 'minimum_deposit_premium_type'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
