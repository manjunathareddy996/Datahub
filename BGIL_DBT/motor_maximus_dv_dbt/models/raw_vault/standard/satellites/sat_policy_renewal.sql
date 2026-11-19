-- Standard sat() for SAT_POLICY_RENEWAL (parent HUB_POLICY, history SCD2), fed whole from central view stitch_mxm__v14_risk_object.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_POLICY_RENEWAL | Renewal Status | None: emits RENEWAL_STATUS; withheld RENEWAL_STATUSS
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_POLICY_RENEWAL | Renewal Status | None: emits RENEWAL_STATUS; withheld RENEWAL_STATUSS
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__policy_renewal'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'BREAK_IN_INDICATOR'
  - 'RENEWAL_BLOCK_REASON'
  - 'RENEWAL_DUE_DATE'
  - 'RENEWAL_STATUS'
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
