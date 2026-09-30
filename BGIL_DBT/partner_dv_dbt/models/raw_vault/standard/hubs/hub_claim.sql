{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL hub() for HUB_CLAIM, 1 contributing table(s)
-- across 1 source_model entries.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_clm_interested_parties__claim'
src_pk: 'CLAIM_HKEY'
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
