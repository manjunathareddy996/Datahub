{{ config(materialized='incremental') }}

-- PARTNER+KYC STANDARD-MODEL hub() for HUB_DOCUMENT over 3 source_model entry(ies).
-- src_nk is PARENT_BK and the business key is namespaced with a PIPE -- the sibling's
-- conventions, counted from the artifact (PARENT_BK x10, pipe x344, colon x0).
--
-- 2 KEY SPELLINGS SHIP ON THIS HUB, BUILT AS MAPPED AND RAISED (5.7).
-- Class: DIFFERENT_KEY_DESIGNS_SHARING_ONE_HUB.
--   2 table(s): BJAZ_T_KYC_POA_DOCUMENT, BJAZ_T_KYC_POI_DOCUMENT
--     upper(trim(coalesce(docs_type,''))) || ':' || upper(trim(coalesce(docs_number,'')))
--   1 table(s): BJAZ_T_KYC_OCR
--     upper(trim(field_type)) || ':' || trim(field_value) || '#' || upper(trim(image_type))
-- DIFFERENT column sets -- ['docs_number', 'docs_type'] against ['field_type',
-- 'field_value', 'image_type']. This is NOT a case variant: two distinct identification
-- designs share one hub, so the same real-world HUB_DOCUMENT reached through the two
-- routes gets two different keys and never reconciles. NOT named in profile flag 8,
-- which addresses HUB_POLICY and HUB_ORG_UNIT only. Built as mapped (5.7) and raised as
-- a NEW finding.
-- The majority form is the first listed. Routed to mapper-liaison.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_bjaz_t_kyc_ocr__document'
  - 'stg2_hub_bjaz_t_kyc_poa_document__document'
  - 'stg2_hub_bjaz_t_kyc_poi_document__document'
src_pk: 'DOCUMENT_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                   src_nk=metadata_dict['src_nk'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
