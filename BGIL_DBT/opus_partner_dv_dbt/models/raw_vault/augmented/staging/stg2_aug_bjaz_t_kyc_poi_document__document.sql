{{ config(materialized='view') }}

-- PARTNER+KYC AUGMENTED (unconfirmed) per-table stage() for HUB_DOCUMENT, table 'BJAZ_T_KYC_POI_DOCUMENT'.
-- 1 proposed attribute(s) from the mapper's Augmentation sheet, NOT in
-- data_7. Target(s) named by the map: SAT_DOCUMENT_DEFINITION.
--
-- Member names are UNDERSCORE(Proposed Attribute) -- the augmented track's own
-- convention, measured over the baseline's 147 decidable payload entries (141
-- follow it, 0 counterexamples). This is a CORRECTION to the profile's
-- 'raw source column verbatim'; see gen_pkyc_augmented's docstring.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_kyc_poi_document'
hashed_columns:
  DOCUMENT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'VERIFICATION_RESPONSE_MESSAGE'
derived_columns:
  PARENT_BK: "upper(trim(coalesce(docs_type,''))) || ':' || upper(trim(coalesce(docs_number,'')))"
  PARENT_NK: "'HUB_DOCUMENT|' || (upper(trim(coalesce(docs_type,''))) || ':' || upper(trim(coalesce(docs_number,''))))"
  VERIFICATION_RESPONSE_MESSAGE: 'response_message'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_KYC_POI_DOCUMENT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
