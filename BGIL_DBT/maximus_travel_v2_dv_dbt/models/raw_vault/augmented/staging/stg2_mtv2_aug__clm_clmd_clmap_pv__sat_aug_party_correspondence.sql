{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_CORRESPONDENCE from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 1 payload column(s); the child key is DISPATCH_REFERENCE.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmap_pv'
hashed_columns:
  PARTY_HKEY__INSURED_CUSTOMER: 'PARTY_NK__INSURED_CUSTOMER'
  HASHDIFF_PARTY_CORRESPONDENCE:
    is_hashdiff: true
    columns:
      - 'DISPATCH_REFERENCE'
      - 'SENDER_NAME'
derived_columns:
  PARTY_BK__INSURED_CUSTOMER: "nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),'')"
  PARTY_NK__INSURED_CUSTOMER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),''))"
  DISPATCH_REFERENCE: "coalesce(nullif(trim(pod_number), ''),'')"
  SENDER_NAME: 'sender_name'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
