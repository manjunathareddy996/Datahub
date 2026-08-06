{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL hub() for HUB_LOCATION, 13 contributing table(s)
-- across 9 source_model entries.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_common_address'
  - 'stg2_hub_azbj_partner_extn__location'
  - 'stg2_hub_bjaz_azbj_part_ext_hist__location'
  - 'stg2_hub_bjaz_clm_supp_extn__location'
  - 'stg2_hub_bjaz_cp_address_link__location'
  - 'stg2_hub_bjaz_cp_part_hist__location'
  - 'stg2_hub_clm_suppliers__location'
  - 'stg2_hub_cp_partners__location'
  - 'stg2_hub_ocp_interested_parties__location'
src_pk: 'LOCATION_HKEY'
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
