{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['AGREEMENT_HKEY', 'HASHDIFF']
    )
}}

-- PARTNER AUGMENTED (unconfirmed) sat() for SAT_AUG_AGREEMENT (HUB_AGREEMENT grain).
-- 1 contributing table(s), union. NOT part of the canonical
-- data_5a.js model -- needs mapper review before being treated as equivalent to a
-- standard-model satellite.

{%- set yaml_metadata -%}
source_model: 'stg2_aug_bjaz_intermediary__agreement'
src_pk: 'AGREEMENT_HKEY'
src_payload:
  - 'AGREEMENT_NATURE_OTHER_DETAIL'
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
