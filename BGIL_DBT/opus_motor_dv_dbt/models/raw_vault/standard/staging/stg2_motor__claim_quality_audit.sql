-- automate_dv.stage() for SAT_CLAIM_QUALITY_AUDIT, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AUDITOR_REFERENCE'
      - 'AUDIT_DATE'
      - 'AUDIT_OUTCOME'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_QUALITY_AUDIT__AUDITOR_REFERENCE, CLAIM_QUALITY_AUDIT__AUDIT_DATE, CLAIM_QUALITY_AUDIT__AUDIT_OUTCOME) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  AUDITOR_REFERENCE: 'CLAIM_QUALITY_AUDIT__AUDITOR_REFERENCE'
  AUDIT_DATE: 'CLAIM_QUALITY_AUDIT__AUDIT_DATE'
  AUDIT_OUTCOME: 'CLAIM_QUALITY_AUDIT__AUDIT_OUTCOME'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v02_claim'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
