{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL hub() for HUB_DISTRIBUTION_CHANNEL, 3 contributing table(s).
-- Added by mapper feedback round 2 (see docs/MAPPER_REPLIES_PARTNER.md item 3) -- this hub
-- had zero verified Partner keys until this round. No canonical SAT_CHANNEL_DEFINITION
-- attribute (Channel Name, Code, Type, Category, etc.) has real Partner source data --
-- only augmented/satellites/sat_aug_channel.sql attaches real attributes to this hub.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_bjaz_intermediary__distribution_channel'
  - 'stg2_hub_bjaz_intermediary_hist__distribution_channel'
  - 'stg2_hub_bjaz_clm_supp_extn__distribution_channel'
src_pk: 'DISTRIBUTION_CHANNEL_HKEY'
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
