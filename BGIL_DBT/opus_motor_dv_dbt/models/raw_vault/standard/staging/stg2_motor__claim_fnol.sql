-- automate_dv.stage() for SAT_CLAIM_FNOL, read off central view stitch_motor__v01_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v01_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FNOL_DATE'
      - 'LOCATION_OF_LOSS'
      - 'PRELIMINARY_LOSS_DESCRIPTION'
      - 'PRELIMINARY_LOSS_ESTIMATE'
      - 'RELATIONSHIP_TO_INSURED'
      - 'REPORTED_BY_CONTACT'
      - 'REPORTED_BY_NAME'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_FNOL__FNOL_DATE, CLAIM_FNOL__LOCATION_OF_LOSS, CLAIM_FNOL__PRELIMINARY_LOSS_DESCRIPTION, CLAIM_FNOL__PRELIMINARY_LOSS_ESTIMATE, CLAIM_FNOL__RELATIONSHIP_TO_INSURED, CLAIM_FNOL__REPORTED_BY_CONTACT, CLAIM_FNOL__REPORTED_BY_NAME) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  FNOL_DATE: 'CLAIM_FNOL__FNOL_DATE'
  LOCATION_OF_LOSS: 'CLAIM_FNOL__LOCATION_OF_LOSS'
  PRELIMINARY_LOSS_DESCRIPTION: 'CLAIM_FNOL__PRELIMINARY_LOSS_DESCRIPTION'
  PRELIMINARY_LOSS_ESTIMATE: 'CLAIM_FNOL__PRELIMINARY_LOSS_ESTIMATE'
  RELATIONSHIP_TO_INSURED: 'CLAIM_FNOL__RELATIONSHIP_TO_INSURED'
  REPORTED_BY_CONTACT: 'CLAIM_FNOL__REPORTED_BY_CONTACT'
  REPORTED_BY_NAME: 'CLAIM_FNOL__REPORTED_BY_NAME'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v01_claim'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
