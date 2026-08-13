{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_QUOTE, 14 contributing table(s)
-- across 7 source_model entries (1 via stitch-stage,
-- 6 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_bjaz_ecard_membr_del_dtls__quote'
  - 'stg2_quote_header'
  - 'stg2_hub_bjaz_grp_hlt_cust_dtls__quote'
  - 'stg2_hub_bjaz_grp_hlt_imd_dtls__quote'
  - 'stg2_hub_bjaz_grp_hlt_maternity_dtls__quote'
  - 'stg2_hub_bjaz_ewr_pol_dtls__quote'
  - 'stg2_hub_bjaz_hdfc_surk_shop__quote'
src_pk: 'QUOTE_HKEY'
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
