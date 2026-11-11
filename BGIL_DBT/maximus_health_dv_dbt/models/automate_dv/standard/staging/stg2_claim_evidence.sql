-- automate_dv.stage() for SAT_CLAIM_EVIDENCE, read off central view stitch_v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EVIDENCE_TYPE'
      - 'MEDIA_REFERENCE'
      - 'EVIDENCE_TYPE_CK'
      - 'MEDIA_REFERENCE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_EVIDENCE__EVIDENCE_TYPE, CLAIM_EVIDENCE__MEDIA_REFERENCE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  EVIDENCE_TYPE_CK: 'CLAIM_EVIDENCE__EVIDENCE_TYPE_CK'
  MEDIA_REFERENCE_CK: 'CLAIM_EVIDENCE__MEDIA_REFERENCE_CK'
  EVIDENCE_TYPE: 'CLAIM_EVIDENCE__EVIDENCE_TYPE'
  MEDIA_REFERENCE: 'CLAIM_EVIDENCE__MEDIA_REFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
