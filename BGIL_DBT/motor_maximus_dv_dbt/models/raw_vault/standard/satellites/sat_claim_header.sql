-- Standard sat() for SAT_CLAIM_HEADER (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW | SAT_CLAIM_HEADER | Claim Type | None: emits CLAIM_TYPES; withheld TYPE_OF_CLAIM
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW | SAT_CLAIM_HEADER | Intimated By Role | None: emits CLAIM_REPORTED_BY; withheld NOTIFIED_BY
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__claim_header'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'CATASTROPHE_CODE'
  - 'CLAIMANT_REFERENCE'
  - 'CLAIM_CATEGORY'
  - 'CLAIM_REFERENCE_NUMBER'
  - 'CLAIM_REMARKS'
  - 'CLAIM_STATUS'
  - 'CLAIM_SUB_STATUS'
  - 'CLAIM_TYPE'
  - 'CLOSED_DATE'
  - 'FAST_TRACK_INDICATOR'
  - 'HANDLING_ORG_UNIT_CODE'
  - 'INTIMATED_BY_ROLE'
  - 'INTIMATION_CHANNEL'
  - 'INVESTIGATION_REQUIRED_INDICATOR'
  - 'LOSS_DATE'
  - 'NOTIFICATION_DATE'
  - 'PRIORITY_CODE'
  - 'REGISTRATION_DATE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                   src_payload=metadata_dict['src_payload'],
                   src_hashdiff=metadata_dict['src_hashdiff'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
