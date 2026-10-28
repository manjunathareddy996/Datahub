{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 ma_sat() for SAT_AUG_POLICY_DOCUMENT_DISPATCH.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, POLICY_HKEY, multi-active on DISPATCH_SERIAL_NUMBER.
--
-- ** UNSTABLE CHILD KEY (BUILD_RULES 5.2): DISPATCH_SERIAL_NUMBER = SERIAL_NO.
-- ** That source column is a RENUMBERING ORDINAL, re-derived by shape from the
-- ** source index, and an ordinal is never a discriminator. A row inserted or
-- ** removed renumbers the rest and re-attaches their history, exactly as a
-- ** renumbered hub key would. A child-key leg needs hub-grade stability.
-- ** BUILT AS MAPPED (BUILD_RULES 5.7). Routed BLOCKING to the MODELLER; see
-- ** build_artifacts/mtv2_spec.json census.ordinal_child_key_summary.
-- **
-- ** SOLE LEG: YES. This child key has 1 leg(s), so the ordinal is the ONLY discriminator.
-- ** The map already routes this as a source gap (DECLARED SOURCE GAP) over 11 map row(s) on 1 view(s).
-- ** ONE QUESTION SETTLES IT: is POD_NUMBER populated and unique per row of this
-- ** satellite's grain? If yes, the child key moves to it in one pass. If no,
-- ** this grain has no stable identifier and the satellite cannot carry
-- ** history at all.

{%- set yaml_metadata -%}
source_model: 'satfeed_mtv2_aug_sat_aug_policy_document_dispatch'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'DISPATCH_SERIAL_NUMBER'
src_payload:
  - 'COURIER_NAME'
  - 'DELIVERY_MODE'
  - 'DELIVERY_STATUS'
  - 'DISPATCHED_DOCUMENT_TYPE'
  - 'DISPATCH_DATE'
  - 'DISPATCH_DESTINATION_TYPE'
  - 'DISPATCH_PRIORITY'
  - 'DISPATCH_REMARKS'
  - 'PROOF_OF_DELIVERY_NUMBER'
  - 'RECIPIENT_NAME'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
