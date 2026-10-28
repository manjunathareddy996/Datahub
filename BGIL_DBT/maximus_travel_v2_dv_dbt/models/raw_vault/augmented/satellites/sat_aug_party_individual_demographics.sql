{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 sat() for SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, PARTY_HKEY, single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mtv2_aug_sat_aug_party_individual_demographics'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AGE_BAND'
  - 'BASIC_QUALIFICATION_BOARD_NAME'
  - 'BASIC_QUALIFICATION_DETAILS'
  - 'BASIC_QUALIFICATION_ROLL_NUMBER'
  - 'DATE_OF_MARRIAGE'
  - 'EDUCATIONAL_INSTITUTE_NAME'
  - 'MOTHER_MAIDEN_NAME'
  - 'NOMINEE_DETAILS_DESCRIPTION'
  - 'NUMBER_OF_DAUGHTERS'
  - 'NUMBER_OF_SONS'
  - 'OTHER_QUALIFICATION_DESCRIPTION'
  - 'OTHER_RELATIONSHIP_DESCRIPTION'
  - 'PERSONAL_DETAILS_DESCRIPTION'
  - 'PROFESSIONAL_QUALIFICATION'
  - 'QUALIFICATION_DETAILS'
  - 'QUALIFICATION_MONTH_OF_PASSING'
  - 'RELATIONSHIP_TO_PRIMARY_INSURED'
  - 'YEAR_OF_PASSING_QUALIFICATION'
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
