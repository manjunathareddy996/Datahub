{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL hub() for HUB_PARTY, 31 contributing table(s)
-- across 10 source_model entries.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_party_individual_demographics'
  - 'stg2_party_identity'
  - 'stg2_party_organisation_profile'
  - 'stg2_hub_bjaz_clm_supp_extn__party'
  - 'stg2_hub_bjaz_cp_address_link__party'
  - 'stg2_hub_bjaz_hm_hospital_master__party'
  - 'stg2_hub_bjaz_intermediary__party'
  - 'stg2_hub_bjaz_intermediary_hist__party'
  - 'stg2_hub_clm_interested_parties__party'
  - 'stg2_hub_clm_suppliers__party'
src_pk: 'PARTY_HKEY'
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
