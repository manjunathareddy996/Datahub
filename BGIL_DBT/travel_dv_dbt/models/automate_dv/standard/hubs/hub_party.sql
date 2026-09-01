{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL hub() for HUB_PARTY, 6 contributing table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_ba_trv_data_policy_dtls_mv__party_cft_mst_comp_ref'
  - 'stg2_hub_ba_trv_data_policy_dtls_mv__party_payer_part_id'
  - 'stg2_hub_ba_trv_plan_mst_mv__party'
  - 'stg2_hub_bjaz_trv_loader_data_mv__party_premiumpayerid'
  - 'stg2_hub_bjaz_trv_loader_data_mv__party_part_id'
  - 'stg2_hub_bjaz_trv_loader_log_table_mv__party'
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
