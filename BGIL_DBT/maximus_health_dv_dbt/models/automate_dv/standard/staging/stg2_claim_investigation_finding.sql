-- automate_dv.stage() for SAT_CLAIM_INVESTIGATION_FINDING, read off central view stitch_v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FINDING_DESCRIPTION'
      - 'FINDING_OUTCOME'
      - 'INVESTIGATION_REFERENCE'
      - 'TRIGGER_CODE'
      - 'FINDING_SEQUENCE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_INVESTIGATION_FINDING__FINDING_DESCRIPTION, CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME, CLAIM_INVESTIGATION_FINDING__INVESTIGATION_REFERENCE, CLAIM_INVESTIGATION_FINDING__TRIGGER_CODE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  FINDING_SEQUENCE_CK: 'CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK'
  FINDING_DESCRIPTION: 'CLAIM_INVESTIGATION_FINDING__FINDING_DESCRIPTION'
  FINDING_OUTCOME: 'CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME'
  INVESTIGATION_REFERENCE: 'CLAIM_INVESTIGATION_FINDING__INVESTIGATION_REFERENCE'
  TRIGGER_CODE: 'CLAIM_INVESTIGATION_FINDING__TRIGGER_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
