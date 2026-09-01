{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['DISTRIBUTION_CHANNEL_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER AUGMENTED (unconfirmed) sat_multi_source() for SAT_AUG_CHANNEL (HUB_DISTRIBUTION_CHANNEL grain).
-- 3 contributing table(s). NOT part of the canonical data_5a.js model.
-- Unblocked by mapper feedback round 2: HUB_DISTRIBUTION_CHANNEL previously had zero
-- verified Partner keys -- now keyed by INTERMEDIARY_ID (BJAZ_INTERMEDIARY/_HIST, a
-- fallback since IRDA_INTERMEDIARY_CODE is too sparse in sample data) or IMD_CODE
-- (BJAZ_CLM_SUPP_EXTN). 2 more columns (AZBJ_PARTNER_EXTN.SUBCODE,
-- BJAZ_AZBJ_PART_EXT_HIST.SUBCODE) remain unbuilt -- those two tables were not given a
-- channel key by the mapper.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_bjaz_intermediary__channel'
  - 'stg2_aug_bjaz_intermediary_hist__channel'
  - 'stg2_aug_bjaz_clm_supp_extn__channel'
src_pk: 'DISTRIBUTION_CHANNEL_HKEY'
src_payload:
  - 'BLOCKED_FOR_RECEIPT_INDICATOR'
  - 'FINANCE_SUB_CHANNEL_CODE'
  - 'GREEN_CHANNEL_INDICATOR'
  - 'IMDFLAG'
  - 'NEW_IMD_TYPE'
  - 'REVISED_CHANNEL_CODE'
  - 'SPECIAL_INTERMEDIARY_CODE'
  - 'SUBIMD_YN'
  - 'SUB_IMD_CODE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_column_map={
                        'stg2_aug_bjaz_intermediary__channel': ['BLOCKED_FOR_RECEIPT_INDICATOR', 'FINANCE_SUB_CHANNEL_CODE', 'GREEN_CHANNEL_INDICATOR', 'IMDFLAG', 'NEW_IMD_TYPE', 'REVISED_CHANNEL_CODE', 'SPECIAL_INTERMEDIARY_CODE', 'SUBIMD_YN'],
                        'stg2_aug_bjaz_intermediary_hist__channel': ['BLOCKED_FOR_RECEIPT_INDICATOR', 'FINANCE_SUB_CHANNEL_CODE', 'GREEN_CHANNEL_INDICATOR', 'IMDFLAG', 'NEW_IMD_TYPE', 'REVISED_CHANNEL_CODE', 'SPECIAL_INTERMEDIARY_CODE', 'SUBIMD_YN'],
                        'stg2_aug_bjaz_clm_supp_extn__channel': ['SUB_IMD_CODE']
                    }) }}
