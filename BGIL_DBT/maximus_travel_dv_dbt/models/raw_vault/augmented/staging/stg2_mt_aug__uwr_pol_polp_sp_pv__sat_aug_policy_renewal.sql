{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_POLICY_RENEWAL from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 8 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_polp_sp_pv'
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
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  EXPIRING_POLICY_INSURER_NAME: 'insurance_company_name'
  RENEWAL_APPLICABLE_INDICATOR: 'renewal_applicable'
  RENEWAL_INDICATOR: 'cast(null as varchar)'
  RENEWAL_NOTICE_EXCEPTION_CLUSTER_NAME: 'rta_cluster_name_rn_exception'
  RENEWAL_QUOTE_GENERATED_INDICATOR: 'renewal_quote_generated'
  REPLACED_POLICY_EXPIRY_DATE: 'old_expiry_date'
  REPLACED_POLICY_INCEPTION_DATE: 'old_inception_date'
  REPLACED_POLICY_PRODUCT_CODE: 'old_product_code'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
