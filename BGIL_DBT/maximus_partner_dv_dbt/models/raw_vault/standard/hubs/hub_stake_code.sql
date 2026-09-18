{{ config(materialized='incremental') }}

-- MAXIMUS PARTNER hub() for HUB_STAKE_CODE.
-- Business key is STAKE_CODE from BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY.
-- A later LNK_PARTY_STAKE_CODE will connect HUB_PARTY and HUB_STAKE_CODE.

{%- set yaml_metadata -%}
source_model:
  - 'hubfeed_stake_code'
src_pk: 'STAKE_CODE_HKEY'
src_nk: 'STAKE_CODE_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
