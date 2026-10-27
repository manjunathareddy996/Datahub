{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_POLICY_DOCUMENT_DISPATCH from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_DISPATCH_DETAILS
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 10 payload column(s); the child key is DISPATCH_SERIAL_NUMBER.
--
-- ** UNSTABLE CHILD KEY (BUILD_RULES 5.2): DISPATCH_SERIAL_NUMBER = SERIAL_NO is defined below from a RENUMBERING
-- ** ORDINAL. An ordinal is never a discriminator: a row inserted or removed
-- ** renumbers the rest and re-attaches their history. BUILT AS MAPPED (5.7) and
-- ** routed BLOCKING to the MODELLER.
-- **
-- ** SOLE LEG: YES. This child key has 1 leg(s), so the ordinal is the ONLY discriminator.
-- ** The map already routes this as a source gap (DECLARED SOURCE GAP) over 11 map row(s) on 1 view(s).
-- ** ONE QUESTION SETTLES IT: is POD_NUMBER populated and unique per row of this
-- ** satellite's grain? If yes, the child key moves to it in one pass. If no,
-- ** this grain has no stable identifier and the satellite cannot carry
-- ** history at all.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_disp'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_DOCUMENT_DISPATCH:
    is_hashdiff: true
    columns:
      - 'COURIER_NAME'
      - 'DELIVERY_MODE'
      - 'DELIVERY_STATUS'
      - 'DISPATCHED_DOCUMENT_TYPE'
      - 'DISPATCH_DATE'
      - 'DISPATCH_DESTINATION_TYPE'
      - 'DISPATCH_PRIORITY'
      - 'DISPATCH_REMARKS'
      - 'DISPATCH_SERIAL_NUMBER'
      - 'PROOF_OF_DELIVERY_NUMBER'
      - 'RECIPIENT_NAME'
derived_columns:
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  DISPATCH_SERIAL_NUMBER: "coalesce(nullif(trim(serial_no), ''),'')"
  COURIER_NAME: 'courier_name'
  DELIVERY_MODE: 'dispatch_mode'
  DELIVERY_STATUS: 'dispatch_status'
  DISPATCHED_DOCUMENT_TYPE: 'document_type'
  DISPATCH_DATE: 'dispatch_date'
  DISPATCH_DESTINATION_TYPE: 'dispatch_destination'
  DISPATCH_PRIORITY: 'priority'
  DISPATCH_REMARKS: 'remarks'
  PROOF_OF_DELIVERY_NUMBER: 'pod_number'
  RECIPIENT_NAME: 'recipient_name'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_DISPATCH_DETAILS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
