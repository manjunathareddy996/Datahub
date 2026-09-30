{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL hub() for HUB_POLICY, 16 contributing table(s)
-- across 8 source_model entries.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_policy_header'
  - 'stg2_hub_ba_hcp_dt_mem__policy'
  - 'stg2_hub_bjaz_ctngy_ff_dtls_extn__policy'
  - 'stg2_hub_bjaz_hcf_member_dtls__policy'
  - 'stg2_policy_bonus_tracking'
  - 'stg2_hub_bjaz_spp_member_dtls__policy'
  - 'stg2_hub_bjaz_starpkg_ff_dtls__policy'
  - 'stg2_hub_ocp_interested_parties__policy'
src_pk: 'POLICY_HKEY'
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
